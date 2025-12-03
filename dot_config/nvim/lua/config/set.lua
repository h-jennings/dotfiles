-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Tabs and indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Line wrapping
vim.opt.wrap = true
vim.opt.linebreak = true -- Break at word boundaries
vim.opt.breakindent = true -- Preserve indentation in wrapped lines
vim.opt.showbreak = "↪ " -- Visual indicator for wrapped lines

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Appearance
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.cursorline = true

-- Undercurl terminal codes
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.opt.undofile = true

-- Split windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Update time
vim.opt.updatetime = 250

-- Command line
vim.opt.showcmd = true
vim.opt.cmdheight = 1

-- Backspace behavior
vim.opt.backspace = "indent,eol,start"

-- Fold settings
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99
vim.opt.foldenable = true

-- Completion options
vim.opt.completeopt = "menu,menuone,noselect"

-- Mouse support
vim.opt.mouse = "a"

-- Performance
vim.opt.lazyredraw = false
vim.opt.timeoutlen = 300
