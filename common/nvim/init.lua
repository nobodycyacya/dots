-- Reference
-- https://github.com/boltlessengineer/NativeVim
-- https://github.com/HCY-ASLEEP/NVIM-Config
-- https://github.com/LazyVim/LazyVim
-- https://github.com/AstroNvim/AstroNvim
-- https://github.com/NvChad/NvChad
-- https://github.com/ayamir/nvimdots
-- https://github.com/nvim-lua/kickstart.nvim

-- Option
vim.opt.clipboard = "unnamedplus,unnamed"
vim.opt.colorcolumn = "80"
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.wildmode = "longest:full,full"
vim.opt.winminwidth = 5
vim.opt.wrap = false
vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.undofile = false
vim.opt.background = "dark"
vim.cmd.colorscheme("habamax")

-- Keybinding
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.api.nvim_set_keymap("n", "<leader>CR", "<cmd>source $MYVIMRC<cr>", { desc = "Config: Reload" })
vim.api.nvim_set_keymap("n", "<leader>CE", "<cmd>edit $MYVIMRC<cr>", { desc = "Config: Edit" })
vim.api.nvim_set_keymap("i", "jk", "<esc>", { desc = "Back to Normal Mode" })
vim.api.nvim_set_keymap("v", "jk", "<esc>", { desc = "Stop Visual Mode" })
vim.api.nvim_set_keymap("c", "jk", "<c-c>", { desc = "Stop Input Commands" })
vim.api.nvim_set_keymap("i", "<C-a>", "<HOME>", { desc = "Move to Start" })
vim.api.nvim_set_keymap("v", "<C-a>", "<HOME>", { desc = "Move to Start" })
vim.api.nvim_set_keymap("c", "<C-a>", "<HOME>", { desc = "Move to Start" })
vim.api.nvim_set_keymap("i", "<C-e>", "<END>", { desc = "Move to End" })
vim.api.nvim_set_keymap("v", "<C-e>", "<END>", { desc = "Move to End" })
vim.api.nvim_set_keymap("c", "<C-e>", "<END>", { desc = "Move to End" })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { desc = "Move to Left Window" })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { desc = "Move to Down Window" })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { desc = "Move to Up Window" })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { desc = "Move to Right Window" })

-- Auto-Command
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ChangeTabSizeWithSpecificFileType", { clear = true }),
	pattern = { "python", "json", "jsonc" },
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 4
	end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ timeout = 2000 })
	end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("LastLocation", { clear = true }),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
			return
		end
		vim.b[buf].lazyvim_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("CloseWithQ", { clear = true }),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"snacks_win",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("WrapWithSpecificType", { clear = true }),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("AutoCreateDirWhenSaveFile", { clear = true }),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("DisabledAutoCommentNextLine", { clear = true }),
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "r", "o", "c" })
	end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("DisableSyntaxWithLargeFile", { clear = true }),
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local file_size = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))
		if file_size > 1.5 * 1024 * 1024 then
			vim.cmd("syntax clear")
		end
	end,
})

-- Bootstrap lazy.nvim
if not vim.loop.fs_stat(vim.fn.stdpath("data") .. "/lazy/lazy.nvim") then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		vim.fn.stdpath("data") .. "/lazy/lazy.nvim",
	})
end
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
require("lazy").setup({
	default = {
		lazy = true,
		version = "*",
		cond = nil,
	},
	ui = {
		size = {
			width = 0.92,
			height = 0.92,
		},
		wrap = true,
		border = "rounded",
		title = "lazy.nvim Panel",
		title_pos = "center",
		backdrop = 100,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"editorconfig",
				"2html_plugin",
				"tohtml",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logipat",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"man",
				"matchit",
				"matchparen",
				"osc52",
				"tar",
				"tarPlugin",
				"rplugin",
				"rrhelper",
				"shada",
				"spellfile",
				"spellfile_plugin",
				"vimball",
				"vimballPlugin",
				"zip",
				"zipPlugin",
				"tutor",
				"rplugin",
				"syntax",
				"synmenu",
				"optwin",
				"compiler",
				"bugreport",
				"ftplugin",
			},
		},
	},
	spec = {
		-- LazyVim --
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.ui.edgy",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.coding.luasnip",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.dap.core",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.editor.aerial",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.editor.illuminate",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.editor.navic",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.editor.neo-tree",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.editor.outline",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.editor.overseer",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.editor.refactoring",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.coding.nvim-cmp",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.formatting.black",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.formatting.prettier",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.clangd",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.cmake",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.go",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.json",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.markdown",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.python",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.r",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.sql",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.typescript",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lang.yaml",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.linting.eslint",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lsp.neoconf",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.lsp.none-ls",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.test.core",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.ui.mini-animate",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.ui.treesitter-context",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.util.project",
		-- },
		-- {
		-- 	"LazyVim/LazyVim",
		-- 	import = "lazyvim.plugins.extras.util.startuptime",
		-- },
		-- AstroNvim --
		{
			"AstroNvim/AstroNvim",
			version = "^5",
			import = "astronvim.plugins",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.bars-and-lines.dropbar-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.bars-and-lines.vim-illuminate",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.code-runner.overseer-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.color.modes-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.color.nvim-highlight-colors",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.color.twilight-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.comment.ts-comments-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.completion.nvim-cmp",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.completion.cmp-cmdline",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.completion.cmp-nvim-lua",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.debugging.nvim-dap-repl-highlights",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.debugging.nvim-dap-virtual-text",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.diagnostics.trouble-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.editing-support.auto-save-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.editing-support.bigfile-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.editing-support.nvim-treesitter-context",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.editing-support.rainbow-delimiters-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.editing-support.todo-comments-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.file-explorer.oil-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.fuzzy-finder.snacks-picker",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.git.diffview-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.git.neogit",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.indent.snacks-indent-hlchunk",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.lsp.lsp-signature-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.lsp.lspsaga-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.lsp.nvim-lint",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.markdown-and-latex.markdown-preview-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.motion.hop-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.motion.vim-matchup",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.bash",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.cmake",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.cpp",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.go",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.json",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.lua",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.markdown",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.python-ruff",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.sql",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.toml",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.typescript-all-in-one",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.pack.yaml",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.programming-language-support.csv-vim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.project.project-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.quickfix.nvim-bqf",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.recipes.vscode-icons",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.scrolling.mini-animate",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.scrolling.nvim-scrollbar",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.syntax.hlargs-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.syntax.vim-cool",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.test.neotest",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.utility.hover-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.utility.mason-tool-installer-nvim",
		},
		{
			"AstroNvim/astrocommunity",
			import = "astrocommunity.utility.neodim",
		},
	},
	local_spec = true,
	profiling = {
		loader = true,
		require = true,
	},
})
