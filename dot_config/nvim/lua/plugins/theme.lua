return {
	{
		"zenbones-theme/zenbones.nvim",
		lazy = false,
		priority = 1000,
		dependencies = { "rktjmp/lush.nvim" },
		config = function()
			vim.g.zenbones = {
				transparent_background = false,
				solid_line_nr = true,
				italic_comments = false,
				italic_strings = false,
			}
		end,
	},
	{
		"webhooked/kanso.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanso").setup({
				bold = false,
				italics = false,
			})
		end,
	},
	{
		"f-person/auto-dark-mode.nvim",
		opts = {
			update_interval = 1000,
			default = "dark",
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
				vim.cmd([[colorscheme kanso-ink]])
			end,
			set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
				vim.cmd([[colorscheme kanso-pearl]])
			end,
		},
	},
}
