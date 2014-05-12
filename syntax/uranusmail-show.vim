" uranusmail show mode syntax file

syntax cluster umShowMsgDesc     contains=umShowMsgDescWho,umShowMsgDescDate,umShowMsgDescTags
syntax match   umShowMsgDescWho  /[^)]\+)/ contained
syntax match   umShowMsgDescDate / ([^)]\+[0-9]) / contained
syntax match   umShowMsgDescTags /([^)]\+)$/ contained

syntax cluster umShowMsgHead    contains=umShowMsgHeadKey,umShowMsgHeadVal
syntax match   umShowMsgHeadKey /^[^:]\+: / contained
syntax match   umShowMsgHeadVal /^\([^:]\+: \)\@<=.*/ contained

syntax cluster umShowMsgBody      contains=@umShowMsgBodyMail,@umShowMsgBodyGit
syntax include @umShowMsgBodyMail syntax/mail.vim

silent! syntax include @umShowMsgBodyGit syntax/uranusmail-git-diff.vim

highlight umShowMsgDescWho       term=reverse cterm=reverse gui=reverse
highlight link umShowMsgDescDate Type
highlight link umShowMsgDescTags String

highlight link umShowMsgHeadKey  Macro
"highlight link umShowMsgHeadVal NONE

highlight Folded term=reverse ctermfg=LightGrey ctermbg=Black guifg=LightGray guibg=Black
