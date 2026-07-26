return {
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {},
	},
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	{
		"folke/trouble.nvim",
		opts = {
			auto_close = true, -- auto close when no items
			auto_open = false, -- don't auto open
			focus = true, -- focus trouble
			modes = {
				diagnostics = {
					auto_refresh = true, -- auto refresh diagnostics
				},
			},
		},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			-- Deliberately not `gr`: Neovim 0.11 ships `grr`/`gra`/`grn`/`gri`/
			-- `grt`/`grx` as defaults, and a bare `gr` mapping is a strict
			-- prefix of all six — every one of them would stall for
			-- `timeoutlen` first. Kept in the existing `<leader>x` Trouble
			-- namespace instead.
			{
				"<leader>xr",
				"<cmd>Trouble lsp toggle focus=true win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
		},
	},
	{
		"stevearc/quicker.nvim",
		ft = "qf",
		config = function()
			require("quicker").setup({
				use_default_opts = true,
				keys = {
					{
						">",
						function()
							require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
						end,
						desc = "Expand quickfix context",
					},
				},
			})
		end,
	},
}
