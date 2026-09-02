-- Telescope: fuzzy pickers for files, project-wide text, buffers, help and LSP
-- results. The modern stand-in for ctrlp.vim from the Missing Semester lecture.
local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    path_display = { "truncate" },
    sorting_strategy = "ascending",
    layout_config = { prompt_position = "top" },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<Esc>"] = actions.close, -- one Esc closes instead of dropping to normal mode
      },
    },
  },
  pickers = {
    find_files = { hidden = true },
    buffers = { sort_lastused = true, ignore_current_buffer = true },
  },
  extensions = {
    ["ui-select"] = { require("telescope.themes").get_dropdown({}) },
  },
})

pcall(telescope.load_extension, "fzf")       -- native sorter, built by bootstrap.lua
pcall(telescope.load_extension, "ui-select") -- route vim.ui.select (code actions) through Telescope

local map = vim.keymap.set
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader><space>", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Grep project" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>", { desc = "Grep word under cursor" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Keymaps" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })
map("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search in buffer" })
map("n", "<leader>f/", "<cmd>Telescope resume<CR>", { desc = "Resume last picker" })
