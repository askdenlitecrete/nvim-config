# Neovim config — from scratch, full-stack web

No distribution and **no plugin-manager framework** — no lazy.nvim, packer or
vim-plug. Plugins are plain `git` checkouts under `pack/core/start/`, Neovim's
own package mechanism (`:help packages`): every directory there is on the
runtimepath at startup. `lua/bootstrap.lua` runs `git clone` for missing ones
and provides `:PluginUpdate` / `:PluginStatus` / `:PluginLock` / `:PluginRestore`.
Every plugin is configured by hand, one feature per file in `lua/plugins/`.

This directory is a **git repo**. `plugins.lock` (committed JSON, name → commit)
is the reproducibility mechanism a plugin manager would give you: a fresh clone
checks out the locked commit, and `:PluginRestore` rolls a bad `:PluginUpdate`
back. `pack/` itself is `.gitignore`d — it's regenerated from `plugins.lock`.

## Layout

```
init.lua              core/* → bootstrap → each plugins/* module
plugins.lock          committed: every plugin pinned to an exact commit
lua/core/             options, keymaps, autocmds   (no plugins)
lua/bootstrap.lua     the plugin list + git clone/update/lock   (the only 3rd-party code)
lua/plugins/
  colorscheme  treesitter  tscontext  telescope  lazydev  lsp  mason-tools
  completion  lint  format  comment  motion  git  gittools  statusline
  explorer  terminal  trouble  search  harpoon  dap  testing  database
  http  web  ui  session  editing
pack/core/start/      the ~66 plugin clones (gitignored, safe to delete + re-clone)
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
| **LSP** | mason + mason-lspconfig + nvim-lspconfig (native `vim.lsp.enable`) | typescript-tools (TS/JS), eslint, html, cssls, tailwindcss, emmet, graphql, prismals, dockerls, docker-compose, jsonls, yamlls, sqlls, marksman, pyright, gopls, rust_analyzer, lua_ls, bashls |
| **Completion** | nvim-cmp, LuaSnip, lspkind, cmp-cmdline, signature-help, lazydev | `:`/`/` cmdline completion; dadbod completion in SQL; lazydev = full nvim-runtime API when editing this config |
| **Refactor** | grug-far.nvim, harpoon (v2) | project-wide find & replace in a buffer; pin & jump between working-set files |
| **Format** | conform.nvim | prettier(d), stylua, shfmt, sql_formatter, gofmt, rustfmt — on save |
| **Lint** | nvim-lint | shellcheck, stylelint, ruff, markdownlint (JS/TS handled by eslint LSP) |
| **Treesitter** | + textobjects, context, ts-autotag, ts-context-commentstring | `vif`/`vaf`, sticky signature header, auto-close JSX tags, JSX-aware comments |
| **Debug** | nvim-dap, dap-ui, dap-virtual-text | js-debug-adapter (Node/Chrome), debugpy (`:MasonInstall debugpy`, needs `uv`) |
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
| `<leader>u` | ui toggles | `<leader>r` | refactor / replace |
| `<leader>m` | marks (harpoon) | | |

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
| `<leader>ma` add harpoon mark · `<leader>mm` menu · `<leader>m1`..`m4` jump |
| `<leader>rr` project find & replace (grug-far) · `<leader>rw` on word under cursor |

### LSP (once a server attaches)
| key | action |
|---|---|
| `gd` `gr` `gI` `gy` | definition / references / implementation / type def |
| `K` hover · `<leader>rn` rename · `<leader>ca` code action |
| `<leader>cf` format · `<leader>cd` line diagnostics · `<leader>ch` toggle inlay hints |
| `<leader>cs` / `<leader>cS` | document / workspace symbols |
| `[d` / `]d` diagnostics · `[f` / `]f` functions · `[c` / `]c` classes · `[x` jump to context |

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
| `:PluginStatus` | list every plugin + its git ref (flags any AHEAD of the lock) |
| `:PluginUpdate` | `git pull --ff-only` each (pinned version tags skipped) |
| `:PluginLock` | write every plugin's exact commit to `plugins.lock` — **commit it** |
| `:PluginRestore` | check every plugin back out to `plugins.lock` (undo a bad update) |
| `:Mason` | install/remove servers, linters, formatters, debug adapters |

**Update flow:** `:PluginUpdate` → restart → `:TSUpdate` → test → `:PluginLock` →
`git commit plugins.lock`. If an update breaks something: `:PluginRestore`.

**Add:** a line in `PLUGINS` (`lua/bootstrap.lua`) → restart → a `lua/plugins/<name>.lua`
doing `require("<name>").setup{…}` → a line in `init.lua`'s loop → `:PluginLock`.
**Remove:** delete those three, then `rm -rf pack/core/start/<name>` → `:PluginLock`.

### Version notes (`lua/bootstrap.lua`)
Runs on **Neovim 0.12** (Homebrew). LSP uses the native `vim.lsp.config` /
`vim.lsp.enable` path via mason-lspconfig's `automatic_enable`. Only two refs are
pinned to a branch: `nvim-treesitter` → `master` (the `main` rewrite needs manual
parser management), `telescope.nvim` → `0.1.x`, `neo-tree.nvim` → `v3.x`. A
future job: migrate treesitter to `main`.

## This machine (WSL2 / Debian trixie)

- **Neovim**: official tarball at `~/.local/bin/nvim` → `~/.local/opt/nvim-0.12.5`
  (that dir is first on `$PATH`). Upgrade = extract the new
  `nvim-linux-x86_64.tar.gz` to `~/.local/opt/nvim-<ver>` and repoint the
  `~/.local/opt/nvim` symlink. Homebrew's 0.12.5 and apt's 0.10.4
  (`/usr/bin/nvim`) sit behind it as fallbacks.
- **Clipboard**: `wl-clipboard` is installed (`wl-copy`), so `y`/`p` share the
  Windows clipboard through WSLg.
- **Nerd Font**: set one in the Windows terminal or icons show as boxes.
- **CLI tools** (Homebrew): `fd` `lazygit` `delta` `bat` `eza` `zoxide` `atuin`
  `direnv` `just` `lazydocker` `watchexec` `difftastic` `uv`. Shell wiring is in
  `~/.zshrc` (`# CLI TOOLS` block).
- **Python tooling** (`debugpy`, `yamllint`, `ruff`): `uv` is installed, so
  `:MasonInstall debugpy yamllint ruff` now works.

Old config kept as `init.vim.bak`.
