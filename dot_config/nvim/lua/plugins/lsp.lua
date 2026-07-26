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
				-- Inline text on every diagnostic line is noise, and it fights
				-- `wrap`. `virtual_lines` renders the full message below the
				-- cursor's line only, so messages stay readable without
				-- permanently cluttering the buffer. Toggle with `<leader>tv`.
				virtual_text = false,
				virtual_lines = { current_line = true },
				-- Errors win the gutter sign and sort first in floats/lists
				-- when a line carries more than one severity.
				severity_sort = true,
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
					source = true,
					-- Focusable so a second `gl` enters the float and it can be
					-- scrolled: TypeScript type errors routinely run past
					-- `max_height` and were otherwise unreadable past line 20.
					focusable = true,
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
					end, "Workspace symbols")

					-- Call hierarchy. Moved off `gic`/`goc` because `gic` made
					-- the much more frequent `gi` a prefix, stalling it for
					-- `timeoutlen` on every use.
					map("n", "<leader>ci", function()
						require("snacks").picker.lsp_incoming_calls()
					end, "Incoming calls")
					map("n", "<leader>co", function()
						require("snacks").picker.lsp_outgoing_calls()
					end, "Outgoing calls")

					-- Actions
					map("n", "gh", vim.lsp.buf.hover, "Hover")
					map("n", "cd", vim.lsp.buf.rename, "Rename")
					map("n", "g.", vim.lsp.buf.code_action, "Code action")

					map("n", "<leader>lr", "<cmd>LspRestart<cr>", "Restart LSP")

					-- "Who imports this file?" — the whole-file counterpart to
					-- `gA`. A Vue SFC's default export has no symbol to put the
					-- cursor on, so symbol-based references can't answer it.
					-- This is the same command VS Code's "Find File References"
					-- runs, and vtsls attaches to `vue` buffers, so it works in
					-- SFCs as well as plain TS.
					if client and client.name == "vtsls" then
						map("n", "gF", function()
							client:exec_cmd({
								command = "typescript.findAllFileReferences",
								arguments = { vim.uri_from_bufnr(bufnr) },
							}, { bufnr = bufnr }, function(err, result)
								if err then
									vim.notify("File references: " .. err.message, vim.log.levels.ERROR)
									return
								end
								if not result or vim.tbl_isempty(result) then
									vim.notify("No file references found", vim.log.levels.WARN)
									return
								end
								vim.fn.setqflist({}, " ", {
									title = "File references: " .. vim.fn.expand("%:t"),
									items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
								})
								require("snacks").picker.qflist()
							end)
						end, "File references (who imports this file)")
					end

					-- Enable inlay hints if supported
					if client and client:supports_method("textDocument/inlayHint") then
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
					"oxlint",
					-- Installed for the binary only, not enabled as a server:
					-- mason puts it on PATH, which is where conform picks it up
					-- when a project has no local `node_modules/.bin/oxfmt`.
					"oxfmt",
					"vue_ls",
					"tailwindcss",
					"jsonls",
					"typos_lsp",
				},
				automatic_installation = false,
			})

			-- Vue 3.x runs in "hybrid mode": vue_ls owns the template/style blocks
			-- and forwards TypeScript requests to whichever TS server is attached
			-- to the *same* buffer. So vtsls must load `@vue/typescript-plugin`
			-- and attach to `vue` files, or `.vue` gets no TypeScript at all.
			local vue_language_server_path = vim.fs.joinpath(
				vim.fn.stdpath("data"),
				"mason/packages/vue-language-server/node_modules/@vue/language-server"
			)

			-- Configure LSP servers
			vim.lsp.config("vtsls", {
				-- lspconfig's defaults plus `vue`. Setting this replaces the
				-- default list rather than extending it, so the others are
				-- repeated here deliberately.
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"vue",
				},
				settings = {
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						preferences = {
							includePackageJsonAutoImports = "on",
							importModuleSpecifier = "non-relative",
							disableSuggestions = false,
							autoImportFileExcludePatterns = { ".turbo/*" },
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
						tsserver = {
							globalPlugins = {
								{
									name = "@vue/typescript-plugin",
									location = vue_language_server_path,
									languages = { "vue" },
									configNamespace = "typescript",
									enableForWorkspaceTypeScriptVersions = true,
								},
							},
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
			vim.lsp.enable("oxlint")
			vim.lsp.enable("vue_ls")
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
