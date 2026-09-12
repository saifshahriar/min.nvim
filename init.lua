--[[ =====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         || Saif's Minimal NVIM||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

This is a minimal version of neovim I plan to use for my university setup. I
have a more feature full setup. This minimal setup is only intended for
environment where less dependency is required. It is configured with necessary
lsps, formatters, etc.
                                                                 ~Saif Shahriar
-- ]]

-- {{{ options
local options = {
	-- global
	timeoutlen = 400,
	undofile = true,
	colorcolumn = "80",
	cursorline = true,
	cursorlineopt = "both",
	foldmethod = "marker",
	laststatus = 3,
	list = true,
	numberwidth = 4,
	number = true,
	relativenumber = true,
	scrolloff = 16,
	showmode = false,
	sidescrolloff = 8,
	-- signcolumn = "yes:2",
	spell = true,
	spellfile = "~/.config/nvim/spell/en.utf-8.add",
	splitkeep = "screen",
	wrap = false,

	-- indenting
	expandtab = false,
	tabstop = 4,
	smartindent = true,
	softtabstop = 4,
	shiftwidth = 4,

	-- searching
	ignorecase = true,
	smartcase = true,

	-- mouse and clipboard support
	clipboard = "unnamedplus",
	mouse = "a",

	-- split
	signcolumn = "yes",
	splitbelow = true,
	splitright = true,
	-- interval for writing swap file to disk, also used by gitsigns
	updatetime = 250,
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.opt.fillchars = { eob = " " }
vim.opt.listchars:append({ tab = "│ ", trail = "" })
vim.opt.whichwrap:append("<>[]hl")

-- disable some default providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- }}}
-- {{{ theming
vim.cmd.colorscheme("retrobox")
vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "#000000" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "#000000" })
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#005100" })
-- }}}
-- {{{ mappings
local map = vim.keymap.set
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- general
map("n", ";", ":")
map("n", "<C-y>", ":%y+<CR>")
map("n", "<Tab>", ":bNext<CR>")
map("n", "<S-Tab>", ":bprev<CR>")

-- window
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- lsp keymap
map("n", "grn", vim.lsp.buf.rename, { desc = "LSP Rename" })
map({ "n", "x" }, "gra", vim.lsp.buf.code_action, { desc = "[G]oto Code [A]ction" })
map("n", "gD", vim.lsp.buf.declaration)

-- competitest
vim.keymap.set("n", "<leader>cr", ":CompetiTest run<CR>", {})
vim.keymap.set("n", "<leader>cnr", ":CompetiTest run_no_compile<CR>", {})
vim.keymap.set("n", "<leader>cs", ":CompetiTest show_ui<CR>", {})
vim.keymap.set("n", "<leader>ct", ":CompetiTest receive testcases<CR>", {})
vim.keymap.set("n", "<leader>cma", ":CompetiTest add_testcase<CR>", {})
vim.keymap.set("n", "<leader>cme", ":CompetiTest edit_testcase<CR>", {})
vim.keymap.set("n", "<leader>cmd", ":CompetiTest delete_testcase<CR>", {})
vim.keymap.set("n", "<leader>cmd", ":CompetiTest delete_testcase<CR>", {})

-- oil
map("n", "<C-n>", function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "oil" then
			vim.api.nvim_win_close(win, true)
			return
		end
	end

	vim.cmd("topleft 30vsplit")
	vim.cmd("Oil")
end, {
	desc = "Toggle Oil",
})

-- }}}
-- {{{ aucmds
vim.api.nvim_create_augroup("SetTextWidth", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "SetTextWidth",
	pattern = { "markdown", "text" },
	callback = function()
		vim.opt_local.textwidth = 80
	end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- General AutoCMDs
vim.cmd([[
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]])

local function max_signs_per_line(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	local placed = vim.fn.sign_getplaced(buf, { group = "*" })
	local max_per_line = 0

	if #placed > 0 then
		local counts = {}
		for _, sign in ipairs(placed[1].signs) do
			local lnum = sign.lnum
			counts[lnum] = (counts[lnum] or 0) + 1
			if counts[lnum] > max_per_line then
				max_per_line = counts[lnum]
			end
		end
	end

	return max_per_line
end

local last_max = 0

-- autocommand: re-check whenever signs may change
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "BufEnter", "DiagnosticChanged" }, {
	callback = function()
		local max_now = max_signs_per_line()
		if max_now ~= last_max then
			last_max = max_now
			if max_signs_per_line() > 1 then
				vim.opt.signcolumn = "auto:3"
			else
				vim.opt.signcolumn = "yes:1"
			end
		end
	end,
})

-- }}}
-- {{{ lsp
vim.diagnostic.config({ virtual_text = true })

vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--header-insertion=iwyu",
		"--header-insertion-decorators=0",
		"--clang-tidy",
		-- "--enable-config",
	},
})

vim.lsp.enable({
	"clangd",
	"jdtls",
	"lua_ls",
})
-- }}}
-- {{{ plugins
vim.opt.packpath:prepend(vim.fn.stdpath("config"))
vim.pack.add({
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/xeluxee/competitest.nvim" },
	{ src = "https://github.com/mcauley-penney/tidy.nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
})

require("nvim-treesitter").setup({
	ensure_installed = {
		"cpp",
		"java",
		"lua",
		"markdown",
		"markdown_inline",
		"sql",
	},
})

require("conform").setup({
	formatters_by_ft = {
		c = { "clang-format" },
		cpp = { "clang-format" },
		java = { "clang-format" },
		lua = { "stylua" },
	},

	format_on_save = {
		timeout_ms = 100000,
		lsp_format = "fallback",
	},
})

require("oil").setup({
	delete_to_trash = true,
	prompt_save_on_select_new_entry = false,
	use_default_keymaps = true,
	view_options = {
		-- Show files and directories that start with "."
		show_hidden = true,
	},
})

require("competitest").setup({ -- to customize settings
	runner_ui = { interface = "popup" },
	popup_ui = {
		total_width = 0.8,
		total_height = 0.8,
		layout = {
			{ 1, { { 1, { { 0.8, "tc" }, { 1, "si" } } }, { 1, "so" } } },
			{ 1, { { 1, "se" }, { 1, "eo" } } },
		},
	},
	save_current_file = true,
	compile_directory = ".",
	compile_command = {
		cpp = {
			exec = "/usr/bin/g++",
			-- exec = "g++",
			args = {
				-- "-D_GLIBCXX_DEBUG",
				-- "-fsanitize=address",
				-- "-fsanitize=address,undefined",
				"-std=c++17",
				-- "-std=c++23",
				-- "-O0",
				"-Wall",
				"-Wextra",
				-- "-fpch-preprocess",
				"-Wshadow",
				-- "-O2",
				"-DONPC",
				-- "-DCIDE",
				-- "-fno-exceptions",
				-- "-fno-rtti",
				-- "-ftime-report",
				"$(FNAME)",
				"-o",
				"$(FNOEXT)",
			},
		},
		rust = { exec = "rustc", args = { "$(FNAME)" } },
	},
	running_directory = ".",
	run_command = {
		c = { exec = "./$(FNOEXT)" },
		cpp = { exec = "./$(FNOEXT)" },
		rust = { exec = "./$(FNOEXT)" },
		python = { exec = "pypy3", args = { "./$(FNAME)" } },
		java = { exec = "java", args = { "./$(FNAME)" } },
	},
	testcases_directory = "./testcases",
	testcases_input_file_format = "$(FNOEXT)_input_$(TCNUM).txt",
	testcases_output_file_format = "$(FNOEXT)_output_$(TCNUM).txt",
})

require("tidy").setup()

require("nvim-autopairs").setup()

-- [[ Snippet Engine ]]

-- NOTE: You can also specify plugin using a version range for its git tag.
--  See `:help vim.version.range()` for more info
vim.pack.add({ { src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2.*") } })
require("luasnip").setup({})

-- `friendly-snippets` contains a variety of premade snippets.
--    See the README about individual language/framework/plugin snippets:
--    https://github.com/rafamadriz/friendly-snippets
--
vim.pack.add({ "https://github.com/rafamadriz/friendly-snippets" })
require("luasnip.loaders.from_vscode").lazy_load()
vim.pack.add({ { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") } })
require("blink.cmp").setup({
	keymap = {
		preset = "none",

		["<Tab>"] = {
			"select_next",
			"fallback",
		},

		["<S-Tab>"] = {
			"select_prev",
			"fallback",
		},

		["<CR>"] = {
			"accept",
			"fallback",
		},
	},

	appearance = {
		-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
		-- Adjusts spacing to ensure icons are aligned
		nerd_font_variant = "mono",
	},

	completion = {
		-- By default, you may press `<c-space>` to show the documentation.
		-- Optionally, set `auto_show = true` to show the documentation after a delay.
		documentation = { auto_show = true, auto_show_delay_ms = 5 },
	},

	sources = {
		default = { "lsp", "path", "snippets" },
	},

	snippets = { preset = "luasnip" },

	-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
	-- which automatically downloads a prebuilt binary when enabled.
	--
	-- By default, we use the Lua implementation instead, but you may enable
	-- the rust implementation via `'prefer_rust_with_warning'`
	--
	-- See `:help blink-cmp-config-fuzzy` for more information
	fuzzy = { implementation = "lua" },

	-- Shows a signature help window while you type arguments for a function
	signature = { enabled = true },
})
-- }}}
