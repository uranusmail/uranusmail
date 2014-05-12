syntax region nmSearch        start=/^/ end=/$/         oneline contains=nmSearchSelect
syntax match  nmSearchSelect  /^ /                      contained nextgroup=nmSearchDate
syntax match  nmSearchDate    /.\{-18}/                 contained nextgroup=nmSearchNum
syntax match  nmSearchNum     /.\{-4}/                  contained nextgroup=nmSearchFrom
syntax match  nmSearchFrom    /.\{-21}/                 contained nextgroup=nmSearchSubject
syntax match  nmSearchSubject /.\{0,}\(([^()]\+)$\)\@=/ contained nextgroup=nmSearchTags
syntax match  nmSearchTags    /.\+$/                    contained

highlight link nmSearchDate    Statement
highlight link nmSearchNum     Type
highlight link nmSearchFrom    Include
highlight link nmSearchSubject Normal
highlight link nmSearchTags    String
