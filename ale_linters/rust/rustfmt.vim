" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Support for rustfmt, a rust style linter

call ale#Set('rust_rustfmt_executable', 'rustfmt')
call ale#Set('rust_rustfmt_options', '')
call ale#Set('rust_rustfmt_style', '(&expandtab ? "hard_tabs=false,tab_spaces=".shiftwidth() : "hard_tabs=true").(&textwidth ? ",max_width=".&textwidth : "")')

function! ale_linters#rust#rustfmt#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'rust_rustfmt_executable')
endfunction

function! ale_linters#rust#rustfmt#GetCommand(buffer) abort
    let l:style = eval(ale#Var(a:buffer, 'rust_rustfmt_style'))
    return ale#Escape(ale_linters#rust#rustfmt#GetExecutable(a:buffer))
    \   . ' --config="'. l:style . '"'
    \   . ' ' . ale#Var(a:buffer, 'rust_rustfmt_options')
    \   . ' < %t | '
    \   . 'diff --old-group-format="%df: warning: rustfmt style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: rustfmt style: )/\n\1\2/g"'
endfunction

function! ale_linters#rust#rustfmt#Handle(buffer, lines) abort
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

call ale#linter#Define('rust', {
\   'name': 'rustfmt',
\   'executable': function('ale_linters#rust#rustfmt#GetExecutable'),
\   'command': function('ale_linters#rust#rustfmt#GetCommand'),
\   'callback': 'ale_linters#rust#rustfmt#Handle',
\   'read_buffer': 0
\})
