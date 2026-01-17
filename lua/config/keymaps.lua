local keymap = vim.keymap
local silent = { silent = true }

keymap.set("n", "Y", "y$")
keymap.set("i", "jj", "<Esc>")
keymap.set("i", "jk", "<Esc>")

keymap.set("n", "j", "gj")
keymap.set("n", "k", "gk")

keymap.set("n", "<Esc>", ":nohl<CR><Esc>", silent)
keymap.set({ "n", "i", "v" }, "<C-s>", "<C-C>:update<CR>", silent)

