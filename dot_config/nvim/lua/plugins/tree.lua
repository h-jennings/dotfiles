return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"antosha417/nvim-lsp-file-operations",
		},
		lazy = false,
		keys = {
			{ "<leader>e", "<cmd>Neotree reveal<cr>", desc = "Find file in filetree" },
			{ "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Toggle filetree" },
		},
		opts = {
			close_if_last_window = true,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			filesystem = {
				filtered_items = {
					visible = false,
					hide_dotfiles = true,
					hide_gitignored = false,
					hide_by_name = {
						".git",
						"node_modules",
						".vscode",
					},
				},
				follow_current_file = {
					enabled = true,
				},
				use_libuv_file_watcher = true,
			},
			window = {
				position = "float",
				width = 40,
			},
		},
	},
	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {},
	},
}
