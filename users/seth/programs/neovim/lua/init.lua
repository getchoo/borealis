--
-- getchoo's neovim config (but in lua :p)
--

local cmd = vim.cmd
local opt = vim.opt

require("getchoo")
require("getchoo.ftdetect")
require("getchoo.lsp")

-- text options
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = false
opt.smartindent = true
opt.wrap = false

-- appearance
opt.syntax = "on"
cmd("filetype plugin indent on")
opt.termguicolors = true

require("catppuccin").setup({
	flavour = "mocha", -- mocha, macchiato, frappe, latte
	integrations = {
		barbar = true,
		gitsigns = true,
		lightspeed = true,
		mason = true,
		cmp = true,
		nvimtree = true,
		treesitter_context = true,
		treesitter = true,
		telescope = true,
		lsp_trouble = true,
	},
})
vim.api.nvim_command("colorscheme catppuccin")
