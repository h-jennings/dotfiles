return {
	{
		-- Installed from GitHub now that it is published. To go back to hacking
		-- on it locally, add `dir = vim.fn.expand("~/repos/personal/nushu.nvim")`
		-- — but note ~/.config/yazi/flavors symlinks into lazy's copy of this
		-- plugin, so a local checkout also wants those symlinks repointed.
		"h-jennings/nushu.nvim",
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
