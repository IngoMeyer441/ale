" Author: Tomota Nakamura <https://github.com/tomotanakamura>
" Description: oclint linter for cpp files

call ale#Set('cpp_oclint_executable', 'oclint')
call ale#Set('cpp_oclint_options', '')
call ale#Set('cpp_oclint_compileflags', '')

function! ale_linters#cpp#oclint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_oclint_executable')
endfunction

function! ale_linters#cpp#oclint#GetCommand(buffer) abort
    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#cpp#oclint#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'cpp_oclint_options') . ' %t '
    \   . '-- -x c++ '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths)
    \   . ale#Var(a:buffer, 'cpp_oclint_compileflags')
endfunction

function! ale_linters#cpp#oclint#Handle(buffer, lines) abort
    " matches: 'bad.cpp:3:5: collapsible if statements [basic|P3]'
    let l:pattern = '\v^(.+):(\d*):(\d*): (.+)$'
    let l:dir = expand('#' . a:buffer . ':p:h')
    let l:output = []
    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'filename': ale#path#GetAbsPath(l:dir, l:match[1]),
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': 'W',
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('cpp', {
\   'name': 'oclint',
\   'output_stream': 'stdout',
\   'executable': function('ale_linters#cpp#oclint#GetExecutable'),
\   'command': function('ale_linters#cpp#oclint#GetCommand'),
\   'callback': 'ale_linters#cpp#oclint#Handle',
\   'read_buffer': 0,
\})
