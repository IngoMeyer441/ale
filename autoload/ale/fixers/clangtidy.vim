" Author: tunnckoCore (Charlike Mike Reagent) <mameto2011@gmail.com>,
"         w0rp <devw0rp@gmail.com>
" Description: Integration between Prettier and ESLint.

call ale#Set(&filetype . '_clangtidy_executable', 'clang-tidy')
" Set this option to check the checks clang-tidy will apply.
call ale#Set(&filetype . '_clangtidy_checks', ['*'])
" Set this option to manually set some options for clang-tidy.
" This will disable compile_commands.json detection.
call ale#Set(&filetype . '_clangtidy_options', '')
call ale#Set('c_build_dir', '')

function! ale#fixers#clangtidy#GetExecutable(buffer) abort
    return ale#Var(a:buffer, &filetype . '_clangtidy_executable')
endfunction

function! s:GetBuildDirectory(buffer) abort
    " Don't include build directory for header files, as compile_commands.json
    " files don't consider headers to be translation units, and provide no
    " commands for compiling header files.
    if expand('#' . a:buffer) =~# '\v\.(h|hpp)$'
        return ''
    endif

    let l:build_dir = ale#Var(a:buffer, 'c_build_dir')

    " c_build_dir has the priority if defined
    if !empty(l:build_dir)
        return l:build_dir
    endif

    return ale#c#FindCompileCommands(a:buffer)
endfunction

function! ale#fixers#clangtidy#Fix(buffer, lines, fix_whole_buffer, line_range) abort
    let l:checks = join(ale#Var(a:buffer, &filetype . '_clangtidy_checks'), ',')
    let l:build_dir = s:GetBuildDirectory(a:buffer)

    " Get the extra options if we couldn't find a build directory.
    let l:options = empty(l:build_dir)
    \   ? ale#Var(a:buffer, &filetype . '_clangtidy_options')
    \       . ' -iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h'))
    \   : ''

    if empty(l:build_dir)
        let l:filename = tempname() . '_clangtidy_linted.cpp'
        " Create a special filename, so we can detect it in the handler.
        call ale#engine#ManageFile(a:buffer, l:filename)
        let l:buflines = getbufline(a:buffer, 1, '$')
        call ale#util#Writefile(a:buffer, l:buflines, l:filename)
        let l:filename = ale#Escape(l:filename)
    else
        let l:filename = '%s'
    endif

    let l:line_filter = a:fix_whole_buffer
    \   ? ''
    \   : ' -line-filter=''[{"name":"%t","lines":[' . string(a:line_range) . ']}]'''

    return {
    \   'command': ale#Escape(ale#fixers#clangtidy#GetExecutable(a:buffer))
    \       . (!empty(l:checks) ? ' -checks=' . ale#Escape(l:checks) : '')
    \       . ' %t'
    \       . ' -fix-errors'
    \       . l:line_filter
    \       . (!empty(l:build_dir) ? ' -p ' . ale#Escape(l:build_dir) : '')
    \       . (!empty(l:options) ? ' -- ' . l:options : ''),
    \   'read_temporary_file': 1,
    \}
endfunction
