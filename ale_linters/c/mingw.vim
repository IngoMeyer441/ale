" Author: w0rp <devw0rp@gmail.com>, Ingo Meyer
" Description: mingw linter for c files

call ale#Set('c_mingw_executable', 'x86_64-w64-mingw32-gcc')
call ale#Set('c_mingw_options', '')

function! ale_linters#c#mingw#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_mingw_executable')
endfunction

function! ale_linters#c#mingw#GetCommand(buffer, output) abort
    let l:cflags = ale#c#GetCFlags(a:buffer, a:output)
    let l:ale_flags = ale#Var(a:buffer, 'c_mingw_options')

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    "
    " `-o /dev/null` or `-o null` is needed to catch all errors,
    " -fsyntax-only doesn't catch everything.
    return '%e -S -x c'
    \   . ' -o ' . g:ale#util#nul_file
    \   . ' -iquote %s:h'
    \   . ale#Pad(l:cflags)
    \   . ale#Pad(l:ale_flags) . ' -'
endfunction

call ale#linter#Define('c', {
\   'name': 'mingw',
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#c#mingw#GetExecutable'),
\   'command': {b -> ale#c#RunMakeCommand(b, function('ale_linters#c#mingw#GetCommand'))},
\   'callback': 'ale#handlers#gcc#HandleGCCFormatWithIncludes',
\})
