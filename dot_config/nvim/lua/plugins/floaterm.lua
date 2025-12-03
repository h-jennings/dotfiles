return {
	"voldikss/vim-floaterm",
	config = function()
		-- Floaterm settings
		vim.g.floaterm_width = 0.9
		vim.g.floaterm_height = 0.9
		vim.g.floaterm_title = ""
		vim.g.floaterm_borderchars = "─│─│╭╮╯╰"

		-- Keybindings
		-- Toggle terminal with <C-`>
		vim.keymap.set("n", "<C-`>", ":FloatermToggle<CR>", { desc = "Toggle floaterm", silent = true })
		vim.keymap.set("t", "<C-`>", "<C-\\><C-n>:FloatermToggle<CR>", { desc = "Toggle floaterm", silent = true })
	end,
}
