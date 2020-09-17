" Author: w0rp <devw0rp@gmail.com>
" Description: mingw linter for c files

call ale#Set('c_mingw_executable', 'x86_64-w64-mingw32-gcc')
call ale#Set('c_mingw_options', '')

function! ale_linters#c#mingw#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_mingw_executable')
endfunction

function! ale_linters#c#mingw#GetCommand(buffer, output) abort
    let l:cflags = ale#c#GetCFlags(a:buffer, a:output)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#c#mingw#GetExecutable(a:buffer))
    \   . ' -S -x c -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . l:cflags
    \   . ale#Var(a:buffer, 'c_mingw_options') . ' -'
endfunction

call ale#linter#Define('c', {
\   'name': 'mingw',
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#c#mingw#GetExecutable'),
\   'command': {b -> ale#c#RunMakeCommand(b, function('ale_linters#c#mingw#GetCommand'))},
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
