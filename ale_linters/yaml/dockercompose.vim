" Author: Ingo Heimbach <i.heimbach@fz-juelich.de>

call ale#Set('yaml_dockercompose_executable', 'docker-compose')
call ale#Set('yaml_dockercompose_options', '')

function! ale_linters#yaml#dockercompose#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'yaml_dockercompose_executable')
endfunction

function! ale_linters#yaml#dockercompose#GetCommand(buffer) abort
    if fnamemodify(bufname(a:buffer), ':t') !=# 'docker-compose.yml'
        return ''
    endif

    return ale_linters#yaml#dockercompose#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'yaml_dockercompose_options')
    \   . ' -f %t config'
endfunction

function! ale_linters#yaml#dockercompose#Handle(buffer, lines) abort
    " Matches all lines, removes `ERROR: ` and extracts line and column if available
    let l:pattern = '^\%(ERROR:\s\)\?\(.\{-1,}\)\%(,\sline\s\(\d\+\),\scolumn\s\(\d\+\)\)\?$'
    let l:output = []

    " join multiline error messages (continuation lines start with whitespace)
    let l:joined_lines = []
    for l:line in a:lines
        let l:match = matchlist(l:line, '^\s\+\(.*\)$')
        if empty(l:match)
            call add(l:joined_lines, l:line)
        else
            let l:joined_lines[-1] .= ' ' . l:match[1]
        endif
    endfor

    for l:match in ale#util#GetMatches(l:joined_lines, l:pattern)
        if len(l:match) > 1
            let l:line = l:match[2] + 0
            let l:col = l:match[3] + 0
        else
            let l:line = 1
            let l:col = 0
        endif
        let l:text = l:match[1]

        call add(l:output, {
        \   'lnum': l:line,
        \   'col': l:col,
        \   'text': l:text,
        \   'type': 'E'
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('yaml', {
\   'name': 'dockercompose',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#yaml#dockercompose#GetExecutable',
\   'command_callback': 'ale_linters#yaml#dockercompose#GetCommand',
\   'callback': 'ale_linters#yaml#dockercompose#Handle',
\   'read_buffer': 0
\})
