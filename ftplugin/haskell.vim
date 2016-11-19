function! REPLEscapeData(env, lines)
  let lines = a:lines
  call insert(lines, ':{')
  call add(lines, ':}')
  return lines
endfunction
