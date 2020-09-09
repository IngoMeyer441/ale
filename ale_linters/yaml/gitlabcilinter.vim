" Author: Ingo Meyer <i.meyer@fz-juelich.de>

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
    \   . ' -f %t'
endfunction

function! ale_linters#yaml#gitlabcilinter#Handle(buffer, lines) abort
    " Matches all lines, extracts line and column if available
    let l:pattern = '^\(.\{-1,}\)\%(\sat\sline\s\(\d\+\)\scolumn\s\(\d\+\)\)\?$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if len(l:match) > 1
            let l:line = l:match[2] + 0
            let l:col = l:match[3] + 0
        else
            let l:line = 1
            let l:col = 0
        endif
        let l:text = l:match[1]

        call add(l:output, {
        \   'lnum': l:line,
        \   'col': l:col,
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
