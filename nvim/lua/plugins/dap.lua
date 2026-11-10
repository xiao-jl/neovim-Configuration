-- 调试器：nvim-dap + nvim-dap-ui
-- Java 由 nvim-jdtls 接管，C/C++ 用 codelldb，Python 用 debugpy（适配器都由 mason 自动装）

local dap = require("dap")
local dapui = require("dapui")

-- ---------- 适配器自动安装 ----------
require("mason-nvim-dap").setup({
  ensure_installed = {
    "codelldb", -- C / C++ / Rust
    "debugpy", -- Python
    "javadbg", -- java-debug-adapter（Java）
    "javatest", -- vscode-java-test（Java 单元测试）
  },
  automatic_installation = true,
  -- python / java 的 adapter 分别在下面和 nvim-jdtls 里配，关掉 mason 的默认 handler
  handlers = {
    python = function() end,
    javadbg = function() end,
    javatest = function() end,
  },
})

-- ---------- 调试界面 ----------
dapui.setup()
require("nvim-dap-virtual-text").setup()

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  pcall(dapui.close)
end
dap.listeners.before.event_exited.dapui_config = function()
  pcall(dapui.close)
end

-- ---------- Python（debugpy） ----------
dap.adapters.python = function(cb)
  local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
  if vim.fn.executable(debugpy) ~= 1 then
    vim.notify("debugpy 未安装：在 nvim 里执行 :MasonInstall debugpy", vim.log.levels.WARN)
    return
  end
  cb({
    type = "executable",
    command = debugpy,
    args = { "-m", "debugpy.adapter" },
  })
end

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "启动当前文件",
    program = "${file}",
    console = "integratedTerminal",
    pythonPath = function()
      local py = vim.fn.exepath("python3")
      return py ~= "" and py or "python"
    end,
  },
}

-- ---------- C / C++ / Rust（codelldb） ----------
local codelldb_conf = {
  {
    name = "启动：选择可执行文件",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("可执行文件路径: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
}
dap.configurations.c = codelldb_conf
dap.configurations.cpp = codelldb_conf
dap.configurations.rust = codelldb_conf

-- ---------- Java（nvim-jdtls） ----------
local mason = vim.fn.stdpath("data") .. "/mason"

-- java-debug / java-test 的 jar，不同 mason 版本目录不一样，都试一遍
local function java_bundles()
  local jars = {}
  for _, dir in ipairs({
    mason .. "/packages/java-debug-adapter/extension/server",
    mason .. "/packages/java-debug-adapter/server",
  }) do
    vim.list_extend(jars, vim.fn.glob(dir .. "/com.microsoft.java.debug.plugin-*.jar", false, true))
  end
  for _, dir in ipairs({
    mason .. "/packages/java-test/extension/server",
    mason .. "/packages/java-test/server",
  }) do
    vim.list_extend(jars, vim.fn.glob(dir .. "/*.jar", false, true))
  end
  return jars
end

-- 找 JDK：没有构建文件的项目，jdtls 自己找不到 java 可执行文件，
-- 不指定的话 :DapNew 会报 "Could not resolve java executable for ..."
local function find_jdk()
  if vim.env.JAVA_HOME and vim.env.JAVA_HOME ~= "" then
    return vim.env.JAVA_HOME
  end
  -- Arch: /usr/lib/jvm/default 指向默认 JDK
  if vim.fn.executable("/usr/lib/jvm/default/bin/java") == 1 then
    return "/usr/lib/jvm/default"
  end
  local javac = vim.fn.exepath("javac")
  if javac ~= "" then
    return vim.fn.fnamemodify(vim.fn.resolve(javac), ":h:h")
  end
  local java = vim.fn.exepath("java")
  if java ~= "" then
    return vim.fn.fnamemodify(vim.fn.resolve(java), ":h:h")
  end
end

-- 找项目根 + 真正的源码根
-- 关键：纯 src 布局下必须把 root_dir 指到 src，否则 jdtls 会把项目根当包根，
-- 报 "The declared package ... does not match the expected package"
local function find_project()
  local markers = { ".git", "pom.xml", "build.gradle", "settings.gradle", "mvnw", "gradlew" }
  local base = require("jdtls.setup").find_root(markers) or vim.fn.getcwd()

  -- Maven / Gradle 项目交给 jdtls 自己解析
  for _, m in ipairs({ "pom.xml", "build.gradle", "settings.gradle", "mvnw", "gradlew" }) do
    if vim.fn.filereadable(base .. "/" .. m) == 1 then
      return base, base
    end
  end

  for _, sub in ipairs({ "/src/main/java", "/src" }) do
    if vim.fn.isdirectory(base .. sub) == 1 then
      return base, base .. sub
    end
  end

  return base, base
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    if vim.fn.executable(mason .. "/bin/jdtls") ~= 1 then
      vim.notify("jdtls 未安装：在 nvim 里执行 :MasonInstall jdtls", vim.log.levels.WARN)
      return
    end

    local project_root, source_root = find_project()
    local project = vim.fn.fnamemodify(project_root, ":t")
    local rel_src = source_root:sub(#project_root + 1):gsub("^/", "")
    if rel_src == "" then
      rel_src = "."
    end

    local jdk = find_jdk()
    local java_settings = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      -- 无构建文件的目录，靠这个告诉 jdtls 源码根在哪
      project = { sourcePaths = { rel_src } },
    }
    if jdk then
      java_settings.jdt = { ls = { java = { home = jdk } } }
      -- 没有构建文件时 jdtls 不会给项目挂 JRE 容器，
      -- 结果为 :DapNew 报 "Could not resolve java executable"。声明一个默认运行时顶上。
      local ver = vim.fn.system({ jdk .. "/bin/java", "-version" }):match('version "(%d+)')
      if ver then
        java_settings.configuration = {
          runtimes = { { name = "JavaSE-" .. ver, path = jdk, default = true } },
        }
      end
    end

    require("jdtls").start_or_attach({
      cmd = { mason .. "/bin/jdtls", "-data", vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project },
      root_dir = project_root,
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      init_options = { bundles = java_bundles() },
      settings = { java = java_settings },
    })

    -- 注册 java adapter + 自动发现 main 类（:DapNew 可以直接列出来）
    require("jdtls").setup_dap({ hotcodereplace = "auto" })
  end,
})

-- Java 启动：自己列 main 类再启动
-- 不用 nvim-jdtls 自带的 :DapNew / fetch_main_configs —— 它内部有 2 秒超时，
-- 而且在这个 Neovim 版本上解析 javaExec 会失败，类一多就报
-- "No configuration found for `java`"。
local function java_launch()
  local bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({ name = "jdtls", bufnr = bufnr })[1]
  if not client then
    vim.notify("jdtls 还没就绪，等它启动完再试", vim.log.levels.WARN)
    return
  end

  local function exec(cmd, args, cb)
    local params = { command = cmd }
    if args then
      params.arguments = args
    end
    client:request("workspace/executeCommand", params, function(err, res)
      if err then
        vim.notify(cmd .. " 失败: " .. vim.inspect(err), vim.log.levels.ERROR)
        return
      end
      cb(res)
    end, bufnr)
  end

  exec("vscode.java.resolveMainClass", nil, function(classes)
    if not classes or #classes == 0 then
      vim.notify("没找到带 main 方法的类", vim.log.levels.WARN)
      return
    end
    vim.ui.select(classes, {
      prompt = "选择要调试的 main 类",
      format_item = function(c)
        return string.format("%s  (%s)", c.mainClass, vim.fn.fnamemodify(c.filePath, ":t"))
      end,
    }, function(choice)
      if not choice then
        return
      end
      local args = { choice.mainClass, choice.projectName }
      exec("vscode.java.resolveJavaExecutable", args, function(java_exec)
        if not java_exec then
          vim.notify("拿不到 java 可执行文件（检查 JDK）", vim.log.levels.ERROR)
          return
        end
        exec("vscode.java.resolveClasspath", args, function(paths)
          dap.run({
            type = "java",
            request = "launch",
            name = "Launch " .. choice.mainClass,
            mainClass = choice.mainClass,
            projectName = choice.projectName,
            javaExec = java_exec,
            modulePaths = paths and paths[1] or {},
            classPaths = paths and paths[2] or {},
            cwd = (client.config.root_dir or vim.fn.getcwd()),
            -- internalConsole：输出走 DAP 事件，在调试面板里看；
            -- 换成 integratedTerminal 会去开真终端，nvim 里没必要
            console = "internalConsole",
          })
        end)
      end)
    end)
  end)
end

vim.api.nvim_create_user_command("JavaDebug", java_launch, { desc = "选择 main 类并启动 Java 调试" })

-- ---------- 快捷键 ----------
local map = vim.keymap.set
local opts = { silent = true }

map("n", "<F9>", function() dap.continue() end, vim.tbl_extend("force", opts, { desc = "调试：启动/继续" }))
map("n", "<F7>", function() dap.step_into() end, vim.tbl_extend("force", opts, { desc = "调试：单步进入" }))
map("n", "<F8>", function() dap.step_over() end, vim.tbl_extend("force", opts, { desc = "调试：单步跳过" }))
map("n", "<S-F8>", function() dap.step_out() end, vim.tbl_extend("force", opts, { desc = "调试：单步跳出" }))
map("n", "<leader>dc", function() dap.continue() end, vim.tbl_extend("force", opts, { desc = "调试：启动/继续" }))
map("n", "<leader>dj", java_launch, vim.tbl_extend("force", opts, { desc = "调试：选 main 类启动（Java）" }))
map("n", "<leader>db", function() dap.toggle_breakpoint() end, vim.tbl_extend("force", opts, { desc = "调试：切换断点" }))
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("断点条件: "))
end, vim.tbl_extend("force", opts, { desc = "调试：条件断点" }))
map("n", "<leader>dl", function() dap.set_breakpoint(nil, vim.fn.input("命中次数: ")) end,
  vim.tbl_extend("force", opts, { desc = "调试：命中次数断点" }))
map("n", "<leader>dt", function() dap.terminate() end, vim.tbl_extend("force", opts, { desc = "调试：终止" }))
map("n", "<leader>dr", function() dap.repl.toggle() end, vim.tbl_extend("force", opts, { desc = "调试：切换 REPL" }))
map("n", "<leader>du", function() dapui.toggle() end, vim.tbl_extend("force", opts, { desc = "调试：切换调试面板" }))
map({ "n", "v" }, "<leader>de", function() dapui.eval() end, vim.tbl_extend("force", opts, { desc = "调试：求值" }))
