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
					-- The autocmd in config/autocmds.lua only covers buffers that
					-- get read; a server can publish against a node_modules file
					-- that was never loaded, and trouble lists any valid buffer.
					-- `filename` is normalized to forward slashes.
					filter = {
						function(item)
							return not item.filename:find("/node_modules/", 1, true)
						end,
					},
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
			-- Reopens whatever a picker last sent here with `<a-t>`/`<a-a>`.
			-- Trouble's own state survives `auto_close`, so this is how you get
			-- a search result set back after dismissing the panel.
			{
				"<leader>xs",
				"<cmd>Trouble snacks toggle<cr>",
				desc = "Search results (Trouble)",
			},
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix list (Trouble)",
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
