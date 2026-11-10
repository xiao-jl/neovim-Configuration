-- 一键运行当前文件：<F5>
-- Java: javac 编译到源码根（不建 out 目录）后 java 运行
-- C/C++: 完整编译链 .i(预处理) → .s(汇编) → .o(目标) → .so(共享库) + 可执行，全部留在 out/
-- Python: python3 -u

local M = {}

local run_win = nil

local function q(s)
  return vim.fn.shellescape(s)
end

-- 构建产物目录：与 src 同级；不是 src 布局就放 base/out
local function out_dir(base)
  if vim.fn.fnamemodify(base, ":t") == "src" then
    return vim.fn.fnamemodify(base, ":h") .. "/out"
  end
  return base .. "/out"
end

-- 从文件目录向上找 src 目录，返回 src 根；找不到返回 nil
local function src_base(dir)
  if vim.fn.fnamemodify(dir, ":t") == "src" then
    return dir
  end
  local p = vim.fn.fnamemodify(dir, ":h")
  while p ~= "/" and p ~= "" do
    if vim.fn.fnamemodify(p, ":t") == "src" then
      return p
    end
    local parent = vim.fn.fnamemodify(p, ":h")
    if parent == p then
      break
    end
    p = parent
  end
  return nil
end

-- C/C++ 产物路径：out/<相对 src 的目录>/<文件名>，避免同名 main.c 互相覆盖
local function c_out_path(dir, name)
  local base = src_base(dir)
  if not base then
    return dir .. "/out/" .. name
  end
  local rel = dir:sub(#base + 2) -- src 下的子目录，可能为空
  local outroot = vim.fn.fnamemodify(base, ":h") .. "/out"
  return rel ~= "" and (outroot .. "/" .. rel .. "/" .. name) or (outroot .. "/" .. name)
end

local function close_run()
  if run_win and vim.api.nvim_win_is_valid(run_win) then
    vim.api.nvim_win_close(run_win, true)
  end
  run_win = nil
end

-- 下方分屏开一个终端执行 script，cwd 为源文件目录
local function open_term(script, cwd)
  close_run()
  vim.cmd("botright 12split")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)
  vim.bo[buf].bufhidden = "wipe"
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, silent = true, desc = "关闭运行窗口" })
  vim.fn.termopen({ "sh", "-c", script }, { cwd = cwd })
  run_win = win
  vim.cmd("startinsert")
end

local function run_java(file)
  local dir = vim.fn.fnamemodify(file, ":p:h")
  local name = vim.fn.fnamemodify(file, ":t:r")

  -- 解析 package
  local pkg
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 100, false)) do
    local m = line:match("^%s*package%s+([%w_%.]+)%s*;")
    if m then
      pkg = m
      break
    end
  end

  -- 源码根：去掉路径末尾的 package 目录
  local root = dir
  if pkg then
    local pp = pkg:gsub("%.", "/")
    if dir:sub(-#pp - 1) == "/" .. pp then
      root = dir:sub(1, #dir - #pp - 1)
    else
      vim.notify("路径与 package 不匹配，按当前目录作源码根", vim.log.levels.WARN)
    end
  end

  -- 源码根下全部 .java 一起编译（class 仍生成在包目录内）
  local files = vim.fn.globpath(root, "**/*.java", false, true)
  if #files == 0 then
    files = { file }
  end

  -- 构建产物统一放 out（与 src 同级）
  local out = out_dir(root)
  vim.fn.mkdir(out, "p")

  -- lib/*.jar 自动加入 classpath
  local jars = vim.fn.globpath(root .. "/lib", "*.jar", false, true)
  local jar_cp = table.concat(jars, ":")
  local classpath = jar_cp ~= "" and (out .. ":" .. jar_cp) or out

  local cmd = { "javac", "-encoding", "UTF-8", "-d", q(out), "-sourcepath", q(root) }
  if jar_cp ~= "" then
    table.insert(cmd, "-cp")
    table.insert(cmd, q(jar_cp))
  end
  for _, f in ipairs(files) do
    table.insert(cmd, q(f))
  end

  local fqcn = pkg and (pkg .. "." .. name) or name
  local script = table.concat(cmd, " ") .. " && java -cp " .. q(classpath) .. " " .. q(fqcn)
  open_term(script, dir)
end

local function run_c(file, ext)
  local dir = vim.fn.fnamemodify(file, ":p:h")
  local name = vim.fn.fnamemodify(file, ":t:r")
  local is_c = ext == "c"
  local cc = is_c and "gcc" or "g++"
  local libs = is_c and " -lm" or ""
  local out = c_out_path(dir, name)
  local odir = vim.fn.fnamemodify(out, ":h")
  vim.fn.mkdir(odir, "p")

  local pp = odir .. "/" .. name .. (is_c and ".i" or ".ii") -- 预处理结果
  local asm = odir .. "/" .. name .. ".s"                    -- 汇编
  local obj = odir .. "/" .. name .. ".o"                    -- 目标文件
  local so = odir .. "/lib" .. name .. ".so"                 -- 共享库

  local lines = {
    "set -e",
    "echo '--- 1/5 预处理 -> ." .. (is_c and "i" or "ii") .. "'",
    q(cc) .. " -g -O0 -E " .. q(file) .. " -o " .. q(pp),
    "echo '--- 2/5 汇编 -> .s'",
    q(cc) .. " -g -O0 -S " .. q(file) .. " -o " .. q(asm),
    "echo '--- 3/5 编译 -> .o'",
    q(cc) .. " -g -O0 -c " .. q(file) .. " -o " .. q(obj),
    "echo '--- 4/5 共享库 -> .so'",
    q(cc) .. " -g -O0 -shared -fPIC " .. q(file) .. " -o " .. q(so) .. libs,
    "echo '--- 5/5 链接 -> 可执行'",
    q(cc) .. " " .. q(obj) .. " -o " .. q(out) .. libs,
    "echo",
    "echo '=== 编译生成的文件 ==='",
    "ls -lh -- " .. q(pp) .. " " .. q(asm) .. " " .. q(obj) .. " " .. q(so) .. " " .. q(out),
    "echo",
    "echo '=== 运行 " .. name .. " ==='",
    q(out),
  }
  open_term(table.concat(lines, "\n"), dir)
end

local function run_python(file)
  local dir = vim.fn.fnamemodify(file, ":p:h")
  -- 字节码缓存也收进 out/，不污染源码目录
  local pycache = out_dir(dir) .. "/pycache"
  vim.fn.mkdir(pycache, "p")
  open_term("env PYTHONPYCACHEPREFIX=" .. q(pycache) .. " python3 -u " .. q(file), dir)
end

function M.run()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("当前 buffer 没有文件名，先保存", vim.log.levels.WARN)
    return
  end
  local ext = vim.fn.fnamemodify(file, ":e"):lower()
  if not ({ java = true, c = true, cpp = true, cc = true, cxx = true, py = true })[ext] then
    vim.notify("不支持的文件类型：" .. (ext == "" and "无扩展名" or ext), vim.log.levels.WARN)
    return
  end

  vim.cmd("silent! write")

  if ext == "java" then
    run_java(file)
  elseif ext == "py" then
    run_python(file)
  else
    run_c(file, ext)
  end
end

vim.keymap.set("n", "<F5>", M.run, { desc = "运行当前文件" })

return M
