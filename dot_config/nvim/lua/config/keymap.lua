local opts = { noremap = true, silent = true }

-- Toggle word wrap
vim.keymap.set("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
end, { noremap = true, silent = true, desc = "Toggle word wrap" })

-- Swap the current-line diagnostic between inline virtual text and full
-- virtual lines. Inline truncates at the window edge, which loses the tail of
-- long messages (TypeScript especially), so this is the escape hatch. The two
-- are mutually exclusive: enabling both renders the same message twice.
local inline_diagnostics
vim.keymap.set("n", "<leader>tv", function()
	local lines_shown = vim.diagnostic.config().virtual_lines
	inline_diagnostics = vim.diagnostic.config().virtual_text or inline_diagnostics
	vim.diagnostic.config({
		virtual_lines = not lines_shown and { current_line = true } or false,
		virtual_text = lines_shown and inline_diagnostics or false,
	})
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

-- herdr-annotate can only receive text through the system clipboard: its
-- `plugin action invoke` CLI takes no context argument, so capture.ts falls
-- back to reading the clipboard. Prepending file:line is the only way the
-- agent learns where the snippet came from -- the exported Markdown records
-- just the workspace/tab label, never a path.
vim.keymap.set("x", "<leader>a", function()
	vim.cmd('normal! "+y')
	-- Read the marks after the yank; it exits visual mode and sets '< and '>.
	local file = vim.fn.expand("%:.")
	local text = vim.fn.getreg("+")
	if file ~= "" then
		text = string.format("%s:%d\n%s", file, vim.fn.line("'<"), text)
	end
	vim.fn.setreg("+", text)
	vim.fn.jobstart({ "herdr", "plugin", "action", "invoke", "annotate.capture" })
end, { noremap = true, silent = true, desc = "Annotate in Herdr" })

vim.keymap.set("n", "ZR", "<cmd>silent! wa | restart<cr>", { desc = "Save all and restart Neovim" })

local function file_ref(absolute, first, last)
	local path = vim.fn.expand(absolute and "%:p" or "%:.")
	local range = first == last and ("#L" .. first) or string.format("#L%d-%d", first, last)
	return "@" .. path .. range
end

local function visual_range()
	local a, b = vim.fn.line("v"), vim.fn.line(".")
	return math.min(a, b), math.max(a, b)
end

local function copy(text)
	vim.fn.setreg("+", text)
	vim.notify("Copied " .. vim.split(text, "\n")[1])
end

vim.keymap.set("n", "<leader>yf", function()
	local line = vim.fn.line(".")
	copy(file_ref(false, line, line))
end, { desc = "Copy @file#Lline" })
vim.keymap.set("x", "<leader>yf", function()
	copy(file_ref(false, visual_range()))
end, { desc = "Copy @file#Lstart-end" })
vim.keymap.set("n", "<leader>yp", function()
	local line = vim.fn.line(".")
	copy(file_ref(true, line, line))
end, { desc = "Copy @abs-file#Lline" })

vim.keymap.set("x", "<leader>yc", function()
	local first, last = visual_range()
	local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
	local ref = file_ref(false, first, last)
	copy(ref .. "\n```" .. vim.bo.filetype .. "\n" .. table.concat(lines, "\n") .. "\n```")
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
end, { desc = "Copy selection as code block" })
