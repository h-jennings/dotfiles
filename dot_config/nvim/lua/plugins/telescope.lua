return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"debugloop/telescope-undo.nvim",
		"isak102/telescope-git-file-history.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	lazy = false,
	opts = {
		pickers = {
			find_files = {
				hidden = true,
			},
			git_files = {
				hidden = true,
			},
		},
		defaults = {
			file_ignore_patterns = {
				"node_modules/*",
			},
			layout_strategy = "vertical",
			layout_config = {
				height = 0.95,
				width = 0.8,
				prompt_position = "bottom",
				vertical = {
					preview_height = 0.6,
				},
			},
		},
		extensions = {
			fzf = {},
		},
	},
	config = function(_, opts)
		require("telescope").setup(opts)
		require("telescope").load_extension("undo")
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("git_file_history")
	end,
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find all files" },
		{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find files tracked with Git" },
		{ "<leader>o", "<cmd>Telescope buffers<cr>", desc = "Recent buffers" },
		{
			"g/",
			function()
				require("config.telescope.multigrep").live_multigrep()
			end,
			desc = "Multi grep (pattern  glob)",
		},
		{ "<leader>u", "<cmd>Telescope undo<cr>", desc = "Undo history" },
	},
}
