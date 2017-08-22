" Author: Ingo Heimbach <i.heimbach@fz-juelich.de>
" Description: Support for yapf, a python style linter

call ale#Set('python_yapf_executable', 'yapf')
call ale#Set('python_yapf_options', '')
call ale#Set('python_yapf_style', '')

function! ale_linters#python#yapf#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'python_yapf_executable')
endfunction

function! ale_linters#python#yapf#GetCommand(buffer) abort
    let l:style = eval(ale#Var(a:buffer, 'python_yapf_style'))
    return ale#Escape(ale_linters#python#yapf#GetExecutable(a:buffer))
    \   . (!empty(l:style) ? ' --style="{' . l:style . '}"' : '')
    \   . ' ' . ale#Var(a:buffer, 'python_yapf_options')
    \   . ' < %t | diff --old-group-format="%df: warning: yapf style: " --unchanged-line-format="" %t -'
endfunction

function! ale_linters#python#yapf#Handle(buffer, lines) abort
    " matches: '2: warning: ...
    let l:pattern = '\v(\d+): warning: (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'text': l:match[2],
        \   'type': 'W',
        \   'sub_type': 'style',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('python', {
\   'name': 'yapf',
\   'executable_callback': 'ale_linters#python#yapf#GetExecutable',
\   'command_callback': 'ale_linters#python#yapf#GetCommand',
\   'callback': 'ale_linters#python#yapf#Handle',
\   'read_buffer': 0
\})
