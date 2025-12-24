return {
	"otavioschwanck/arrow.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		show_icons = true,
		leader_key = "<space><space>", -- Quick access to bookmarks UI
		buffer_leader_key = "m", -- Buffer-specific bookmarks
		separate_by_branch = true, -- Separate bookmarks by git branch
		save_key = "cwd", -- Save bookmarks per working directory (project-specific)
		mappings = {
			edit = "e",
			delete_mode = "d",
			clear_all_items = "C",
			toggle = "s", -- save/remove current file
			open_vertical = "v",
			open_horizontal = "-",
			quit = "q",
			remove = "x",
		},
		window = {
			border = "rounded",
		},
	},
	keys = function()
		local arrow = require("arrow.persist")
		local ui = require("arrow.ui")

		return {
			-- Quick menu (similar to harpoon's <leader>he)
			{
				"<leader>hm",
				function()
					ui.openMenu()
				end,
				desc = "Arrow: Open menu",
			},
			-- Navigate to bookmarks 1-4
			{
				"<leader>hh",
				function()
					arrow.go_to(1)
				end,
				desc = "Arrow: Go to bookmark 1",
			},
			{
				"<leader>hj",
				function()
					arrow.go_to(2)
				end,
				desc = "Arrow: Go to bookmark 2",
			},
			{
				"<leader>hk",
				function()
					arrow.go_to(3)
				end,
				desc = "Arrow: Go to bookmark 3",
			},
			{
				"<leader>hl",
				function()
					arrow.go_to(4)
				end,
				desc = "Arrow: Go to bookmark 4",
			},
			-- Previous bookmark
			{
				"<leader>ho",
				function()
					require("arrow.persist").previous()
				end,
				desc = "Arrow: Previous bookmark",
			},
			-- Next bookmark
			{
				"<leader>hn",
				function()
					require("arrow.persist").next()
				end,
				desc = "Arrow: Next bookmark",
			},
			-- Toggle current file
			{
				"<leader>he",
				function()
					require("arrow.persist").toggle()
				end,
				desc = "Arrow: Toggle bookmark",
			},
		}
	end,
}
