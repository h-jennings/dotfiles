-- The leader key was a blank wall: 20+ bindings spread across `<leader>f`,
-- `<leader>g`, `<leader>x` and friends, with nothing to tell you what's there
-- at the moment you press it. which-key turns the pause after `<leader>` into
-- a menu, so bindings get discovered instead of memorized.
--
-- Deliberately adds no keymaps of its own — the `spec` below is only labels
-- for prefixes that already exist.
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- Vertical list anchored to the right; easier to scan than the
		-- default bottom-of-screen grid once a group has ~8 entries.
		preset = "helix",
		-- Well under `timeoutlen` (300ms), so the popup shows up before
		-- Neovim would give up waiting for the rest of a mapping.
		delay = 250,
		icons = {
			mappings = false,
		},
		spec = {
			-- `<leader>g` is genuinely half grep and half git. Labelled as
			-- both rather than pretending otherwise.
			{ "<leader>g", group = "grep / git" },
			{ "<leader>gh", group = "github" },
			{ "<leader>f", group = "find" },
			{ "<leader>x", group = "trouble / lists" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "calls" },
			{ "<leader>t", group = "toggle" },
			{ "<leader>s", group = "treesitter swap" },
			{ "g", group = "goto / grep" },
		},
	},
	keys = {
		{
			"<leader>fw",
			function()
				require("which-key").show({ global = true })
			end,
			desc = "Show all keymaps (which-key)",
		},
	},
}
