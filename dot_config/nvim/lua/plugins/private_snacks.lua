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
			layout = {
				cycle = false,
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
			sources = {
				files = {
					hidden = true,
					exclude = { "node_modules/*" },
				},
				git_files = {
					hidden = true,
				},
				grep = {
					hidden = true,
					exclude = { "node_modules/*" },
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
	--     <alt-g> - toggle live mode
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
			"<leader>gd",
			function()
				vim.ui.input({ prompt = "Directory: ", default = vim.fn.getcwd(), completion = "dir" }, function(dir)
					if dir and dir ~= "" then
						require("snacks").picker.grep({ cwd = vim.fn.expand(dir) })
					end
				end)
			end,
			desc = "Grep in directory",
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
			desc = "Grep word under cursor",
			mode = { "n", "x" },
		},
		{
			"<leader>gg",
			function()
				require("snacks").lazygit()
			end,
			desc = "Open lazygit",
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
