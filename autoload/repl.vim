" ======================================================================
" File:                     repl.vim
" Maintainer:               Joshua Potter <jrpotter2112@gmail.com>
"
" ======================================================================

" SCRIPT VARIABLES: {{{1
" ======================================================================

" s:repl_linkage :: { Int : Int } {{{2
" ----------------------------------------------------------------------
" Pairs a buffer with the buffer containing the terminal it sends data to

let s:repl_linkage = {}


" FUNCTION: GetVisualSelection() {{{1
" ======================================================================

function! repl#get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][:col2 - 1]
  let lines[0] = lines[0][col1 - 1:]
  return lines
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
    let s:repl_linkage[parent] = bufnr('%')
    exe "normal! \<C-w>p"
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
  call repl#open_repl(a:vert, b:target_repl)
endfunction


" FUNCTION: EscapeData(data) {{{1
" ======================================================================
" Used for properly formatting text out to the target terminal.

function! repl#escape_data(data)
  if exists('*REPLEscapeData')
    if type(a:data) == type('')
      return REPLEscapeData(b:target_repl, [a:data])
    else
      return REPLEscapeData(b:target_repl, a:data)
    endif
  endif
  return a:data
endfunction


" FUNCTION: SendToRepl(data) {{{1
" ======================================================================

function! repl#send_to_repl(data)
  let parent = bufnr('%')
  if has_key(s:repl_linkage, parent)
    let term_id = getbufvar(s:repl_linkage[parent], 'terminal_job_id')
    call jobsend(term_id, repl#escape_data(a:data))
    call jobsend(term_id, "\n")
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
  if has_key(g:repl_targets, &filetype)
    for repl in g:repl_targets[&filetype]
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
  if exists('b:target_repl')
    return
  endif
  let b:target_repl = repl#get_target_repl()
  exe 'noremap <silent> <buffer> <Plug>REPL_OpenHorizontalRepl ' .
      \ ':call repl#open_repl(0, ''' . b:target_repl . ''')<CR>'
  exe 'noremap <silent> <buffer> <Plug>REPL_OpenVerticalRepl ' .
      \ ':call repl#open_repl(1, ''' . b:target_repl . ''')<CR>'
endfunction

