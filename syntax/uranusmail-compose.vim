runtime! syntax/mail.vim

syntax region umComposeHelp          contains=umComposeHelpLine start='^Uranusmail-Help:\%1l' end='^\(Uranusmail-Help:\)\@!'
syntax match  umComposeHelpLine      /Uranusmail-Help:/ contained

highlight link umComposeHelp        Include
highlight link umComposeHelpLine    Error
