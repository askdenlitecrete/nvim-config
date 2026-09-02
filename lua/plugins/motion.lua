-- flash.nvim: type `s` then two characters and every match on screen gets a
-- one-key label -- press it to teleport there. The modern equivalent of
-- vim-easymotion, recommended in the Missing Semester lecture.
--
--   s{c}{c}   jump to a match
--   S         Treesitter-aware structural select
--   r         (operator-pending) act at a flash target, e.g. yr<label>
--   f/F/t/T   labelled when a match is far away
require("flash").setup({
  modes = {
    char = { jump_labels = true },
  },
})

local flash = require("flash")
local map = vim.keymap.set
map({ "n", "x", "o" }, "s", function() flash.jump() end, { desc = "Flash jump" })
map({ "n", "x", "o" }, "S", function() flash.treesitter() end, { desc = "Flash Treesitter" })
map("o", "r", function() flash.remote() end, { desc = "Remote flash" })
map({ "o", "x" }, "R", function() flash.treesitter_search() end, { desc = "Treesitter search" })
map("c", "<C-s>", function() flash.toggle() end, { desc = "Toggle flash in / search" })
