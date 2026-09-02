-- Editor behaviour. This is the Lua translation of the ~/.vimrc shown in MIT's
-- "Missing Semester" Vim lecture, with a few widely-used extras.

local opt = vim.opt

-- Line numbers -------------------------------------------------------------
opt.number = true
opt.relativenumber = true -- jump N lines with Nj / Nk

-- Indentation: 4 spaces, no hard tabs -----------------------------------
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Line wrapping ---------------------------------------------------------
opt.wrap = true
opt.linebreak = true   -- break at word boundaries, not mid-word
opt.breakindent = true -- keep wrapped lines indented

-- Appearance ----------------------------------------------------------------
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes" -- always shown, so the buffer doesn't jump sideways
opt.scrolloff = 8      -- keep context around the cursor
opt.sidescrolloff = 8
opt.showmode = false   -- the statusline already shows the mode
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Search (Missing Semester: case-insensitive unless you type a capital) --
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Splits open down / right, like a tiling WM ---------------------------
opt.splitright = true
opt.splitbelow = true

-- Files & buffers -----------------------------------------------------------
opt.exrc = true        -- load a project-local .nvim.lua / .nvimrc (Neovim
                       -- prompts once to trust it; secure by default on 0.10+)
opt.hidden = true      -- switch away from a modified buffer without saving
opt.swapfile = false
opt.backup = false
opt.undofile = true    -- undo history survives closing the file
opt.updatetime = 250   -- drives CursorHold (LSP hover, gitsigns)
opt.timeoutlen = 400   -- ms to wait for a multi-key mapping

-- System integration ------------------------------------------------------
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- y/p share the OS clipboard
                              -- (WSL: needs win32yank.exe or wl-clipboard on PATH)

-- Completion menu ---------------------------------------------------------
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12 -- cap the popup at 12 rows

-- Remote plugin providers ----------------------------------------------------
-- This config is pure Lua -- nothing here is a vimscript remote plugin, so the
-- perl/ruby/node/python3 host shims are dead weight that only surface as
-- :checkhealth warnings. Disable them explicitly.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

-- Don't let programs rewrite the terminal/tab title (handled by the terminal).
opt.title = false
