" Author: geam <mdelage@student.42.fr>
" Description: mingw linter for cpp files
"
call ale#Set('cpp_mingw_executable', 'x86_64-w64-mingw32-gcc')
call ale#Set('cpp_mingw_options', '')

function! ale_linters#cpp#mingw#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_mingw_executable')
endfunction

function! ale_linters#cpp#mingw#GetCommand(buffer, output) abort
    let l:cflags = ale#c#GetCFlags(a:buffer, a:output)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#cpp#mingw#GetExecutable(a:buffer))
    \   . ' -S -x c++ -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . l:cflags
    \   . ale#Var(a:buffer, 'cpp_mingw_options') . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'mingw',
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#cpp#mingw#GetExecutable'),
\   'command_chain': [
\       {'callback': 'ale#c#GetMakeCommand', 'output_stream': 'stdout'},
\       {'callback': 'ale_linters#cpp#mingw#GetCommand'},
\   ],
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
