" Author: Tomota Nakamura <https://github.com/tomotanakamura>, Ingo Meyer
" Description: oclint linter for c files

call ale#Set('c_oclint_executable', 'oclint')
call ale#Set('c_oclint_options', '')
call ale#Set('c_oclint_compileflags', '')

function! ale_linters#c#oclint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_oclint_executable')
endfunction

function! ale_linters#c#oclint#GetCommand(buffer) abort
    let l:compile_commands_option = substitute(
                \ ale#handlers#cppcheck#GetCompileCommandsOptions(a:buffer),
                \ '^--project',
                \ '-p',
                \ '')
    let l:oclint_compileflags = ale#Var(a:buffer, 'c_oclint_compileflags')
    let l:buffer_path_include = empty(l:compile_commands_option)
    \   ? ale#handlers#cppcheck#GetBufferPathIncludeOptions(a:buffer)
    \   : ''

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return '%e'
    \   . ale#Pad(ale#Var(a:buffer, 'c_oclint_options'))
    \   . ale#Pad(l:compile_commands_option)
    \   . ' %s'
    \   . (!empty(l:oclint_compileflags) && !empty(l:buffer_path_include) ? ' --' : '')
    \   . ale#Pad(l:oclint_compileflags)
    \   . l:buffer_path_include
endfunction

function! ale_linters#c#oclint#Handle(buffer, lines) abort
    " matches: 'bad.c:3:5: collapsible if statements [basic|P3]'
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

call ale#linter#Define('c', {
\   'name': 'oclint',
\   'output_stream': 'stdout',
\   'executable': function('ale_linters#c#oclint#GetExecutable'),
\   'command': function('ale_linters#c#oclint#GetCommand'),
\   'callback': 'ale_linters#c#oclint#Handle',
\   'lint_file': 1,
\})
