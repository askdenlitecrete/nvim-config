-- Auto-install the non-LSP tools (formatters, linters, debug adapters) that
-- conform.nvim / nvim-lint / nvim-dap expect. mason-lspconfig only handles
-- language servers; this fills the gap without another plugin, using mason's
-- own registry API (works on mason 1.x).
--
-- Add/remove a line, restart nvim. Manage manually any time with :Mason.
--
-- NOTE: Python-based tools (debugpy, yamllint, ruff via pip) are NOT listed
-- here because this machine's python3 has no pip/ensurepip. To enable them:
--     sudo apt install python3-pip python3-venv
--     :MasonInstall debugpy yamllint ruff
local WANT = {
  -- formatters
  "stylua",
  "prettierd",
  "shfmt",
  "sql-formatter",
  -- linters
  "eslint_d",
  "stylelint",
  "shellcheck",
  "markdownlint",
  -- debug adapters
  "js-debug-adapter",
}
-- Want Dockerfile linting too? `:MasonInstall hadolint` and add it to
-- lint.linters_by_ft.dockerfile in lua/plugins/lint.lua.

local ok, registry = pcall(require, "mason-registry")
if not ok then
  return
end

-- Fast path: which of WANT are not on disk yet? (uses the bundled registry,
-- no network call -- so a fully-provisioned machine pays nothing here.)
local function missing()
  local out = {}
  for _, name in ipairs(WANT) do
    local found, pkg = pcall(registry.get_package, name)
    if found and not pkg:is_installed() then
      out[#out + 1] = pkg
    end
  end
  return out
end

local pending = missing()
if #pending == 0 then
  return
end

local function install(pkgs)
  for _, pkg in ipairs(pkgs) do
    vim.notify("mason: installing " .. pkg.name)
    pkg:install()
  end
end

-- Refresh once so we fetch current versions, then install what's still missing.
if registry.refresh then
  registry.refresh(vim.schedule_wrap(function()
    install(missing())
  end))
else
  install(pending)
end
