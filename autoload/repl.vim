" ======================================================================
" File:                     repl.vim
" Maintainer:               Joshua Potter <jrpotter2112@gmail.com>
"
" ======================================================================

" SCRIPT VARIABLES: {{{1
" ======================================================================

" s:repl_linkage :: { Int : Int } {{{2
" ----------------------------------------------------------------------
" Pairs a buffer with the terminal_job_id it is bound to

let s:repl_linkage = {}


" FUNCTION: GetVisualSelection() {{{1
" ======================================================================

function! repl#get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][:col2 - 1]
  let lines[0] = lines[0][col1 - 1:]
endfunction


" FUNCTION: ToggleRepl(vert, link) {{{1
" ======================================================================
" Attempts to open a repl that has already been opened

function! repl#toggle_repl(vert, link)
  if bufwinnr(a:link) == -1
    if a:vert | vsplit | else | split | end
    exe a:link . "buffer"
    exe "normal! \<C-w>p"
  else
    exe bufwinnr(a:link) . 'close!'
  end
endfunction


" FUNCTION: OpenRepl(vert, target) {{{1
" ======================================================================
" Opens a new REPL if one is not already bound to the current buffer

function! repl#open_repl(vert, target)
  let parent = bufnr('%')
  if has_key(s:repl_linkage, parent)
    call repl#toggle_repl(a:vert, s:repl_linkage[parent])
  else
    if a:vert | vsplit | else | split | end
    enew
    if empty(a:target)
      call termopen(g:repl_default_command)
    else
      call termopen(a:target)
    end
    let bt = bufnr('%')
    let bv = getbufvar('%', 'terminal_job_id')
    exe "normal! \<C-w>p"
    let s:repl_linkage[parent] = bt
  end
endfunction


" FUNCTION: DeleteRepl(filename) {{{1
" ======================================================================

function! repl#delete_repl(filename)
  let bt = bufnr(a:filename)
  if has_key(s:repl_linkage, bt)
    exe 'bdelete! ' . s:repl_linkage[bt]
    unlet s:repl_linkage[bt]
  endif
endfunction


" FUNCTION: RestartRepl() {{{1
" ======================================================================

function! repl#restart_repl(vert)
  call repl#delete_repl('%')
  call repl#open_repl(a:vert, repl#get_target_repl())
endfunction


" FUNCTION: SendToRepl(data) {{{1
" ======================================================================

function! repl#send_to_repl(data)
  let parent = bufnr('%')
  if has_key(s:repl_linkage, parent)
    call jobsend(s:repl_linkage[parent], a:data)
  endif
endfunction


" FUNCTION: SendSelectionToRepl(data) {{{1
" ======================================================================

function! repl#send_selection_to_repl()
  call repl#send_to_repl(repl#get_visual_selection())
endfunction


" FUNCTION: GetTargetRepl() {{{1
" ======================================================================

function! repl#get_target_repl()
  if has_key(s:repl_targets, &filetype)
    for repl in s:repl_targets[&filetype]
      if executable(repl)
        return repl
      endif
    endfor
  endif
  return ''
endfunction


" FUNCTION: InitializeRepl() {{{1
" ======================================================================
" Instantiates the mappings for the entered buffer

function! repl#initialize_repl()
  if exists('b:initialized_terminal_repl')
    return
  endif
  let b:initialized_terminal_repl = 1
  let target_repl = s:GetTargetRepl()
  exe ' nnoremap <silent> <buffer> <Plug>OpenHorizontalRepl ' .
      \ ':call repl#open_repl(0, ''' . target_repl . ''')<CR>'
  exe ' nnoremap <silent> <buffer> <Plug>OpenVerticalRepl ' .
      \ ':call repl#open_repl(1, ''' . target_repl . ''')<CR>'
endfunction