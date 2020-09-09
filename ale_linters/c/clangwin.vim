" Author: Masahiro H https://github.com/mshr-h
" Description: clang linter (windows mode) for c files

call ale#Set('c_clangwin_executable', 'clang')
call ale#Set('c_clangwin_options', '')
call ale#Set('c_clangwin_windows_include_directories', [expand('~/win_include')])
call ale#Set('c_clangwin_windows_options', '-Wno-unknown-pragmas --target=amd64-pc-windows-msvc -fms-compatibility-version=19 -U__clang__ -U__clang_version__ -U__clang_major__ -U__clang_minor__ -U__clang_patchlevel__ -U__llvm__')
call ale#Set('c_clangwin_enable', 0)

function! ale_linters#c#clangwin#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_clangwin_executable')
endfunction

function! ale_linters#c#clangwin#GetCommand(buffer) abort
    if !ale#Var(a:buffer, 'c_clangwin_enable')
        return ''
    endif

    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)
    if !empty(ale#Var(a:buffer, 'c_clangwin_windows_include_directories'))
        let l:std_include_paths = '-isystem' . join(ale#Var(a:buffer, 'c_clangwin_windows_include_directories'), ' -isystem')
    else
        let l:std_include_paths = ''
    endif
    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#c#clangwin#GetExecutable(a:buffer))
    \   . ' -S -x c -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths) . ' '
    \   . ale#Var(a:buffer, 'c_clangwin_options') . ' '
    \   . ale#Var(a:buffer, 'c_clangwin_windows_options') . ' '
    \   . (!empty(l:std_include_paths) ? '-nostdinc ' . l:std_include_paths : '')
    \   . ' -'
endfunction

call ale#linter#Define('c', {
\   'name': 'clangwin',
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#c#clangwin#GetExecutable'),
\   'command': function('ale_linters#c#clangwin#GetCommand'),
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
