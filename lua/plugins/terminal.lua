-- toggleterm: run a shell (or a REPL, or lazygit) in a split without leaving
-- Neovim -- compile, run tests, poke at things, jump straight back to the code.
--
--   <C-\>        toggle the last terminal (horizontal)
--   <leader>tf   float      <leader>th  horizontal      <leader>tv  vertical
--   <leader>tr   run the current file
--   <leader>tg   lazygit (only if lazygit is installed)
--   1<C-\>       terminal #1  (any count = a separate numbered terminal)
-- Inside a terminal:  <Esc> / jk -> normal mode,  <C-h/j/k/l> -> switch window
require("toggleterm").setup({
  open_mapping = [[<C-\>]],
  direction = "horizontal",
  start_in_insert = true,
  persist_size = true,
  persist_mode = false,
  float_opts = { border = "curved" },
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return math.floor(vim.o.columns * 0.4)
    end
  end,
})

local map = vim.keymap.set
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Terminal: float" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Terminal: horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", { desc = "Terminal: vertical" })

-- Terminal-mode conveniences for every toggleterm buffer.
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*toggleterm#*",
  callback = function()
    local o = { buffer = 0, silent = true }
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], o)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], o)
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], o)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], o)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], o)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], o)
  end,
})

-- lazygit in a full-screen floating terminal, if it's on PATH.
if vim.fn.executable("lazygit") == 1 then
  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new({
    cmd = "lazygit",
    direction = "float",
    float_opts = { border = "curved" },
    hidden = true,
  })
  vim.keymap.set("n", "<leader>tg", function() lazygit:toggle() end, { desc = "Terminal: lazygit" })
end

-- Send the current file to a terminal and run it (language-aware).
vim.api.nvim_create_user_command("Run", function()
  local runners = {
    python = "python3",
    lua = "lua",
    sh = "bash",
    bash = "bash",
    javascript = "node",
    go = "go run",
  }
  local runner = runners[vim.bo.filetype]
  if not runner then
    vim.notify("No runner for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end
  vim.cmd("write")
  require("toggleterm").exec(runner .. " " .. vim.fn.shellescape(vim.fn.expand("%:p")))
end, { desc = "Run the current file in a terminal" })
vim.keymap.set("n", "<leader>tr", "<cmd>Run<CR>", { desc = "Terminal: run current file" })
