return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			-- `biome-check` over `biome`: it runs `biome check --write`, so one
			-- formatter covers formatting, safe lint fixes and import sorting.
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "biome-check", "oxfmt", "prettier", stop_after_first = true },
				typescript = { "biome-check", "oxfmt", "prettier", stop_after_first = true },
				typescriptreact = { "biome-check", "oxfmt", "prettier", stop_after_first = true },
				javascriptreact = { "biome-check", "oxfmt", "prettier", stop_after_first = true },
				json = { "biome-check", "prettier", stop_after_first = true },
				-- No biome: its Vue support is script-block only, and
				-- `stop_after_first` would let it beat oxfmt.
				vue = { "oxfmt", "prettier", stop_after_first = true },
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
				["biome-check"] = { require_cwd = true },
				oxfmt = { require_cwd = true },
				prettier = { require_cwd = true },
			},
			-- `lsp_format` is left at its "never" default on purpose: with
			-- `fallback`, a project that disqualifies every formatter above gets
			-- restyled by whichever LSP answers — vue_ls was rewriting 54 lines
			-- of an oxfmt repo per write.
			format_on_save = {
				timeout_ms = 3000,
			},
		})
	end,
}
