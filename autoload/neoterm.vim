" Internal: Creates a new neoterm buffer.
function! neoterm#new(...)
  if !has_key(g:neoterm, "term")
    exec "source " . globpath(&rtp, "autoload/neoterm.term.vim")
  end

  let current_window = g:neoterm.new_split()
  let handlers = len(a:000) ? a:1 : {}

  let instance = g:neoterm.term.new(g:neoterm.next_id(), handlers)
  let g:neoterm.instances[instance.id] = instance
  let b:neoterm_id = instance.id

  call instance.mappings()

  if g:neoterm_keep_term_open
    silent exec current_window . "wincmd w | set noinsertmode"
  else
    startinsert
  end
endfunction

function! neoterm#toggle()
  if neoterm#tab_has_neoterm()
    call g:neoterm.last().close()
  else
    if g:neoterm.has_any()
      call g:neoterm.last().open()
    else
      call neoterm#new()
    end
  end
endfunction

" Internal: Creates a new neoterm buffer, or opens if it already exists.
function! neoterm#open()
  if !neoterm#tab_has_neoterm()
    if !g:neoterm.has_any()
      call neoterm#new()
    else
      call g:neoterm.last().open()
    end
  end
endfunction

function! neoterm#close()
  call g:neoterm.last().close()
endfunction

" Public: Executes a command on terminal.
" Evaluates any "%" inside the command to the full path of the current file.
function! neoterm#do(command)
  let command = neoterm#expand_cmd(a:command)

  call neoterm#exec([command, ""])
endfunction

" Internal: Loads a terminal, if it is not loaded, and execute a list of
" commands.
function! neoterm#exec(command)
  call neoterm#open()
  call g:neoterm.last().exec(a:command)
endfunction

function! neoterm#map_for(command)
  exec "nnoremap <silent> "
        \ . g:neoterm_automap_keys .
        \ " :T " . neoterm#expand_cmd(a:command) . "<cr>"
endfunction

" Internal: Expands "%" in commands to current file full path.
function! neoterm#expand_cmd(command)
  let command = substitute(a:command, '%\(:[phtre]\)\+', '\=expand(submatch(0))', 'g')
  return substitute(command, '%', expand('%:p'), 'g')
endfunction

" Internal: Open a new split with the current neoterm buffer if there is one.
"
" Returns: 1 if a neoterm split is opened, 0 otherwise.
function! neoterm#tab_has_neoterm()
  if g:neoterm.has_any()
    let buffer_id = g:neoterm.last().buffer_id
    return bufexists(buffer_id) > 0 && bufwinnr(buffer_id) != -1
  end
endfunction

" Internal: Clear the current neoterm buffer. (Send a <C-l>)
function! neoterm#clear()
  silent call g:neoterm.last().clear()
endfunction

" Internal: Kill current process on neoterm. (Send a <C-c>)
function! neoterm#kill()
  silent call g:neoterm.last().kill()
endfunction

function! neoterm#list()
  echo keys(g:neoterm.instances)
endfunction
