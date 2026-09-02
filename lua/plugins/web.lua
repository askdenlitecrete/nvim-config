-- Web-specific editing helpers.

-- Auto-close and auto-rename HTML/JSX/Vue tags: type `<div>` and the `</div>`
-- appears; edit one tag name and the pair updates.
require("nvim-ts-autotag").setup({
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = false,
  },
})

-- Colour swatches inline for #rrggbb, rgb(), hsl(), Tailwind classes, CSS vars.
require("colorizer").setup({
  filetypes = {
    "css", "scss", "less", "html", "javascript", "javascriptreact",
    "typescript", "typescriptreact", "vue", "svelte", "astro",
    "lua", "conf", "tmux",
  },
  user_default_options = {
    css = true,
    tailwind = "both", -- highlight tailwind class names and show the colour
    names = false,     -- don't colour the word "red" etc.
    mode = "background",
  },
})
vim.keymap.set("n", "<leader>uc", "<cmd>ColorizerToggle<CR>", { desc = "Toggle colour swatches" })

-- package.json: show installed vs latest npm versions inline, and change them.
require("package-info").setup({
  package_manager = "npm",
  hide_up_to_date = true,
})
local pi = require("package-info")
vim.keymap.set("n", "<leader>ns", pi.show, { desc = "npm: show versions" })
vim.keymap.set("n", "<leader>nu", pi.update, { desc = "npm: update package on line" })
vim.keymap.set("n", "<leader>ni", pi.install, { desc = "npm: install new package" })
vim.keymap.set("n", "<leader>nd", pi.delete, { desc = "npm: delete package on line" })
vim.keymap.set("n", "<leader>nc", pi.change_version, { desc = "npm: change package version" })
