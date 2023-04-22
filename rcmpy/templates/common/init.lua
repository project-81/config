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
  ["<leader>p"] = ":tabp<cr>",
  ["<leader>n"] = ":tabn<cr>",
  ["<leader>t"] = ":tab split +Explore<cr>",
  ["<leader>T"] = ":Explore<cr>",

  -- On a split keyboard, it's awkward to press '<leader>n'. Allow using 'b' as
  -- well.
  ["<leader>b"] = ":tabn<cr>",

  -- Fast reload settings.
  ["<leader>rv"] = ":source $MYVIMRC<cr>",

  -- Visualize tabs and newlines toggle.
  ["<leader>l"] = ":set list!<cr>",
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
  keybinds["<C-" .. key .. ">"] = ":" .. name .. "<cr>"
end

-- Register keybinds.
for key, action in pairs(keybinds) do
  vim.keymap.set("n", key, action)
end

-- Plugins.
vim.cmd([[
  let g:plug_url_format = 'git@github.com:%s.git'
  call plug#begin('~/.vim/plugged')

  Plug 'jiangmiao/auto-pairs'
  Plug 'dense-analysis/ale'
  Plug 'vim-airline/vim-airline'
  Plug 'flazz/vim-colorschemes'

  call plug#end()

  colo atom

  let g:airline#extensions#ale#enabled = 1
]])
