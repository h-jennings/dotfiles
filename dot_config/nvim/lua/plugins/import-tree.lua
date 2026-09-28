return {
	-- Import graph as an upward tree: the current file at the bottom, its
	-- importers stacked above, expand a layer at a time up to a page. See
	-- the repo's README.
	"h-jennings/import-tree.nvim",
	-- Use the local checkout under lazy's `dev.path` while working on the
	-- plugin. Machines without a checkout fall back to the GitHub repo.
	dev = true,
	keys = {
		{
			"<leader>cp",
			function()
				require("import-tree").tree()
			end,
			desc = "Importer tree (upward)",
		},
	},
	opts = {
		-- Keys are Lua patterns matched against the vtsls root, so one
		-- entry also covers a repo's worktrees.
		projects = {
			["hyper%-space"] = {
				-- Router-level components, marked as pages in the tree.
				ceiling = { "/src/pages/" },
			},
		},
	},
}
