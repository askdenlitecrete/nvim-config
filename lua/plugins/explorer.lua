-- Neo-tree: a file-explorer sidebar (also does buffers and a git-status view).
--   <leader>e   toggle        <leader>o   focus        <leader>ge  git status
-- Inside the tree: <CR> open, a add, d delete, r rename, x cut, p paste,
--                  H toggle hidden, ? help

-- WSL: the OS-level (libuv/inotify) file watcher gets no events on the Windows
-- drive mounts -- DrvFs under /mnt/c, /mnt/d, ... doesn't deliver them -- and
-- arming it there makes `nvim .` under /mnt hang instead of opening the tree.
-- Keep the watcher on real Linux paths; under /mnt fall back to
-- enable_refresh_on_write plus the FocusGained `checktime` autocmd in core.
-- Decided once from the startup cwd (neo-tree merges its config lazily on the
-- first open). If you start nvim on a Linux path and only later cd into /mnt,
-- restart nvim there -- toggling it live isn't worth the complexity.
local function in_windows_mount(path)
  return vim.fs.normalize(path or vim.fn.getcwd()):match("^/mnt/") ~= nil
end

require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  filesystem = {
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = not in_windows_mount(), -- off under /mnt/ (see above)
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
