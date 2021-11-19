" Author: Ingo Meyer <https://github.com/IngoMeyer441>
" Description: oclint linter for cpp files, based on `clangtidy.vim`

call ale#Set('cpp_oclint_executable', 'oclint')
call ale#Set('cpp_oclint_options', '')
call ale#Set('cpp_oclint_compileflags', '')

function! ale_linters#cpp#oclint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_oclint_executable')
endfunction

function! ale_linters#cpp#oclint#GetCommand(buffer, output) abort
    let l:cflags = ''
    let l:build_dir = ale#c#GetBuildDirectory(a:buffer)
    if empty(l:build_dir)
        let l:user_cflags = ale#Var(a:buffer, 'cpp_oclint_compileflags')
        let l:auto_cflags = ale#c#GetCFlags(a:buffer, a:output)
        let l:cflags = l:user_cflags . (!empty(l:user_cflags) ? ale#Pad(l:auto_cflags) : l:auto_cflags)
    endif

    return '%e'
    \   . ale#Pad(ale#Var(a:buffer, 'cpp_oclint_options'))
    \   . (!empty(l:build_dir) ? ' -p=' . ale#Escape(l:build_dir) : '')
    \   . ' %s'
    \   . (!empty(l:cflags) ? ' --' : '')
    \   . ale#Pad(l:cflags)
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
\   'command': {b -> ale#c#RunMakeCommand(b, function('ale_linters#cpp#oclint#GetCommand'))},
\   'callback': 'ale_linters#cpp#oclint#Handle',
\   'lint_file': 1,
\})
