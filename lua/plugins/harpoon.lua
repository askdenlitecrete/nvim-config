-- harpoon (v2): pin the 3-5 files you're actually bouncing between and jump
-- straight to them by number -- faster than buffer cycling or a fuzzy find for
-- your working set. The marks are per project root.
--
--   <leader>ma      add the current file to the list
--   <leader>mm      toggle the quick-menu (edit/reorder/delete marks there)
--   <leader>m1..m4  jump to mark 1-4
--   <leader>mn / mp next / previous mark
local harpoon = require("harpoon")
harpoon:setup()

local map = vim.keymap.set
map("n", "<leader>ma", function() harpoon:list():add() end, { desc = "Harpoon: add file" })
map("n", "<leader>mm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: menu" })
for i = 1, 4 do
  map("n", "<leader>m" .. i, function() harpoon:list():select(i) end, { desc = "Harpoon: file " .. i })
end
map("n", "<leader>mn", function() harpoon:list():next() end, { desc = "Harpoon: next mark" })
map("n", "<leader>mp", function() harpoon:list():prev() end, { desc = "Harpoon: prev mark" })
