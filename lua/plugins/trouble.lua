-- trouble.nvim: a sortable, foldable panel for diagnostics, LSP references,
-- quickfix and location lists. todo-comments: highlight and search
-- TODO/FIXME/HACK/NOTE/PERF comments.
require("trouble").setup({
  focus = true,
})

local map = vim.keymap.set
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (workspace)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Diagnostics (buffer)" })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle<CR>", { desc = "Symbols outline" })
map("n", "<leader>xl", "<cmd>Trouble lsp toggle<CR>", { desc = "LSP defs / refs / impl" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<CR>", { desc = "Location list" })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>", { desc = "TODO / FIXME list" })

require("todo-comments").setup({
  signs = true,
})
map("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO comment" })
map("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous TODO comment" })
map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Find TODO comments" })
