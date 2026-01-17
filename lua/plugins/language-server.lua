local arr = require("internal.array")
local lang = require("internal.language-server")

-- https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
local lsp_servers = {
    lang.server("dockerls"),
    lang.server("gopls", {
        -- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#configuration
        settings = {
            gopls = {
                -- gofumpt = true,
                codelenses = {
                    gc_details = false,
                    generate = true,
                    regenerate_cgo = true,
                    run_govulncheck = true,
                    test = true,
                    tidy = true,
                    upgrade_dependency = true,
                    vendor = true,
                },
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
                analyses = {
                    fieldalignment = false,
                    nilness = true,
                    unusedparams = true,
                    unusedwrite = true,
                    useany = true,
                },
                usePlaceholders = true,
                completeUnimported = true,
                staticcheck = true,
                directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                semanticTokens = true,
            },
        },
    }),
    lang.server("gradle_ls"),
    lang.server("html"),
    lang.server("jedi_language_server"), -- python
    lang.server("jsonls"), -- json
    lang.server("kotlin_language_server"),
    lang.server("lua_ls", {
        -- https://luals.github.io/wiki/configuration/#neovim
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
            },
        },
    }),
    lang.server("tailwindcss"),
    lang.server("ts_ls", {
        -- Prevent conflict with denols
        root_markers = { "package.json" },
        single_file_support = false,
    }),
    lang.server("yamlls"),
}

local server_names = function(servers)
    return arr.map(servers, function(s) return s.name end)
end

return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = true,
    },
    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
        },
        config = function()
            -- bind vscode like snippets to luasnip
            require("luasnip.loaders.from_vscode").lazy_load()

            local cmp = require("cmp")
            local select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<Tab>"] = cmp.mapping.select_next_item(select),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(select),
                    ["<Enter>"] = cmp.mapping.confirm({ select = true }),
                }),
            })
        end,
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspStart" },
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "williamboman/mason-lspconfig.nvim" },
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Configure all LSP servers using vim.lsp.config (Neovim 0.11+)
            for _, s in ipairs(lsp_servers) do
                local config = vim.tbl_deep_extend("force", {
                    capabilities = capabilities,
                }, s.setup)
                vim.lsp.config(s.name, config)
            end

            -- Enable all configured servers
            vim.lsp.enable(server_names(lsp_servers))

            -- Mason for auto-installation
            require("mason-lspconfig").setup({
                ensure_installed = server_names(lsp_servers),
            })

            -- LspAttach autocmd for keymaps & workarounds
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)

                    -- LSP keymaps (equivalent to lsp-zero defaults)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover)
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition)
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
                    vim.keymap.set("n", "go", vim.lsp.buf.type_definition)
                    vim.keymap.set("n", "gr", vim.lsp.buf.references)
                    vim.keymap.set("n", "gs", vim.lsp.buf.signature_help)
                    vim.keymap.set("n", "gl", vim.diagnostic.open_float)
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

                    -- Go semantic tokens workaround
                    -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
                    local client = vim.lsp.get_client_by_id(args.data.client_id)

                    if client and client.name == "gopls" then
                        if not client.server_capabilities.semanticTokensProvider then
                            local semantic = client.config.capabilities.textDocument.semanticTokens
                            if semantic then
                                client.server_capabilities.semanticTokensProvider = {
                                    full = true,
                                    legend = {
                                        tokenModifiers = semantic.tokenModifiers,
                                        tokenTypes = semantic.tokenTypes,
                                    },
                                    range = true,
                                }
                            end
                        end
                    end
                end,
            })

            -- Format on save for Go files
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go",
                callback = function()
                    vim.lsp.buf.format({
                        async = false,
                        timeout_ms = 10000,
                    })
                end,
            })
        end,
    },
}

