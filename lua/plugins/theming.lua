local function github()
    return {
        "projekt0n/github-nvim-theme",
        config = function()
            -- vim.cmd('colorscheme github_dark')
        end,
    }
end

return {
    github(),
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                },
                extensions = { "nvim-tree" },
                sections = {
                    lualine_a = {"mode"},
                    lualine_b = {"branch", "diff", "diagnostics"},
                    lualine_c = {{"filename", path=3}},
                    lualine_x = {"encoding", "filetype", "lsp_status"},
                    lualine_y = {"progress"},
                    lualine_z = {"location"}
                },
            })
        end
    },
    {
        "f-person/auto-dark-mode.nvim",
        opts = {
            set_dark_mode = function()
                vim.cmd('colorscheme github_dark_tritanopia')
            end,
            set_light_mode = function()
                vim.cmd('colorscheme github_light_tritanopia')
            end,
        }
    }
}
