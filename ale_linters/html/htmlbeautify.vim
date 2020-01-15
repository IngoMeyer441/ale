" Author: Ingo Heimbach <i.heimbach@fz-juelich.de>
" Description: Support for html-beautify, a html style linter

call ale#Set('html_htmlbeautify_executable', 'html-beautify')
call ale#Set('html_htmlbeautify_options', '')
call ale#Set('html_htmlbeautify_style', '(&expandtab ? "--indent-size ".shiftwidth() : "--indent-with-tabs ")')

function! ale_linters#html#htmlbeautify#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'html_htmlbeautify_executable')
endfunction

function! ale_linters#html#htmlbeautify#GetCommand(buffer) abort
    let l:style = eval(ale#Var(a:buffer, 'html_htmlbeautify_style'))
    return ale#Escape(ale_linters#html#htmlbeautify#GetExecutable(a:buffer))
    \   . (!empty(l:style) ? ' ' . l:style : '')
    \   . ' ' . ale#Var(a:buffer, 'html_htmlbeautify_options')
    \   . ' < %t | '
    \   . 'diff --old-group-format="%df: warning: htmlbeautify style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: htmlbeautify style: )/\n\1\2/g"'
endfunction

function! ale_linters#html#htmlbeautify#Handle(buffer, lines) abort
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

call ale#linter#Define('html', {
\   'name': 'htmlbeautify',
\   'executable_callback': 'ale_linters#html#htmlbeautify#GetExecutable',
\   'command_callback': 'ale_linters#html#htmlbeautify#GetCommand',
\   'callback': 'ale_linters#html#htmlbeautify#Handle',
\   'read_buffer': 0
\})
