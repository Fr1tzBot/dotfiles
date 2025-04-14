return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
    },
    config = function()
        local cmp = require("cmp")

        cmp.setup({
            preselect = cmp.PreselectMode.None,
            completion = {
                completeopt = 'menu,menuone,noinsert,noselect',
            },
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
            }),
            snippet = {
                -- expand = function(args)
                --     vim.fn["vsnip#anonymous"](args.body)
                -- end,
            },
        })
    end,
}

