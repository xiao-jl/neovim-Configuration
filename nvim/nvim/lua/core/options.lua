local opt = vim.opt

-- 行号
opt.relativenumber = true
opt.number = true

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- 防止包裹
opt.wrap = false

-- 光标行
opt.cursorline = true

-- 光标：平时不设，交给 Konsole profile（方块 + 动效）；插入模式临时换成常亮竖线
opt.guicursor = ""
vim.api.nvim_create_autocmd("InsertEnter", { command = "set guicursor=i:ver25" })
vim.api.nvim_create_autocmd("InsertLeave", { command = "set guicursor=" })

-- 启用鼠标
opt.mouse:append("a")

-- 系统剪贴板
opt.clipboard:append("unnamedplus")

-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 外观
opt.termguicolors = true
opt.signcolumn = "yes"
vim.cmd[[colorscheme tokyonight-moon]]
