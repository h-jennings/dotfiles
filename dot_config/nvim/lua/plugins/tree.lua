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
				-- `<c-s>` in yazi greps wherever you've navigated to. Both use
				-- the built-in "snacks.picker" string rather than a hand-rolled
				-- function: it titles the picker with the directory, and it
				-- carries a `defer_fn` + `startinsert` workaround for something
				-- that kicks the picker out of insert mode when it opens after
				-- yazi closes. A custom function gets neither.
				grep_in_directory = "snacks.picker",
				-- `<c-s>` dispatches here instead when files are multi-selected
				-- in yazi, so grep is scoped to just those paths. This defaulted
				-- to "telescope", which isn't installed — multi-select + `<c-s>`
				-- was a hard error.
				grep_in_selected_files = "snacks.picker",
			},
		},
		init = function()
			vim.g.loaded_netrwPlugin = 1 -- disable netrw
		end,
	},
}
