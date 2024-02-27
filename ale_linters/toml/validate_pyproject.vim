" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Support for https://github.com/abravalheri/validate-pyproject,
"              a linter for `pyproject.toml` files

call ale#Set('toml_validate_pyproject_executable', 'validate-pyproject')
call ale#Set('toml_validate_pyproject_options', '')

function! ale_linters#toml#validate_pyproject#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'toml_validate_pyproject_executable')
endfunction

function! ale_linters#toml#validate_pyproject#GetCommand(buffer) abort
    if fnamemodify(bufname(a:buffer), ':t') !=# 'pyproject.toml'
        return ''
    endif

    return ale_linters#toml#validate_pyproject#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'toml_validate_pyproject_options')
endfunction

function! ale_linters#toml#validate_pyproject#Handle(buffer, lines) abort
    let l:output = []

    for l:text in a:lines[1:]
        call add(l:output, {
        \   'lnum': 1,
        \   'col': 0,
        \   'text': l:text,
        \   'type': 'E'
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('toml', {
\   'name': 'validate-pyproject',
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#toml#validate_pyproject#GetExecutable'),
\   'command': function('ale_linters#toml#validate_pyproject#GetCommand'),
\   'callback': 'ale_linters#toml#validate_pyproject#Handle'
\})
