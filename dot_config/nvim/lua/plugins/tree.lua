return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "-", "<cmd>Oil --float --preview<cr>", desc = "Open parent directory" },
		},
		opts = {
			default_file_explorer = true,
			columns = { "icon", "permissions", "size", "mtime" },
			view_options = { show_hidden = true },
			lsp_file_methods = { autosave_changes = true },
			float = { max_width = 200 },
		},
	},
}
