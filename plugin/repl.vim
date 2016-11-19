" ======================================================================
" File:                     repl.vim
" Maintainer:               Joshua Potter <jrpotter2112@gmail.com>
"
" ======================================================================

if exists('g:loaded_repl')
  finish
endif
let g:loaded_repl = 1


" GLOBAL VARIABLES: {{{1
" ======================================================================

" g:repl_targets :: { String : [String] } {{{2
" ----------------------------------------------------------------------
" The REPLs that should be opened in order of priority. For instance,
" currently for detected python filetypes we first attempt to order an
" iPython REPL and, barring that, a python3 REPL. If no possible REPL
" exists, we instead issue out the default command.

if !exists('g:repl_targets')
  let g:repl_targets = {
      \ 'python' : ['ipython', 'python3'],
      \ 'haskell' : ['ghci'],
      \ }
endif


" g:repl_default_command :: String {{{2
" ----------------------------------------------------------------------
" The default shell command that should be run when no proper REPL is
" found.

if !exists('g:repl_default_command')
  let g:repl_default_command = "$SHELL -d -f"
endif


" MAPPINGS: Plug Mappings {{{1
" ======================================================================

nnoremap <Plug>REPL_RestartHorizontalRepl
    \ :<C-u>call repl#restart_repl(0)<CR>
nnoremap <Plug>REPL_RestartVerticalRepl
    \ :<C-u>call repl#restart_repl(1)<CR>
nnoremap <Plug>REPL_SendLineToRepl
    \ :<C-u>call repl#send_to_repl(getline('.'))<CR>
nnoremap <Plug>REPL_SendFileToRepl
    \ :<C-u>call repl#send_to_repl(getline(1, '$'), "\n")<CR>
vnoremap <Plug>REPL_SendSelectionToRepl
    \ :<C-u>call repl#send_selection_to_repl()<CR>


" PROCEDURE: Initialize {{{1
" ======================================================================

augroup repl_buf_autocommands
  autocmd!
  autocmd BufEnter * call repl#initialize_repl()
  autocmd BufUnload * call repl#delete_repl(expand('<afile>'))
augroup END

nmap <Leader>ss <Plug>REPL_OpenHorizontalRepl
nmap <Leader>sv <Plug>REPL_OpenVerticalRepl

nmap <C-c><C-s> <Plug>REPL_RestartHorizontalRepl
nmap <C-c><C-v> <Plug>REPL_RestartVerticalRepl
nmap <C-c><C-c> <Plug>REPL_SendLineToRepl
nmap <C-c><C-f> <Plug>REPL_SendFileToRepl
vmap <C-c><C-c> <Plug>REPL_SendSelectionToRepl

