return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("lualine").setup({
			options = {
				globalstatus = true,
			},
			sections = {
				lualine_c = {
					function()
						return require("arrow.statusline").text_for_statusline_with_icons()
					end,
					{ "filename", path = 1 },
				},
			},
		})
	end,
}
