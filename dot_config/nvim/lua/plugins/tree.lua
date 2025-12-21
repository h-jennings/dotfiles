return {
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>e", "<cmd>Yazi<cr>", desc = "Open yazi at current file" },
			{ "<C-n>", "<cmd>Yazi toggle<cr>", desc = "Toggle yazi" },
			{ "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Open yazi at cwd" },
		},
		opts = {
			open_for_directories = true, -- replaces netrw
			keymaps = {
				show_help = "<f1>",
				replace_in_directory = false,
			},
			integrations = {
				grep_in_directory = function(directory)
					require("snacks").picker.grep({ cwd = directory })
				end,
			},
		},
		init = function()
			vim.g.loaded_netrwPlugin = 1 -- disable netrw
		end,
	},
}
