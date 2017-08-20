" Author: Ingo Heimbach <i.heimbach@fz-juelich.de>
" Description: Support for rstcheck, a rst linter

call ale#Set('rst_rstcheck_executable', 'rstcheck')
call ale#Set('rst_rstcheck_options', '')

function! ale_linters#rst#rstcheck#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'rst_rstcheck_executable')
endfunction

function! ale_linters#rst#rstcheck#GetCommand(buffer) abort
    return ale#Escape(ale_linters#rst#rstcheck#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'rst_rstcheck_options')
    \   . ' -'
endfunction

function! ale_linters#rst#rstcheck#Handle(buffer, lines) abort
    " matches: '-:2: (WARNING/2) Title underline too short.'
    let l:pattern = '\v:(\d+): \((.+)\) (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'text': l:match[3],
        \   'type': (l:match[2] is# 'SEVERE/4') ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('rst', {
\   'name': 'rstcheck',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#rst#rstcheck#GetExecutable',
\   'command_callback': 'ale_linters#rst#rstcheck#GetCommand',
\   'callback': 'ale_linters#rst#rstcheck#Handle'
\})
