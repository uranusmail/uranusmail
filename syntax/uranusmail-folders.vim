" uranusmail folders mode syntax file

syntax region umFoldersCount     start='^' end='\%10v'
syntax region umFoldersName      start='\%11v' end='\%31v'
syntax match  umFoldersSearch    /([^()]\+)$/

highlight link umFoldersCount     Statement
highlight link umFoldersName      Type
highlight link umFoldersSearch    String

highlight CursorLine term=reverse cterm=reverse gui=reverse
