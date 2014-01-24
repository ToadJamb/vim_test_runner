" File:        test_runner.vim
" Author:      Travis Herrick
" Version:     0.3
" Description: Send filename and line number to a named pipe

function tt:TriggerFilePath()
  let home = expand('~')
  let trigger_file = '.triggertest'

  return join([home, trigger_file], '/')
endfunction

let s:trigger_test_path = tt:TriggerFilePath()

function tt:CreatePipeMessage()
  echom 'Please create a named pipe at ' . s:trigger_test_path
endfunction

function tt:SendToPipe(args)
  if filereadable(s:trigger_test_path)
    call writefile(a:args, s:trigger_test_path)
  else
    call tt:CreatePipeMessage()
  endif
endfunction

function tt:TriggerTest()
  let linenum = line('.')
  let fname   = expand('%')

  let args    = [join([fname, linenum], ' ')]

  call tt:SendToPipe(args)
endfunction

function tt:TriggerPreviousTest()
  call tt:SendToPipe([''])
endfunction
