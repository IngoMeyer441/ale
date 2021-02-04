" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Support for isort, a python style linter

call ale#Set('python_isort_executable', 'isort')
call ale#Set('python_isort_options', '(&textwidth ? "--line-length ".&textwidth : "")')

function! ale_linters#python#isort#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'python_isort_executable')
endfunction

function! ale_linters#python#isort#GetCommand(buffer) abort
    let l:options = eval(ale#Var(a:buffer, 'python_isort_options'))
    return ale#Escape(ale_linters#python#isort#GetExecutable(a:buffer))
    \   . ' --stdout ' . l:options
    \   . ' - < %t | '
    \   . 'diff --old-group-format="%df: warning: isort style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: isort style: )/\n\1\2/g"'
endfunction

function! ale_linters#python#isort#Handle(buffer, lines) abort
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
\   'name': 'isort',
\   'executable': function('ale_linters#python#isort#GetExecutable'),
\   'command': function('ale_linters#python#isort#GetCommand'),
\   'callback': 'ale_linters#python#isort#Handle',
\   'read_buffer': 0
\})
