# Neovim 键位表

> 生成时间：2026-10-07 ｜ 环境：Neovim 0.12.5 + lazy.nvim（nvim-treesitter main 分支）
> 配置位置：`~/.config/nvim/` ｜ `<leader>` = **空格**
> 本表按"键位来源"分组：自己定义的 → 插件自带 → Neovim 0.12 内置默认。

---

## 1. 自定义键位

来源：`lua/core/keymaps.lua`、`lua/plugins/telescope.lua`、`lua/plugins/cmp.lua`

### 编辑

| 模式 | 键位 | 作用 |
|---|---|---|
| i | `jk` | 退出插入模式 |
| v / x | `J` | 选中行下移一行（自动重排缩进） |
| v / x | `K` | 选中行上移一行（自动重排缩进） |

### 窗口

| 模式 | 键位 | 作用 |
|---|---|---|
| n | `<Space>sv` | 垂直分屏（`<C-w>v`，左右分屏）⚠️ 配置注释写的是"水平"，实际是左右 |
| n | `<Space>sh` | 水平分屏（`<C-w>s`，上下分屏） |

### buffer / 搜索

| 模式 | 键位 | 作用 |
|---|---|---|
| n | `<C-h>` | 上一个 buffer |
| n | `<C-l>` | 下一个 buffer |
| n | `<Space>nh` | 取消搜索高亮（`:nohl`） |

### 文件树与查找（telescope）

| 模式 | 键位 | 作用 |
|---|---|---|
| n | `<Space>e` | 开关 nvim-tree 文件树 |
| n | `<Space>ff` | 查找文件 |
| n | `<Space>fg` | 全文实时 grep（依赖 `ripgrep`） |
| n | `<Space>fb` | 已打开 buffer 列表 |
| n | `<Space>fh` | 帮助标签 |

### 调试（nvim-dap）

来源：`lua/plugins/dap.lua`。Java / C / C++ / Rust / Python 通用。

| 模式 | 键位 | 作用 |
|---|---|---|
| n | `<F9>` | 启动 / 继续（`dap.continue`） |
| n | `<F7>` | 单步进入 |
| n | `<F8>` | 单步跳过 |
| n | `<S-F8>` | 单步跳出 |
| n | `<Space>dc` | 启动 / 继续 |
| n | `<Space>dj` | **选 main 类启动（Java 专用）**，等同 `:JavaDebug` |
| n | `<Space>db` | 当前行切换断点 |
| n | `<Space>dB` | 条件断点（输入表达式） |
| n | `<Space>dl` | 命中次数断点（输入次数） |
| n | `<Space>dt` | 终止调试 |
| n | `<Space>dr` | 开关 REPL |
| n | `<Space>du` | 开关调试面板（Scopes / Breakpoints / Stacks / Watches / Console） |
| n / v | `<Space>de` | 求值光标下的表达式 |

> Java 建议用 `<Space>dj`，不要用 `:DapNew`——nvim-jdtls 自带的 main 类发现与本机 Neovim 0.12 不兼容（2 秒超时 + 解析 javaExec 失败），类一多就报 `No configuration found for 'java'`。
> C / C++：直接 `<F9>`，会提示输入可执行文件路径（记得 `gcc -g` 编译）。

### 补全（nvim-cmp）

| 模式 | 键位 | 作用 |
|---|---|---|
| i | `<C-b>` | 候选文档向上滚动 |
| i | `<C-f>` | 候选文档向下滚动 |
| i | `<C-e>` | 取消本次补全 |
| i | `<CR>` | 确认当前选中项（经 autopairs 包装后仍是补全确认） |
| i / s | `<Tab>` | 下一个候选；无候选时展开/跳转 snippet |
| i / s | `<S-Tab>` | 上一个候选；无候选时反向跳转 snippet |

---

## 2. 插件自带键位

### 2.1 nvim-cmp `preset.insert`（插入模式）

| 键位 | 作用 |
|---|---|
| `<C-n>` / `<C-p>` | 下 / 上一个候选；弹窗未打开时触发补全 |
| `<Down>` / `<Up>` | 下 / 上一个候选 |
| `<C-y>` | 确认（不选中） |

> cmp 的键位是**插入时才挂到当前 buffer** 的，`:nmap` 看不到属正常现象。

### 2.2 Comment.nvim

| 模式 | 键位 | 作用 |
|---|---|---|
| n | `gcc` | 注释/取消注释当前行 |
| n | `gbc` | 块注释当前行 |
| n | `gc{motion}` | 按 motion 行注释（如 `gcip`） |
| n | `gb{motion}` | 按 motion 块注释 |
| n | `gco` / `gcO` / `gcA` | 下方 / 上方 / 行尾插入注释 |
| x | `gc` / `gb` | 注释选中区域（行注释 / 块注释） |

### 2.3 LuaSnip

| 模式 | 键位 | 作用 |
|---|---|---|
| i / s | `<Tab>` / `<S-Tab>` | 展开 snippet / 跳到下一个、上一个占位符 |
| i / s | `<Plug>luasnip-expand-or-jump` 等 | LuaSnip 内部映射（一般不直接用） |

> Neovim 0.12 原生 snippet 也占用 `<Tab>`/`<S-Tab>`，无 snippet 时回退为普通 Tab。

### 2.4 nvim-autopairs

| 模式 | 键位 | 作用 |
|---|---|---|
| i | `<CR>` | 括号自动配对确认（`completion_confirm`） |

### 2.5 telescope（picker 内，buffer 局部，退出即失效）

**插入模式**

| 键位 | 作用 |
|---|---|
| `<C-n>` / `<C-p>`（或 `<Down>` / `<Up>`） | 下 / 上移动选择 |
| `<CR>` | 打开选中项 |
| `<C-x>` / `<C-v>` / `<C-t>` | 水平 / 垂直 / 新标签页打开 |
| `<Tab>` / `<S-Tab>` | 多选并向下 / 向上移动 |
| `<C-q>` / `<M-q>` | 发送（选中）结果到 quickfix 并打开 |
| `<C-u>` / `<C-d>` | 预览窗口向上 / 向下滚动 |
| `<C-f>` / `<C-k>` | 预览窗口向左 / 向右滚动 |
| `<PageUp>` / `<PageDown>` | 结果列表上 / 下翻页 |
| `<C-r><C-w>` / `<C-r><C-a>` / `<C-r><C-f>` / `<C-r><C-l>` | 插入光标下的 词 / 大写词 / 文件名 / 整行 |
| `<C-/>`（即 `<C-_>`） | 显示全部键位（which-key） |
| `<C-c>` / `<Esc>` | 关闭 picker |

**普通模式**

| 键位 | 作用 |
|---|---|
| `j` / `k` | 下 / 上移动选择 |
| `H` / `M` / `L` | 跳到顶部 / 中间 / 底部 |
| `gg` / `G` | 首个 / 末个结果 |
| `<CR>`、`<C-x>`、`<C-v>`、`<C-t>` | 打开（同插入模式） |
| `<Tab>` / `<S-Tab>`、`<C-q>`、`<M-q>` | 多选、送 quickfix（同插入模式） |
| `<Esc>` | 关闭 picker |

### 2.6 nvim-tree（文件树窗口内，buffer 局部）

| 键位 | 作用 |
|---|---|
| `<CR>` / `o` | 打开文件 / 展开目录 |
| `<C-v>` / `<C-x>` / `<C-t>` | 垂直分屏 / 水平分屏 / 新标签打开 |
| `O` / `<C-e>` / `<Tab>` | 无窗口选择器打开 / 原地打开 / 预览 |
| `a` | 新建文件或目录 |
| `d` / `<Del>` / `D` | 删除 / 删除 / 移到回收站 |
| `r` / `e` / `u` / `<C-r>` | 重命名 / 改名（basename）/ 全路径改名 / 省略文件名 |
| `c` / `gp` / `p` | 复制 / 移动 / 粘贴 |
| `gy` / `ge` | 复制绝对路径 / 复制文件名 |
| `-` / `P` | 上级目录 / 父目录 |
| `R` / `S` / `f` / `F` | 刷新 / 搜索 / 启动实时过滤 / 清除过滤 |
| `H` / `I` / `C` / `B` / `M` / `U` / `L` | 过滤开关：点文件 / git 忽略 / git 干净 / 无 buffer / 无书签 / 自定义 / 折叠空目录 |
| `E` / `W` | 全部展开 / 全部折叠 |
| `m` / `bmv` / `bd` / `bt` | 书签 / 移动书签 / 删除书签 / 回收站书签 |
| `K` / `J` / `<` / `>` | 第一个 / 最后一个 / 上一个 / 下一个同级节点 |
| `[c` / `]c` | 上一个 / 下一个 git 变更 |
| `[e` / `]e` | 上一个 / 下一个诊断 |
| `.` / `s` / `q` | 执行命令 / 运行系统程序 / 关闭树 |
| `g?` | **显示文件树全部键位** |
| `<2-LeftMouse>` / `<2-RightMouse>` | 双击打开 / 双击 cd |

### 2.7 没有默认键位的插件

| 插件 | 说明 |
|---|---|
| gitsigns.nvim | 新版**不提供任何默认映射**，配置里也没在 `on_attach` 里加 → 目前只能 `:Gitsigns …` 命令，如 `:Gitsigns diffthis`、`:Gitsigns preview_hunk`、`:Gitsigns blame_line`、`:Gitsigns nav_hunk next` |
| bufferline.nvim | 未配置键位（默认就没有），切 buffer 用 `<C-h>`/`<C-l>` |
| lualine.nvim / mason.nvim | 纯 UI，无键位 |

---

## 3. Neovim 0.12 内置默认键位

来源：`/usr/share/nvim/runtime/lua/vim/_core/defaults.lua`，全局生效。

### LSP（需 LSP 已 attach）

| 模式 | 键位 | 作用 |
|---|---|---|
| n | `grn` | 重命名符号 |
| n | `gra` | code action |
| n | `grr` | 查看引用 |
| n | `gri` | 查看实现 |
| n | `grt` | 查看类型定义 |
| n | `grx` | 运行 codelens |
| n | `gO` | 文档符号列表 |
| i / s | `<C-S>` | 签名帮助 |

### 诊断

| 模式 | 键位 | 作用 |
|---|---|---|
| n | `]d` / `[d` | 下一个 / 上一个诊断 |
| n | `]D` / `[D` | 最后一个 / 第一个诊断 |
| n | `<C-w>d` | 显示光标所在行的诊断 |

### Treesitter 语法节点（选区）

| 模式 | 键位 | 作用 |
|---|---|---|
| x / o | `an` / `in` | 选中父（外层）/ 子（内层）节点 |
| x | `]n` / `[n` | 下一个 / 上一个节点 |
| x | `]N` / `[N` | 下一个 / 上一个兄弟节点 |

### 其它常用

| 模式 | 键位 | 作用 |
|---|---|---|
| n | `%` / `g%` / `[%` / `]%` / `a%`（x/o） | matchit 括号、注释配对跳转 |
| n | `[<Space>` / `]<Space>` | 光标上 / 下插入空行 |
| n | `]b` / `[b` / `]B` / `[B` | 下 / 上一个 buffer、末 / 首个 buffer |
| n | `]q` / `[q` / `]Q` / `[Q` | quickfix 下 / 上、末 / 首 |
| n | `]l` / `[l` / `]L` / `[L` | location list 下 / 上、末 / 首 |
| n | `]t` / `[t` / `]T` / `[T` | tag 下 / 上、末 / 首 |
| n | `]a` / `[a` / `]A` / `[A` | 参数列表下 / 上、末 / 首 |
| n | `Y` | `y$`（复制到行尾） |
| n | `&` | 重复上一次 `:s` |

---

## 4. 已知冲突与坑

1. **`<C-h>` / `<C-l>` 被 buffer 切换占用**，导致 vim-tmux-navigator 的**左右窗口导航失效**。
   目前 `vim-tmux-navigator` 只剩：
   - `<C-j>` → `TmuxNavigateDown`
   - `<C-k>` → `TmuxNavigateUp`
   - `<C-\>` → `TmuxNavigatePrevious`

   想恢复左右导航：把 buffer 切换改成 `<S-h>`/`<S-l>`（改 `lua/core/keymaps.lua`），
   或在 tmux 配置里换键。

2. **`<Space>sv` 是左右分屏**，注释里写的"水平"与实际相反（`<C-w>v` = vertical split = 左右）。

3. **gitsigns 没有任何键位**，左侧只有符号提示，跳变更只能用 `:Gitsigns nav_hunk`。

4. **cmp 键位不显示在 `:nmap`** 里（插入时才挂 buffer），不要误判为没生效。

5. `<C-d>` 在插入模式是 Neovim 默认的"减少缩进"，未被插件覆盖。

---

## 5. 自查命令

| 命令 | 作用 |
|---|---|
| `:map` / `:nmap` / `:imap` / `:xmap` | 列出全局键位 |
| `:verbose map <键>` | 查看某个键**是谁**映射的、最后在哪改的 |
| `:map <buffer>` | 列出当前 buffer 的局部键位（文件树、picker、cmp 都在这里） |
| `:Telescope keymaps` | 用 picker 模糊搜索所有键位 |
| `:lua print(vim.inspect(vim.api.nvim_get_keymap('n')))` | 结构化列出普通模式键位 |
| `g?`（文件树内）/ `<C-/>`（picker 内） | 查看该插件的完整键位帮助 |

---

## 6. 可选的补全方案

如果需要，可以在配置里补上：

- **gitsigns**：`]c`/`[c` 跳变更，`<Space>hs/hr/hp/hb/hd` 暂存、重置、预览、blame、diff
- **bufferline**：`<Tab>`/`<S-Tab>` 切 buffer、`<Space>bd` 关闭 buffer、`<Space>bp` 选 buffer
- **文件树**：把 `<Space>e` 同时加上"打开时自动定位当前文件"
