return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			-- Ensure these parsers are installed (async; no-op if already present).
			require("nvim-treesitter").install({
				"lua",
				"typescript",
				"tsx",
				"markdown",
				"markdown_inline",
				"json",
			})

			-- On `main`, highlighting is no longer auto-enabled. Start treesitter
			-- for any filetype that has an installed parser; skip the rest.
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
					if lang and pcall(vim.treesitter.language.add, lang) then
						vim.treesitter.start(args.buf, lang)
					end
				end,
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
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
				},
				move = {
					set_jumps = true,
				},
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")
			local swap = require("nvim-treesitter-textobjects.swap")

			-- Select
			local select_maps = {
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
			}
			for lhs, query in pairs(select_maps) do
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject(query, "textobjects")
				end, { desc = "Select " .. query })
			end

			-- Move
			local move_maps = {
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
			}
			for fn, maps in pairs(move_maps) do
				for lhs, query in pairs(maps) do
					vim.keymap.set({ "n", "x", "o" }, lhs, function()
						move[fn](query, "textobjects")
					end, { desc = fn .. " " .. query })
				end
			end

			-- Swap
			vim.keymap.set("n", "<leader>sa", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap next parameter" })
			vim.keymap.set("n", "<leader>sA", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap previous parameter" })

			-- NOTE: lsp_interop / peek_definition_code (<leader>df, <leader>dF)
			-- was removed in the textobjects `main` rewrite and has no replacement.
		end,
	},
}
