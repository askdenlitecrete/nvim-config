-- Statusline + winbar.
--   statusline: mode, git branch/diff, file, diagnostics, filetype, position
--   winbar:     nvim-navic breadcrumbs (Class > method > block) for the file
local navic = require("nvim-navic")

-- lualine's "filename" component prints a terminal buffer's raw name
-- (term://<cwd>//<pid>:<shell>;#toggleterm#<n>). Show a clean label instead.
local function filename_fmt(name)
  if vim.bo.buftype ~= "terminal" then
    return name
  end
  local bufname = vim.api.nvim_buf_get_name(0)
  local cmd = bufname:match("//%d+:([^;]+)") or "terminal"
  local id = bufname:match("#toggleterm#(%d+)")
  return "  " .. vim.fn.fnamemodify(cmd, ":t") .. (id and ("  toggleterm " .. id) or "")
end

require("lualine").setup({
  options = {
    theme = "auto", -- follows the active colorscheme (catppuccin ships no plain "catppuccin" theme)
    globalstatus = true,
    component_separators = "|",
    section_separators = "",
    disabled_filetypes = {
      winbar = { "neo-tree", "dbui", "dap-repl", "dapui_scopes", "dapui_watches" },
    },
  },
  sections = {
    lualine_b = { "branch", "diff" },
    lualine_c = { { "filename", path = 1, fmt = filename_fmt } }, -- path relative to cwd
    lualine_x = {
      { "diagnostics", sources = { "nvim_diagnostic" } }, -- covers LSP + nvim-lint
      "filetype",
    },
  },
  inactive_sections = {
    lualine_c = { { "filename", path = 1, fmt = filename_fmt } }, -- same clean terminal label
    lualine_x = { "location" },
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
    -- no winbar on any terminal window (toggleterm or plain :terminal) --
    -- there's nothing structural to show for a shell session
    lualine_c = {
      {
        "filename",
        path = 1,
        fmt = filename_fmt,
        cond = function() return vim.bo.buftype ~= "terminal" end,
      },
    },
  },
})
