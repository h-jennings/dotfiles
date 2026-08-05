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
				-- Undercurl + gutter signs only. Inline text and virtual lines
				-- both shift the buffer around as the cursor moves; read the
				-- full message with `gl` or toggle lines with `<leader>tv`.
				virtual_text = false,
				virtual_lines = false,
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

					-- No `:LspRestart` on 0.12 — lspconfig bails when builtin `:lsp` exists.
					map("n", "<leader>lr", "<cmd>lsp restart<cr>", "Restart LSP")

					if client and client.name == "vtsls" then
						-- Restarts tsserver inside vtsls, so the client stays attached and
						-- `<leader>lr`'s detach/reattach of every other server is avoided.
						map("n", "<leader>lt", function()
							client:exec_cmd({ command = "typescript.restartTsServer" }, { bufnr = bufnr })
						end, "Restart tsserver")

						-- For stale tsconfig/node_modules after a branch switch or install.
						map("n", "<leader>lp", function()
							client:exec_cmd({ command = "typescript.reloadProjects" }, { bufnr = bufnr })
						end, "Reload TS projects")

						-- "Who imports this file?" — the whole-file counterpart to
						-- `gA`. A Vue SFC's default export has no symbol to put the
						-- cursor on, so symbol-based references can't answer it.
						-- This is the same command VS Code's "Find File References"
						-- runs, and vtsls attaches to `vue` buffers, so it works in
						-- SFCs as well as plain TS.
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

					-- Vue hybrid mode puts two inlay-hint providers on one buffer,
					-- but nvim tracks a single document version for all of them:
					-- whichever answers second makes the other's columns stale, and
					-- the decoration provider throws "Invalid 'col'" mid-edit. vtsls
					-- owns the TS hints here, so drop vue_ls's.
					if client and client.name == "vue_ls" then
						client.server_capabilities.inlayHintProvider = nil
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

					-- Wash the other occurrences of whatever the cursor is on, so a
					-- token reads as a reference without opening `gA`. No `enable()`
					-- API for this one on 0.12, so it's a hand-rolled pair: the handler
					-- adds extmarks without clearing first, which is what
					-- `clear_references` is for. One pair per buffer, not per client —
					-- hence the guard, since LspAttach fires once per client.
					if
						client
						and client:supports_method("textDocument/documentHighlight")
						and not vim.b[bufnr].document_highlight_attached
					then
						vim.b[bufnr].document_highlight_attached = true

						-- Buffer-scoped autocmds in a shared group, so Neovim drops them
						-- with the buffer. A per-buffer group would leak, and couldn't be
						-- deleted on LspDetach anyway — that fires per client.
						local group = vim.api.nvim_create_augroup("lsp-document-highlight", { clear = false })

						-- In an SFC vue_ls and vtsls both answer with the same ranges but
						-- different kinds, so the declaration's wash lands on whichever
						-- shade is drawn last. Accepted: `document_highlight()` takes no
						-- say in which clients answer, and both shades are subtle.
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							desc = "Highlight references to the symbol under the cursor",
							group = group,
							buffer = bufnr,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							desc = "Clear reference highlights",
							group = group,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.clear_references()
							end,
						})

						-- Otherwise a dead server's marks sit there until the next cursor
						-- move. The autocmds can stay: with nothing left to answer, the
						-- request is a no-op.
						vim.api.nvim_create_autocmd("LspDetach", {
							desc = "Drop reference highlights when a server detaches",
							group = group,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.clear_references()
							end,
						})
					end
				end,
			})

			-- nvim 0.12's builtin capability providers (document_color, semantic
			-- tokens, …) leak a stopped client's id: `Client:_on_detach` only forgets
			-- the client while `client:supports_method()` still answers true, which it
			-- doesn't for a *dynamically* registered capability once the server is
			-- gone (tailwindcss registers `textDocument/documentColor` that way). The
			-- provider keeps the dead id, and document_color re-requests on every edit
			-- via `on_lines`, so `assert(get_client_by_id(id))` then fires on every
			-- keystroke. Drop the id ourselves, first, on every detach.
			vim.api.nvim_create_autocmd("LspDetach", {
				desc = "Forget a detaching client in builtin LSP capability providers",
				callback = function(args)
					-- Private module on purpose — nothing public reaches this state.
					-- pcall so an upgrade that fixes or renames it degrades to a no-op
					-- instead of erroring on every detach.
					local ok, providers = pcall(function()
						return vim.lsp._capability.all
					end)
					if not ok then
						return
					end

					for _, Provider in pairs(providers) do
						local provider = Provider.active[args.buf]
						if provider and provider.client_state[args.data.client_id] then
							provider:on_detach(args.data.client_id)
							if not next(provider.client_state) then
								provider:destroy()
							end
						end
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
				-- Otherwise mason-lspconfig enables every server it finds installed,
				-- including leftovers no longer listed above. The explicit
				-- `vim.lsp.enable()` calls below are the source of truth.
				automatic_enable = false,
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

			-- lspconfig's tailwindcss root_dir ends its marker list with `.git` — a
			-- fallback for v4, where `tailwind.config.*` is optional — so the server
			-- starts in *any* git repo holding a JS/TS/CSS file, tailwind or not.
			-- Same list without that fallback: a real config file, or `tailwindcss`
			-- named in package.json, which is how v4 projects pull it in.
			vim.lsp.config("tailwindcss", {
				root_dir = function(bufnr, on_dir)
					local fname = vim.api.nvim_buf_get_name(bufnr)
					local root_files = {
						"tailwind.config.js",
						"tailwind.config.cjs",
						"tailwind.config.mjs",
						"tailwind.config.ts",
						"postcss.config.js",
						"postcss.config.cjs",
						"postcss.config.mjs",
						"postcss.config.ts",
					}
					root_files = require("lspconfig.util").insert_package_json(root_files, "tailwindcss", fname)

					local found = vim.fs.find(root_files, { path = fname, upward = true })[1]
					if found then
						on_dir(vim.fs.dirname(found))
					end
				end,
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
