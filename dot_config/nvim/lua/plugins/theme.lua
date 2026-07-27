return {
	{
		"webhooked/kanso.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- Slightly modified version of the default float colors for better contrast with the background
			local float = {
				ink = { bg = "#22262D", fg = "#C5C9C7", bg_border = "#22262D", fg_border = "#75797f" },
				pearl = { bg = "#e2e1df", fg = "#22262D", bg_border = "#e2e1df", fg_border = "#6d6d69" },
			}

			require("kanso").setup({
				bold = false,
				italics = false,
				colors = {
					theme = {
						ink = { ui = { float = float.ink } },
						pearl = { ui = { float = float.pearl } },
					},
				},
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
