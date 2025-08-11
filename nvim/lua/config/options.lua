-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Enable true color support
vim.opt.termguicolors = true

-- Set leader key (LazyVim uses space by default)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable line numbers
vim.opt.number = false
vim.opt.relativenumber = false

-- Single file workflow - close current buffer when opening new files
vim.opt.hidden = false -- Don't keep buffers hidden
