-- neotest: run tests from the editor, see pass/fail signs in the gutter, read
-- output inline, debug a failing test with nvim-dap.
--
-- Adapters auto-detect per project (jest OR vitest based on config/deps):
--   neotest-vitest      Vite / Vitest projects
--   neotest-jest        Jest projects
--   neotest-playwright  Playwright e2e (:NeotestPlaywrightProject to pick a project)
--   neotest-python      pytest / unittest
--
--   <leader>Tr nearest   <leader>Tf file    <leader>Ta whole suite
--   <leader>Ts summary   <leader>To output  <leader>TO output panel
--   <leader>Tw watch     <leader>Td debug nearest (needs plugins/dap.lua)
--   ]n / [n              next / previous failed test
local neotest = require("neotest")

neotest.setup({
  adapters = {
    require("neotest-vitest"),
    require("neotest-jest")({ jestCommand = "npm test --" }),
    require("neotest-playwright").adapter({
      options = { persist_project_selection = true, enable_dynamic_test_discovery = true },
    }),
    require("neotest-python")({ dap = { justMyCode = false } }),
  },
  status = { virtual_text = true },
  output = { open_on_run = false },
  quickfix = { enabled = false },
})

local map = vim.keymap.set
map("n", "<leader>Tr", function() neotest.run.run() end, { desc = "Test: nearest" })
map("n", "<leader>Tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test: file" })
map("n", "<leader>Ta", function() neotest.run.run(vim.uv.cwd()) end, { desc = "Test: whole suite" })
map("n", "<leader>Tl", function() neotest.run.run_last() end, { desc = "Test: rerun last" })
map("n", "<leader>Tx", function() neotest.run.stop() end, { desc = "Test: stop" })
map("n", "<leader>Ts", function() neotest.summary.toggle() end, { desc = "Test: summary panel" })
map("n", "<leader>To", function() neotest.output.open({ enter = true, auto_close = true }) end, { desc = "Test: output" })
map("n", "<leader>TO", function() neotest.output_panel.toggle() end, { desc = "Test: output panel" })
map("n", "<leader>Tw", function() neotest.watch.toggle(vim.fn.expand("%")) end, { desc = "Test: watch file" })
map("n", "<leader>Td", function() neotest.run.run({ strategy = "dap" }) end, { desc = "Test: debug nearest" })
map("n", "]n", function() neotest.jump.next({ status = "failed" }) end, { desc = "Next failed test" })
map("n", "[n", function() neotest.jump.prev({ status = "failed" }) end, { desc = "Previous failed test" })
