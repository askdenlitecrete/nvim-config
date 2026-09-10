-- Small automatic behaviours. Nothing here depends on a plugin.

local augroup = function(name) return vim.api.nvim_create_augroup("cfg_" .. name, { clear = true }) end
local autocmd = vim.api.nvim_create_autocmd

-- Flash the text you just yanked.
autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Strip trailing whitespace on save (formatters handle the rest per-filetype).
autocmd("BufWritePre", {
  group = augroup("trim_whitespace"),
  pattern = "*",
  callback = function()
    if not vim.bo.modifiable or vim.bo.readonly then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Reopen a file at the line you left it on.
autocmd("BufReadPost", {
  group = augroup("last_location"),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Refresh buffers changed on disk (git checkout, a restored tmux session, a
-- formatter run in another pane) when focus or a terminal returns to nvim.
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("autoread"),
  callback = function()
    if vim.o.buftype == "" then vim.cmd("checktime") end
  end,
})

-- In throwaway windows, `q` closes.
autocmd("FileType", {
  group = augroup("quick_close"),
  pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "startuptime", "query" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
  end,
})

-- Don't continue comment leaders onto the next line when you press o/O.
autocmd("FileType", {
  group = augroup("no_auto_comment"),
  callback = function()
    vim.opt_local.formatoptions:remove({ "o", "r" })
  end,
})
