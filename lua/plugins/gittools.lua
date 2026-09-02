-- Full git surface on top of the gutter signs in plugins/git.lua.
--   vim-fugitive   :Git (status/stage/commit), :Git blame, :Gdiffsplit, :Gread
--   diffview.nvim  a real diff & merge-conflict UI, plus file history
local map = vim.keymap.set

-- fugitive
map("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Git status (fugitive)" })
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
map("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })
map("n", "<leader>gP", "<cmd>Git pull --rebase<CR>", { desc = "Git pull --rebase" })
map("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame (full)" })

-- diffview
require("diffview").setup({
  enhanced_diff_hl = true,
  view = {
    merge_tool = { layout = "diff3_mixed" },
  },
})
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Diff view (working tree)" })
map("n", "<leader>gD", "<cmd>DiffviewClose<CR>", { desc = "Close diff view" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "File history (current file)" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>", { desc = "File history (branch)" })
map("v", "<leader>gh", "<Esc><cmd>'<,'>DiffviewFileHistory<CR>", { desc = "History of selection" })
