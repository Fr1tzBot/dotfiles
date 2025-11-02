require("config.lazy")

require("nvim-treesitter.configs").setup({
    ensure_installed = {"c", "rust", "python", "lua", "vim", "markdown", "bash"},
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true }
})

local programs = {
    ["bash"] = "bash-language-server",
    ["clangd"] = "clangd",
    ["java"] = "jdtls",
    ["lua"] = "lua-language-server",
    ["pylint"] = "pylint",
    ["rust-analyzer"] = "rust-analyzer",
    ["shellcheck"] = "shellcheck"
}

local ensure_installed = {}

for bin, server in ipairs(programs) do
    if vim.fn.executable(bin) == 0 then
        table.insert(ensure_installed, server)
        print(server)
    end
end

require("mason-tool-installer").setup {
    ensure_installed = ensure_installed,
    auto_update = true,
}

require("mason").setup()

for _, i in pairs(ensure_installed) do
    vim.lsp.enable(i)
end

require('telescope').setup{
    pickers = {
        find_files = {
            hidden = true
        }
    },
    defaults = {
       file_ignore_patterns = { "^.git/" }
    }
}

require("lualine").setup {
    options = {
        theme = "gruvbox",
        icons_enabled = true,
    },
    sections = {
        lualine_a = {"mode"},
        lualine_b = {"branch", "diff", "diagnostics"},
        lualine_c = {"filename"},
        lualine_x = {"encoding", "fileformat", "filetype"},
        lualine_y = {"progress"},
        lualine_z = {"location"}
    }
}
-- disable default statusline
vim.opt.laststatus = 3
vim.opt.showtabline = 0


vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
}

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

vim.opt.termguicolors = true
vim.opt.autoindent = true
vim.opt.startofline = true
vim.opt.confirm = true
vim.opt.mouse = ""
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
vim.opt.conceallevel = 2

-- disable auto commenting new lines
vim.cmd("autocmd BufEnter * set fo-=c fo-=r fo-=o")
-- remove trailing whitespaces on save
vim.cmd("autocmd BufWritePre * %s/\\s\\+$//e")
-- return to last edit position when opening a file
vim.cmd("autocmd BufReadPost * if line(\"'\\\"\") > 0 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif")

--map q to quit in normal mode
-- vim.api.nvim_set_keymap("n", "q", ":q<CR>", { noremap = true, silent = true })
--same for q!
vim.api.nvim_set_keymap("n", "Q", ":q!<CR>", { noremap = true, silent = true })
--Wq typo alias
vim.api.nvim_create_user_command('Wq', 'wq', {})

vim.api.nvim_create_user_command("Lg", ":LazyGit", {nargs = 0, desc = "Open LazyGit"})

vim.api.nvim_set_keymap("i", "<Tab>", "<C-T>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", "<C-D>", { noremap = true, silent = true })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

vim.opt.syntax = "on"
vim.cmd("colorscheme gruvbox")
vim.opt.background = "dark"
--make bg transparent if sway is installed
if vim.fn.executable("sway") == 1 then
    vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
end

require("lazy").update({
    show = false,
    wait = false,
})

