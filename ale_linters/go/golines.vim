" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Support for golines, a go style linter

call ale#Set('go_golines_executable', 'golines')
call ale#Set('go_golines_options', '(&textwidth ? "--max-len=".&textwidth." " : "")."--tab-len=".&shiftwidth')

function! ale_linters#go#golines#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'go_golines_executable')
endfunction

function! ale_linters#go#golines#GetCommand(buffer) abort
    let l:options = eval(ale#Var(a:buffer, 'go_golines_options'))
    return ale#Escape(ale_linters#go#golines#GetExecutable(a:buffer))
    \   . ale#Pad(l:options)
    \   . ' %t | '
    \   . 'diff --old-group-format="%df: warning: golines style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: golines style: )/\n\1\2/g"'
endfunction

function! ale_linters#go#golines#Handle(buffer, lines) abort
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

call ale#linter#Define('go', {
\   'name': 'golines',
\   'executable': function('ale_linters#go#golines#GetExecutable'),
\   'command': function('ale_linters#go#golines#GetCommand'),
\   'callback': 'ale_linters#go#golines#Handle',
\   'read_buffer': 0
\})
