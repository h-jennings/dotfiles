return {
	"trevorhauter/gitportal.nvim",
	config = function()
		local gitportal = require("gitportal")

		gitportal.setup({
			always_include_current_line = true,
		})

		-- Both take the cursor line in normal mode and the selected range in
		-- visual, so the link points at exactly what you're looking at.
		vim.keymap.set(
			{ "n", "v" },
			"<leader>go",
			gitportal.open_file_in_browser,
			{ desc = "Open this line on GitHub" }
		)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>gl",
			gitportal.copy_link_to_clipboard,
			{ desc = "Copy GitHub link to this line" }
		)

		-- `<leader>gi` (open_file_in_neovim: paste a GitHub URL, jump to that
		-- file and line) removed — the inverse direction, and not one you were
		-- reaching for. `:lua require("gitportal").open_file_in_neovim()` still
		-- works on the rare occasion it's wanted.
	end,
}
