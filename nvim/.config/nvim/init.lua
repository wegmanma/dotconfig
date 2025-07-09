require("core.options") -- Load general options
require("core.keymaps") -- Load general keymaps

-- Install package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.winbar = nil
-- Import color theme based on environment variable NVIM_THEME
local default_color_scheme = "kanagawa_paper"
local env_var_nvim_theme = os.getenv("NVIM_THEME") or default_color_scheme

-- Define a table of theme modules
local themes = {
  nord = "plugins.themes.nord",
  onedark = "plugins.themes.onedark",
  kanagawa = "plugins.themes.kanagawa",
  kanagawa_paper = "plugins.themes.kanagawa-paper",
}
vim.o.laststatus = 3
-- Setup plugins
require("lazy").setup({
  require(themes[env_var_nvim_theme]),
  require("plugins.debug"),
  require("plugins.telescope"),
  require("plugins.treesitter"),
  require("plugins.rust-tools"),
  require("plugins.lsp"),
  require("plugins.autocompletion"),
  require("plugins.none-ls"),
  require("plugins.lualine"),
  require("plugins.neo-tree"),
  require("plugins.alpha"),
  require("plugins.indent-blankline"),
  require("plugins.gitsigns"),
  require("plugins.misc"),
  require("plugins.typst-preview"),
}, {
  ui = {
    -- If you have a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
vim.opt.guifont = "CaskaydiaCove NFM"

-- Function to check if a file exists
local function file_exists(file)
  local f = io.open(file, "r")
  if f then
    f:close()
    return true
  else
    return false
  end
end

-- Path to the session file
local session_file = ".session.vim"

-- Check if the session file exists in the current directory
if file_exists(session_file) then
  -- Source the session file
  vim.cmd("source " .. session_file)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "c", "cpp", "h", "hpp", "go", "make", "cmake", "sh" -- use tabs
  },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
	vim.g.rustfmt_autosave = 0
  end,
})
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
