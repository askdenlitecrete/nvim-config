-- ~/.config/nvim/init.lua
--
-- Built from scratch. No plugin-manager framework (no lazy.nvim, no packer,
-- no vim-plug) and no distribution. Plugins are plain git checkouts under
--     ~/.config/nvim/pack/core/start/
-- which is Neovim's own built-in package mechanism (:help packages) -- Neovim
-- puts every directory there on the runtimepath at startup, nothing else
-- required. lua/bootstrap.lua just runs `git clone` for any that are missing.
--
-- Layout
--   lua/core/         editor behaviour, zero plugins
--   lua/bootstrap.lua clone missing plugins + :PluginUpdate / :PluginStatus
--   lua/plugins/      one file per feature, each configures ONE plugin
--
-- See README.md for the keymap cheatsheet and the Missing-Semester mapping.

require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Make sure every plugin listed in lua/bootstrap.lua is on disk (clones the
-- missing ones). Safe to delete this line if you'd rather `git clone` by hand.
require("bootstrap").ensure()

-- Configure each feature. Order matters only where noted.
for _, mod in ipairs({
  "plugins.colorscheme",
  "plugins.treesitter",
  "plugins.tscontext",   -- sticky signature header (treesitter-context)
  "plugins.telescope",   -- before lsp: LspAttach maps use telescope.builtin
  "plugins.lazydev",     -- before lsp: extends lua_ls / adds a cmp source
  "plugins.lsp",         -- sets up nvim-navic; before statusline
  "plugins.mason-tools",
  "plugins.completion",
  "plugins.minuet",     -- local-LLM ghost-text (after completion: reuses cmp/plenary)
  "plugins.lint",
  "plugins.format",
  "plugins.comment",
  "plugins.motion",
  "plugins.git",         -- before statusline: lualine's `diff` section reads gitsigns
  "plugins.gittools",
  "plugins.statusline",
  "plugins.explorer",
  "plugins.terminal",
  "plugins.trouble",
  "plugins.search",      -- grug-far project find & replace
  "plugins.harpoon",     -- pinned-file quick-nav
  "plugins.dap",
  "plugins.testing",
  "plugins.database",
  "plugins.http",
  "plugins.web",
  "plugins.ui",
  "plugins.session",
  "plugins.editing",     -- last: which-key group labels
}) do
  local ok, err = pcall(require, mod)
  if not ok then
    vim.schedule(function()
      vim.notify(("[%s] %s"):format(mod, err), vim.log.levels.ERROR)
    end)
  end
end
