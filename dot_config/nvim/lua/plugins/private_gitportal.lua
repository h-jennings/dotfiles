return {
	"trevorhauter/gitportal.nvim",
	config = function()
		local gitportal = require("gitportal")

		gitportal.setup({
			always_include_current_line = true,
		})

		-- Open current file in browser (with line in normal, selection in visual)
		vim.keymap.set({ "n", "v" }, "<leader>go", gitportal.open_file_in_browser, { desc = "Git open in browser" })

		-- Copy permalink to clipboard (with line in normal, selection in visual)
		vim.keymap.set({ "n", "v" }, "<leader>gl", gitportal.copy_link_to_clipboard, { desc = "Git copy link" })

		-- Open git URL in Neovim
		vim.keymap.set("n", "<leader>gi", gitportal.open_file_in_neovim, { desc = "Git open URL in Neovim" })
	end,
}
