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

  Plug 'LunarWatcher/auto-pairs'
  Plug 'dense-analysis/ale'
  Plug 'vim-airline/vim-airline'
  Plug 'flazz/vim-colorschemes'
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'wakatime/vim-wakatime'

  call plug#end()

  colo atom

  let g:airline#extensions#ale#enabled = 1

  " ale settings
  let g:ale_linters = {
  \   'c': ['cc'],
  \   'cpp': ['cc'],
  \   'python': ['ruff', 'flake8', 'mypy', 'pylint'],
  \   'lua': ['luac'],
  \}
  let g:ale_fixers = {
  \   '*': ['remove_trailing_lines', 'trim_whitespace'],
  \   'c': ['clang-format'],
  \   'cpp': ['clang-format'],
  \   'java': ['clang-format'],
  \   'python': ['isort', 'black'],
  \   'lua': ['stylua'],
  \}
  let flags = '-Wall -Werror -Wextra -Wpedantic'
  let g:ale_cpp_cc_options = '-std=gnu++2b ' . flags
  let g:ale_c_cc_options = '-std=gnu17' . flags
  let g:ale_python_pylsp_config = {}
  let line_length = '--line-length 79'
  let g:ale_python_black_options = line_length
  let g:ale_python_isort_options = line_length . ' --profile black --fss -m 3'
  let g:ale_fix_on_save = 1

  augroup indent_settings
    au!
    au FileType c setlocal ts=4 sts=4 sw=4 expandtab
    au FileType cpp setlocal ts=4 sts=4 sw=4 expandtab

    au FileType css setlocal ts=2 sts=2 sw=2 expandtab
    au FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
    au FileType html setlocal ts=2 sts=2 sw=2 expandtab
  augroup END
]])

if (vim.fn.filereadable("./.vimrc") ~= 0) then
  vim.cmd("source ./.vimrc")
end
