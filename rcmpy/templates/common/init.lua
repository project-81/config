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

  -- Find files (uses fzf plugin).
  ["<leader>f"] = ":tab split +Files<cr>",
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
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'

  call plug#end()

  colo atom

  let g:airline#extensions#ale#enabled = 1

  " ale settings
  let g:ale_linters = {
  \   'c': ['cc'],
  \   'cpp': ['cc'],
  \   'python': ['ruff', 'flake8', 'mypy', 'pylint'],
  \}
  let g:ale_fixers = {
  \   '*': ['remove_trailing_lines', 'trim_whitespace'],
  \   'c': ['clang-format'],
  \   'cpp': ['clang-format'],
  \   'python': ['isort', 'black'],
  \}
  let g:ale_python_pylsp_config = {}
  let line_length = '--line-length 79'
  let g:ale_python_black_options = line_length
  let g:ale_python_isort_options = line_length . ' --profile black --fss -m 3'
  let g:ale_fix_on_save = 1

  augroup indent_settings
    au!
    au FileType c setlocal ts=4 sts=4 sw=4 expandtab
    au FileType cpp setlocal ts=4 sts=4 sw=4 expandtab
  augroup END
]])

if (vim.fn.filereadable("./.vimrc") ~= 0) then
  vim.cmd("source ./.vimrc")
end
