-- kulala.nvim: a REST client. Open a `.http` file, put the cursor on a request,
-- and send it -- responses render in a split. Supports variables, environments
-- (http-client.env.json), GraphQL and gRPC.
--
--   ### separates requests in a .http file, e.g.
--     GET https://api.example.com/users
--     Authorization: Bearer {{token}}
--
--   <leader>Rs  send request under cursor    <leader>Rr  replay last
--   <leader>Ra  send all in file             <leader>Re  pick environment
--   <leader>Rc  copy as curl                 [r / ]r     jump between requests
require("kulala").setup({
  display_mode = "split",
  split_direction = "vertical",
  default_view = "body",
  debug = false,
  -- Don't let kulala git-clone + compile its own tree-sitter parser on
  -- startup (needs the tree-sitter CLI). Its built-in parser is fine.
  treesitter = { enable = false },
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("cfg_kulala", { clear = true }),
  pattern = { "http", "rest" },
  callback = function()
    local k = require("kulala")
    local o = { buffer = true }
    vim.keymap.set("n", "<leader>Rs", k.run, vim.tbl_extend("force", o, { desc = "REST: send request" }))
    vim.keymap.set("n", "<leader>Rr", k.replay, vim.tbl_extend("force", o, { desc = "REST: replay last" }))
    vim.keymap.set("n", "<leader>Ra", k.run_all, vim.tbl_extend("force", o, { desc = "REST: send all" }))
    vim.keymap.set("n", "<leader>Re", k.set_selected_env, vim.tbl_extend("force", o, { desc = "REST: pick environment" }))
    vim.keymap.set("n", "<leader>Rc", k.copy, vim.tbl_extend("force", o, { desc = "REST: copy as curl" }))
    vim.keymap.set("n", "]r", k.jump_next, vim.tbl_extend("force", o, { desc = "Next request" }))
    vim.keymap.set("n", "[r", k.jump_prev, vim.tbl_extend("force", o, { desc = "Previous request" }))
  end,
})
