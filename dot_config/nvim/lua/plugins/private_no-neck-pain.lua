return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	keys = {
		{ "<leader>cl", "<cmd>NoNeckPain<cr>", desc = "Toggle no-neck-pain (center layout)" },
	},
	opts = {
		width = 160,
		integrations = {
			-- `<leader>xr` opens trouble as a right-hand split. Not a built-in
			-- integration, so without this its width skews the centering.
			trouble = { position = "right" },
		},
	},
}
