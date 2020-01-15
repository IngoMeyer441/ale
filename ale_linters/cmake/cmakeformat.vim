" Author: Ingo Heimbach <i.heimbach@fz-juelich.de>
" Description: Support for cmake_format, a cmake style linter

call ale#Set('cmake_cmakeformat_executable', 'cmake-format')
call ale#Set('cmake_cmakeformat_options', '"--tab-size ".shiftwidth().(&textwidth ? " --line-width ".&textwidth : "")')

function! ale_linters#cmake#cmakeformat#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cmake_cmakeformat_executable')
endfunction

function! ale_linters#cmake#cmakeformat#GetCommand(buffer) abort
    let l:options = eval(ale#Var(a:buffer, 'cmake_cmakeformat_options'))
    return ale#Escape(ale_linters#cmake#cmakeformat#GetExecutable(a:buffer))
    \   . ' '. l:options
    \   . ' - < %t | '
    \   . 'diff --old-group-format="%df: warning: cmake_format style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: cmake_format style: )/\n\1\2/g"'
endfunction

function! ale_linters#cmake#cmakeformat#Handle(buffer, lines) abort
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
\   'name': 'cmakeformat',
\   'executable_callback': 'ale_linters#cmake#cmakeformat#GetExecutable',
\   'command_callback': 'ale_linters#cmake#cmakeformat#GetCommand',
\   'callback': 'ale_linters#cmake#cmakeformat#Handle',
\   'read_buffer': 0
\})
