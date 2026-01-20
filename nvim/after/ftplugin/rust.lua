vim.opt.tabstop=4
vim.opt.softtabstop=4
vim.opt.shiftwidth=4

vim.cmd([[
com! Format :wa | !cargo fmt
cnoreabbrev fmt Format
]])
