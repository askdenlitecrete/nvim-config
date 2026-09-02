-- vim-dadbod + dadbod-ui: connect to Postgres / MySQL / SQLite / etc., browse
-- schema, write and run queries, all inside Neovim. dadbod-completion feeds
-- table/column names into nvim-cmp for `sql` buffers (wired in completion.lua).
--
--   <leader>Du   toggle the DB explorer sidebar
--   <leader>Df   find/add a buffer connection
--   inside a .sql buffer:  <leader>S  run the query under the cursor
--
-- Add connections by exporting URLs in your shell, e.g.
--   export DATABASE_URL="postgres://user:pass@localhost:5432/mydb"
-- or set them permanently:
--   vim.g.dbs = { dev = "postgres://...", staging = "postgres://..." }
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1
vim.g.db_ui_win_position = "left"
vim.g.db_ui_winwidth = 32
vim.g.db_ui_execute_on_save = 0 -- don't run the whole file every :w

-- Pick up a DATABASE_URL from the environment as a "dev" connection.
if vim.env.DATABASE_URL and vim.env.DATABASE_URL ~= "" then
  vim.g.dbs = vim.g.dbs or { dev = vim.env.DATABASE_URL }
end

local map = vim.keymap.set
map("n", "<leader>Du", "<cmd>DBUIToggle<CR>", { desc = "Database: toggle UI" })
map("n", "<leader>Df", "<cmd>DBUIFindBuffer<CR>", { desc = "Database: find buffer" })
map("n", "<leader>Dr", "<cmd>DBUIRenameBuffer<CR>", { desc = "Database: rename buffer" })
map("n", "<leader>Dl", "<cmd>DBUILastQueryInfo<CR>", { desc = "Database: last query info" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("cfg_dadbod_sql", { clear = true }),
  pattern = { "sql", "mysql", "plsql" },
  callback = function()
    vim.keymap.set("n", "<leader>S", "<Plug>(DBUI_ExecuteQuery)", { buffer = true, desc = "Run SQL query" })
    vim.keymap.set("v", "<leader>S", "<Plug>(DBUI_ExecuteQuery)", { buffer = true, desc = "Run selected SQL" })
    vim.opt_local.omnifunc = "vim_dadbod_completion#omni"
  end,
})
