-- vim:foldmethod=marker
-- Lazy Bootstrap {{{
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
-- }}}

local lisps = { "yuck", "fennel", "clojure", "scheme", "lisp" }
local lsp = { "c", "rust", "rs", "typescript", "cpp", "v", "zig", "python", "go" }

function getHeader()
	local header = vim.split(
		[[
							  ,-.       _,---._ __  / \
							 /  )    .-'       `./ /   \
							(  (   ,'            `/    /|
							 \  `-"             \'\   / |
							  `.              ,  \ \ /  |
							   /`.          ,'-`----Y   |
							  (            ;        |   '
							  |  ,-.    ,-'         |  /
							  |  | (   |            | /
							  )  |  \  `.___________|/
							  `--'   `--'                                                               
]],
		"\n"
	)

	local maxlen = 0
	for _, line in ipairs(header) do
		if #line > maxlen then
			maxlen = #line
		end
	end

	for _, line in ipairs(header) do
		header[_] = line .. string.rep(" ", maxlen - #line)
	end

	return header
end

local opts = {
	defaults = {
		lazy = true,
	},
}

require("lazy").setup({

	-- Components {{{
	-- Tresitter
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true, disable = { "nim" } },
				indent = { enable = true },
			})
		end,
		lazy = false,
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		ft = lsp,
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			-- Lsp Server Config {{{
			local l = require("lspconfig")
			local c = {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			}
			l.zls.setup(c)
			l.denols.setup({
				init_options = {
					unstable = true,
				},
				capabilities = c.capabilities,
			})
			l.clangd.setup({
				cmd = {
					"clangd",
					"--limit-results=20",
					"-j=2",
					"--background-index",
					"--pch-storage=memory",
					"--header-insertion=never",
				},
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
			l.rust_analyzer.setup(c)
			l.gopls.setup(c)
			l.pyright.setup(c, {
				settings = {
					python = {
						useLibraryCodeForTypes = true,
					},
				},
			})
			-- l.tsserver.setup(c)
			-- }}}

			local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end
		end,
	},
	-- }}}

	-- Language Support {{{
	-- Eww Configuration Language
	{
		"elkowar/yuck.vim",
		ft = "yuck",
	},

	{
		"zah/nim.vim",
		ft = "nim",
	},

	-- Shader Language
	{
		"tikhomirov/vim-glsl",
		ft = "glsl",
	},

	-- Fennel
	{
		"mnacamura/vim-fennel-syntax",
		ft = "fennel",
	},
	-- }}}

	-- Misc {{{

	{
		"nvim-treesitter/playground",
		keys = {
			{ "<f9>", ":TSHighlightCapturesUnderCursor<cr>" },
		},
		dependencies = { "nvim-treesitter" },
		cmd = { "TSHighlightCapturesUnderCursor" },
	},
	-- }}}

	-- Other UI {{{
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({
				highlight = {
					multiline = false,
				},
			})
		end,
		event = "VeryLazy",
	},
	-- Colorizer
	{
		"NvChad/nvim-colorizer.lua",
		ft = { "lua", "css", "html", "javascript", "vim" },
		config = function()
			require("colorizer").setup({
				user_default_options = {
					names = false,
				},
			})
		end,
	},

	-- Tree / Project Drawer
	{
		"kyazdani42/nvim-tree.lua",
		cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeClose" },
		keys = { { "<C-f>", "<cmd>NvimTreeToggle<CR>", silent = true, desc = "Open File Tree" } },
		dependencies = "kyazdani42/nvim-web-devicons",
		config = function()
			require("nvim-tree").setup({
				disable_netrw = true,
				hijack_netrw = true,
				respect_buf_cwd = true,
				view = {
					width = 20,
					side = "left",
				},
				git = {
					enable = false,
				},
			})
		end,
	},

	-- General Finding Toolkit
	{
		"nvim-telescope/telescope.nvim",
		cmd = { "Telescope" },
		keys = {
			{ "ff", "<cmd>Telescope find_files theme=ivy hidden=true<CR>", silent = true, desc = "File Finder" },
			{ "fi", "<cmd>Telescope live_grep theme=ivy<CR>", silent = true, desc = "File Search" },
			{ "fb", "<cmd>Telescope buffers theme=ivy<CR>", silent = true, desc = "Buffer Manager" },
			{
				"fs",
				"<cmd>Telescope lsp_document_symbols theme=ivy<CR>",
				silent = true,
				desc = "Symbols in workspace",
			},
			{ "ft", "<cmd>Telescope diagnostics theme=ivy<CR>", silent = true, desc = "LSP Diagnostics" },
		},
		dependencies = {
			"kyazdani42/nvim-web-devicons",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local actions = require("telescope.actions")
			require("telescope").setup({
				defaults = {
					prompt_prefix = "λ ",
					prompt_title = false,
					results_title = false,
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["qq"] = actions.close,
						},
					},
					file_ignore_patterns = { "^.git/" },
				},
			})
		end,
	},

	-- {
	-- 	"nvimdev/dashboard-nvim",
	-- 	event = "VimEnter",
	-- 	config = function()
	-- 		require("dashboard").setup({
	-- 			config = {
	-- 				shortcut = {
	-- 					{ desc = 'An eye for an eye makes the world blind.' }
	-- 				},
	-- 				header = getHeader(),
	-- 			},
	-- 		})
	-- 	end,
	-- },

	-- }}}

	-- Debugger {{{
	{
		"mfussenegger/nvim-dap",
		keys = {
			{
				"<F6>",
				function()
					require("dap").continue()
				end,
			},
			{
				"<leader>b",
				function()
					require("dap").toggle_breakpoint()
				end,
			},
		},
		config = function()
			local dap = require("dap")
			dap.adapters.cppdbg = {
				id = "cppdbg",
				type = "executable",
				command = "/home/portal/.vscode/extensions/ms-vscode.cpptools-1.14.5-linux-x64/debugAdapters/bin/OpenDebugAD7",
			}
			local enablePretty = {
				{
					text = "-enable-pretty-printing",
					description = "enable pretty printing",
					ignoreFailures = false,
				},
			}
			dap.configurations.cpp = {
				{
					name = "Launch file",
					type = "cppdbg",
					request = "launch",
					setupCommands = enablePretty,
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = true,
				},
				{
					name = "Attach to gdbserver :1234",
					type = "cppdbg",
					setupCommands = enablePretty,
					request = "launch",
					MIMode = "gdb",
					miDebuggerServerAddress = "localhost:1234",
					miDebuggerPath = "/usr/bin/gdb",
					cwd = "${workspaceFolder}",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
				},
			}
			dap.configurations.c = dap.configurations.cpp
			dap.configurations.rust = dap.configurations.cpp
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"nvim-dap",
		},
		keys = {},
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
	-- }}}

	-- Editing: {{{

	{
		"tpope/vim-surround",
		lazy = false
	},

	-- HTML Editing
	{
		"mattn/emmet-vim",
		ft = { "html" },
	},

	{
		"tpope/vim-commentary",
		lazy = false,
	},

	{
		"windwp/nvim-autopairs",
		event = "VeryLazy",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	-- Lisp Editing
	{
		"eraserhd/parinfer-rust",
		ft = lisps,
	},

	{
		"junegunn/rainbow_parentheses.vim",
		ft = lisps,
		config = function()
			vim.fn["rainbow_parentheses#toggle"]()
		end,
	},

	{
		"abecodes/tabout.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-treesitter", "nvim-cmp" },
		config = function()
			require("tabout").setup({
				tabkey = "",
				backwards_tabkey = "",
			})
		end,
	},
	{
		"machakann/vim-sandwich",
		event = "VeryLazy",
	},

	-- }}}

	{
		'dgagn/diagflow.nvim',
		event = 'LspAttach', -- This is what I use personnally and it works great
		opts = {}
	},

	{
		'loctvl842/monokai-pro.nvim',
		lazy = false,
		config = function()
			require('monokai-pro').setup({
				filter = "spectrum"
			})
			vim.cmd([[ colorscheme monokai-pro ]])
		end
	},

	{
		'zbirenbaum/copilot.lua',
		event = "VeryLazy",
		config = function()
			require('copilot').setup({
				suggestion = {enabled = false},
				panel = {enabled=false}
			})
		end
	},

	{
		"zbirenbaum/copilot-cmp",
		config = function ()
			require("copilot_cmp").setup()
		end
	},

	-- LSP Components {{{
	{
		"glepnir/lspsaga.nvim",
		branch = "main",
		event = "BufRead",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		keys = { { "<S-r>", "<cmd>Lspsaga rename<CR>", silent = true } },
		config = function()
			require("lspsaga").setup({
				symbol_in_winbar = {
					enable = false,
					separator = " / ",
				},
				ui = {
					border = "rounded",
				},
				lightbulb = {
					enable = true,
					sign = true,
					enable_in_insert = true,
				},
				outline = {
					keys = {
						jump = "<CR>",
					},
				},
			})
		end,
	},

	{
		"hrsh7th/cmp-nvim-lsp",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"windwp/nvim-autopairs",
			"hrsh7th/vim-vsnip",
			"hrsh7th/cmp-vsnip",
			"onsails/lspkind.nvim",
		},
		lazy = false,
		config = function()
			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			local feedkey = function(key, mode)
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
			end

			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vi)
						local kind = require("lspkind").cmp_format({
							mode = "",
							menu = {
								buffer = "[buf]",
								nvim_lsp = "[lsp]",
								vsnip = "[snp]",
							},
						})(entry, vi)
						local parts = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. (parts[1] or "") .. ""
						return kind
					end,
				},
				window = {
					completion = {
						winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
						col_offset = -3,
						side_padding = 0,
					},
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif vim.fn["vsnip#available"](1) == 1 then
							feedkey("<Plug>(vsnip-expand-or-jump)", "")
						elseif has_words_before() then
							cmp.complete()
						else
							fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function()
						if cmp.visible() then
							cmp.select_prev_item()
						elseif vim.fn["vsnip#jumpable"](-1) == 1 then
							feedkey("<Plug>(vsnip-jump-prev)", "")
						end
					end, { "i", "s" }),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "copilot" },
					{ name = "nvim_lsp" },
					{ name = "vsnip" },
				}, {
						{ name = "path" },
					}),
			})
			cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
		end,
	},

	-- }}}
}, opts)
