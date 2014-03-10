" File:        test_runner.vim
" Author:      Travis Herrick
" Version:     0.3
" Description: Send filename and line number to a named pipe

function tt:TriggerFilePath()
  let home = expand('~')
  let pipe_name = '.test_runner'

  let current_dir = getcwd()
  let project = fnamemodify(current_dir, ':t')

  let global_named_pipe  = join([home, pipe_name], '/')
  let project_named_pipe = join([home, '.' . project . pipe_name], '/')
  let local_named_pipe   = join([current_dir, pipe_name], '/')

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
