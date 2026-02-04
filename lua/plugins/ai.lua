return {
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim", "akinsho/toggleterm.nvim" },
        config = function()
            local Terminal = require("toggleterm.terminal").Terminal
            local claude_term = nil

            -- Helper function to create terminal
            local function create_terminal(cmd_string, env_table)
                claude_term = Terminal:new({
                    cmd = cmd_string,
                    direction = "horizontal",
                    size = 20,
                    hidden = true,
                    env = env_table,
                    on_open = function(t)
                        vim.cmd("startinsert!")
                        vim.keymap.set("t", "<C-j>", [[<C-\><C-n>]], { buffer = t.bufnr, silent = true })
                    end,
                    on_exit = function()
                        claude_term = nil
                    end,
                })
            end

            require("claudecode").setup({
                terminal_cmd = "raicode",
                terminal = {
                    provider = {
                        setup = function(config) end,

                        open = function(cmd_string, env_table, effective_config, focus)
                            if not claude_term then
                                create_terminal(cmd_string, env_table)
                            end
                            claude_term:open()
                            if focus ~= false and claude_term:is_open() then
                                vim.api.nvim_set_current_win(claude_term.window)
                            end
                        end,

                        close = function()
                            if claude_term then
                                claude_term:close()
                            end
                        end,

                        simple_toggle = function(cmd_string, env_table, effective_config)
                            if not claude_term then
                                create_terminal(cmd_string, env_table)
                            end
                            claude_term:toggle()
                        end,

                        focus_toggle = function(cmd_string, env_table, effective_config)
                            if not claude_term then
                                create_terminal(cmd_string, env_table)
                                claude_term:toggle()
                            elseif claude_term:is_open() then
                                local current_win = vim.api.nvim_get_current_win()
                                if current_win == claude_term.window then
                                    claude_term:close()
                                else
                                    vim.api.nvim_set_current_win(claude_term.window)
                                end
                            else
                                claude_term:toggle()
                            end
                        end,

                        get_active_bufnr = function()
                            return claude_term and claude_term:is_open() and claude_term.bufnr or nil
                        end,

                        is_available = function()
                            return true
                        end,
                    },
                },
            })
        end,
        keys = {
            { "<C-j>",      nil },
            { "<C-j><C-f>", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
            { "<C-j><C-r>", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
            { "<C-j><C-c>", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<C-j><C-m>", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Model" },
            { "<C-j><C-b>", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add Buffer" },
            { "<C-j><C-k>", "<cmd>ClaudeCodeSend<cr>",        mode = "v", desc = "Send to Claude" },
            { "<C-j><C-k>", "<cmd>ClaudeCodeTreeAdd<cr>",     desc = "Add File", ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" } },
            { "<C-j><C-a>", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept Diff" },
            { "<C-j><C-d>", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny Diff" },
        },
    }
}
