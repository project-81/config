-- 80 character limit reminder.
vim.opt.colorcolumn = "80"

-- Fix newlines by default.
vim.opt.fixeol = true

-- Visualize tabs and newlines.
vim.opt.listchars = { tab = "▸\\ ", eol = "¬" }

function navigate_panes(key)
  -- Get an identifier for the current buffer.
  curr = vim.fn.winnr()

  -- Run 'wincmd' and check if the current buffer changed or not.
  vim.cmd("wincmd " .. key)
  if (curr == vim.fn.winnr()) then
    if (key == "j" or key == "k") then
      vim.cmd("wincmd s")
    else
      vim.cmd("wincmd v")
    end

    -- Move to the newly created buffer.
    vim.cmd("wincmd " .. key)
  end
end

keybinds = {
  -- Quick insertion.
  ["<Space>"] = "i_<Esc>r",

  -- Navigating tabs.
  ["<leader>p"] = ":tabp<CR>",
  ["<leader>n"] = ":tabn<CR>",
  ["<leader>t"] = ":tab split +Explore<CR>",
  ["<leader>T"] = ":Explore<CR>",

  -- On a split keyboard, it's awkward to press '<leader>n'. Allow using 'b' as
  -- well.
  ["<leader>b"] = ":tabn<CR>",

  -- Fast reload settings.
  ["<leader>rv"] = ":source $MYVIMRC<CR>",

  -- Visualize tabs and newlines toggle.
  ["<leader>l"] = ":set list!<CR>",
}

-- Register user functions for pane navigation.
user_command_mapping = {
  WinMoveUp = "k",
  WinMoveDown = "j",
  WinMoveLeft = "h",
  WinMoveRight = "l",
}
for name, key in pairs(user_command_mapping) do
  -- Register the command.
  vim.api.nvim_create_user_command(
    name, function() navigate_panes(key) end, {}
  )

  -- Assign the appropriate keybind.
  keybinds["<C-" .. key .. ">"] = ":" .. name .. "<CR>"
end

-- Register keybinds.
for key, action in pairs(keybinds) do
  vim.keymap.set("n", key, action)
end

-- Prevent netrw's <C-l> overriding our mapping.
local netrw = vim.api.nvim_create_augroup("netrw_mapping", { clear = true })
vim.api.nvim_create_autocmd(
  "FileType",
  {
    pattern = "netrw",
    group = netrw,
    callback = function(args)
      modes = {"n", "v", "o"}
      key = "<C-l>"
      vim.keymap.del(modes, key, { buffer = true })
      vim.keymap.set(modes, key, "WinMoveRight<CR>", { buffer = true })
    end
  }
)
