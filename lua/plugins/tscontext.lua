-- nvim-treesitter-context: pins the enclosing function / class / block
-- signature to the top of the window as you scroll into a long body, so you
-- never lose track of what you're inside. Treesitter-driven, no LSP needed.
require("treesitter-context").setup({
  max_lines = 3,        -- cap the sticky header at 3 lines
  multiline_threshold = 1,
  trim_scope = "outer",
  mode = "cursor",
})

-- jump up to the context line (handy in a deeply nested body)
vim.keymap.set("n", "[x", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "Jump to context" })

-- <leader>uC = toggle the sticky context header
vim.keymap.set("n", "<leader>uC", "<cmd>TSContextToggle<CR>", { desc = "Toggle sticky context" })
