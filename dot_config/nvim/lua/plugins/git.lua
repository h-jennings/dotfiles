return {
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",
		keys = {
			{
				"<leader>gd",
				function()
					local base = vim.fn.systemlist("git symbolic-ref --short refs/remotes/origin/HEAD")[1]
					if vim.v.shell_error ~= 0 then
						base = nil
						for _, b in ipairs({ "develop", "main", "master" }) do
							vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", b })
							if vim.v.shell_error == 0 then
								base = b
								break
							end
						end
					end
					if not base then
						return vim.notify("CodeDiff: no base branch found", vim.log.levels.WARN)
					end
					vim.cmd("CodeDiff " .. base .. "...")
				end,
				desc = "Diff stack vs default branch (CodeDiff)",
			},
			{ "<leader>gD", ":CodeDiff ", desc = "CodeDiff against…" },
		},
		opts = {},
	},
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

				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, { desc = "Blame Line" })
				map("n", "<leader>hB", gs.blame, { desc = "Blame File (pane)" })
				map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
				map("n", "<leader>tB", function()
					vim.g.gitsigns_base_head = not vim.g.gitsigns_base_head
					if vim.g.gitsigns_base_head then
						gs.change_base("HEAD", true)
						vim.notify("Gitsigns: comparing against HEAD (staged changes visible)")
					else
						gs.reset_base(true)
						vim.notify("Gitsigns: comparing against index")
					end
				end, { desc = "Toggle diff base HEAD / index" })
				-- Was `toggle_deleted`, now deprecated in favour of this: rather
				-- than globally showing every deleted line, it renders the hunk
				-- under the cursor inline, deletions included.
				map("n", "<leader>td", gs.preview_hunk_inline, { desc = "Preview Hunk Inline (w/ deleted)" })
			end,
		},
	},
}
