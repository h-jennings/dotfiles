-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- Create undo directory if it doesn't exist
local undodir = os.getenv("HOME") .. "/.nvim/undodir"
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

-- Auto-reload files when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	desc = "Check if files need to be reloaded",
	group = vim.api.nvim_create_augroup("auto-reload", { clear = true }),
	callback = function()
		if vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})

-- Close certain filetypes with q
vim.api.nvim_create_autocmd("FileType", {
	desc = "Close certain filetypes with q",
	group = vim.api.nvim_create_augroup("close-with-q", { clear = true }),
	pattern = {
		"qf",
		"help",
		"man",
		"notify",
		"lspinfo",
		"startuptime",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- Fall back to the dashboard when the last real file is closed, instead of
-- being left on an empty [No Name] buffer. Snacks only opens the dashboard
-- at startup and exposes no option for this, so it's wired up by hand.
vim.api.nvim_create_autocmd("BufDelete", {
	desc = "Show dashboard when the last file buffer is closed",
	group = vim.api.nvim_create_augroup("dashboard-on-empty", { clear = true }),
	callback = function()
		-- BufDelete fires *before* the buffer is unlisted, so defer the check.
		-- Deliberately not comparing against the event's buffer number: those
		-- get recycled, and by the time this runs the deleted buffer is already
		-- unlisted, so the `buflisted` test below excludes it anyway.
		vim.schedule(function()
			-- Don't fight Neovim on the way out: quitting deletes every buffer.
			if vim.v.exiting ~= vim.NIL then
				return
			end

			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if
					vim.bo[buf].buflisted
					and vim.bo[buf].buftype == ""
					and vim.api.nvim_buf_get_name(buf) ~= ""
				then
					return
				end
			end

			-- Only take over an ordinary window. Floating pickers and the file
			-- tree can be focused when a background buffer is deleted, and
			-- replacing those with the dashboard would be hostile.
			local win = vim.api.nvim_get_current_win()
			if vim.api.nvim_win_get_config(win).relative ~= "" or vim.bo.buftype ~= "" then
				return
			end

			-- `win`/`buf` of 0 reuse the current ones, so the dashboard renders
			-- in place rather than opening a float over the top.
			require("snacks").dashboard({ win = 0, buf = 0 })
		end)
	end,
})

-- Dependency sources aren't yours to fix, so diagnostics on them are pure
-- noise: they follow a `gd` into a `.d.ts` and then sit in the workspace-wide
-- lists for the rest of the session. Disabling per buffer (rather than
-- detaching the client) keeps hover and go-to-definition working in there.
vim.api.nvim_create_autocmd("BufReadPost", {
	desc = "Disable diagnostics in node_modules",
	group = vim.api.nvim_create_augroup("no-node-modules-diagnostics", { clear = true }),
	pattern = "*/node_modules/*",
	callback = function(event)
		vim.diagnostic.enable(false, { bufnr = event.buf })
	end,
})

-- Resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
	desc = "Resize splits when window is resized",
	group = vim.api.nvim_create_augroup("resize-splits", { clear = true }),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})
