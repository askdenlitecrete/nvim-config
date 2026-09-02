-- lazydev.nvim: makes lua_ls actually understand *this config* -- the Neovim
-- runtime API, `vim.*`, `vim.uv`, and every plugin under pack/ -- so editing
-- lua/plugins/*.lua gets real completion and go-to-definition instead of
-- "undefined global `vim`". Only attaches in Lua buffers inside a nvim config.
require("lazydev").setup({
  library = {
    -- load luvit types when `vim.uv` is referenced
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

-- Feed lazydev's completions into nvim-cmp (see lua/plugins/completion.lua,
-- which lists { name = "lazydev" } as a source).
