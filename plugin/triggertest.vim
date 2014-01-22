" File:        triggertest.vim
" Author:      Travis Herrick
" Version:     0.2
" Description: Send filename and line number to a named pipe

function TriggerFilePath()
  let home = expand('~')
  let trigger_file = '.triggertest'

  return join([home, trigger_file], '/')
endfunction

function TriggerTest()
  let linenum = line('.') 
  let fname = expand('%')
  let args =  join([fname, linenum], ' ')
  let path = TriggerFilePath()

  if filereadable(path)
    call writefile([args], path)
  else
    echom 'Please create a named pipe called `.triggertest` in the current directory'
  endif
endfunction

function TriggerPreviousTest()
  let cwd = getcwd()
  let path = TriggerFilePath()

  if filereadable(path)
    call writefile([''], path)
  else
    echom 'Please create a named pipe called `.triggertest` in the current directory'
  endif
endfunction

nmap <silent> <leader>t :call TriggerTest()<CR>
nmap <silent> <leader>r :call TriggerPreviousTest()<CR>
