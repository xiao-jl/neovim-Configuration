require("mason").setup({
  ui = {
      icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
      }
  }
})

require("mason-lspconfig").setup({
  -- 确保安装，根据需要填写
  ensure_installed = {
    "lua_ls",
  },
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- 新版 lspconfig 用 vim.lsp.config 自定义；mason-lspconfig 会自动 vim.lsp.enable('lua_ls')
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
})
