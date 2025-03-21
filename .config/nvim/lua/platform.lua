local M = {}

-- Opt into filetype.lua
-- vim.g.do_filetype_lua = 1
-- vim.g.did_load_filetypes = 0

-- Enable Mouse Support
vim.opt.mouse = "a"

-- Disable Line Wrappping
vim.opt.wrap = false

-- Line Number & Sign Column
vim.opt.number = true
vim.opt.signcolumn = "number"

-- Colorscheme
vim.opt.termguicolors = true
vim.cmd([[ syntax on ]])

-- Completion
vim.o.completeopt = "menuone,noselect"

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Statusline & Command Line
vim.opt.laststatus = 0
-- vim.opt.cmdheight = 0

-- Split below
vim.opt.splitbelow = true

-- Folding
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

-- Ruler, Statusline & Title
vim.opt.statusline = "::"
vim.opt.titlestring = "  %t"
vim.opt.title = true

-- Colorscheme
vim.opt.background = "dark"
-- vim.cmd([[ colorscheme personal ]])

vim.g.zig_fmt_autosave = 0
vim.g.user_emmet_leader_key = "<Insert>"
vim.g.vsnip_filetypes.dart = { "flutter" }
vim.g.vim_markdown_folding_disabled = true
vim.g.mapleader = ","

vim.opt.grepprg = "grep -nHbFr"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.showmode = false

vim.g.c_syntax_for_h = true

-- Disable Default Nvim Plugins {{{
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_2html_plugin = 1
-- }}}

-- Find highlight group
function _G.foldText()
	local x = vim.fn.getline(vim.v.foldstart)
	local s, e = x:find(" .* {{{")
	return vim.v.folddashes:gsub("-", ";") .. " " .. x:sub(s + 1, e - 3)
end

-- function _G.updateRuler()
-- 	local ft = vim.bo.filetype
-- 	vim.opt.rulerformat = "%" .. #ft .. "(%Y%)"
-- end

vim.g.markdown_fenced_languages = {
	"ts=typescript",
}

-- vim.opt.foldtext = "v:lua.foldText()"
vim.opt.fillchars = { fold = " " }

return M
