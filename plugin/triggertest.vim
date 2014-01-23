" File:        test_runner.vim
" Author:      Travis Herrick
" Version:     0.2
" Description: Send filename and line number to a named pipe

function TriggerFilePath()
  let home = expand('~')
  let trigger_file = '.triggertest'

  return join([home, trigger_file], '/')
endfunction

let s:trigger_test_path = TriggerFilePath()

function CreatePipeMessage()
  echom 'Please create a named pipe at ' . s:trigger_test_path
endfunction

function SendToPipe(args)
  if filereadable(s:trigger_test_path)
    call writefile(a:args, s:trigger_test_path)
  else
    call CreatePipeMessage()
  endif
endfunction

function TriggerTest()
  let linenum = line('.')
  let fname   = expand('%')

  let args    = [join([fname, linenum], ' ')]

  call SendToPipe(args)
endfunction

function TriggerPreviousTest()
  call SendToPipe([''])
endfunction

nmap <silent> <leader>t :call TriggerTest()<CR>
nmap <silent> <leader>r :call TriggerPreviousTest()<CR>
