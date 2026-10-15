-- nvim-treesitter (main 分支)
-- main 已删除 configs 语法：本插件只负责 parser / query 的安装与管理，
-- 高亮、缩进由 Neovim 自带能力（vim.treesitter.start / indentexpr）在 FileType 时启用。
require("nvim-treesitter").setup {
  install_dir = vim.fn.stdpath("data") .. "/site", -- parser 与 query 装到这里（自动置顶 rtp）
}

-- 需要安装的语言（异步，已装则跳过）
require("nvim-treesitter").install {
  "vim", "vimdoc", "bash", "c", "cpp", "javascript", "json", "lua",
  "python", "typescript", "tsx", "css", "rust", "markdown", "markdown_inline",
}

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    -- 没有对应 parser 时 start 会报错，用 pcall 兜住
    if pcall(vim.treesitter.start) then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
