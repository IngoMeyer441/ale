" Author: Ingo Heimbach <i.heimbach@fz-juelich.de>
" Description: Support for css-beautify, a css style linter

call ale#Set('css_cssbeautify_executable', 'css-beautify')
call ale#Set('css_cssbeautify_options', '')

function! ale_linters#css#cssbeautify#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'css_cssbeautify_executable')
endfunction

function! ale_linters#css#cssbeautify#GetCommand(buffer) abort
    return ale#Escape(ale_linters#css#cssbeautify#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'css_cssbeautify_options')
    \   . ' < %t | diff --old-group-format="%df: warning: cssbeautify style: " --unchanged-line-format="" %t -'
endfunction

function! ale_linters#css#cssbeautify#Handle(buffer, lines) abort
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

call ale#linter#Define('css', {
\   'name': 'cssbeautify',
\   'executable_callback': 'ale_linters#css#cssbeautify#GetExecutable',
\   'command_callback': 'ale_linters#css#cssbeautify#GetCommand',
\   'callback': 'ale_linters#css#cssbeautify#Handle',
\   'read_buffer': 0
\})
