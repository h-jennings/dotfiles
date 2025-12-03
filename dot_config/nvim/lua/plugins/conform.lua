return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "biome", "prettier", stop_after_first = true },
				typescript = { "biome", "prettier", stop_after_first = true },
				typescriptreact = { "biome", "prettier", stop_after_first = true },
				javascriptreact = { "biome", "prettier", stop_after_first = true },
				json = { "biome", "prettier", stop_after_first = true },
				yaml = { "prettier" },
				markdown = { "prettier" },
				html = { "prettier" },
			},
			formatters = {
				biome = {
					require_cwd = true,
					cwd = require("conform.util").root_file({ "biome.json", "biome.jsonc" }),
				},
				prettier = {
					cwd = require("conform.util").root_file({
						".prettierrc",
						".prettierrc.json",
						".prettierrc.yml",
						".prettierrc.yaml",
						".prettierrc.json5",
						".prettierrc.js",
						".prettierrc.cjs",
						".prettierrc.mjs",
						"prettier.config.js",
						"prettier.config.cjs",
						"prettier.config.mjs",
					}),
				},
			},
			format_on_save = {
				timeout_ms = 3000,
				lsp_format = "fallback",
			},
		})
	end,
}
