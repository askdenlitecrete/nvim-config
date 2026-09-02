-- catppuccin colour scheme.
require("catppuccin").setup({
  flavour = "mocha", -- latte | frappe | macchiato | mocha
  background = { light = "latte", dark = "mocha" },
  transparent_background = true, -- inherit the terminal/tmux bg (#1e1e2e), so no edge rim

  integrations = {
    cmp = true,
    gitsigns = true,
    neotree = true,
    treesitter = true,
    native_lsp = { enabled = true },
    telescope = { enabled = true },
    which_key = true,
    indent_blankline = { enabled = true },
    mason = true,
  },
})

vim.cmd.colorscheme("catppuccin")
