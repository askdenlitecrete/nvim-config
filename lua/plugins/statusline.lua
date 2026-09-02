-- Statusline + winbar.
--   statusline: mode, git branch/diff, file, diagnostics, filetype, position
--   winbar:     nvim-navic breadcrumbs (Class > method > block) for the file
local navic = require("nvim-navic")

require("lualine").setup({
  options = {
    theme = "auto", -- follows the active colorscheme (catppuccin ships no plain "catppuccin" theme)
    globalstatus = true,
    component_separators = "|",
    section_separators = "",
    disabled_filetypes = { winbar = { "neo-tree", "dbui", "dap-repl", "dapui_scopes", "dapui_watches" } },
  },
  sections = {
    lualine_b = { "branch", "diff" },
    lualine_c = { { "filename", path = 1 } }, -- path relative to cwd
    lualine_x = {
      { "diagnostics", sources = { "nvim_diagnostic" } }, -- covers LSP + nvim-lint
      "filetype",
    },
  },
  winbar = {
    lualine_c = {
      {
        function() return navic.get_location() end,
        cond = function() return navic.is_available() end,
      },
    },
  },
  inactive_winbar = {
    lualine_c = { { "filename", path = 1 } },
  },
})
