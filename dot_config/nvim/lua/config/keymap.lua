local opts = { noremap = true, silent = true }

-- Toggle word wrap
vim.keymap.set("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
end, { noremap = true, silent = true, desc = "Toggle word wrap" })

-- Toggle diagnostic virtual lines. Handy when the message below the cursor
-- gets in the way while editing dense code.
vim.keymap.set("n", "<leader>tv", function()
	local shown = vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = not shown and { current_line = true } or false })
end, { noremap = true, silent = true, desc = "Toggle diagnostic virtual lines" })

-- `hlsearch` keeps matches lit until something clears them, and `<Esc>` is
-- otherwise a no-op in normal mode. The trailing `<Esc>` keeps pending state
-- (counts, operators) cancelling as usual.
vim.keymap.set(
	"n",
	"<Esc>",
	"<cmd>nohlsearch<CR><Esc>",
	{ noremap = true, silent = true, desc = "Clear search highlight" }
)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)
vim.keymap.set("n", "<C-j>", ":cnext<CR>", opts)
vim.keymap.set("n", "<C-k>", ":cprevious<CR>", opts)
vim.keymap.set("n", "<leader>q", ":cclose<CR>", { noremap = true, silent = true, desc = "Close quickfix list" })
vim.keymap.set("n", "<leader>R", function()
	vim.ui.input({ prompt = "Command: " }, function(command)
		local dir = vim.fn.expand("%:p:h")
		if command then -- check for nil in case user cancels
			vim.cmd(string.format("!cd %s && %s", vim.fn.fnameescape(dir), command))
		end
	end)
end, opts)
vim.keymap.set("v", "<leader>R", function()
	vim.ui.input({ prompt = "Command: " }, function(command)
		local dir = vim.fn.expand("%:p:h")
		if command then -- check for nil in case user cancels
			vim.cmd(string.format("!cd %s && %s", vim.fn.fnameescape(dir), command))
		end
	end)
end, opts)

-- `<C-w>+` takes a count but doesn't repeat, so every nudge is a fresh chord.
-- This holds the keyboard until you leave, which matches herdr's own modal
-- resize (prefix+shift+r) instead of competing with it. Keys are read with
-- getcharstr(), so they bypass mappings and can't collide with anything.
vim.keymap.set("n", "<leader>w", function()
	local step = 2
	local actions = {
		h = "vertical resize -" .. step,
		l = "vertical resize +" .. step,
		j = "resize -" .. step,
		k = "resize +" .. step,
		["="] = "wincmd =",
	}
	while true do
		vim.cmd("redraw")
		vim.api.nvim_echo({ { "-- RESIZE --  h/l width  j/k height  =  <Esc>", "ModeMsg" } }, false, {})
		local ok, ch = pcall(vim.fn.getcharstr)
		if not ok then -- <C-c>
			break
		end
		if actions[ch] then
			pcall(vim.cmd, actions[ch])
		elseif ch == "\27" or ch == "q" then
			break
		else
			-- Replay whatever else you typed rather than swallowing it.
			vim.api.nvim_feedkeys(ch, "n", false)
			break
		end
	end
	vim.api.nvim_echo({}, false, {})
end, { noremap = true, silent = true, desc = "Resize mode" })
