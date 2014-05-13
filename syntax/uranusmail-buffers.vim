syntax region nmBuffer       start=/^/ end=/$/ oneline contains=nmBufferNumber
syntax match  nmBufferNumber /^[0-9]*: / contained nextgroup=nmBufferType
syntax match  nmBufferType   /[^ ]*/       contained nextgroup=nmRepresent
syntax match  nmRepresent    /.*/          contained

highlight link nmBufferNumber Statement
highlight link nmBufferType   Type
highlight link nmRepresent    Include
