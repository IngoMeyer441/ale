" Author: w0rp <devw0rp@gmail.com, Ingo Meyer
" Description: clang linter (windows mode) for cpp files

call ale#Set('cpp_clangwin_executable', 'clang')
call ale#Set('cpp_clangwin_options', '')
call ale#Set('cpp_clangwin_windows_include_directories', [expand('~/win_include')])
call ale#Set('cpp_clangwin_target', 'amd64-pc-windows-msvc')
call ale#Set('cpp_clangwin_windows_options', '-Wno-unknown-pragmas -fms-compatibility-version=19 -U__clang__ -U__clang_version__ -U__clang_major__ -U__clang_minor__ -U__clang_patchlevel__ -U__llvm__')
call ale#Set('cpp_clangwin_enable', 0)

function! ale_linters#cpp#clangwin#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_clangwin_executable')
endfunction

function! ale_linters#cpp#clangwin#GetCommand(buffer) abort
    if !ale#Var(a:buffer, 'cpp_clangwin_enable')
        return ''
    endif

    if !empty(ale#Var(a:buffer, 'cpp_clangwin_windows_include_directories'))
        let l:std_include_paths = '-isystem' . join(ale#Var(a:buffer, 'cpp_clangwin_windows_include_directories'), ' -isystem')
    else
        let l:std_include_paths = ''
    endif

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    "
    " `-o /dev/null` or `-o null` is needed to catch all errors,
    " -fsyntax-only doesn't catch everything.
    return '%e -S -x c++'
    \   . ' -o ' . g:ale#util#nul_file
    \   . ' -iquote %s:h'
    \   . ale#Pad(ale#Var(a:buffer, 'cpp_clangwin_options'))
    \   . ale#Pad(ale#Var(a:buffer, 'cpp_clangwin_windows_options'))
    \   . ' --target=' . ale#Var(a:buffer, 'cpp_clangwin_target')
    \   . (!empty(l:std_include_paths) ? ' -nostdinc ' . l:std_include_paths : '')
    \   . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangwin',
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#cpp#clangwin#GetExecutable'),
\   'command': function('ale_linters#cpp#clangwin#GetCommand'),
\   'callback': 'ale#handlers#gcc#HandleGCCFormatWithIncludes',
\})
