" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: ifort linter for fortran files

call ale#Set('fortran_ifort_executable', 'ifort')
call ale#Set('fortran_ifort_options', '')

function! ale_linters#fortran#ifort#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'fortran_ifort_executable')
endfunction

function! ale_linters#fortran#ifort#GetCommand(buffer) abort
    " -I with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#fortran#ifort#GetExecutable(a:buffer))
    \   . ' -syntax-only'
    \   . ' -I' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#Var(a:buffer, 'fortran_ifort_options')
    \   . ' %t'
endfunction

function! ale_linters#fortran#ifort#Handle(buffer, lines) abort
    " matches: 'main.f90(3): error #5082: Syntax error, found END-OF-STATEMENT ...'
    let l:pattern = '\v\((\d+)\): (\w+) (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'text': l:match[3],
        \   'type': (l:match[2] is# 'error') ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('fortran', {
\   'name': 'ifort',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#fortran#ifort#GetExecutable',
\   'command_callback': 'ale_linters#fortran#ifort#GetCommand',
\   'callback': 'ale_linters#fortran#ifort#Handle',
\   'read_buffer': 0,
\})
