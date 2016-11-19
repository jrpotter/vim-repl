function! REPLEscapeData(env, lines)
  let lines = a:lines
  if a:env == 'ipython'
    call insert(lines, '%cpaste')
    call add(lines, '--')
  else
    let i = 0
    while i < len(lines)
      let lines[i] = substitute(lines[i], '"', '\\"', 'g')
      let i = i + 1
    endwhile
    call insert(lines, 'exec("""')
    call add(lines, '""")')
  end
  return lines
endfunction
