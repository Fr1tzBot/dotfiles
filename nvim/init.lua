local gh = function(x) return 'https://github.com/' .. x end
local cb = function(x) return 'https://codeberg.org/' .. x end

--TODO: pin versions to releases where applicable
vim.pack.add({
    gh("ellisonleao/gruvbox.nvim"), --Theme
    gh("kdheepak/lazygit.nvim"), --Lazygit integration
    gh("nvim-tree/nvim-web-devicons"), --LuaLine/nvim-tree dependency
    gh('nvim-lualine/lualine.nvim'), --Line
    gh("hrsh7th/cmp-nvim-lsp"), --nvim-cmp dependency
    gh("hrsh7th/cmp-buffer"), --nvim-cmp dependency
    gh("hrsh7th/cmp-path"), --nvim-cmp dependency
    gh("L3MON4D3/LuaSnip"), --Snippet Engine (integrates with nvim-cmp)
    gh("saadparwaiz1/cmp_luasnip"), --Abandoned, so git latest is okay. LuaSnip source for nvim-cmp
    gh("hrsh7th/nvim-cmp"), --Autofill
    {src=gh("neovim/nvim-lspconfig"), version=vim.version.range("*")}, --Default LSP configs
    gh("folke/lazydev.nvim"), --Extensions for lua_ls lsp
    cb("mfussenegger/nvim-jdtls"), --Extensions for jdtls (java) lsp
    {src=gh("nvim-tree/nvim-tree.lua"), version=vim.version.range("*")}, --File Browser
    gh("nvim-lua/plenary.nvim"), --obsidian.nvim dependency
    {src=gh("obsidian-nvim/obsidian.nvim"), version=vim.version.range("*")}, --obsidian integration
})


-- remove packages that aren't specifically installed
local unused = vim.iter(vim.pack.get())
 :filter(function(x) return not x.active end)
 :map(function(x) return x.spec.name end)
 :totable()

for i, lang in pairs(unused) do
    vim.pack.del(lang)
end

local langs = {
    {prog="asm-lsp", lsp="asm_lsp"},
    {prog="bash-language-server", lsp="bashls"},
    {prog="clangd", lsp="clangd"},
    {prog="jdtls", lsp="jdtls"},
    {prog="lua-language-server", lsp="lua_ls"},
    {prog="matlab-language-server", lsp="matlab_ls"},
    {prog="pylsp", lsp="pylsp"},
    {prog="verible-verilog-ls", lsp="verible"},
    {prog="rust-analyzer", lsp="rust_analyzer"}
}

for i, lang in pairs(langs) do
    if vim.fn.executable(lang.prog) then
        -- print("Enabling "..lang.lsp)
        vim.lsp.enable(lang.lsp)
    end
end

-- vim.pack.update()
if vim.fn.executable("lua-language-server") then
    require("lazydev").setup{}
end

local cmp = require("cmp")
cmp.setup({
    preselect = cmp.PreselectMode.None,
    completion = {completeopt = 'menu,menuone,noinsert,noselect'},
    mapping = {
        --["<C-Space>"] = cmp.mapping.complete(),
        ["<S-CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
        { name = 'luasnip' },
    }),
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
})

require('nvim-tree').setup{}

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

require("obsidian").setup {
    workspaces = {
        {name = "brain", path = "~/Documents/brain"}
    },
    completion = {
        nvim_cmp = true,
        min_chars = 2,
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
vim.api.nvim_set_keymap("n", "q", ":q<CR>", { noremap = true, silent = true })
--same for q!
vim.api.nvim_set_keymap("n", "Q", ":q!<CR>", { noremap = true, silent = true })
--Wq typo alias
-- vim.api.nvim_create_user_command('Wq', 'wq', {})

vim.api.nvim_create_user_command("Lg", ":LazyGit", {nargs = 0, desc = "Open LazyGit"})

vim.api.nvim_set_keymap("i", "<Tab>", "<C-T>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", "<C-D>", { noremap = true, silent = true })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

vim.opt.syntax = "on"
vim.cmd("set clipboard+=unnamedplus")
vim.cmd("colorscheme gruvbox")
vim.opt.background = "dark"

--make bg transparent if sway is installed
if vim.fn.executable("sway") == 1 or vim.fn.executable("niri") then
    vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
end

