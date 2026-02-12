return {
    {
        "folke/sidekick.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {
            nes = {
                enabled = false,
            },
            cli = {
                mux = {
                    enabled = true,
                    backend = "tmux",
                },
                tools = {
                    raicode = {
                        cmd = { "raicode" },
                    },
                },
            },
        },
        keys = {
            {
                "<tab>",
                function()
                    if not require("sidekick").nes_jump_or_apply() then
                        return "<Tab>"
                    end
                end,
                expr = true,
                desc = "Goto/Apply Next Edit Suggestion",
            },
            {
                "<C-,>",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle",
                mode = { "n", "t", "i", "x" },
            },
            {
                "<leader>aa",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<leader>as",
                function()
                    require("sidekick.cli").select({
                        cb = function(state)
                            if not state then
                                return
                            end
                            local State = require("sidekick.cli.state")
                            State.attach(state, { show = true, focus = true })
                            if state.external and state.session and state.session.tmux_pane_id then
                                vim.system({ "tmux", "select-pane", "-t", state.session.tmux_pane_id })
                            end
                        end,
                    })
                end,
                desc = "Select CLI",
            },
            {
                "<leader>ad",
                function() require("sidekick.cli").close() end,
                desc = "Detach a CLI Session",
            },
            {
                "<leader>at",
                function() require("sidekick.cli").send({ msg = "{this}" }) end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>af",
                function() require("sidekick.cli").send({ msg = "{file}" }) end,
                desc = "Send File",
            },
            {
                "<leader>av",
                function() require("sidekick.cli").send({ msg = "{selection}" }) end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function() require("sidekick.cli").prompt() end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
            {
                "<leader>ac",
                function() require("sidekick.cli").toggle({ name = "raicode", focus = true }) end,
                desc = "Sidekick Toggle Raicode",
            },
        },
    }
}
