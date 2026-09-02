-- Small, single-purpose editing plugins + the which-key group labels.

-- Auto-close brackets / quotes, and add the closing pair after cmp confirms
-- a function name.
require("nvim-autopairs").setup({ check_ts = true })
do
  local ok, cmp = pcall(require, "cmp")
  if ok then
    cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
  end
end

-- Operate on surrounding pairs:
--   cs"'   change "..." -> '...'      ds(   delete surrounding ( )
--   ysiw]  wrap word in [ ]           S)    (visual) wrap selection in ( )
require("nvim-surround").setup({})

-- Vertical guide at each indent level.
require("ibl").setup({
  indent = { char = "│" },
  scope = { enabled = true, show_start = false, show_end = false },
})

-- After a pause mid-keystroke, a popup lists what each next key does, grouped:
require("which-key").setup({
  spec = {
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code / LSP" },
    { "<leader>d", group = "debug (DAP)" },
    { "<leader>f", group = "find (Telescope)" },
    { "<leader>g", group = "git" },
    { "<leader>h", group = "git hunk" },
    { "<leader>m", group = "marks (harpoon)" },
    { "<leader>n", group = "npm / package.json" },
    { "<leader>P", group = "project / session" },
    { "<leader>r", group = "refactor / replace" },
    { "<leader>R", group = "REST client" },
    { "<leader>s", group = "split" },
    { "<leader>t", group = "terminal" },
    { "<leader>T", group = "test (neotest)" },
    { "<leader>u", group = "ui toggles" },
    { "<leader>x", group = "diagnostics / lists (Trouble)" },
    { "<leader>D", group = "database" },
  },
})

-- vim-sleuth has no setup(): being on the runtimepath is enough. It detects
-- each file's indentation and overrides the 4-space default in options.lua.
