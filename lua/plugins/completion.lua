-- The completion popup. nvim-cmp merges several sources into one menu:
--   nvim_lsp                language-server suggestions
--   nvim_lsp_signature_help function signature while typing arguments
--   luasnip                 snippet expansions (friendly-snippets = big default set)
--   buffer                  words already open in a buffer
--   path                    filesystem paths
-- Plus `:` and `/` command-line completion via cmp-cmdline.
local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

require("luasnip.loaders.from_vscode").lazy_load() -- friendly-snippets

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  completion = { completeopt = "menu,menuone,noinsert" },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      ellipsis_char = "…",
      menu = {
        nvim_lsp = "[LSP]",
        luasnip = "[snip]",
        buffer = "[buf]",
        path = "[path]",
        nvim_lsp_signature_help = "[sig]",
      },
    }),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lsp_signature_help" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- Query databases: dadbod completion in SQL buffers (see plugins/database.lua).
cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
  sources = cmp.config.sources({
    { name = "vim-dadbod-completion" },
    { name = "buffer" },
  }),
})

-- `/` and `?` search completion from the current buffer.
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = "buffer" } },
})

-- `:` command completion (commands + paths).
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
  matching = { disallow_symbol_nonprefix_matching = false },
})
