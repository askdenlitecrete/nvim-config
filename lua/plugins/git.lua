-- gitsigns: added/changed/removed markers in the sign column, plus stage /
-- reset / preview / blame of individual hunks without leaving the buffer.
require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
  on_attach = function(buffer)
    local gs = require("gitsigns")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = "Git: " .. desc })
    end

    map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
    map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
    map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
    map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
    map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
    map("n", "<leader>hd", gs.diffthis, "Diff against index")
    map("n", "<leader>ht", gs.toggle_current_line_blame, "Toggle inline blame")
  end,
})
