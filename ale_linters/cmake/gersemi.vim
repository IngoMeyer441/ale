" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Support for gersemi, a cmake style linter

call ale#Set('cmake_gersemi_executable', 'gersemi')
call ale#Set('cmake_gersemi_options', '"--indent ".shiftwidth().(&textwidth ? " --line-length ".&textwidth : "")')

function! ale_linters#cmake#gersemi#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cmake_gersemi_executable')
endfunction

function! ale_linters#cmake#gersemi#GetCommand(buffer) abort
    let l:options = eval(ale#Var(a:buffer, 'cmake_gersemi_options'))
    return ale#Escape(ale_linters#cmake#gersemi#GetExecutable(a:buffer))
    \   . ' '. l:options
    \   . ' - < %t | '
    \   . 'diff --old-group-format="%df: warning: gersemi style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: gersemi style: )/\n\1\2/g"'
endfunction

function! ale_linters#cmake#gersemi#Handle(buffer, lines) abort
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

call ale#linter#Define('cmake', {
\   'name': 'gersemi',
\   'executable': function('ale_linters#cmake#gersemi#GetExecutable'),
\   'command': function('ale_linters#cmake#gersemi#GetCommand'),
\   'callback': 'ale_linters#cmake#gersemi#Handle',
\   'read_buffer': 0
\})
