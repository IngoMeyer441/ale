" Author: Ingo Heimbach <i.heimbach@fz-juelich.de>
" Description: Support for black, a python style linter

call ale#Set('python_black_executable', 'black')
call ale#Set('python_black_options', '"--quiet".(&textwidth ? " --line-length ".&textwidth : "")')

function! ale_linters#python#black#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'python_black_executable')
endfunction

function! ale_linters#python#black#GetCommand(buffer) abort
    let l:options = eval(ale#Var(a:buffer, 'python_black_options'))
    return ale#Escape(ale_linters#python#black#GetExecutable(a:buffer))
    \   . ' --fast ' . l:options
    \   . ' - < %t | '
    \   . 'diff --old-group-format="%df: warning: black style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: black style: )/\n\1\2/g"'
endfunction

function! ale_linters#python#black#Handle(buffer, lines) abort
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
\   'name': 'black',
\   'executable_callback': 'ale_linters#python#black#GetExecutable',
\   'command_callback': 'ale_linters#python#black#GetCommand',
\   'callback': 'ale_linters#python#black#Handle',
\   'read_buffer': 0
\})
