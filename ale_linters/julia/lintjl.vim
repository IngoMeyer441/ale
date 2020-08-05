" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Lint.jl linter for julia files

call ale#Set('julia_lintjl_julia_executable', 'julia')
call ale#Set('julia_lintjl_julia_script', '''using Lint; for message in lintfile("%s"); println(message); end''')
call ale#Set('julia_lintjl_options', '')

function! ale_linters#julia#lintjl#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'julia_lintjl_julia_executable')
endfunction

function! ale_linters#julia#lintjl#GetCommand(buffer) abort
    " -I with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#julia#lintjl#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'julia_lintjl_options')
    \   . ' -e '
    \   . ale#Var(a:buffer, 'julia_lintjl_julia_script')
endfunction

function! ale_linters#julia#lintjl#Handle(buffer, lines) abort
    " matches: 'test.jl:23 E321 prit: use of undeclared symbol'
    let l:pattern = '\v(\d+) (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'text': l:match[2],
        \   'type': (l:match[2][0] is# 'E') ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('julia', {
\   'name': 'lintjl',
\   'output_stream': 'stdout',
\   'executable_callback': 'ale_linters#julia#lintjl#GetExecutable',
\   'command_callback': 'ale_linters#julia#lintjl#GetCommand',
\   'callback': 'ale_linters#julia#lintjl#Handle',
\   'lint_file': 1,
\})
