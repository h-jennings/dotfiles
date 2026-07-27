return {
	{
		"h-jennings/nushu.nvim",
		-- Local checkout while working out the quirks; remove `dir` to install
		-- from GitHub once stable
		dir = vim.fn.expand("~/repos/personal/nushu.nvim"),
		lazy = false,
		priority = 1000,
		config = function()
			require("nushu").setup({
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
				vim.cmd([[colorscheme nushu]])
			end,
			set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
				vim.cmd([[colorscheme nushu]])
			end,
		},
	},
}
