return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		dashboard = {
			enabled = true,
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "projects", icon = " ", title = "Projects", indent = 2, padding = 1 },
				{ section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1, limit = 8 },
				{ section = "startup" },
			},
		},
		lazygit = {
			enabled = true,
		},
		picker = {
			layout = {
				layout = {
					backdrop = false,
					width = 0.8,
					height = 0.95,
					box = "vertical",
					border = "rounded",
					title = "{title} {live} {flags}",
					title_pos = "center",
					{ win = "preview", title = "{preview}", height = 0.6, border = "bottom" },
					{ win = "input", height = 1, border = "bottom" },
					{ win = "list", border = "none" },
				},
			},
			sources = {
				files = {
					hidden = true,
					exclude = { "node_modules/*" },
				},
				git_files = {
					hidden = true,
				},
				grep = {
					hidden = true,
					exclude = { "node_modules/*" },
				},
			},
		},
	},
	keys = {
		{
			"<leader>ff",
			function()
				require("snacks").picker.files()
			end,
			desc = "Find all files",
		},
		{
			"<leader>fg",
			function()
				require("snacks").picker.git_files()
			end,
			desc = "Find files tracked with Git",
		},
		{
			"<leader>o",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Recent buffers",
		},
		{
			"g/",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Multi grep (pattern  glob)",
		},
		{
			"<leader>*",
			function()
				require("snacks").picker.grep_word()
			end,
			desc = "Grep word under cursor",
			mode = { "n", "x" },
		},
		{
			"<leader>gg",
			function()
				require("snacks").lazygit()
			end,
			desc = "Open lazygit",
		},
	},
}
