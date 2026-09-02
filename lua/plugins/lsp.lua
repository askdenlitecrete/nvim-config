-- LSP: go-to-definition, references, hover docs, rename, code actions and live
-- diagnostics -- the same language servers editors like VS Code use.
--   mason.nvim            downloads the servers into ~/.local/share/nvim/mason
--   mason-lspconfig.nvim  maps mason names <-> lspconfig names
--   nvim-lspconfig        the per-server launch configs
--
-- Pinned in lua/bootstrap.lua because this box runs Neovim 0.10.4:
--   nvim-lspconfig v1.8.0  (v2 nags every startup that 0.10 is deprecated)
--   mason 1.x / mason-lspconfig 1.x  (2.x expects 0.11+)
-- After upgrading Neovim, unpin them and optionally move to vim.lsp.config().

require("mason").setup()

-- Breadcrumbs in the winbar (see lua/plugins/statusline.lua). auto_attach means
-- navic hooks every server that supports document symbols with no extra code.
require("nvim-navic").setup({
  lsp = { auto_attach = true },
  highlight = true,
  separator = "  ",
  depth_limit = 5,
})

-- One entry per server; empty table = lspconfig defaults.
local servers = {
  -- backend / general
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        hint = { enable = true }, -- inlay hints
      },
    },
  },
  ts_ls = {
    settings = {
      typescript = { inlayHints = {
        includeInlayParameterNameHints = "literal",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = true,
      } },
      javascript = { inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
      } },
    },
  },
  eslint = {
    -- fix all auto-fixable problems on save
    on_attach = function(_, bufnr)
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        command = "silent! EslintFixAll",
      })
    end,
  },
  pyright = {},
  gopls = {},
  rust_analyzer = {},
  bashls = {},

  -- web frontend
  html = {},
  cssls = {},
  tailwindcss = {},
  emmet_language_server = {}, -- HTML/JSX emmet expansion (also see :h emmet)
  graphql = {},

  -- data / infra
  jsonls = {},
  yamlls = {},
  sqlls = {},
  prismals = {},
  dockerls = {},
  docker_compose_language_service = {},
  marksman = {}, -- markdown
}

-- Only auto-install servers whose language toolchain is actually present. This
-- box has no Go or Rust, and mason builds gopls with `go install` -- without it
-- the install fails on every single startup (the "Press ENTER" nag). The server
-- stays configured below, so `:MasonInstall gopls` after installing Go is enough.
local needs_toolchain = { gopls = "go", rust_analyzer = "cargo" }
local ensure_installed = {}
for name in pairs(servers) do
  local tool = needs_toolchain[name]
  if not tool or vim.fn.executable(tool) == 1 then
    ensure_installed[#ensure_installed + 1] = name
  end
end

require("mason-lspconfig").setup({
  ensure_installed = ensure_installed,
  automatic_installation = false, -- don't retry installs for servers opened by filetype
})

-- Advertise nvim-cmp's extra completion capabilities to every server.
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
end

local lspconfig = require("lspconfig")
for name, cfg in pairs(servers) do
  cfg.capabilities = capabilities
  local ok = pcall(lspconfig[name].setup, cfg)
  if not ok then
    vim.schedule(function()
      vim.notify("lspconfig: unknown server '" .. name .. "' (skipped)", vim.log.levels.WARN)
    end)
  end
end

-- Buffer-local keymaps, wired only once a server attaches to the buffer.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("cfg_lsp_attach", { clear = true }),
  callback = function(event)
    local function bmap(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
    end
    local tb = require("telescope.builtin")
    bmap("gd", tb.lsp_definitions, "Goto definition")
    bmap("gr", tb.lsp_references, "Goto references")
    bmap("gI", tb.lsp_implementations, "Goto implementation")
    bmap("gy", tb.lsp_type_definitions, "Goto type definition")
    bmap("gD", vim.lsp.buf.declaration, "Goto declaration")
    bmap("<leader>cs", tb.lsp_document_symbols, "Document symbols")
    bmap("<leader>cS", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")
    bmap("K", vim.lsp.buf.hover, "Hover documentation")
    bmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    bmap("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    bmap("[d", function() vim.diagnostic.goto_prev() end, "Previous diagnostic")
    bmap("]d", function() vim.diagnostic.goto_next() end, "Next diagnostic")
    vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help,
      { buffer = event.buf, desc = "LSP: signature help" })

    -- Inlay hints toggle (Neovim 0.10 API)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.supports_method("textDocument/inlayHint") then
      bmap("<leader>ch", function()
        local on = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
        vim.lsp.inlay_hint.enable(not on, { bufnr = event.buf })
      end, "Toggle inlay hints")
    end
  end,
})

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
})
