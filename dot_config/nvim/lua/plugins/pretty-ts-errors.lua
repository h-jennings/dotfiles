-- Needs the CLI: `npm i -g pretty-ts-errors-markdown`.
-- Auto-open is off: it pops a float on every CursorHold, fighting `gl`.
return {
	{
		"youyoumu/pretty-ts-errors.nvim",
		cmd = { "PrettyTsError", "PrettyTsErrors", "PrettyTsToggleAuto" },
		keys = {
			{ "gL", function() require("pretty-ts-errors").show_formatted_error() end, desc = "Pretty TS error" },
		},
		opts = {
			auto_open = false,
		},
	},
}
