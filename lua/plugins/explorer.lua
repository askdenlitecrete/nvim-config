-- Neo-tree: a file-explorer sidebar (also does buffers and a git-status view).
--   <leader>e   toggle        <leader>o   focus        <leader>ge  git status
-- Inside the tree: <CR> open, a add, d delete, r rename, x cut, p paste,
--                  H toggle hidden, ? help
require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  filesystem = {
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true, -- react to external file changes
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = true,
    },
  },
  window = {
    width = 32,
    mappings = { ["<space>"] = "none" }, -- keep <space> as leader inside the tree
  },
})

local map = vim.keymap.set
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "File explorer (toggle)" })
map("n", "<leader>o", "<cmd>Neotree focus<CR>", { desc = "File explorer (focus)" })
map("n", "<leader>ge", "<cmd>Neotree git_status<CR>", { desc = "Git status tree" })
