local opts = { noremap = true, silent = true }

-- Toggle word wrap
vim.keymap.set("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
end, { noremap = true, silent = true, desc = "Toggle word wrap" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)
vim.keymap.set("n", "<C-j>", ":cnext<CR>", opts)
vim.keymap.set("n", "<C-k>", ":cprevious<CR>", opts)
vim.keymap.set("n", "<leader>q", ":cclose<CR>", { noremap = true, silent = true, desc = "Close quickfix list" })
vim.keymap.set("n", "<leader>R", function()
	vim.ui.input({ prompt = "Command: " }, function(command)
		local dir = vim.fn.expand("%:p:h")
		if command then -- check for nil in case user cancels
			vim.cmd(string.format("!cd %s && %s", dir, command))
		end
	end)
end, opts)
vim.keymap.set("v", "<leader>R", function()
	vim.ui.input({ prompt = "Command: " }, function(command)
		local dir = vim.fn.expand("%:p:h")
		if command then -- check for nil in case user cancels
			vim.cmd(string.format("!cd %s && %s", dir, command))
		end
	end)
end, opts)
