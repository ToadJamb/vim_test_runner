" File:        triggertest.vim
" Author:      Travis Herrick
" Version:     0.2
" Description: Send filename and line number to a named pipe

function TriggerFilePath()
  let home = expand('~')
  let trigger_file = '.triggertest'

  return join([home, trigger_file], '/')
endfunction

let tt:path = TriggerFilePath()

function CreatePipeMessage()
  echom 'Please create a named pipe at ' . tt:path
endfunction

function TriggerTest()
  let linenum = line('.') 
  let fname = expand('%')
  let args =  join([fname, linenum], ' ')

  if filereadable(tt:path)
    call writefile([args], path)
  else
    call CreatePipeMessage(path)
  endif
endfunction

function TriggerPreviousTest()
  if filereadable(tt:path)
    call writefile([''], path)
  else
    call CreatePipeMessage(path)
  endif
endfunction

nmap <silent> <leader>t :call TriggerTest()<CR>
nmap <silent> <leader>r :call TriggerPreviousTest()<CR>
