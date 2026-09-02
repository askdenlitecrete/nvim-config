-- project.nvim   detect the project root (.git, package.json, go.mod, ...) and
--                cd into it automatically; adds a Telescope `projects` picker.
-- persistence.nvim  save a session per project directory and restore it, so
--                reopening a repo brings back your windows, tabs and buffers.
--
--   <leader>Pr  restore session for this directory
--   <leader>Pl  restore the last session
--   <leader>Pd  stop saving the current session
--   <leader>fp  find projects (Telescope)

-- project.nvim is unmaintained: its LSP root detection calls the deprecated
-- vim.lsp.buf_get_clients() on every buffer event (we enable the "lsp" method
-- below), which nags "... is deprecated. Run :checkhealth vim.deprecated".
-- Point that name at the current API, minus the deprecation shim, before the
-- plugin loads. Also future-proofs it for when Neovim removes the alias.
-- Remove this if project.nvim is ever patched or replaced.
if vim.lsp.buf_get_clients then
  vim.lsp.buf_get_clients = function(bufnr)
    return vim.lsp.get_clients({ bufnr = bufnr })
  end
end

require("project_nvim").setup({
  detection_methods = { "pattern", "lsp" },
  patterns = {
    ".git", "package.json", "pnpm-workspace.yaml", "turbo.json",
    "go.mod", "Cargo.toml", "pyproject.toml", "Makefile", ".root",
  },
})
pcall(function() require("telescope").load_extension("projects") end)
vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<CR>", { desc = "Find projects" })

require("persistence").setup()
local map = vim.keymap.set
map("n", "<leader>Pr", function() require("persistence").load() end, { desc = "Restore session (cwd)" })
map("n", "<leader>Pl", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
map("n", "<leader>Pd", function() require("persistence").stop() end, { desc = "Don't save this session" })
