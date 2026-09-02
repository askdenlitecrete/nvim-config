-- Commenting. Neovim 0.10 ships `gc`/`gcc`, but it can't switch comment syntax
-- based on cursor position -- which you need in JSX/TSX/Vue/Svelte, where a
-- comment is `//` in code but `{/* */}` inside markup. Comment.nvim +
-- nvim-ts-context-commentstring gets it right.
--
--   gcc      toggle line          gbc      toggle block
--   gc{motion} / gc (visual)      gcap = comment a paragraph
--   gcO / gco / gcA               add a comment above / below / at end of line
vim.g.skip_ts_context_commentstring_module = true
require("ts_context_commentstring").setup({ enable_autocmd = false })

require("Comment").setup({
  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})
