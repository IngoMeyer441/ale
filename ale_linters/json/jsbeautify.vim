" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Support for js-beautify, a javascript/json style linter

call ale#Set('json_jsbeautify_executable', 'js-beautify')
call ale#Set('json_jsbeautify_options', '')
call ale#Set('json_jsbeautify_style', '"-n -X -".(&expandtab ? "s ".shiftwidth() : "t").(&textwidth ? " -w ".&textwidth : "")')

function! ale_linters#json#jsbeautify#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'json_jsbeautify_executable')
endfunction

function! ale_linters#json#jsbeautify#GetCommand(buffer) abort
    let l:style = eval(ale#Var(a:buffer, 'json_jsbeautify_style'))
    return ale#Escape(ale_linters#json#jsbeautify#GetExecutable(a:buffer))
    \   . (!empty(l:style) ? ' ' . l:style : '')
    \   . ' ' . ale#Var(a:buffer, 'json_jsbeautify_options')
    \   . ' --stdin < %t | '
    \   . 'diff --old-group-format="%df: warning: js-beautify style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: js-beautify style: )/\n\1\2/g"'
endfunction

function! ale_linters#json#jsbeautify#Handle(buffer, lines) abort
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

call ale#linter#Define('json', {
\   'name': 'jsbeautify',
\   'executable_callback': 'ale_linters#json#jsbeautify#GetExecutable',
\   'command_callback': 'ale_linters#json#jsbeautify#GetCommand',
\   'callback': 'ale_linters#json#jsbeautify#Handle',
\   'read_buffer': 0
\})
