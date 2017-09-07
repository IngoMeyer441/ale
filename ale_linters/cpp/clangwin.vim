" Author: Masahiro H https://github.com/mshr-h
" Description: clang linter (windows mode) for cpp files

call ale#Set('cpp_clangwin_executable', 'clang')
call ale#Set('cpp_clangwin_options', '-std=c++11 -Wall')
call ale#Set('cpp_clangwin_windows_include_directory', expand('~/win_include'))
call ale#Set('cpp_clangwin_windows_options', '-Wno-unknown-pragmas --target=amd64-pc-windows-msvc -fms-compatibility-version=19 -U__clang__ -U__clang_version__ -U__clang_major__ -U__clang_minor__ -U__clang_patchlevel__ -U__llvm__')

function! ale_linters#cpp#clangwin#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_clangwin_executable')
endfunction

function! ale_linters#cpp#clangwin#GetCommand(buffer) abort
    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#cpp#clangwin#GetExecutable(a:buffer))
    \   . ' -S -x c++ -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths) . ' '
    \   . ale#Var(a:buffer, 'cpp_clangwin_options') . ' '
    \   . ale#Var(a:buffer, 'cpp_clangwin_windows_options') . ' '
    \   . (!empty(ale#Var(a:buffer, 'cpp_clangwin_windows_include_directory')) ? '-nostdinc -isystem' . ale#Var(a:buffer, 'cpp_clangwin_windows_include_directory') . ' ' : '')
    \   . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangwin',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#cpp#clangwin#GetExecutable',
\   'command_callback': 'ale_linters#cpp#clangwin#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
