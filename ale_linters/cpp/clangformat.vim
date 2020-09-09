" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Support for clangformat, a cpp style linter

call ale#Set('cpp_clangformat_executable', 'clang-format')
call ale#Set('cpp_clangformat_options', '')
call ale#Set('cpp_clangformat_style', '"{BasedOnStyle: Google, ".(&textwidth ? "ColumnLimit: ".&textwidth.", " : "").(&expandtab ? "UseTab: Never, IndentWidth: ".shiftwidth() : "UseTab: Always")."}"')

function! ale_linters#cpp#clangformat#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_clangformat_executable')
endfunction

function! ale_linters#cpp#clangformat#GetCommand(buffer) abort
    let l:style = eval(ale#Var(a:buffer, 'cpp_clangformat_style'))
    return ale#Escape(ale_linters#cpp#clangformat#GetExecutable(a:buffer))
    \   . ' --assume-filename="%s"'
    \   . ' --style="' . l:style . '"'
    \   . ' ' . ale#Var(a:buffer, 'cpp_clangformat_options')
    \   . ' < %t | '
    \   . 'diff --old-group-format="%df: warning: clang-format style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: clang-format style: )/\n\1\2/g"'
endfunction

function! ale_linters#cpp#clangformat#Handle(buffer, lines) abort
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

call ale#linter#Define('cpp', {
\   'name': 'clangformat',
\   'executable': function('ale_linters#cpp#clangformat#GetExecutable'),
\   'command': function('ale_linters#cpp#clangformat#GetCommand'),
\   'callback': 'ale_linters#cpp#clangformat#Handle',
\   'read_buffer': 0
\})
