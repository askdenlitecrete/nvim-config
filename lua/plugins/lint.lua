-- Standalone linters for tools that aren't language servers. The direct
-- descendant of ALE from the Missing Semester lecture: run a checker on save,
-- show the results as diagnostics.
--
-- JS/TS linting is handled by the `eslint` language server (see plugins/lsp.lua),
-- not here. Install the rest with :Mason (mostly auto-installed by mason-tools).
local lint = require("lint")

lint.linters_by_ft = {
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  python = { "ruff" },
  css = { "stylelint" },
  scss = { "stylelint" },
  less = { "stylelint" },
  markdown = { "markdownlint" },
  -- dockerfile -> handled by the dockerls LSP (add "hadolint" here if you install it)
  -- yaml       -> handled by the yamlls LSP (yamllint needs python3-pip)
}

local function run()
  lint.try_lint(nil, { ignore_errors = true }) -- silently skips linters not installed
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("cfg_nvim_lint", { clear = true }),
  callback = run,
})

vim.api.nvim_create_user_command("Lint", run, { desc = "Run linters now" })
