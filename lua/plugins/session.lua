-- project.nvim   detect the project root (.git, package.json, go.mod, ...) and
--                cd into it automatically; adds a Telescope `projects` picker.
-- persistence.nvim  save a session per project directory and restore it, so
--                reopening a repo brings back your windows, tabs and buffers.
--
--   <leader>Pr  restore session for this directory
--   <leader>Pl  restore the last session
--   <leader>Pd  stop saving the current session
--   <leader>fp  find projects (Telescope)
--
-- session-kit additions (see ~/.config/session-kit/README.md):
--   * bare `nvim` in a directory with a saved session auto-restores it -- no
--     <leader>Pr needed. Opening a file (`nvim foo.lua`), a directory
--     (`nvim .` -> that's neo-tree's job), a diff, or stdin skips the restore.
--   * <leader>bu  reopen the last closed buffer (browser Ctrl-Shift-T), cursor
--                 restored to where you left it. Repeatable.

-- project.nvim is unmaintained: its LSP root detection calls the deprecated
-- vim.lsp.buf_get_clients() on every buffer event (we enable the "lsp" method
-- below), which nags "... is deprecated. Run :checkhealth vim.deprecated".
-- Point that name at the current API, minus the deprecation shim, before the
-- plugin loads. Also future-proofs it for when Neovim removes the alias.
-- Remove this if project.nvim is ever patched or replaced.
if vim.lsp.buf_get_clients then
  vim.lsp.buf_get_clients = function(bufnr)
    return vim.lsp.get_clients({ bufnr = bufnr })
  end
end

require("project_nvim").setup({
  detection_methods = { "pattern", "lsp" },
  patterns = {
    ".git", "package.json", "pnpm-workspace.yaml", "turbo.json",
    "go.mod", "Cargo.toml", "pyproject.toml", "Makefile", ".root",
  },
})
pcall(function() require("telescope").load_extension("projects") end)
vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<CR>", { desc = "Find projects" })

require("persistence").setup()

-- persistence.nvim sets sessionoptions itself but leaves out localoptions, so a
-- restored split loses its per-window foldmethod / conceallevel / wrap. Add it
-- back without disturbing the rest of the list.
vim.opt.sessionoptions:append("localoptions")

local map = vim.keymap.set
map("n", "<leader>Pr", function() require("persistence").load() end, { desc = "Restore session (cwd)" })
map("n", "<leader>Pl", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
map("n", "<leader>Pd", function() require("persistence").stop() end, { desc = "Don't save this session" })

-- ---------------------------------------------------------------------------
-- Auto-restore the session on launch, browser-style.
-- ---------------------------------------------------------------------------
-- persistence.nvim already SAVES on exit; this makes RESTORE automatic for a
-- bare `nvim` started in a directory that has a saved session. Deliberately
-- only bare `nvim` -- `nvim <dir>` opens neo-tree (netrw hijack) as the sole
-- window, and sourcing a session under it trips neo-tree's
-- close_if_last_window and quits nvim mid-restore. For a directory, let
-- neo-tree do its job; use <leader>Pr if you actually want the session.
-- Opening a file, a diff, or reading stdin is likewise left untouched.
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("cfg_session_autorestore", { clear = true }),
  nested = true, -- let the sourced session fire its own FileType/BufRead autocmds
  callback = function()
    if vim.g.session_kit_no_autorestore then return end
    if #vim.api.nvim_list_uis() == 0 then return end -- headless (scripts, sessions-save)
    if vim.o.diff then return end
    if vim.g.read_from_stdin then return end
    if #vim.fn.argv() > 0 then return end -- a file or dir was named; don't hijack it
    if vim.bo.modified then return end    -- already typing in the scratch buffer

    -- don't auto-restore for $HOME or a scratch dir under /tmp: persistence.nvim
    -- (need = 1) writes a session for *any* directory you open a file in, and
    -- silently reviving a months-old buffer set when you just ran `nvim` in ~
    -- is worse than starting clean. Explicit <leader>Pr still works there.
    local cwd = vim.fs.normalize(vim.fn.getcwd())
    if cwd == vim.fs.normalize(vim.env.HOME) or cwd == "/tmp" or cwd:match("^/tmp/") then
      return
    end

    vim.schedule(function()
      local persistence = require("persistence")
      if vim.fn.filereadable(persistence.current()) == 1
        or vim.fn.filereadable(persistence.current({ branch = false })) == 1
      then
        pcall(persistence.load)
      end
    end)
  end,
})

-- ---------------------------------------------------------------------------
-- Reopen the last closed buffer  --  <leader>bu  (browser Ctrl-Shift-T)
-- ---------------------------------------------------------------------------
-- No plugin: a small stack fed by BufDelete. Ctrl-Shift-T itself is caught by
-- Windows Terminal for whole-tab restore, so nvim gets its own leader mapping.
local closed_stack = {}
local CLOSED_MAX = 25

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = vim.api.nvim_create_augroup("cfg_closed_buffers", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then return end
    local name = vim.api.nvim_buf_get_name(ev.buf)
    if name == "" or vim.fn.filereadable(name) == 0 then return end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lnum = (mark and mark[1] > 0) and mark[1] or 1
    if closed_stack[#closed_stack] and closed_stack[#closed_stack].file == name then
      closed_stack[#closed_stack].line = lnum
      return
    end
    closed_stack[#closed_stack + 1] = { file = name, line = lnum }
    if #closed_stack > CLOSED_MAX then table.remove(closed_stack, 1) end
  end,
})

map("n", "<leader>bu", function()
  local entry = table.remove(closed_stack)
  if not entry then
    vim.notify("session-kit: no closed buffer to reopen", vim.log.levels.INFO)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(entry.file))
  pcall(vim.api.nvim_win_set_cursor, 0, { math.max(entry.line, 1), 0 })
end, { desc = "Reopen last closed buffer" })
