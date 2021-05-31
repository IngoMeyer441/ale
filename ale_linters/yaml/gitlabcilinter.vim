" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Support for https://gitlab.com/devopshq/gitlab-ci-linter,
"              a linter for `.gitlab-c.yml` files

call ale#Set('yaml_gitlabcilinter_executable', 'gitlab-ci-linter')
call ale#Set('yaml_gitlabcilinter_options', '')

function! ale_linters#yaml#gitlabcilinter#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'yaml_gitlabcilinter_executable')
endfunction

function! ale_linters#yaml#gitlabcilinter#GetCommand(buffer) abort
    if fnamemodify(bufname(a:buffer), ':t') !=# '.gitlab-ci.yml'
        return ''
    endif

    return ale_linters#yaml#gitlabcilinter#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'yaml_gitlabcilinter_options')
    \   . ' --filename %t'
endfunction

function! ale_linters#yaml#gitlabcilinter#Handle(buffer, lines) abort
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

call ale#linter#Define('yaml', {
\   'name': 'gitlabcilinter',
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#yaml#gitlabcilinter#GetExecutable'),
\   'command': function('ale_linters#yaml#gitlabcilinter#GetCommand'),
\   'callback': 'ale_linters#yaml#gitlabcilinter#Handle',
\   'read_buffer': 0
\})
