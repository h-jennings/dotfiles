return {
	"trevorhauter/gitportal.nvim",
	config = function()
		local gitportal = require("gitportal")

		gitportal.setup({
			always_include_current_line = true,
		})

		-- Open current file in browser (with line in normal, selection in visual)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>gp",
			gitportal.open_file_in_browser,
			{ desc = "Open file in browser" }
		)

		-- Copy permalink to clipboard (with line in normal, selection in visual)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>gy",
			gitportal.copy_link_to_clipboard,
			{ desc = "Copy permalink to clipboard" }
		)

		-- Open git URL in Neovim
		vim.keymap.set("n", "<leader>ig", gitportal.open_file_in_neovim, { desc = "Open git URL in Neovim" })
	end,
}
