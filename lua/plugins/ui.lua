-- Reading/UI niceties.

-- render-markdown: pretty in-buffer rendering of headings, code blocks, tables,
-- callouts and checkboxes while you edit .md files (no browser preview needed).
require("render-markdown").setup({
  completions = { lsp = { enabled = true } },
  heading = { sign = false },
  code = { sign = false, width = "block", min_width = 45 },
  latex = { enabled = false }, -- no latex2text/utftex on this box; silences :checkhealth
})

-- `<leader>u` = UI toggles
local map = vim.keymap.set
map("n", "<leader>um", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle markdown render" })
map("n", "<leader>uw", function()
  vim.opt_local.wrap = not vim.opt_local.wrap:get()
end, { desc = "Toggle line wrap" })
map("n", "<leader>us", function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
end, { desc = "Toggle spell check" })
map("n", "<leader>ud", function()
  local on = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not on)
  vim.notify("Diagnostics " .. (on and "OFF" or "ON"))
end, { desc = "Toggle diagnostics" })
map("n", "<leader>ul", function()
  vim.opt_local.list = not vim.opt_local.list:get()
end, { desc = "Toggle whitespace chars" })
