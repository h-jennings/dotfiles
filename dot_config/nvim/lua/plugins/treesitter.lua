return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
				},
				ensure_installed = {
					"lua",
					"typescript",
					"tsx",
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			max_lines = 1,
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							-- Functions
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							-- Classes
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							-- Parameters/arguments
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							-- Conditionals
							["ai"] = "@conditional.outer",
							["ii"] = "@conditional.inner",
							-- Loops
							["al"] = "@loop.outer",
							["il"] = "@loop.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]]"] = "@class.outer",
							["]a"] = "@parameter.inner",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[["] = "@class.outer",
							["[a"] = "@parameter.inner",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>sa"] = "@parameter.inner",
						},
						swap_previous = {
							["<leader>sA"] = "@parameter.inner",
						},
					},
					lsp_interop = {
						enable = true,
						border = "rounded",
						floating_preview_opts = {},
						peek_definition_code = {
							["<leader>df"] = "@function.outer",
							["<leader>dF"] = "@class.outer",
						},
					},
				},
			})
		end,
	},
}
