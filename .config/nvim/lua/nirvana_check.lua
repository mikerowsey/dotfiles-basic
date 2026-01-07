------------------------------------------------------------
-- NirvanaCheck
-- One-command health verification
------------------------------------------------------------

vim.api.nvim_create_user_command("NirvanaCheck", function()
  local lines = {}

  local function ok(msg) table.insert(lines, "OK   " .. msg) end
  local function bad(msg) table.insert(lines, "FAIL " .. msg) end

  -- Neovim version
  local v = vim.version()
  if v and v.major == 0 and v.minor >= 11 then
    ok(string.format("Neovim %d.%d.%d", v.major, v.minor, v.patch))
  else
    bad("Neovim version < 0.11")
  end

  -- Treesitter active (current buffer)
  local buf = vim.api.nvim_get_current_buf()
  local ts_active = vim.treesitter.highlighter.active[buf] ~= nil
  if ts_active then
    ok("Treesitter active for current buffer")
  else
    bad("Treesitter not active for current buffer")
  end

  -- clangd attached
  local clangd_attached = false
  for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
    if client.name == "clangd" then
      clangd_attached = true
      break
    end
  end

  if clangd_attached then
    ok("clangd LSP attached")
  else
    bad("clangd not attached")
  end

  -- compile_commands.json
  local cwd = vim.fn.getcwd()
  if vim.fn.filereadable(cwd .. "/compile_commands.json") == 1 then
    ok("compile_commands.json found")
  else
    bad("compile_commands.json missing in project root")
  end

  -- clang-format
  if vim.fn.executable("clang-format") == 1 then
    ok("clang-format available")
  else
    bad("clang-format not found in PATH")
  end

  -- Output (plain, predictable)
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, {
    title = "NirvanaCheck",
  })
end, {
  desc = "Verify Neovim nirvana health",
})
