return {
    -- https://github.com/tpope/vim-sleuth
    { "tpope/vim-sleuth" },
    -- https://github.com/windwp/nvim-autopairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
    },
    -- https://github.com/kylechui/nvim-surround
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = true
    },
    -- https://github.com/nvzone/typr
    {
        "nvzone/typr",
        dependencies = "nvzone/volt",
        opts = {},
        cmd = { "Typr", "TyprStats" },
    },
    -- https://github.com/akinsho/toggleterm.nvim
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("toggleterm").setup({
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                open_mapping = [[<leader>t]],
                hide_numbers = true,
                start_in_insert = true,
                insert_mappings = false,
                terminal_mappings = false,
                direction = "float",
                close_on_exit = true,
                float_opts = {
                    border = "rounded",
                    width = math.floor(vim.o.columns * 0.80),
                    height = math.floor(vim.o.lines * 0.90),
                    winblend = 0,
                },
            })
        end,
        keys = {
            { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",      desc = "Terminal Float" },
            { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal Horizontal" },
            { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>",   desc = "Terminal Vertical" },
        },
    }
}
