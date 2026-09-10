-- The only place third-party code enters this config. Each entry is a git
-- repository that gets cloned verbatim into pack/core/start/ -- Neovim loads
-- everything in that directory automatically (:help packages). There is no
-- plugin manager: no lazy-loading graph, no DSL. Just `git` + a lockfile.
--
--   :PluginStatus    list plugins and their checked-out ref
--   :PluginUpdate    `git pull --ff-only` every plugin (skips pinned tags)
--   :PluginLock      record every plugin's exact commit to plugins.lock
--   :PluginRestore   check every plugin back out to the commit in plugins.lock
--
-- plugins.lock (JSON, committed) is the reproducibility mechanism a plugin
-- manager would give you: a fresh clone checks out the locked commit, and
-- :PluginRestore rolls a bad :PluginUpdate back. Workflow: :PluginUpdate ->
-- test -> :PluginLock -> commit. If an update breaks something: :PluginRestore.
--
-- To add a plugin:    add a line below, restart nvim (it clones on start),
--                     then add a lua/plugins/<name>.lua that configures it,
--                     then :PluginLock.
-- To remove one:      delete its line, its lua/plugins file, its init.lua
--                     entry, then `rm -rf pack/core/start/<name>` + :PluginLock.

local M = {}

-- { url [, ref = "branch-or-tag"] [, name = "dir override"] }.
-- A `ref` that looks like a version tag (v1, v1.2.3) is treated as pinned:
-- :PluginUpdate leaves it alone. A branch ref (master, main) still updates.
local PLUGINS = {
  -- colours  (repo is catppuccin/nvim -> force a sane directory name)
  { "https://github.com/catppuccin/nvim", name = "catppuccin" },
  -- shared lua libraries
  { "https://github.com/nvim-lua/plenary.nvim" },
  { "https://github.com/MunifTanjim/nui.nvim" },
  { "https://github.com/nvim-tree/nvim-web-devicons" },
  -- syntax tree  (master branch: the `main` rewrite has a different, manual API)
  { "https://github.com/nvim-treesitter/nvim-treesitter", ref = "master" },
  -- fuzzy finder  (modern ctrlp)
  { "https://github.com/nvim-telescope/telescope.nvim", ref = "0.1.x" },
  { "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  -- LSP
  { "https://github.com/neovim/nvim-lspconfig" },
  { "https://github.com/williamboman/mason.nvim" },
  { "https://github.com/williamboman/mason-lspconfig.nvim" },
  { "https://github.com/pmizio/typescript-tools.nvim" }, -- faster TS/JS server, replaces ts_ls
  { "https://github.com/folke/lazydev.nvim" },           -- full Lua LSP when editing this config
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
  { "https://github.com/nvim-treesitter/nvim-treesitter-context" },     -- sticky signature line
  { "https://github.com/windwp/nvim-ts-autotag" },                      -- auto close/rename <tags>
  { "https://github.com/numToStr/Comment.nvim" },                       -- gc, JSX-aware
  { "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" }, -- correct comment string in JSX/Vue
  { "https://github.com/catgoose/nvim-colorizer.lua" },                 -- #rrggbb colour swatches
  { "https://github.com/vuki656/package-info.nvim" },                   -- npm versions inside package.json

  -- completion polish
  { "https://github.com/onsails/lspkind.nvim" },
  { "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help" },
  { "https://github.com/hrsh7th/cmp-cmdline" },

  -- diagnostics / navigation UI
  { "https://github.com/folke/trouble.nvim" },
  { "https://github.com/folke/todo-comments.nvim" },
  { "https://github.com/SmiteshP/nvim-navic" },        -- code-context breadcrumbs
  { "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
  { "https://github.com/MeanderingProgrammer/render-markdown.nvim" }, -- in-buffer markdown rendering

  -- search & replace across the project
  { "https://github.com/MagicDuck/grug-far.nvim" },

  -- jump between the handful of files you're actually working in
  { "https://github.com/ThePrimeagen/harpoon", ref = "harpoon2" },

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
local LOCKFILE = vim.fn.stdpath("config") .. "/plugins.lock"

local function dir_name(spec)
  return spec.name or (spec[1]:gsub("%.git$", ""):match("([^/]+)$"))
end

-- a ref is "pinned" (never auto-updated) when it looks like a version tag
local function is_pinned(ref)
  return ref ~= nil and ref:match("^v?%d") ~= nil
end

local function git(args)
  local out = vim.fn.system(vim.list_extend({ "git" }, args))
  return vim.v.shell_error == 0, out
end

local function read_lock()
  local f = io.open(LOCKFILE, "r")
  if not f then return {} end
  local raw = f:read("*a")
  f:close()
  local ok, tbl = pcall(vim.json.decode, raw)
  return (ok and type(tbl) == "table") and tbl or {}
end

local function write_lock(tbl)
  -- stable key order so the committed file has a clean diff
  local keys = {}
  for k in pairs(tbl) do keys[#keys + 1] = k end
  table.sort(keys)
  local parts = {}
  for _, k in ipairs(keys) do
    parts[#parts + 1] = ('  %s: %s'):format(vim.json.encode(k), vim.json.encode(tbl[k]))
  end
  local f = assert(io.open(LOCKFILE, "w"))
  f:write("{\n" .. table.concat(parts, ",\n") .. "\n}\n")
  f:close()
end

local function head_sha(dir)
  local ok, out = git({ "-C", dir, "rev-parse", "HEAD" })
  return ok and vim.trim(out) or nil
end

-- check `dir` out to `sha`, fetching it first if it isn't present (shallow
-- clones won't have it). Best-effort: a missing commit just leaves the branch.
local function checkout_sha(dir, sha)
  if head_sha(dir) == sha then return true end
  git({ "-C", dir, "fetch", "--depth=1", "origin", sha })
  local ok = git({ "-C", dir, "checkout", "--detach", sha })
  return ok
end

function M.ensure()
  vim.fn.mkdir(START, "p")
  local lock = read_lock()
  local cloned = {}

  for _, spec in ipairs(PLUGINS) do
    local name = dir_name(spec)
    local dir = START .. "/" .. name
    if vim.fn.isdirectory(dir) == 0 then
      local args = { "clone", "--recurse-submodules", "--shallow-submodules" }
      -- a locked commit needs history to fetch into; otherwise stay shallow
      if not lock[name] then vim.list_extend(args, { "--depth=1" }) end
      if spec.ref then vim.list_extend(args, { "--branch", spec.ref }) end
      vim.list_extend(args, { spec[1], dir })
      vim.notify("bootstrap: cloning " .. name)
      local ok, out = git(args)
      if ok then
        if lock[name] then checkout_sha(dir, lock[name]) end
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
          .. "Restart nvim, then run :TSUpdate to compile parsers, then :PluginLock.",
        vim.log.levels.WARN
      )
    end)
  end
end

vim.api.nvim_create_user_command("PluginStatus", function()
  local lock = read_lock()
  local lines = {}
  for _, spec in ipairs(PLUGINS) do
    local n = dir_name(spec)
    local dir = START .. "/" .. n
    local ref = "(missing)"
    if vim.fn.isdirectory(dir) == 1 then
      local ok, out = git({ "-C", dir, "describe", "--all", "--always", "--dirty" })
      ref = ok and vim.trim(out) or "?"
    end
    local sha = head_sha(dir)
    local locked = lock[n]
    local mark = ""
    if spec.ref and is_pinned(spec.ref) then
      mark = "  [pinned " .. spec.ref .. "]"
    elseif locked and sha and locked ~= sha then
      mark = "  [AHEAD of lock]"
    end
    lines[#lines + 1] = ("%-30s %s%s"):format(n, ref, mark)
  end
  vim.notify(table.concat(lines, "\n"))
end, { desc = "List plugins and their git ref" })

vim.api.nvim_create_user_command("PluginUpdate", function()
  for _, spec in ipairs(PLUGINS) do
    local n = dir_name(spec)
    local dir = START .. "/" .. n
    if vim.fn.isdirectory(dir) == 1 then
      if is_pinned(spec.ref) then
        vim.notify("skip (pinned) " .. n)
      else
        vim.notify("pull " .. n)
        -- reattach if we're on a detached locked commit
        if spec.ref then git({ "-C", dir, "checkout", spec.ref }) end
        git({ "-C", dir, "pull", "--ff-only", "--recurse-submodules" })
      end
    end
  end
  pcall(vim.cmd, "silent! helptags ALL")
  vim.notify("PluginUpdate done -- restart, :TSUpdate, test, then :PluginLock", vim.log.levels.WARN)
end, { desc = "git pull --ff-only every non-pinned plugin" })

vim.api.nvim_create_user_command("PluginLock", function()
  local lock = {}
  for _, spec in ipairs(PLUGINS) do
    local n = dir_name(spec)
    local dir = START .. "/" .. n
    if vim.fn.isdirectory(dir) == 1 then
      local sha = head_sha(dir)
      if sha then lock[n] = sha end
    end
  end
  write_lock(lock)
  vim.notify(("PluginLock: recorded %d plugins to %s"):format(vim.tbl_count(lock), LOCKFILE))
end, { desc = "Record every plugin's exact commit to plugins.lock" })

vim.api.nvim_create_user_command("PluginRestore", function()
  local lock = read_lock()
  if vim.tbl_isempty(lock) then
    vim.notify("PluginRestore: plugins.lock is empty or missing", vim.log.levels.ERROR)
    return
  end
  local n_ok, n_miss = 0, 0
  for _, spec in ipairs(PLUGINS) do
    local n = dir_name(spec)
    local dir = START .. "/" .. n
    if vim.fn.isdirectory(dir) == 1 and lock[n] then
      if checkout_sha(dir, lock[n]) then n_ok = n_ok + 1 else n_miss = n_miss + 1 end
    end
  end
  pcall(vim.cmd, "silent! helptags ALL")
  vim.notify(("PluginRestore: %d at locked commit, %d failed. Restart + :TSUpdate."):format(n_ok, n_miss),
    n_miss > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
end, { desc = "Check every plugin out to the commit in plugins.lock" })

return M
