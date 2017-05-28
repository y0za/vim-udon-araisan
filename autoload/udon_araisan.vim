let s:plugin_name = 'vim-udon-araisan'
let s:frame_num = 4
let s:interframe_gap = 150

function! s:render_frame(bufname, frame) abort
  if bufnr(a:bufname) == -1
    return
  endif

  let mode = mode()
  let prev_winnum = winnr()
  let winnum = bufwinnr(a:bufname)
  if winnum != prev_winnum
    if winnum == -1
      silent exec 'sp ' . a:bufname
    else
      exec winnum . 'wincmd w'
    endif
  endif

  setlocal modifiable
  silent %delete _
  put =a:frame
  setlocal nomodifiable

  if winnum == -1
    silent hide
  endif

  exec prev_winnum . 'wincmd w'
  if mode =~# '[sSvV]'
    silent! normal gv
  endif
  if mode !~# '[cC]'
    redraw
  endif
endfunction

function! s:open_window(bufname) abort
  if bufnr(a:bufname) != -1
    return
  endif

  silent noautocmd rightbelow new
  setlocal noswapfile
  silent exec 'noautocmd file ' a:bufname
  setlocal nomodified
  setlocal nomodifiable
endfunction

let s:frame_manager = {'count': 0, 'frames': [], 'bufname': 'udon-araisan://'}

function! s:frame_manager.setup() abort
  call s:open_window(self.bufname)
  if len(self.frames) == 0
    call self.load_frames()
  endif
endfunction

function! s:frame_manager.load_frames() abort
  let dir = expand('<sfile>:p:h') . '/resource'
  for i in range(s:frame_num)
    let frame_path = dir . '/frame' . i . '.txt'
    let frame = join(readfile(frame_path), "\n")
    call add(self.frames, frame)
  endfor
endfunction

function! s:frame_manager.render_next(timer) abort
  let inbound = self.count >= len(self.frames)
  let max = (len(self.frames) - 1) * 2
  let frame_index = inbound ? max - self.count : self.count

  call s:render_frame(self.bufname, self.frames[frame_index])

  let self.count = (self.count + 1) % max
endfunction

function! s:frame_manager.start() abort
  call s:frame_manager.setup()
  let self.timer = timer_start(s:interframe_gap, s:frame_manager.render_next, {'repeat': -1})
endfunction

function! s:frame_manager.stop() abort
  if has_key(self, 'timer')
    call timer_stop(self.timer)
  endif
endfunction

function! udon_araisan#start() abort
  call s:frame_manager.start()
endfunction

function! udon_araisan#stop() abort
  call s:frame_manager.stop()
endfunction
