-- The only place third-party code enters this config. Each entry is a git
-- repository that gets cloned verbatim into pack/core/start/ -- Neovim loads
-- everything in that directory automatically (:help packages). There is no
-- plugin manager: no lazy-loading graph, no lockfile, no DSL. Just `git`.
--
--   :PluginStatus   list plugins and their checked-out ref
--   :PluginUpdate   `git pull --ff-only` every plugin (skips pinned tags)
--
-- To add a plugin:    add a line below, restart nvim (it clones on start),
--                     then add a lua/plugins/<name>.lua that configures it.
-- To remove one:      delete its line, its lua/plugins file, and
--                     `rm -rf pack/core/start/<name>`.

local M = {}

-- { url [, ref = "branch-or-tag"] [, name = "dir override"] }.
-- ref is pinned and never auto-updated by :PluginUpdate.
local PLUGINS = {
  -- colours  (repo is catppuccin/nvim -> force a sane directory name)
  { "https://github.com/catppuccin/nvim", name = "catppuccin" },
  -- shared lua libraries
  { "https://github.com/nvim-lua/plenary.nvim" },
  { "https://github.com/MunifTanjim/nui.nvim" },
  { "https://github.com/nvim-tree/nvim-web-devicons" },
  -- syntax tree
  { "https://github.com/nvim-treesitter/nvim-treesitter", ref = "master" }, -- `main` needs nvim 0.11+
  -- fuzzy finder  (modern ctrlp)
  { "https://github.com/nvim-telescope/telescope.nvim", ref = "0.1.x" },
  { "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  -- LSP  (pinned: this box runs nvim 0.10.4)
  { "https://github.com/neovim/nvim-lspconfig", ref = "v1.8.0" },
  { "https://github.com/williamboman/mason.nvim", ref = "v1.11.0" },
  { "https://github.com/williamboman/mason-lspconfig.nvim", ref = "v1.32.0" },
  -- completion
  { "https://github.com/hrsh7th/nvim-cmp" },
  { "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { "https://github.com/hrsh7th/cmp-buffer" },
  { "https://github.com/hrsh7th/cmp-path" },
  { "https://github.com/L3MON4D3/LuaSnip" },
  { "https://github.com/saadparwaiz1/cmp_luasnip" },
  { "https://github.com/rafamadriz/friendly-snippets" },
  -- lint + format  (modern ALE)
  { "https://github.com/mfussenegger/nvim-lint" },
  { "https://github.com/stevearc/conform.nvim" },
  -- motion  (modern easymotion)
  { "https://github.com/folke/flash.nvim" },
  -- ui
  { "https://github.com/nvim-lualine/lualine.nvim" },
  { "https://github.com/lewis6991/gitsigns.nvim" },
  { "https://github.com/nvim-neo-tree/neo-tree.nvim", ref = "v3.x" },
  { "https://github.com/akinsho/toggleterm.nvim" },
  -- editing
  { "https://github.com/windwp/nvim-autopairs" },
  { "https://github.com/kylechui/nvim-surround" },
  { "https://github.com/folke/which-key.nvim" },
  { "https://github.com/lukas-reineke/indent-blankline.nvim" },
  { "https://github.com/tpope/vim-sleuth" },

  -- ============ full-stack web additions ============

  -- treesitter-driven editing for web
  { "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" }, -- vif/vaf/]f etc.
  { "https://github.com/windwp/nvim-ts-autotag" },                      -- auto close/rename <tags>
  { "https://github.com/numToStr/Comment.nvim" },                      -- gc, JSX-aware
  { "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" }, -- correct comment string in JSX/Vue
  { "https://github.com/catgoose/nvim-colorizer.lua" },                -- #rrggbb colour swatches
  { "https://github.com/vuki656/package-info.nvim" },                  -- npm versions inside package.json

  -- completion polish
  { "https://github.com/onsails/lspkind.nvim" },
  { "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help" },
  { "https://github.com/hrsh7th/cmp-cmdline" },

  -- diagnostics / navigation UI
  { "https://github.com/folke/trouble.nvim" },
  { "https://github.com/folke/todo-comments.nvim" },
  { "https://github.com/SmiteshP/nvim-navic" },        -- code-context breadcrumbs
  { "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
  { "https://github.com/MeanderingProgrammer/render-markdown.nvim", ref = "v8.13.0" }, -- newer main drifts to nvim 0.11-only; health.lua has a local 0.10 patch


  -- git tooling beyond the gutter
  { "https://github.com/tpope/vim-fugitive" },
  { "https://github.com/sindrets/diffview.nvim" },

  -- debugging (DAP) -- js-debug-adapter is installed via lua/plugins/mason-tools.lua
  { "https://github.com/mfussenegger/nvim-dap" },
  { "https://github.com/rcarriga/nvim-dap-ui" },
  { "https://github.com/nvim-neotest/nvim-nio" },      -- dap-ui + neotest dependency
  { "https://github.com/theHamsta/nvim-dap-virtual-text" },

  -- test runner
  { "https://github.com/nvim-neotest/neotest" },
  { "https://github.com/antoinemadec/FixCursorHold.nvim" },
  { "https://github.com/marilari88/neotest-vitest" },
  { "https://github.com/nvim-neotest/neotest-jest" },
  { "https://github.com/nvim-neotest/neotest-python" },
  { "https://github.com/thenbe/neotest-playwright" },

  -- database client
  { "https://github.com/tpope/vim-dadbod" },
  { "https://github.com/kristijanhusak/vim-dadbod-ui" },
  { "https://github.com/kristijanhusak/vim-dadbod-completion" },

  -- HTTP / REST client (.http files)
  { "https://github.com/mistweaverco/kulala.nvim" },

  -- project + session
  { "https://github.com/ahmedkhalf/project.nvim" },
  { "https://github.com/folke/persistence.nvim" },
}

local START = vim.fn.stdpath("config") .. "/pack/core/start"

local function dir_name(spec)
  return spec.name or (spec[1]:gsub("%.git$", ""):match("([^/]+)$"))
end

local function git(args)
  local out = vim.fn.system(vim.list_extend({ "git" }, args))
  return vim.v.shell_error == 0, out
end

function M.ensure()
  vim.fn.mkdir(START, "p")
  local cloned = {}

  for _, spec in ipairs(PLUGINS) do
    local name = dir_name(spec)
    local dir = START .. "/" .. name
    if vim.fn.isdirectory(dir) == 0 then
      local args = { "clone", "--depth=1", "--recurse-submodules", "--shallow-submodules" }
      if spec.ref then vim.list_extend(args, { "--branch", spec.ref }) end
      vim.list_extend(args, { spec[1], dir })
      vim.notify("bootstrap: cloning " .. name)
      local ok, out = git(args)
      if ok then
        cloned[#cloned + 1] = name
        vim.opt.runtimepath:append(dir) -- usable this session
      else
        vim.notify("bootstrap: FAILED " .. name .. "\n" .. out, vim.log.levels.ERROR)
      end
    end
  end

  if #cloned > 0 then
    -- build steps for the plugins that need a compile
    local fzf = START .. "/telescope-fzf-native.nvim"
    if vim.fn.isdirectory(fzf) == 1 and vim.fn.executable("make") == 1 then
      vim.fn.system({ "make", "-C", fzf })
    end
    pcall(vim.cmd, "packloadall!")
    pcall(vim.cmd, "silent! helptags ALL")
    vim.schedule(function()
      vim.notify(
        "Installed: " .. table.concat(cloned, ", ") .. "\n"
          .. "Restart nvim, then run :TSUpdate to compile parsers.",
        vim.log.levels.WARN
      )
    end)
  end
end

vim.api.nvim_create_user_command("PluginStatus", function()
  local lines = {}
  for _, spec in ipairs(PLUGINS) do
    local n = dir_name(spec)
    local dir = START .. "/" .. n
    local ref = "(missing)"
    if vim.fn.isdirectory(dir) == 1 then
      local ok, out = git({ "-C", dir, "describe", "--all", "--always", "--dirty" })
      ref = ok and vim.trim(out) or "?"
    end
    lines[#lines + 1] = ("%-28s %s%s"):format(n, ref, spec.ref and ("  [pinned " .. spec.ref .. "]") or "")
  end
  vim.notify(table.concat(lines, "\n"))
end, { desc = "List plugins and their git ref" })

vim.api.nvim_create_user_command("PluginUpdate", function()
  for _, spec in ipairs(PLUGINS) do
    local n = dir_name(spec)
    local dir = START .. "/" .. n
    if vim.fn.isdirectory(dir) == 1 then
      if spec.ref and spec.ref:match("^v%d") then
        vim.notify("skip (pinned) " .. n)
      else
        vim.notify("pull " .. n)
        git({ "-C", dir, "pull", "--ff-only", "--recurse-submodules" })
      end
    end
  end
  pcall(vim.cmd, "silent! helptags ALL")
  vim.notify("PluginUpdate done -- restart nvim, then :TSUpdate", vim.log.levels.WARN)
end, { desc = "git pull --ff-only every non-pinned plugin" })

return M
