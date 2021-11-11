" Author: w0rp <devw0rp@gmail.com, Ingo Meyer
" Description: clang linter (unix mode) for cpp files

call ale#Set('cpp_clangunix_executable', 'clang')
call ale#Set('cpp_clangunix_options', '')
call ale#Set('cpp_clangunix_unix_include_directories', [expand('~/linux_include')])
call ale#Set('cpp_clangunix_target', 'amd64-pc-linux-gcc')
call ale#Set('cpp_clangunix_unix_options', '-Wno-unknown-pragmas -U__clang__ -U__clang_version__ -U__clang_major__ -U__clang_minor__ -U__clang_patchlevel__ -U__llvm__')
call ale#Set('cpp_clangunix_enable', 0)

function! ale_linters#cpp#clangunix#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_clangunix_executable')
endfunction

function! ale_linters#cpp#clangunix#GetCommand(buffer) abort
    if !ale#Var(a:buffer, 'cpp_clangunix_enable')
        return ''
    endif

    if !empty(ale#Var(a:buffer, 'cpp_clangunix_unix_include_directories'))
        let l:std_include_paths = '-isystem' . join(ale#Var(a:buffer, 'cpp_clangunix_unix_include_directories'), ' -isystem')
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
    \   . ale#Pad(ale#Var(a:buffer, 'cpp_clangunix_options'))
    \   . ale#Pad(ale#Var(a:buffer, 'cpp_clangunix_unix_options'))
    \   . ' --target=' . ale#Var(a:buffer, 'cpp_clangunix_target')
    \   . (!empty(l:std_include_paths) ? ' -nostdinc ' . l:std_include_paths : '')
    \   . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangunix',
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#cpp#clangunix#GetExecutable'),
\   'command': function('ale_linters#cpp#clangunix#GetCommand'),
\   'callback': 'ale#handlers#gcc#HandleGCCFormatWithIncludes',
\})
