return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = function()
		local harpoon = require("harpoon")

		return {
			-- Add current file to harpoon
			{
				"<leader>hm",
				function()
					harpoon:list():add()
				end,
				desc = "Harpoon: Mark file",
			},
			-- Edit editors (same as quick pick in nvim)
			{
				"<leader>he",
				function()
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon: Edit editors",
			},
			-- Navigate to editors 1-4 with hjkl
			{
				"<leader>hh",
				function()
					harpoon:list():select(1)
				end,
				desc = "Harpoon: Go to 1",
			},
			{
				"<leader>hj",
				function()
					harpoon:list():select(2)
				end,
				desc = "Harpoon: Go to 2",
			},
			{
				"<leader>hk",
				function()
					harpoon:list():select(3)
				end,
				desc = "Harpoon: Go to 3",
			},
			{
				"<leader>hl",
				function()
					harpoon:list():select(4)
				end,
				desc = "Harpoon: Go to 4",
			},
			-- Previous harpoon editor
			{
				"<leader>ho",
				function()
					harpoon:list():prev()
				end,
				desc = "Harpoon: Previous editor",
			},
			-- Add to specific slots 1-4
			{
				"<leader>h1",
				function()
					harpoon:list():replace_at(1)
				end,
				desc = "Harpoon: Add to slot 1",
			},
			{
				"<leader>h2",
				function()
					harpoon:list():replace_at(2)
				end,
				desc = "Harpoon: Add to slot 2",
			},
			{
				"<leader>h3",
				function()
					harpoon:list():replace_at(3)
				end,
				desc = "Harpoon: Add to slot 3",
			},
			{
				"<leader>h4",
				function()
					harpoon:list():replace_at(4)
				end,
				desc = "Harpoon: Add to slot 4",
			},
		}
	end,
}
