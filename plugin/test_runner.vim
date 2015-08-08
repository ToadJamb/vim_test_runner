" File:        test_runner.vim
" Author:      Travis Herrick
" Version:     0.0.7
" Description: Send filename and line number to a named pipe

function! s:TriggerFilePath()
  let home = expand('~')
  let pipe_name = '.test_runner'

  let current_dir = getcwd()
  let project = fnamemodify(current_dir, ':t')

  let global_named_pipe  = join([home, pipe_name], '/')
  let project_named_pipe = join([home, '.' . project . pipe_name], '/')
  let local_named_pipe   = join([current_dir, pipe_name], '/')

  "echom strftime('%c')
  "echom project_named_pipe
  "echom local_named_pipe
  "echom global_named_pipe

  if filereadable(project_named_pipe)
    let named_pipe = project_named_pipe
  elseif filereadable(local_named_pipe)
    let named_pipe = local_named_pipe
  elseif filereadable(global_named_pipe)
    let named_pipe = global_named_pipe
  else
    let named_pipe = project_named_pipe
  endif

  return named_pipe
endfunction

let s:trigger_test_path = s:TriggerFilePath()

function! s:CreatePipeMessage()
  echom 'Please create a named pipe at ' . s:trigger_test_path
endfunction

function! s:SendToPipe(args)
  if filereadable(s:trigger_test_path)
    call writefile([join(a:args, ' ')], s:trigger_test_path)
  else
    call s:CreatePipeMessage()
  endif
endfunction

function! TriggerTest()
  let linenum = line('.')
  let fname   = expand('%')

  let s:args  = [fname, linenum]

  call s:SendToPipe(s:args)
endfunction

function! TriggerPreviousTest()
  call s:SendToPipe(s:args)
endfunction
