return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"saghen/blink.cmp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			-- Shared float window border style
			local border_style = {
				{ "╭", "FloatBorder" },
				{ "─", "FloatBorder" },
				{ "╮", "FloatBorder" },
				{ "│", "FloatBorder" },
				{ "╯", "FloatBorder" },
				{ "─", "FloatBorder" },
				{ "╰", "FloatBorder" },
				{ "│", "FloatBorder" },
			}

			-- Configure diagnostics
			vim.diagnostic.config({
				underline = true,
				virtual_text = false,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚",
						[vim.diagnostic.severity.WARN] = "󰀪",
						[vim.diagnostic.severity.HINT] = "󰌶",
						[vim.diagnostic.severity.INFO] = "󰋽",
					},
					numhl = {
						[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
						[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
					},
				},
				float = {
					border = border_style,
					source = "always",
					focusable = false,
					style = "minimal",
					max_width = 80,
					max_height = 20,
					pad_top = 1,
					pad_bottom = 1,
				},
			})

			-- Configure hover handler to match diagnostics styling
			local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
			function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
				opts = opts or {}
				opts.border = opts.border or border_style
				opts.max_width = opts.max_width or 80
				opts.max_height = opts.max_height or 20
				return orig_util_open_floating_preview(contents, syntax, opts, ...)
			end

			-- Get capabilities from blink.cmp and set globally
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-- Configure LSP keymaps and features on attach
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)

					local map = function(mode, keys, func, desc)
						vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
					end

					-- Navigation
					map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
					map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
					map("n", "gi", function()
						require("snacks").picker.lsp_implementations()
					end, "Goto Implementations")
					map("n", "gA", function()
						require("snacks").picker.lsp_references()
					end, "Find References")
					map("n", "gy", vim.lsp.buf.type_definition, "Type Definition")

					-- Diagnostics
					map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")

					-- Symbols
					map("n", "gs", function()
						require("snacks").picker.lsp_symbols()
					end, "Buffer symbols")
					map("n", "gS", function()
						require("snacks").picker.lsp_workspace_symbols()
					end, "Buffer symbols")

					-- Call hierarchy
					map("n", "gic", function()
						require("snacks").picker.lsp_incoming_calls()
					end, "Incoming calls")
					map("n", "goc", function()
						require("snacks").picker.lsp_outgoing_calls()
					end, "Outgoing calls")

					-- Actions
					map("n", "gh", vim.lsp.buf.hover, "Hover")
					map("n", "cd", vim.lsp.buf.rename, "Rename")
					map("n", "g.", vim.lsp.buf.code_action, "Code action")

					map("n", "<leader>lr", "<cmd>LspRestart<cr>", "Restart LSP")

					-- Enable inlay hints if supported
					if client and client.supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

						map("n", "<leader>th", function()
							vim.lsp.inlay_hint.enable(
								not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
								{ bufnr = bufnr }
							)
						end, "[T]oggle Inlay [H]ints")
					end

					-- Biome: Apply safe fixes on save
					if client and client.name == "biome" then
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.code_action({
									context = {
										only = { "source.fixAll.biome" },
										diagnostics = {},
									},
									apply = true,
								})
							end,
						})
					end
				end,
			})

			-- Setup Mason
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"vtsls",
					"cssls",
					"cssmodules_ls",
					"lua_ls",
					"eslint",
					"biome",
					"tailwindcss",
					"jsonls",
					"typos_lsp",
				},
				automatic_installation = false,
			})

			-- Configure LSP servers
			vim.lsp.config("vtsls", {
				settings = {
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						preferences = {
							includePackageJsonAutoImports = "on",
							importModuleSpecifier = "non-relative",
							disableSuggestions = false,
							autoImportFileExcludePatterns = { "node_modules/*", ".turbo/*" },
						},
						inlayHints = {
							parameterNames = { enabled = "none" },
							parameterTypes = { enabled = false },
							variableTypes = { enabled = false },
							propertyDeclarationTypes = { enabled = false },
							functionLikeReturnTypes = { enabled = true },
							enumMemberValues = { enabled = false },
						},
						tsserver = {
							maxTsServerMemory = 8192,
							skipLibCheck = true,
							useSyntaxServer = "auto",
							watchOptions = {
								excludeDirectories = {
									"**/node_modules",
									"**/.turbo",
									"**/.git",
									"**/dist",
									"**/build",
								},
							},
						},
					},
					javascript = {
						updateImportsOnFileMove = { enabled = "always" },
						preferences = {
							includePackageJsonAutoImports = "on",
							importModuleSpecifier = "non-relative",
						},
						inlayHints = {
							parameterNames = { enabled = "none" },
							parameterTypes = { enabled = false },
							variableTypes = { enabled = false },
							propertyDeclarationTypes = { enabled = false },
							functionLikeReturnTypes = { enabled = true },
							enumMemberValues = { enabled = false },
						},
					},
					vtsls = {
						autoUseWorkspaceTsdk = true,
						enableMoveToFileCodeAction = true,
						experimental = {
							maxInlayHintLength = 65,
						},
					},
				},
			})

			-- Enable LSP servers
			vim.lsp.enable("vtsls")
			vim.lsp.enable("cssls")
			vim.lsp.enable("cssmodules_ls")
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("eslint")
			vim.lsp.enable("biome")
			vim.lsp.enable("tailwindcss")
			vim.lsp.enable("jsonls")
			vim.lsp.enable("typos_lsp")
		end,
	},
	{
		"saghen/blink.cmp",
		version = "v0.*",
		opts = {
			keymap = {
				preset = "default",
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
				["<C-y>"] = { "select_and_accept" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },
			},
			completion = {
				menu = {
					auto_show = true,
				},
				ghost_text = {
					enabled = false,
				},
			},
			sources = {
				default = { "lsp" },
				providers = {
					lsp = {
						opts = {
							tailwind_color_icon = "██",
						},
					},
				},
			},
		},
	},
}
