return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "biome", "oxfmt", "prettier", stop_after_first = true },
				typescript = { "biome", "oxfmt", "prettier", stop_after_first = true },
				typescriptreact = { "biome", "oxfmt", "prettier", stop_after_first = true },
				javascriptreact = { "biome", "oxfmt", "prettier", stop_after_first = true },
				json = { "biome", "prettier", stop_after_first = true },
				yaml = { "prettier" },
				markdown = { "prettier" },
				html = { "prettier" },
			},
			-- Each formatter only runs where the project has its config file.
			-- `require_cwd` is what enforces that: without it a failed cwd lookup
			-- is not disqualifying and the formatter runs anyway. Root detection
			-- itself is left to conform's defaults, which are broader than a
			-- hand-written list (biome also matches `.biome.json{,c}`; prettier
			-- also checks the `prettier` key in `package.json`).
			formatters = {
				biome = { require_cwd = true },
				oxfmt = { require_cwd = true },
				prettier = { require_cwd = true },
			},
			format_on_save = {
				timeout_ms = 3000,
				lsp_format = "fallback",
			},
		})
	end,
}
