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

-- Resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
	desc = "Resize splits when window is resized",
	group = vim.api.nvim_create_augroup("resize-splits", { clear = true }),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})
