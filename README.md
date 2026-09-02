# Neovim config — from scratch, full-stack web

No distribution and **no plugin-manager framework** — no lazy.nvim, packer or
vim-plug. Plugins are plain `git` checkouts under `pack/core/start/`, Neovim's
own package mechanism (`:help packages`): every directory there is on the
runtimepath at startup. `lua/bootstrap.lua` runs `git clone` for missing ones
and provides `:PluginUpdate` / `:PluginStatus`. Every plugin is configured by
hand, one feature per file in `lua/plugins/`.

## Layout

```
init.lua              core/* → bootstrap → each plugins/* module
lua/core/             options, keymaps, autocmds   (no plugins)
lua/bootstrap.lua     the plugin list + git clone/update   (the only 3rd-party code)
lua/plugins/
  colorscheme  treesitter  telescope  lsp  mason-tools  completion
  lint  format  comment  motion  git  gittools  statusline  explorer
  terminal  trouble  dap  testing  database  http  web  ui  session  editing
pack/core/start/      the ~60 plugin clones (safe to delete + re-clone)
```

## Missing-Semester lecture → this config

| Lecture pick | Here |
|---|---|
| custom `~/.vimrc` | `lua/core/options.lua` + `keymaps.lua` |
| `ctrlp.vim` fuzzy open | `telescope.nvim` |
| `ale` async lint + fix | `eslint`/other LSPs + `nvim-lint` + `conform.nvim` |
| `vim-easymotion` | `flash.nvim` |
| `syntax on` | `nvim-treesitter` |
| "one plugin at a time, no distro" | one file per plugin, plain `git` clones |

## Full-stack toolset

| Area | Plugins | Notes |
|---|---|---|
| **LSP** | mason + mason-lspconfig + nvim-lspconfig | ts_ls, eslint, html, cssls, tailwindcss, emmet, graphql, prismals, dockerls, docker-compose, jsonls, yamlls, sqlls, marksman, pyright, gopls, rust_analyzer, lua_ls, bashls |
| **Completion** | nvim-cmp, LuaSnip, lspkind, cmp-cmdline, signature-help | `:`/`/` cmdline completion; dadbod completion in SQL |
| **Format** | conform.nvim | prettier(d), stylua, shfmt, sql_formatter, gofmt, rustfmt — on save |
| **Lint** | nvim-lint | shellcheck, stylelint, ruff, markdownlint (JS/TS handled by eslint LSP) |
| **Treesitter** | + textobjects, ts-autotag, ts-context-commentstring | `vif`/`vaf`, auto-close JSX tags, JSX-aware comments |
| **Debug** | nvim-dap, dap-ui, dap-virtual-text | js-debug-adapter (Node/Chrome), debugpy (needs pip) |
| **Test** | neotest + vitest / jest / playwright / python | signs in the gutter, debug a test with DAP |
| **Git** | gitsigns, vim-fugitive, diffview.nvim | gutter + full status/commit + diff & history UI |
| **DB** | vim-dadbod (+ ui, + completion) | Postgres/MySQL/SQLite; picks up `$DATABASE_URL` |
| **HTTP** | kulala.nvim | send requests from `.http` files |
| **Web extras** | nvim-colorizer, package-info.nvim | colour swatches, npm versions in package.json |
| **Navigation** | trouble.nvim, todo-comments, nvim-navic, telescope-ui-select | diagnostics panel, breadcrumbs in winbar, code actions in Telescope |
| **Project** | project.nvim, persistence.nvim | auto project-root, per-directory sessions |
| **Reading** | render-markdown.nvim | in-buffer markdown rendering |

## First run

`nvim` clones every plugin. Then, opening code files for the first time:
- **Mason** installs the language servers/tools in the background — watch `:Mason`.
  (Big binaries like `gopls`, `marksman` can take a minute.)
- **Treesitter** compiles parsers on demand — `:TSUpdate` fetches the full set.

Restart once it settles. Verify with `:checkhealth`.

## Key bindings

Leader is `<Space>`. `jk` leaves insert mode. `ZZ` saves-and-quits.
Pause after `<leader>` to see the menu (which-key). Group prefixes:

| prefix | area | prefix | area |
|---|---|---|---|
| `<leader>f` | find (Telescope) | `<leader>d` | debug (DAP) |
| `<leader>c` | code / LSP | `<leader>T` | test (neotest) |
| `<leader>g` | git | `<leader>x` | diagnostics / lists (Trouble) |
| `<leader>h` | git hunk | `<leader>D` | database |
| `<leader>t` | terminal | `<leader>R` | REST client |
| `<leader>s` | split | `<leader>n` | npm / package.json |
| `<leader>b` | buffer | `<leader>P` | project / session |
| `<leader>u` | ui toggles | `<leader>r` | rename / refactor |

### Everyday
| key | action |
|---|---|
| `<leader>ff` / `<leader><space>` | find files |
| `<leader>fg` | live grep · `<leader>fw` grep word · `<leader>fs` in-buffer |
| `<leader>fr` recent · `<leader>fb` buffers · `<leader>fp` projects · `<leader>ft` TODOs |
| `<leader>e` | file explorer · `<leader>o` focus it |
| `<C-h/j/k/l>` | move between splits · `<C-arrows>` resize |
| `<S-h>` / `<S-l>` | prev / next buffer · `<leader>bd` close buffer |
| `s` + 2 chars | flash jump · `S` treesitter select |
| `<C-\>` | terminal · `<leader>tr` run current file · `<leader>tg` lazygit |
| `gcc` / `gc{motion}` | toggle comment (JSX-aware) |

### LSP (once a server attaches)
| key | action |
|---|---|
| `gd` `gr` `gI` `gy` | definition / references / implementation / type def |
| `K` hover · `<leader>rn` rename · `<leader>ca` code action |
| `<leader>cf` format · `<leader>cd` line diagnostics · `<leader>ch` toggle inlay hints |
| `<leader>cs` / `<leader>cS` | document / workspace symbols |
| `[d` / `]d` diagnostics · `[f` / `]f` functions · `[c` / `]c` classes |

### Git
| key | action |
|---|---|
| `]h` / `[h` hunk · `<leader>hs` stage · `<leader>hr` reset · `<leader>hp` preview · `<leader>hb` blame |
| `<leader>gg` fugitive status · `<leader>gc` commit · `<leader>gp` push |
| `<leader>gd` diffview · `<leader>gh` file history · `<leader>ge` git tree |

### Debug
| key | action |
|---|---|
| `<leader>db` breakpoint · `<leader>dB` conditional · `<leader>dc` / `F5` continue |
| `<leader>di`/`F11` into · `<leader>do`/`F10` over · `<leader>dO`/`F12` out |
| `<leader>du` toggle UI · `<leader>dr` REPL · `<leader>de` eval · `<leader>dt` terminate |

### Test
| key | action |
|---|---|
| `<leader>Tr` nearest · `<leader>Tf` file · `<leader>Ta` suite · `<leader>Tl` rerun last |
| `<leader>Ts` summary · `<leader>To` output · `<leader>Tw` watch · `<leader>Td` debug nearest |
| `]n` / `[n` | next / previous failed test |

### Trouble / diagnostics
| key | action |
|---|---|
| `<leader>xx` workspace diagnostics · `<leader>xX` buffer · `<leader>xs` symbols outline |
| `<leader>xl` LSP refs · `<leader>xq` quickfix · `<leader>xt` TODOs |

### Database / REST
| key | action |
|---|---|
| `<leader>Du` DB explorer · `<leader>Df` find DB buffer · `<leader>S` (in `.sql`) run query |
| `<leader>Rs` send request · `<leader>Rr` replay · `<leader>Re` pick env  (in `.http`) |

## Managing plugins

| command | effect |
|---|---|
| `:PluginStatus` | list every plugin + its git ref |
| `:PluginUpdate` | `git pull --ff-only` each (pinned tags skipped) |
| `:Mason` | install/remove servers, linters, formatters, debug adapters |

**Add:** a line in `PLUGINS` (`lua/bootstrap.lua`) → restart → a `lua/plugins/<name>.lua`
doing `require("<name>").setup{…}` → a line in `init.lua`'s loop.
**Remove:** delete those three, then `rm -rf pack/core/start/<name>`.
**By hand, no bootstrap:** `git clone --depth=1 <url> ~/.config/nvim/pack/core/start/<name>`.

### Pinned for Neovim 0.10.4 (`lua/bootstrap.lua`)
`nvim-lspconfig` → `v1.8.0`, `mason`/`mason-lspconfig` → `1.x`, `nvim-treesitter`
→ `master`. After upgrading Neovim to 0.11+, drop those `ref =` fields and
`:PluginUpdate`.

## This machine (WSL2 / Debian trixie)

- **Clipboard** (`y`/`p` with Windows): `sudo apt install wl-clipboard`, or put
  `win32yank.exe` on the Windows PATH.
- **Nerd Font**: set one in the Windows terminal or icons show as boxes.
- **Python tooling** (`debugpy`, `yamllint`, `ruff`): this box's `python3` has no
  pip — `sudo apt install python3-pip python3-venv`, then
  `:MasonInstall debugpy yamllint ruff`.
- **Optional**: `lazygit` (for `<leader>tg`).

Old config kept as `init.vim.bak`.
