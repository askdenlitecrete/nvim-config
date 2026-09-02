-- LSP: go-to-definition, references, hover docs, rename, code actions and live
-- diagnostics -- the same language servers editors like VS Code use.
--   mason.nvim            downloads the servers into ~/.local/share/nvim/mason
--   mason-lspconfig.nvim  installs the set below + auto-enables what's present
--   nvim-lspconfig        ships the per-server `lsp/*.lua` configs that
--                         vim.lsp.enable() consumes (Neovim 0.11+ native API)
--
-- TypeScript/JavaScript is handled by typescript-tools.nvim, not ts_ls -- it
-- drives tsserver directly (faster, lower memory on a monorepo). ts_ls is
-- excluded from auto-enable below so the two don't both attach.

require("mason").setup()

-- Breadcrumbs in the winbar (see lua/plugins/statusline.lua). auto_attach hooks
-- every server that supports document symbols with no extra code.
require("nvim-navic").setup({
  lsp = { auto_attach = true },
  highlight = true,
  separator = "  ",
  depth_limit = 5,
})

-- One entry per server; empty table = defaults. Merged onto vim.lsp.config().
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        -- lazydev.nvim (lua/plugins/lazydev.lua) feeds it the nvim runtime,
        -- so `vim` resolves without the old globals hack.
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        hint = { enable = true }, -- inlay hints
      },
    },
  },
  pyright = {},
  gopls = {},
  rust_analyzer = {},
  bashls = {},

  -- web frontend
  html = {},
  cssls = {},
  tailwindcss = {},
  emmet_language_server = {},
  graphql = {},
  eslint = {}, -- fix-on-save wired in the LspAttach handler below

  -- data / infra
  jsonls = {},
  yamlls = {},
  sqlls = {},
  prismals = {},
  dockerls = {},
  docker_compose_language_service = {},
  marksman = {},
}

-- Advertise nvim-cmp's extra completion capabilities to every server.
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
end
vim.lsp.config("*", { capabilities = capabilities })

for name, cfg in pairs(servers) do
  if next(cfg) ~= nil then
    vim.lsp.config(name, cfg)
  end
end

-- Servers whose language toolchain must be present to be useful. This box has
-- no Go or Rust: mason builds gopls with `go install` (fails without Go), and
-- an installed rust_analyzer attaches to every .rs buffer and errors
-- "cargo not found". Both stay in `servers` above; install the toolchain +
-- `:MasonInstall gopls` / `rust_analyzer` to light them back up.
local needs_toolchain = { gopls = "go", rust_analyzer = "cargo" }

-- The servers we can actually use here: everything in `servers`, minus any whose
-- language toolchain is absent (no Go/Rust on this box).
local usable = {}
for name in pairs(servers) do
  local tool = needs_toolchain[name]
  if not tool or vim.fn.executable(tool) == 1 then
    usable[#usable + 1] = name
  end
end

require("mason-lspconfig").setup({
  ensure_installed = usable,
  -- Don't let mason-lspconfig auto-enable *every* installed server -- that
  -- double-attaches when two cover one filetype (dockerls + docker-language-
  -- server on a Dockerfile) and lights up toolchain-less servers already on
  -- disk (rust_analyzer -> "cargo not found" on every .rs buffer). We enable
  -- exactly `usable` ourselves.
  automatic_enable = false,
})
vim.lsp.enable(usable)

-- typescript-tools.nvim: attaches to JS/TS buffers as its own LSP client, so
-- the LspAttach keymaps and navic below apply to it unchanged.
require("typescript-tools").setup({
  settings = {
    tsserver_file_preferences = {
      includeInlayParameterNameHints = "literal",
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = false,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
  },
})

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
    bmap("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
    bmap("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
    vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help,
      { buffer = event.buf, desc = "LSP: signature help" })

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end

    -- eslint: fix all auto-fixable problems on save
    if client.name == "eslint" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = event.buf,
        callback = function() pcall(vim.cmd, "EslintFixAll") end,
      })
    end

    -- Inlay hints toggle
    if client:supports_method("textDocument/inlayHint") then
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
