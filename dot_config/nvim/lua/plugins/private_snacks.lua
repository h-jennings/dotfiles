-- Shared by the `files` and `grep` sources. Both previously used
-- `node_modules/*`, which silently did the wrong thing: a glob containing a
-- slash is anchored to the search root by both `rg -g` and `fd -E`, so only a
-- top-level `node_modules` was excluded and every `packages/*/node_modules` in
-- a monorepo leaked into results. `**/node_modules/**` matches at any depth.
local exclude = {
	"**/node_modules/**",
	"**/.turbo/**",
	"**/dist/**",
	"**/.next/**",
	"**/coverage/**",
	"**/*.lock",
	"**/pnpm-lock.yaml",
}

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		dashboard = {
			enabled = true,
			sections = {
				{ section = "header" },
				-- { section = "keys", gap = 1, padding = 1 },
				{ section = "projects", icon = " ", title = "Projects", indent = 2, padding = 1 },
				{ section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1, limit = 8 },
				{ section = "startup" },
			},
		},
		indent = {
			enabled = true,
			animate = {
				enabled = false,
			},
			scope = {
				enabled = true,
			},
		},
		input = {
			enabled = true,
		},
		lazygit = {
			enabled = true,
			-- `configure = true` (the default) is doing real work here: it
			-- generates a theme file from the current colorscheme and points
			-- lazygit at BOTH files via LG_CONFIG_FILE, so ~/.config/lazygit/
			-- config.yml still wins on everything it sets (delta pager, custom
			-- commands, sidePanelWidth). The generated file only adds colors,
			-- nerd font version, and `os.editPreset = "nvim-remote"` — which is
			-- the point: `e` on a file opens it in THIS Neovim, not a nested one.
			win = { style = "lazygit" },
			-- These are the `nvim-remote` preset's own commands with exactly
			-- one word changed: `--remote-tab` -> `--remote`. The preset opens
			-- every file in a NEW TAB, which is the safe choice for a tool that
			-- can't see your layout, but wrong for browsing a diff file by file
			-- — you end up with a tab per file you glanced at. `--remote` is
			-- `:edit` in the window you were already in.
			--
			-- Explicit `os.edit`/`os.editAtLine` take precedence over
			-- `os.editPreset`, which snacks still writes alongside them.
			config = {
				os = {
					edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})',
					editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>")',
				},
			},
		},
		styles = {
			lazygit = {
				-- snacks' terminal style binds a double-tap `<esc>` (within
				-- 200ms) to `stopinsert`. In lazygit `<esc>` is the back-out
				-- key and gets pressed fast and repeatedly, so this ejected you
				-- into normal mode mid-navigation. `false` disables the
				-- inherited mapping; `q` still hides the window.
				keys = { term_normal = false },
				-- 0.9 with a dimmed backdrop is right for a transient float.
				-- This isn't transient — it's where the work happens.
				width = 0.95,
				height = 0.95,
				backdrop = false,
			},
		},
		terminal = {
			enabled = true,
		},
		picker = {
			matcher = {
				frecency = true,
				filename_bonus = true,
				cwd_bonus = true,
			},
			-- Registered as a named preset rather than inlined into `layout`
			-- below: a global layout with positional window entries suppresses
			-- preset resolution for every source, so sources that ship their own
			-- preset (e.g. `select`, used by `vim.ui.select`) would inherit this
			-- one instead.
			layouts = {
				preview_top = {
					layout = {
						backdrop = false,
						width = 0.6,
						height = 0.9,
						box = "vertical",
						border = "rounded",
						title = "{title} {live} {flags}",
						title_pos = "center",
						{ win = "preview", title = "{preview}", height = 0.6, border = "bottom" },
						{ win = "input", height = 1, border = "bottom" },
						{ win = "list", border = "none" },
					},
				},
			},
			layout = {
				preset = "preview_top",
				cycle = false,
			},
			-- A picker is modal: it closes the moment you pick something, which
			-- is wrong for "find every use of X and work through them". These
			-- two hand the result set off to something that sticks around.
			-- `require` is deferred into the action body so this doesn't force
			-- Trouble to load at startup just to read the spec.
			actions = {
				trouble_open = function(picker)
					require("trouble.sources.snacks").open(picker, { type = "smart" })
				end,
				-- `add = true` appends instead of replacing, so several
				-- searches can be accumulated into one working set.
				trouble_add = function(picker)
					require("trouble.sources.snacks").open(picker, { type = "smart", add = true })
				end,
			},
			win = {
				input = {
					keys = {
						-- Joins the existing `<a-*>` family. `<c-t>` is taken by
						-- `tab` and `<c-a>` by `select_all`.
						["<a-t>"] = { "trouble_open", mode = { "i", "n" } },
						["<a-a>"] = { "trouble_add", mode = { "i", "n" } },
					},
				},
			},
			sources = {
				files = {
					hidden = true,
					exclude = exclude,
				},
				git_files = {
					hidden = true,
				},
				grep = {
					hidden = true,
					exclude = exclude,
				},
				lsp_symbols = {
					filter = {
						default = {
							"Class",
							"Constructor",
							"Enum",
							"Function",
							"Interface",
							"Method",
							"Struct",
						},
						markdown = true,
						help = true,
					},
				},
			},
		},
	},
	-- ─── SEARCHING: THE THREE KEYS THAT MATTER ───────────────────────────
	--   g/          Grep the project. This is the one.
	--   <leader>ff  Find a file by name.
	--   <leader>*   Grep what's under the cursor (or the selection, in visual).
	--
	--   Forgot something? <leader>fk fuzzy-searches every keymap you have,
	--   and which-key shows the menu if you just pause after <leader>.
	--
	--   Everything below is a variant. The `<leader>g{p,b}` maps are only
	--   shortcuts for what the inline syntax already does from inside `g/`.
	--   To grep a directory you have to pick, use `<leader>e` (yazi) to
	--   navigate there and hit `<c-s>` — no path typing.
	-- ─────────────────────────────────────────────────────────────────────
	--
	-- FZF SEARCH SYNTAX (use during interactive search):
	--   Inline filtering examples:
	--     file:lua$ searchterm    - Filter by filename ending in 'lua', then search
	--     searchterm -- -g=*.lua  - Add ripgrep glob option interactively
	--
	--   Built-in toggles:
	--     <alt-h> - toggle hidden files
	--     <alt-i> - toggle ignored files
	--     <alt-f> - toggle follow symlinks
	--     <alt-r> - toggle regex mode
	--     <ctrl-g> - toggle live mode
	--
	--   Making results persist (nothing is selected => acts on ALL results):
	--     <ctrl-q> - send to quickfix; quicker.nvim makes it editable, so you
	--                can retype matches in place and `:w` to write every file
	--     <alt-t>  - send to Trouble (persistent, navigable tree panel)
	--     <alt-a>  - ADD to Trouble, accumulating across several searches
	--     <Tab>    - select individual items first to narrow what gets sent
	keys = {
		{
			"<leader>ff",
			function()
				require("snacks").picker.files()
			end,
			desc = "Find all files",
		},
		{
			"<leader>fg",
			function()
				require("snacks").picker.git_files()
			end,
			desc = "Find files tracked with Git",
		},
		{
			"<leader>fd",
			function()
				vim.ui.input({ prompt = "Directory: ", default = vim.fn.getcwd(), completion = "dir" }, function(dir)
					if dir and dir ~= "" then
						require("snacks").picker.files({ cwd = vim.fn.expand(dir) })
					end
				end)
			end,
			desc = "Find files in directory",
		},
		{
			"<leader>fp",
			function()
				vim.ui.input({ prompt = "Pattern (e.g. *.lua): " }, function(pattern)
					if pattern and pattern ~= "" then
						require("snacks").picker.files({ glob = pattern })
					end
				end)
			end,
			desc = "Find files by pattern",
		},
		{
			"<leader>fk",
			function()
				require("snacks").picker.keymaps()
			end,
			desc = "Search keymaps",
		},
		{
			"<leader>o",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Recent buffers",
		},
		{
			"g/",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Multi grep (pattern  glob)",
		},
		{
			"<leader>gp",
			function()
				vim.ui.input({ prompt = "Pattern (e.g. *.lua): " }, function(pattern)
					if pattern and pattern ~= "" then
						require("snacks").picker.grep({ glob = pattern })
					end
				end)
			end,
			desc = "Grep by pattern",
		},
		{
			"<leader>gb",
			function()
				local buf_dir = vim.fn.expand("%:p:h")
				require("snacks").picker.grep({ cwd = buf_dir })
			end,
			desc = "Grep in buffer's directory",
		},
		{
			"<leader>*",
			function()
				require("snacks").picker.grep_word()
			end,
			desc = "Grep word under cursor (whole word)",
		},
		{
			"<leader>*",
			function()
				-- `grep_word` defaults to `args = { "--word-regexp" }`. That's
				-- right for `<cword>`, which is a complete word by definition,
				-- but wrong for a visual selection: selecting `seFooB` out of
				-- `useFooBar` has a word boundary at neither end, so ripgrep
				-- returned nothing at all. Clearing `args` makes the selection
				-- a plain substring search.
				require("snacks").picker.grep_word({ args = {} })
			end,
			desc = "Grep selection (substring)",
			mode = "x",
		},
		-- Narrower scopes than `g/`, for when the project-wide result set is
		-- more noise than signal.
		{
			"<leader>/",
			function()
				require("snacks").picker.lines()
			end,
			desc = "Search lines in current buffer",
		},
		{
			"<leader>?",
			function()
				require("snacks").picker.grep_buffers()
			end,
			desc = "Grep open buffers",
		},
		{
			"<leader>fr",
			function()
				require("snacks").picker.resume()
			end,
			desc = "Resume last picker",
		},
		{
			"<leader>gg",
			function()
				require("snacks").lazygit()
			end,
			desc = "Lazygit",
		},
		-- The two things lazygit structurally cannot do: it has no idea where
		-- your cursor is. Everything else about browsing history is better in
		-- lazygit, so nothing else from `picker.git_*` is bound here.
		{
			"<leader>gf",
			function()
				require("snacks").picker.git_log_file()
			end,
			desc = "History of this file",
		},
		{
			"<leader>gc",
			function()
				require("snacks").picker.git_log_line()
			end,
			desc = "History of this line",
		},
		-- Close the buffer, not the window. `:q` closes a window and exits
		-- Neovim once it's the last one; `:bd` keeps Neovim alive but tears
		-- down the layout when the buffer is in a split. `bufdelete` does
		-- neither: it swaps the window to the most-recently-used listed
		-- buffer, or an empty scratch buffer when nothing else is open.
		{
			"<leader>bd",
			function()
				require("snacks").bufdelete()
			end,
			desc = "Close buffer (keep window)",
		},
		{
			"<leader>bo",
			function()
				require("snacks").bufdelete.other()
			end,
			desc = "Close other buffers",
		},
		{
			"<C-`>",
			function()
				require("snacks").terminal.toggle()
			end,
			desc = "Toggle terminal",
			mode = { "n", "t" },
		},
		{
			"<leader>gho",
			function()
				require("snacks").picker.gh_pr()
			end,
			desc = "GitHub PRs (open)",
		},
		{
			"<leader>gha",
			function()
				require("snacks").picker.gh_pr({ state = "all" })
			end,
			desc = "GitHub PRs (all)",
		},
	},
}
