" Author: keith <k@keith.so>
" Description: py3kwarn for python files

let g:ale_python_py3kwarn_executable =
\   get(g:, 'ale_python_py3kwarn_executable', 'py3kwarn')

let g:ale_python_py3kwarn_options =
\   get(g:, 'ale_python_py3kwarn_options', '')

let g:ale_python_py3kwarn_use_global = get(g:, 'ale_python_py3kwarn_use_global', 0)

function! ale_linters#python#py3kwarn#GetExecutable(buffer) abort
    return ale#python#FindExecutable(a:buffer, 'python_py3kwarn', ['py3kwarn'])
endfunction

function! ale_linters#python#py3kwarn#GetCommand(buffer) abort
    return ale#Escape(ale_linters#python#py3kwarn#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'python_py3kwarn_options')
    \   . ' %s'
endfunction

function! ale_linters#python#py3kwarn#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " test.py:4:4: PY3K (FixBasestring) basestring; -> str;
    let l:pattern = '\v^[^:]+:(\d+):(\d+): PY3K \(([^(]*)\) (.*)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        "let l:failed = append(0, l:match)
        let l:code = l:match[3]

        if (l:code is# 'C0303')
        \ && !ale#Var(a:buffer, 'warn_about_trailing_whitespace')
            " Skip warnings for trailing whitespace if the option is off.
            continue
        endif

        if l:code is# 'I0011'
            " Skip 'Locally disabling' message
             continue
        endif

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4] . ' (' . l:match[3] . ')',
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('python', {
\   'name': 'py3kwarn',
\   'executable_callback': 'ale_linters#python#py3kwarn#GetExecutable',
\   'command_callback': 'ale_linters#python#py3kwarn#GetCommand',
\   'callback': 'ale_linters#python#py3kwarn#Handle',
\   'lint_file': 1,
\})
