-- Local-LLM code completion (Copilot-style ghost text), served entirely on this
-- machine by an Ollama daemon on the RTX 3050 Ti -- no cloud call, no API key,
-- works offline. Use it for the cheap, low-stakes typing (boilerplate, the
-- obvious next line, repetitive blocks); keep Claude/the API for real reasoning.
--
-- How it works:
--   * Ollama exposes an OpenAI-compatible endpoint at :11434/v1/completions
--     that understands fill-in-the-middle (prompt + suffix) for the
--     qwen2.5-coder models.
--   * minuet sends the code around the cursor, shows the reply as grey virtual
--     text. Nothing is inserted until you press the accept key.
--
-- Keymaps (insert mode -- Alt so they don't clash with nvim-cmp's C-n/C-p/Tab):
--   <A-y>       accept the whole suggestion
--   <A-Right>   accept one line
--   <A-]> <A-[> cycle to the next / previous suggestion
--   <A-e>       dismiss
--   <A-Space>   request a suggestion manually (works even when auto-trigger is off)
--   <leader>tm  toggle auto-trigger (normal mode) -- silence it during deep work
--
-- Requires the Ollama side to be up:  systemctl --user start ollama   (or: ollama serve)
-- and the model pulled:               ollama pull qwen2.5-coder:1.5b-base
-- See ~/.config/gpu-workflow.md for the whole setup.

local ok, minuet = pcall(require, "minuet")
if not ok then
  return -- plugin not cloned yet (offline); init.lua already logs the miss
end

-- Keep every knob sized for a 4 GB card running a 1.5B model: short context,
-- one candidate, generous debounce so we don't queue a request per keystroke.
minuet.setup({
  provider = "openai_fim_compatible",
  n_completions = 1,
  context_window = 2000, -- chars of surrounding code sent as context
  request_timeout = 5,   -- seconds; 1.5B cold-starts in ~1-2s on the 3050 Ti
  throttle = 1500,       -- ms between requests
  debounce = 600,        -- ms of no typing before firing

  provider_options = {
    openai_fim_compatible = {
      -- Ollama ignores the key but minuet insists on naming a SET env var.
      api_key = "TERM",
      name = "Ollama",
      end_point = "http://localhost:11434/v1/completions",
      model = "qwen2.5-coder:1.5b-base",
      optional = {
        max_tokens = 128,
        top_p = 0.9,
      },
    },
  },

  virtualtext = {
    -- Auto-fire only in languages worth it here; everything else is manual
    -- via <A-Space>. Add filetypes freely.
    auto_trigger_ft = {
      "lua", "typescript", "typescriptreact", "javascript", "javascriptreact",
      "python", "go", "rust", "sh", "bash", "zsh", "json", "jsonc", "yaml",
      "toml", "sql", "html", "css", "scss", "vue", "svelte", "markdown",
    },
    keymap = {
      accept = "<A-y>",
      accept_line = "<A-Right>",
      accept_n_lines = "<A-n>",
      prev = "<A-[>",
      next = "<A-]>",
      dismiss = "<A-e>",
    },
  },
})

-- Manual trigger, independent of the auto-trigger filetype list. minuet's
-- virtualtext has no dedicated "request" call -- action.next fires a request
-- when no suggestion exists yet, and cycles once one does.
vim.keymap.set("i", "<A-Space>", function()
  require("minuet.virtualtext").action.next()
end, { desc = "minuet: suggest / cycle (local LLM)" })

-- Flip auto-trigger without leaving nvim -- handy when the fan spins up or the
-- ghost text gets distracting.
vim.keymap.set("n", "<leader>tm", "<cmd>Minuet virtualtext toggle<cr>",
  { desc = "Toggle minuet auto-completion" })
