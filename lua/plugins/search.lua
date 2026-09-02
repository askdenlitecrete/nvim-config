-- grug-far.nvim: project-wide find & replace in a single editable buffer.
-- Type a search (and optional replace), see every match with context, tweak
-- the ripgrep flags inline, then apply -- across the whole project or one file.
--
--   <leader>rr   open grug-far  (in visual mode: seeded with the selection)
--   <leader>rw   open, seeded with the word under the cursor
--   <leader>rf   open, scoped to the current file
-- Inside the buffer:  <localleader>r apply · <localleader>s sync line · ? help
require("grug-far").setup({
  headerMaxWidth = 80,
})

local map = vim.keymap.set
map("n", "<leader>rr", function() require("grug-far").open() end, { desc = "Search & replace (project)" })
map("v", "<leader>rr", function() require("grug-far").with_visual_selection() end, { desc = "Search & replace (selection)" })
map("n", "<leader>rw", function()
  require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search & replace word" })
map("n", "<leader>rf", function()
  require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search & replace (this file)" })
