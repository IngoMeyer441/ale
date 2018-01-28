" Author: Masahiro H https://github.com/mshr-h
" Description: clang linter (unix mode) for c files

call ale#Set('c_clangunix_executable', 'clang')
call ale#Set('c_clangunix_options', '')
call ale#Set('c_clangunix_unix_include_directories', [expand('~/linux_include')])
call ale#Set('c_clangunix_target', 'amd64-pc-linux-gcc')
call ale#Set('c_clangunix_unix_options', '-Wno-unknown-pragmas -U__clang__ -U__clang_version__ -U__clang_major__ -U__clang_minor__ -U__clang_patchlevel__ -U__llvm__')
call ale#Set('c_clangunix_enable', 0)

function! ale_linters#c#clangunix#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_clangunix_executable')
endfunction

function! ale_linters#c#clangunix#GetCommand(buffer) abort
    if !ale#Var(a:buffer, 'c_clangunix_enable')
        return ''
    endif

    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)
    if !empty(ale#Var(a:buffer, 'c_clangunix_unix_include_directories'))
        let l:std_include_paths = '-isystem' . join(ale#Var(a:buffer, 'c_clangunix_unix_include_directories'), ' -isystem')
    else
        let l:std_include_paths = ''
    endif
    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return ale#Escape(ale_linters#c#clangunix#GetExecutable(a:buffer))
    \   . ' -S -x c -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths) . ' '
    \   . ale#Var(a:buffer, 'c_clangunix_options') . ' '
    \   . '--target=' . ale#Var(a:buffer, 'c_clangunix_target') . ' '
    \   . ale#Var(a:buffer, 'c_clangunix_unix_options') . ' '
    \   . (!empty(l:std_include_paths) ? '-nostdinc ' . l:std_include_paths : '')
    \   . ' -'
endfunction

call ale#linter#Define('c', {
\   'name': 'clangunix',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#c#clangunix#GetExecutable',
\   'command_callback': 'ale_linters#c#clangunix#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
