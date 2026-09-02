-- Treesitter: a real syntax tree for the buffer, driving highlighting,
-- indentation, structural selection and text objects. Replaces `syntax on`.
--
-- Parsers are C libraries compiled on demand. Run :TSUpdate after install to
-- fetch/compile the set below; `auto_install` grabs any others as you open them.
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    -- core
    "bash", "c", "diff", "lua", "luadoc", "vim", "vimdoc", "query",
    "markdown", "markdown_inline", "regex", "comment",
    -- web frontend
    "html", "css", "scss", "javascript", "typescript", "tsx", "jsdoc",
    "vue", "svelte", "astro", "styled",
    -- backend / data
    "python", "go", "gomod", "gosum", "rust", "sql", "graphql", "prisma",
    "json", "jsonc", "json5", "yaml", "toml", "http", "xml", "ini",
    -- infra / vcs
    "dockerfile", "gitcommit", "gitignore", "git_config", "git_rebase",
    "terraform", "hcl",
  },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true, disable = { "yaml" } }, -- ts yaml indent is fussy
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>",
      node_incremental = "<C-space>",
      node_decremental = "<bs>",
      scope_incremental = "<C-s>",
    },
  },
  -- nvim-treesitter-textobjects
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer", -- an argument
        ["ia"] = "@parameter.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["a/"] = "@comment.outer",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
      goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
    },
    swap = {
      enable = true,
      swap_next = { ["<leader>cx"] = "@parameter.inner" }, -- swap arg with next
      swap_previous = { ["<leader>cX"] = "@parameter.inner" },
    },
  },
})
