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

" s:repl_targets :: { String : [String] } {{{2
" ----------------------------------------------------------------------
" The REPLs that should be opened in order of priority. For instance,
" currently for detected python filetypes we first attempt to order an
" iPython REPL and, barring that, a python3 REPL. If no possible REPL
" exists, we instead issue out the default command.

let g:repl_targets = {
    \ 'python' : ['ipython', 'python3'],
    \ 'haskell' : ['ghci'],
    \ }

" s:repl_default_command :: String {{{2
" ----------------------------------------------------------------------
" The default shell command that should be run when no proper REPL is
" found.

let g:repl_default_command = "$SHELL -d -f"


" MAPPINGS: Plug Mappings {{{1
" ======================================================================

nnoremap <Plug>RestartHorizontalRepl :call <SID>RestartRepl(0)<CR>
nnoremap <Plug>RestartVerticalRepl :call <SID>RestartRepl(1)<CR>
nnoremap <Plug>SendLineToRepl :call <SID>SendToRepl(getline('.'))<CR>
nnoremap <Plug>SendFileToRepl :call <SID>SendToRepl(getline(1, '$'))<CR>
vnoremap <Plug>SendSelectionToRepl :call <SID>SendSelectionToRepl()<CR>


" PROCEDURE: Initialize {{{1
" ======================================================================

augroup repl_buf_autocommands
  autocmd!
  autocmd BufEnter * call <SID>InitializeRepl()
  autocmd BufUnload * call <SID>DeleteSlime(expand('<afile>'))
augroup END

nnoremap <Leader>ss <Plug>OpenHorizontalRepl
nnoremap <Leader>sv <Plug>OpenVerticalRepl

nnoremap <C-c><C-s> <Plug>RestartHorizontalRepl
nnoremap <C-c><C-v> <Plug>RestartVerticalRepl
nnoremap <C-c><C-c> <Plug>SendLineToRepl
nnoremap <C-c><C-f> <Plug>SendFileToRepl
vnoremap <C-c><C-c> <Plug>SendSelectionToRepl

