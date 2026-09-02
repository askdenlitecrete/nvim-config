-- Core mappings. Plugin-specific keys live next to each plugin in lua/plugins/.
-- The leader is set here because it must exist before any plugin loads.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Exit insert mode without stretching for Esc (classic Missing Semester tip) --
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- <Esc> in normal mode clears search highlight ------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- File actions ------------------------------------------------------------
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>quitall<CR>", { desc = "Quit all" })
-- (save-and-quit is native `ZZ`; <leader>x is the Trouble prefix)

-- Move between splits with Ctrl + hjkl ----------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Resize splits with Ctrl + arrows -----------------------------------------
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Taller window" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shorter window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Narrower window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Wider window" })

-- Split creation --------------------------------------------------------
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalise splits" })

-- Buffer cycling --------------------------------------------------------
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Keep the cursor centred while navigating -------------------------------
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "J", "mzJ`z", { desc = "Join line (keep cursor)" })

-- Move the visual selection up / down ----------------------------------
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Re-indent without losing the selection --------------------------------
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Paste over a selection without overwriting the yank register ----------
map("x", "<leader>p", [["_dP]], { desc = "Paste (keep register)" })
