require("config.lazy")

require("nvim-treesitter.configs").setup({
    ensure_installed = {"c", "lua", "vim", "markdown", "bash"},
    highlight = { enable = true },
    indent = { enable = true }
})

require("mason-tool-installer").setup {
    ensure_installed = {
        "clangd",
        "rust-analyzer",
        "bash-language-server",
        "shellcheck",
        "pylint"
    },

    auto_update = true,
}

vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
}

vim.opt.termguicolors = true
vim.opt.autoindent = true
vim.opt.startofline = true
vim.opt.confirm = true
vim.opt.mouse = "a"
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.title = true
vim.opt.showcmd = true
vim.opt.cursorline = false
vim.opt.wildmenu = true
vim.opt.showmatch = true
vim.opt.emoji = true
vim.opt.showmode = true
vim.opt.hls = true
vim.opt.ic = true
vim.opt.is = true
vim.opt.cursorcolumn = false
vim.opt.scrolljump = 5
vim.opt.lazyredraw = true
vim.opt.redrawtime = 10000
vim.opt.synmaxcol = 180
vim.opt.re = 1
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.cmdheight = 1
vim.opt.updatetime = 300
vim.opt.shortmess:append("c")
vim.opt.signcolumn = "yes"
vim.opt.whichwrap = "<,>,[,]"
vim.opt.backspace = "indent,eol,start"

-- disable auto commenting new lines
vim.cmd("autocmd BufEnter * set fo-=c fo-=r fo-=o")
-- remove trailing whitespaces on save
vim.cmd("autocmd BufWritePre * %s/\\s\\+$//e")
-- return to last edit position when opening a file
vim.cmd("autocmd BufReadPost * if line(\"'\\\"\") > 0 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif")

--map q to quit in normal mode
vim.api.nvim_set_keymap("n", "q", ":q<CR>", { noremap = true, silent = true })
--same for q!
vim.api.nvim_set_keymap("n", "Q", ":q!<CR>", { noremap = true, silent = true })
--Wq typo alias
vim.api.nvim_create_user_command('Wq', 'wq', {})

vim.api.nvim_set_keymap("i", "<Tab>", "<C-T>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", "<C-D>", { noremap = true, silent = true })


vim.opt.syntax = "on"
vim.cmd("colorscheme gruvbox")
vim.opt.background = "dark"
--make bg transparent
vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")

--disable copilot by default
vim.cmd("Copilot suggestion toggle_auto_trigger")
