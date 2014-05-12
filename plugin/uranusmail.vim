if exists("g:loaded_uranusmail")
  finish
endif

if !has("ruby") || version < 700
  finish
endif

let g:loaded_uranusmail = 1

let g:uranusmail_folders_maps = {
  \ 'q'       : 'cannot_kill_this_buffer()',
  \ '<Enter>' : 'folders_show_search()',
  \ 's'       : 'folders_search_prompt()',
  \ '='       : 'folders_refresh()',
  \ 'c'       : 'compose()',
  \ ';'       : 'list_buffers()',
  \ }

let g:uranusmail_search_maps = {
  \ 'q'       : 'kill_this_buffer()',
  \ '<Enter>' : 'search_show_thread()',
  \ 'A'       : 'search_tag("-inbox -unread")',
  \ 'I'       : 'search_tag("-unread")',
  \ 't'       : 'search_tag("")',
  \ 's'       : 'search_search_prompt()',
  \ '='       : 'search_refresh()',
  \ '?'       : 'search_info()',
  \ 'c'       : 'compose()',
  \ 'x'       : 'toggle_select_thread()',
  \ ';'       : 'list_buffers()',
  \ }

let g:uranusmail_show_maps = {
  \ 'q'     : 'kill_this_buffer()',
  \ 'A'     : 'show_tag("-inbox -unread")',
  \ 'I'     : 'show_tag("-unread")',
  \ 't'     : 'show_tag("")',
  \ 'o'     : 'show_open_msg()',
  \ 'e'     : 'show_extract_msg()',
  \ 's'     : 'show_save_msg()',
  \ 'p'     : 'show_save_patches()',
  \ 'r'     : 'show_reply()',
  \ '?'     : 'show_info()',
  \ '<Tab>' : 'show_next_msg()',
  \ 'c'     : 'compose()',
  \ ';'     : 'list_buffers()',
  \ }

let g:uranusmail_compose_maps = {
  \ ',s' : 'compose_send()',
  \ ',q' : 'compose_quit()',
  \ ';'  : 'list_buffers()',
  \ }

let s:uranusmail_folders_default = [
  \ [ 'new', 'tag:inbox and tag:unread' ],
  \ [ 'inbox', 'tag:inbox' ],
  \ [ 'unread', 'tag:unread' ],
  \ ]

let s:uranusmail_date_format_default = '%d.%m.%y %H:%M:%S'
let s:notmuch_config = expand("~/.notmuch-config")

function! s:set_defaults()
  if !exists('g:notmuch_config')
    let g:notmuch_config = s:notmuch_config
  endif

  if !exists('g:uranusmail_folders')
    let g:uranusmail_folders = s:uranusmail_folders_default
  endif


  if !exists('g:uranusmail_date_format')
    let g:uranusmail_date_format = s:uranusmail_date_format_default
  endif
endfunction

function! s:set_map(maps)
  nmapclear <buffer>
  for [key, code] in items(a:maps)
    let cmd = printf(":call <SID>%s<CR>", code)
    exec printf('nnoremap <buffer> %s %s', key, cmd)
  endfor
endfunction

function! s:new_buffer(type)
  enew
  setlocal buftype=nofile bufhidden=hide
  keepjumps 0d
  execute printf('set filetype=uranusmail-%s', a:type)
  execute printf('set syntax=uranusmail-%s', a:type)
  ruby $curbuf.init(VIM::evaluate('a:type'))
endfunction

function! s:toggle_select_thread()
  setlocal modifiable
  ruby $curbuf.toggle_select_thread
  normal j
  setlocal nomodifiable
endfunction

function! s:set_menu_buffer()
  setlocal nomodifiable
  setlocal cursorline
  setlocal nowrap
endfunction

function! s:folders_show_search()
  ruby VIM::command("call s:search('#{$curbuf.line_info[:search]}')")
endfunction

function! s:cannot_kill_this_buffer()
  echo "Cannot delete this buffer."
endfunction

function! s:kill_this_buffer()
ruby << EOF
  $curbuf.destroy!
  VIM::command("bdelete!")
EOF
endfunction

function! s:show(thread_id)
  call s:new_buffer('show')
  setlocal modifiable
ruby << EOF
  options = {date_fmt: VIM::evaluate('g:uranusmail_date_format')}
  $uranusmail.render_thread(VIM::evaluate('a:thread_id'), options)
EOF
  setlocal nomodifiable
  call s:set_map(g:uranusmail_show_maps)
endfunction

function! s:search_show_thread()
  ruby VIM::command("call s:show('#{$curbuf.line_info[:thread_id]}')")
endfunction

function! s:search(search)
  call s:new_buffer('search')
ruby << EOF
  options = {date_fmt: VIM::evaluate('g:uranusmail_date_format')}
  $uranusmail.render_search(VIM::evaluate('a:search'), options)
EOF
  call s:set_menu_buffer()
  call s:set_map(g:uranusmail_search_maps)
  autocmd CursorMoved <buffer> call s:show_cursor_moved()
endfunction

function! s:show_cursor_moved()
ruby << EOF
  if $curbuf.load_more?
    VIM::command('setlocal modifiable')
    $curbuf.do_next
    VIM::command('setlocal nomodifiable')
  end
EOF
endfunction

function! s:folders()
  call s:new_buffer('folders')
  ruby $uranusmail.render_folders(VIM::evaluate('g:uranusmail_folders'))
  call s:set_menu_buffer()
  call s:set_map(g:uranusmail_folders_maps)
endfunction

function! s:folders_refresh()
  setlocal modifiable
ruby << EOF
  $uranusmail.database.open_or_reopen
  $uranusmail.render_folders(VIM::evaluate('g:uranusmail_folders'))
EOF
  setlocal nomodifiable
endfunction

function! s:Uranusmail(...)
  call s:set_defaults()

ruby << EOF
  begin
    require 'uranusmail'
  rescue LoadError
    load_path_modified = false
    ::VIM::evaluate('&runtimepath').to_s.split(',').each do |path|
      lib = "#{path}/ruby/lib"
      if !$LOAD_PATH.include?(lib) && File.exist?("#{lib}/uranusmail")
        $LOAD_PATH << lib
        load_path_modified = true
      end
    end

    if load_path_modified
      retry
    else
      raise $LOAD_PATH
    end
  end

  $uranusmail = Uranusmail::Main.init(config_file: VIM::evaluate('g:notmuch_config'))
EOF

  if a:0
    call s:search(join(a:000))
  else
    call s:folders()
  endif
endfunction

command -nargs=* Uranusmail call s:Uranusmail(<f-args>)
