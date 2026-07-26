return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			current_line_blame = false,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1000,
			},
			preview_config = {
				border = "rounded",
				style = "minimal",
			},
			on_attach = function(bufnr)
				local gs = require("gitsigns")

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation. `next_hunk`/`prev_hunk` are deprecated in favour
				-- of `nav_hunk(direction)`; the guard stays because `]c`/`[c`
				-- are Vim's own diff-mode motions and must win there.
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.nav_hunk("next")
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Next Hunk" })

				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.nav_hunk("prev")
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Previous Hunk" })

				-- Actions
				-- `stage_hunk` toggles: pressed on an already-staged hunk it
				-- unstages. That's why there's no `<leader>hu` — the deprecated
				-- `undo_stage_hunk` it used to call is now just this key again.
				map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage / unstage Hunk" })
				map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Stage Hunk" })
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Reset Hunk" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, { desc = "Blame Line" })
				-- Full-file blame in a side pane that scrolls with the buffer —
				-- the sustained version of `<leader>hb`'s one-line popup.
				map("n", "<leader>hB", gs.blame, { desc = "Blame File (pane)" })
				map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "Diff This ~" })

				-- Every hunk in the working tree, in one list. quicker.nvim
				-- makes the quickfix editable, so this is the one review flow
				-- lazygit has no answer for: read all the changes top to bottom,
				-- fix typos in place, `:w` to write across every file.
				map("n", "<leader>hq", function()
					gs.setqflist("all")
				end, { desc = "All hunks in repo → quickfix" })
				map("n", "<leader>hQ", function()
					gs.setqflist()
				end, { desc = "Buffer hunks → quickfix" })

				-- Toggles
				map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
				-- Was `toggle_deleted`, now deprecated in favour of this: rather
				-- than globally showing every deleted line, it renders the hunk
				-- under the cursor inline, deletions included.
				map("n", "<leader>td", gs.preview_hunk_inline, { desc = "Preview Hunk Inline (w/ deleted)" })

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Hunk" })
			end,
		},
	},
}
