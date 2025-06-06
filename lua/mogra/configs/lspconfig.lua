local M = {}
local map = vim.keymap.set
-- export on_attach & capabilities
M.on_attach = function(_, bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
  map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
  map("n", "gi", vim.lsp.buf.implementation, opts "Go to implementation")
  map("n", "<leader>sh", vim.lsp.buf.signature_help, opts "Show signature help")
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
  map("n", "K", vim.lsp.buf.hover, opts "Lsp Hover")
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts "List workspace folders")

  map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")

  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
  map("n", "gr", vim.lsp.buf.references, opts "Show references")
  map("n", "<leader>er", vim.diagnostic.open_float, opts "Show diagnostic hover window")
  map("n", "<leader>jd", "<cmd>belowright split | lua vim.lsp.buf.definition()<CR>", opts "Open definition in split window")
end

-- disable semanticTokens
M.on_init = function(client, _)
  if client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

M.defaults = function(_, _)
  require "mogra.ui.lsp"
  local lspconfig = require "lspconfig"
  lspconfig.lua_ls.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    on_init = M.on_init,

    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            vim.fn.expand "$VIMRUNTIME/lua",
            vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
            vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
            vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  }
  lspconfig.terraformls.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    on_init = M.on_init,
  }
  lspconfig.sqlls.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    on_init = M.on_init,
  }
  lspconfig.jdtls.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    on_init = M.on_init,
  }
  lspconfig.kotlin_language_server.setup {
    -- cmd = vim.lsp.rpc.connect("127.0.0.1", 49100),
    cmd = { "kotlin-ls", "--stdio" },
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    on_init = M.on_init,
    root_markers = { "build.gradle", "build.gradle.kts", "pom.xml" },
  }
  -- lspconfig.kotlin_lsp.setup {
  --   cmd = { "kotlin-ls", "--stdio" },
  --   single_file_support = true,
  --   filetypes = { "kotlin" },
  --   root_markers = { "build.gradle", "build.gradle.kts", "pom.xml" },
  --   on_attach = M.on_attach,
  --   capabilities = M.capabilities,
  --   on_init = M.on_init,
  -- }
  -- for fold
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  -- graphql
  lspconfig.graphql.setup {
    filetypes = {
      "graphql",
      "gql",
      "graphqls",
    },
    capabilities = capabilities,
  }
  lspconfig.yamlls.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    on_init = M.on_init,
  }
end

return M.defaults
