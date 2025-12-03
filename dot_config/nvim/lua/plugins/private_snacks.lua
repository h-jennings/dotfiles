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
	},
}
