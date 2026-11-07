return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "-", "<cmd>Oil --float --preview<cr>", desc = "Open parent directory" },
		},
		opts = {
			default_file_explorer = true,
			columns = { "icon", "permissions", "size", "mtime" },
			view_options = { show_hidden = true },
			lsp_file_methods = { autosave_changes = true },
			float = { max_width = 200 },
		},
		init = function()
			-- vtsls only gets rename events for ts/js files and folders, so
			-- renaming a `.vue` file updated no imports. Ask its tsserver
			-- (with the Vue plugin) for the edits directly, like VS Code does.
			vim.api.nvim_create_autocmd("User", {
				pattern = "OilActionsPost",
				callback = function(args)
					if args.data.err then
						return
					end
					for _, action in ipairs(args.data.actions) do
						local _, src = require("oil.util").parse_url(action.src_url or "")
						local _, dest = require("oil.util").parse_url(action.dest_url or "")
						if action.type == "move" and action.entry_type == "file" and src and dest and src:match("%.vue$") then
							require("config.vue_rename").update_imports(src, dest)
						end
					end
				end,
			})
		end,
	},
}
