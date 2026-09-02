-- Debugging via the Debug Adapter Protocol.
--   nvim-dap                the client (breakpoints, stepping, REPL)
--   nvim-dap-ui             scopes / watches / stacks / breakpoints panels
--   nvim-dap-virtual-text   inline variable values while stepping
--
-- Adapters (installed by plugins/mason-tools.lua):
--   js-debug-adapter   Node, Chrome, and any JS/TS runtime
--   debugpy            Python
--
--   <leader>db breakpoint   <leader>dB conditional   <leader>dc continue/start
--   <leader>di step-into    <leader>do step-over     <leader>dO step-out
--   <leader>du toggle UI    <leader>dr REPL          <leader>dt terminate
--   F5 continue  F10 over  F11 into  F12 out
local dap = require("dap")
local dapui = require("dapui")

require("nvim-dap-virtual-text").setup({ commented = true })
dapui.setup()

-- Open/close the UI automatically with the session.
dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual" })

-- ---- adapters -----------------------------------------------------------
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"

-- JS / TS (vscode-js-debug via mason's js-debug-adapter)
dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = mason_bin .. "js-debug-adapter",
    args = { "${port}" },
  },
}
for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
  dap.configurations[ft] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch current file (node)",
      program = "${file}",
      cwd = "${workspaceFolder}",
      runtimeExecutable = "node",
      sourceMaps = true,
      skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to process (pick)",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
      sourceMaps = true,
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug vitest (current file)",
      runtimeExecutable = "node",
      runtimeArgs = { "./node_modules/vitest/vitest.mjs", "run", "${file}" },
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      sourceMaps = true,
    },
  }
end

-- Python (debugpy). Only wired up when the adapter is actually installed: this
-- box has no pip, so `:MasonInstall debugpy` is a prerequisite (see
-- mason-tools.lua). Registering a missing command just makes :checkhealth fail.
local debugpy = mason_bin .. "debugpy-adapter"
if vim.fn.executable(debugpy) == 1 then
  dap.adapters.python = { type = "executable", command = debugpy }
  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch current file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
    },
  }
end

-- ---- keymaps ----------------------------------------------------------
local map = vim.keymap.set
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: breakpoint" })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: conditional breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "Debug: continue / start" })
map("n", "<leader>di", dap.step_into, { desc = "Debug: step into" })
map("n", "<leader>do", dap.step_over, { desc = "Debug: step over" })
map("n", "<leader>dO", dap.step_out, { desc = "Debug: step out" })
map("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: toggle REPL" })
map("n", "<leader>dl", dap.run_last, { desc = "Debug: run last" })
map("n", "<leader>dt", dap.terminate, { desc = "Debug: terminate" })
map("n", "<leader>du", dapui.toggle, { desc = "Debug: toggle UI" })
map("n", "<leader>de", function() dapui.eval(nil, { enter = true }) end, { desc = "Debug: eval" })
map("v", "<leader>de", function() dapui.eval() end, { desc = "Debug: eval selection" })

map("n", "<F5>", dap.continue, { desc = "Debug: continue" })
map("n", "<F10>", dap.step_over, { desc = "Debug: step over" })
map("n", "<F11>", dap.step_into, { desc = "Debug: step into" })
map("n", "<F12>", dap.step_out, { desc = "Debug: step out" })
