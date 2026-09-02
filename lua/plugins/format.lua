-- Format-on-save with real formatters (stylua, prettier, ruff, shfmt...).
-- conform.nvim runs the right tool per filetype and falls back to the LSP
-- formatter when none is configured.
--
-- Install formatters with :Mason.  Toggle with :FormatToggle (! = this buffer).
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },
    ["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    scss = { "prettierd", "prettier", stop_after_first = true },
    less = { "prettierd", "prettier", stop_after_first = true },
    vue = { "prettierd", "prettier", stop_after_first = true },
    svelte = { "prettierd", "prettier", stop_after_first = true },
    astro = { "prettierd", "prettier", stop_after_first = true },
    graphql = { "prettierd", "prettier", stop_after_first = true },
    sql = { "sql_formatter" },
    go = { "gofmt" },
    rust = { "rustfmt" },
    ["_"] = { "trim_whitespace" }, -- fallback for filetypes with no formatter
  },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer/selection" })

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    vim.b.disable_autoformat = not vim.b.disable_autoformat
  else
    vim.g.disable_autoformat = not vim.g.disable_autoformat
  end
  local off = args.bang and vim.b.disable_autoformat or vim.g.disable_autoformat
  vim.notify("Autoformat " .. (off and "OFF" or "ON") .. (args.bang and " (buffer)" or ""))
end, { bang = true, desc = "Toggle format-on-save (! = this buffer only)" })
