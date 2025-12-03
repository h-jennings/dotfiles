return {
	"github/copilot.vim",
	event = "InsertEnter",
	config = function()
		-- Use a specific Node.js version (mise/asdf may switch to older versions per project)
		-- Set this to your global Node.js 22+ path
		vim.g.copilot_node_command = vim.fn.expand("~/.local/share/mise/installs/node/latest/bin/node")

		-- Disable default Tab mapping to avoid conflict with nvim-cmp
		vim.g.copilot_no_tab_map = true

		-- Keymaps
		vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
			desc = "Copilot: Accept suggestion",
		})

		vim.keymap.set("i", "<C-L>", "<Plug>(copilot-accept-word)", {
			desc = "Copilot: Accept word",
		})

		vim.keymap.set("i", "<C-H>", "<Plug>(copilot-dismiss)", {
			desc = "Copilot: Dismiss suggestion",
		})

		vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", {
			desc = "Copilot: Next suggestion",
		})

		vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", {
			desc = "Copilot: Previous suggestion",
		})

		-- Optional: Disable for certain filetypes
		vim.g.copilot_filetypes = {
			["*"] = true,
			gitcommit = false,
			gitrebase = false,
		}
	end,
}
