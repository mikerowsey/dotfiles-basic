------------------------------------------------------------
-- core.lua (minimal, deterministic)
------------------------------------------------------------

-----------------------------
-- Options
-----------------------------
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true

-- How long (ms) before swap write and CursorHold events
vim.o.updatetime = 300

-- How long (ms) to wait for mapped key sequences
vim.o.timeoutlen = 800

vim.o.clipboard = "unnamedplus"
vim.o.undofile = true       -- Persistent undo across sessions
vim.o.ignorecase = true     -- Case-insensitive search
vim.o.smartcase = true      -- Unless uppercase present
vim.o.scrolloff = 8         -- Keep 8 lines visible above/below cursor

-- Indent (1TBS, 4 spaces)
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.smartindent = true

-----------------------------
-- Keymap helpers (you own every mapping)
-----------------------------
local function nmap(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

local function vmap(lhs, rhs, desc)
  vim.keymap.set("v", lhs, rhs, { silent = true, desc = desc })
end

-----------------------------
-- lazy.nvim bootstrap
-----------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------
-- Plugins
-----------------------------
require("lazy").setup({
  -- Theme FIRST so it's available when we set colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      local tb = require("telescope.builtin")
      nmap("<leader>ff", tb.find_files, "Find files")
      nmap("<leader>fg", tb.live_grep, "Live grep")
      nmap("<leader>fb", tb.buffers, "Buffers")
      nmap("<leader>fs", tb.lsp_document_symbols, "Symbols")
    end,
  },

  -- Treesitter (Neovim 0.11+ builtin - just install parsers)
  {
    "nvim-treesitter/nvim-treesitter",
    ft = { "c", "cmake", "lua" },
    build = ":TSInstall c cmake lua",
  },
}, {
  defaults = { lazy = true },
})

-----------------------------
-- Colorscheme
-----------------------------
vim.cmd.colorscheme("catppuccin-mocha")

-----------------------------
-- Diagnostics (quiet, pull-based)
-----------------------------
vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  signs = false,
  update_in_insert = false,
})

-----------------------------
-- LSP: clangd (Neovim 0.11+ built-in)
-----------------------------
vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy" },
})
vim.lsp.enable("clangd")

-----------------------------
-- LSP: CMake (deterministic attach for cmake-language-server 0.1.11)
-----------------------------
local cmake_grp = vim.api.nvim_create_augroup("CmakeLspAttach", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = cmake_grp,
  pattern = "cmake",
  callback = function(args)
    local root = vim.fs.root(args.buf, { "CMakeLists.txt", ".git" }) or vim.fn.getcwd()

    vim.lsp.start({
      name = "cmake",
      cmd = { "cmake-language-server" }, -- NO --stdio (not supported by your version)
      root_dir = root,
      reuse_client = function(client, conf)
        return client.name == conf.name and client.root_dir == conf.root_dir
      end,
    })
  end,
})

-----------------------------
-- LSP keymaps
-----------------------------
nmap("gd", vim.lsp.buf.definition, "LSP: definition")
nmap("gr", vim.lsp.buf.references, "LSP: references")
nmap("K", vim.lsp.buf.hover, "LSP: hover")
nmap("<leader>rn", vim.lsp.buf.rename, "LSP: rename")
nmap("<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
nmap("<leader>e", vim.diagnostic.open_float, "Diag: float")
nmap("[d", vim.diagnostic.goto_prev, "Diag: prev")
nmap("]d", vim.diagnostic.goto_next, "Diag: next")
nmap("<C-s>", vim.lsp.buf.signature_help, "LSP: signature help")
vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, { desc = "LSP: signature help" })

-- Manual completion (reference-only)
vim.keymap.set("i", "<M-/>", "<C-x><C-o>", {
  desc = "Manual LSP completion (reference only)",
})

-----------------------------
-- Manual format (clang-format for C)
-----------------------------
vim.api.nvim_create_user_command("Format", function()
  local ft = vim.bo.filetype
  if ft == "c" then
    vim.cmd("write")
    local result = vim.system({ "clang-format", "-i", vim.fn.expand("%:p") }):wait()
    if result.code ~= 0 then
      vim.notify("clang-format failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
    else
      vim.notify("Formatted with clang-format", vim.log.levels.INFO)
    end
    vim.cmd("edit")
    return
  end
  vim.lsp.buf.format({ async = false })
end, { desc = "Manual format" })

nmap("<leader>cf", "<cmd>Format<cr>", "Format (manual)")

-----------------------------
-- Move lines (tmux-safe)
-----------------------------
nmap("<leader>j", ":m .+1<CR>==", "Move line down")
nmap("<leader>k", ":m .-2<CR>==", "Move line up")
vmap("<leader>j", ":m '>+1<CR>gv=gv", "Move selection down")
vmap("<leader>k", ":m '<-2<CR>gv=gv", "Move selection up")

-- =========================================================
-- Buffer Keymaps
-- =========================================================

-- ---------------------------------------------------------
-- Navigation
-- ---------------------------------------------------------
nmap("<leader>bn", ":bnext<CR>", "Buffer: next")
nmap("<leader>bp", ":bprevious<CR>", "Buffer: previous")
nmap("<leader>bf", ":bfirst<CR>", "Buffer: first")
nmap("<leader>bl", ":blast<CR>", "Buffer: last")
nmap("<leader>bb", ":b#<CR>", "Buffer: alternate")

-- ---------------------------------------------------------
-- Deletion (window-safe)
-- ---------------------------------------------------------
vim.api.nvim_create_user_command("BDelete", function()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  if #buffers > 1 then
    vim.cmd("bp | bd #")
  else
    vim.notify("Cannot delete the last buffer", vim.log.levels.WARN)
  end
end, {})

nmap("<leader>bd", ":BDelete<CR>", "Buffer: delete (safe)")
nmap("<leader>bD", ":bd!<CR>", "Buffer: delete (force)")

-- ---------------------------------------------------------
-- Listing / Selection
-- ---------------------------------------------------------
nmap("<leader>bs", ":ls<CR>:buffer<Space>", "Buffer: select from list")

-- ---------------------------------------------------------
-- Direct Buffer Access (1–9)
-- ---------------------------------------------------------
nmap("<leader>1", ":buffer 1<CR>", "Buffer: 1")
nmap("<leader>2", ":buffer 2<CR>", "Buffer: 2")
nmap("<leader>3", ":buffer 3<CR>", "Buffer: 3")
nmap("<leader>4", ":buffer 4<CR>", "Buffer: 4")
nmap("<leader>5", ":buffer 5<CR>", "Buffer: 5")
nmap("<leader>6", ":buffer 6<CR>", "Buffer: 6")
nmap("<leader>7", ":buffer 7<CR>", "Buffer: 7")
nmap("<leader>8", ":buffer 8<CR>", "Buffer: 8")
nmap("<leader>9", ":buffer 9<CR>", "Buffer: 9")

-- ---------------------------------------------------------
-- Cleanup
-- ---------------------------------------------------------
-- Close all buffers except current
nmap("<leader>bo", ":%bd|e#|bd#<CR>", "Buffer: only (close others)")


-----------------------------
-- NirvanaCheck command (separate file)
-----------------------------
local ok, _ = pcall(require, "nirvana_check")
if not ok then
  vim.notify("nirvana_check.lua not found", vim.log.levels.WARN)
end
