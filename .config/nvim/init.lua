--[[
 _______                     __
|    |  |.-----.-----.--.--.|__|.--------.
|       ||  -__|  _  |  |  ||  ||        |
|__|____||_____|_____|\___/ |__||__|__|__|
]]

-- 🔧 Basic Platfrom & Utilities
require("platform")

-- 📦 Plugins & Plugin Manager
require("mod")

-- ⌨️  Key Bindings
require("bindings")

-- 🛺 Autocommands for convienience
vim.cmd("source $XDG_CONFIG_HOME/nvim/lua/auto.vim")
