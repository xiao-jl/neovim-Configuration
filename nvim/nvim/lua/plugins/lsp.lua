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
    "lua_ls", -- Lua
    "clangd", -- C / C++
    "pylsp",  -- Python（node 现在有了，想换 pyright 把 pylsp 改成 pyright）
    "jdtls",  -- Java
    "html",   -- HTML（走 npm 的 vscode-html-language-server）
  },
  -- jdtls 交给 nvim-jdtls 启动（见 plugins/dap.lua），
  -- 不排除的话两个都会起，导致重复的补全/诊断
  automatic_enable = {
    exclude = { "jdtls" },
  },
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- '*' 对所有 language server 生效；原来只写了 'lua_ls'，
-- 其它语言拿不到 cmp 的补全能力（snippet、附加字段等）
vim.lsp.config('*', {
  capabilities = capabilities,
})
