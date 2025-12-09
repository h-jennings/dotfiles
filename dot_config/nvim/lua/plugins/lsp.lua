return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
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

			-- Get capabilities from nvim-cmp and set globally
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
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
					"harper_ls",
				},
				automatic_installation = false,
			})

			-- Configure LSP servers
			vim.lsp.config("harper_ls", {
				settings = {
					["harper-ls"] = {
						linters = {
							SpellCheck = false, -- typos handles all spell checking
							SpelledNumbers = false,
							AnA = true,
							SentenceCapitalization = false,
							UnclosedQuotes = true,
							WrongQuotes = false,
							LongSentences = true,
							RepeatedWords = true,
							Spaces = true,
							Matcher = true,
						},
					},
				},
			})

			vim.lsp.config("vtsls", {
				settings = {
					typescript = {
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
						tsserver = {
							maxTsServerMemory = 8192,
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
			vim.lsp.enable("harper_ls")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"js-everts/cmp-tailwind-colors",
		},
		config = function()
			local cmp = require("cmp")
			local cmp_select = { behavior = cmp.SelectBehavior.Insert }
			cmp.setup({
				completion = {
					autocomplete = false, -- Disable automatic completion popup
				},
				experimental = {
					ghost_text = false, -- Disabled to avoid conflict with Copilot inline suggestions
				},
				sources = {
					{ name = "nvim_lsp" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(), -- Manual trigger completion menu
					["<Tab>"] = cmp.mapping.select_next_item({ behaviour = cmp.SelectBehavior.Insert }),
					["<S-Tab>"] = cmp.mapping.select_prev_item({ behaviour = cmp.SelectBehavior.Insert }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				formatting = {
					format = require("cmp-tailwind-colors").format,
				},
			})
		end,
	},
}
