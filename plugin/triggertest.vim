" File:          triggertest.vim
" Author:        Rit Li
" Version:       0.1
" Description:   Send filename and line number to a named pipe

function TriggerTest()
    let linenum = line('.') 
    let fname = expand('%')
    let args =  join([fname, linenum], " ")
    let cwd = getcwd()
    let path = join([cwd, ".triggertest"], "/")
    if filereadable(path)
        call writefile([args], path)
    else
        echom "Please create a named pipe called `.triggertest` in the current directory"
    endif
endfunction

function TriggerPreviousTest()
    let cwd = getcwd()
    let path = join([cwd, ".triggertest"], "/")
    if filereadable(path)
        call writefile([""], path)
    else
        echom "Please create a named pipe called `.triggertest` in the current directory"
    endif
endfunction

nmap <silent> <leader>t :call TriggerTest()<CR>
nmap <silent> <leader>r :call TriggerPreviousTest()<CR>
