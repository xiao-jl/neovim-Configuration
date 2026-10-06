-- 自动安装 lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "folke/tokyonight.nvim" }, -- 主题

  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } }, -- 状态栏

  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } }, -- 文档树

  { "christoomey/vim-tmux-navigator" }, -- 用 ctl-hjkl 来定位窗口

  -- 语法高亮/main 分支：只装 parser+query，高亮与缩进用 Neovim 0.12 自带能力
  { "nvim-treesitter/nvim-treesitter", branch = "main", lazy = false, build = ":TSUpdate" },

  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },

  -- 自动补全
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" }, -- snippets 引擎，不装这个自动补全会出问题
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
  { "hrsh7th/cmp-path" },

  { "numToStr/Comment.nvim" }, -- gcc 和 gc 注释
  { "windwp/nvim-autopairs" }, -- 自动补全括号

  { "akinsho/bufferline.nvim" }, -- buffer 分割线
  { "lewis6991/gitsigns.nvim" }, -- 左侧 git 提示

  { "nvim-telescope/telescope.nvim", version = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } }, -- 文件检索
}, {
  -- 保持原 packer 的立即加载行为：所有插件启动时加载，缺失的自动安装
  default = { lazy = false },
  install = { missing = true },
})
