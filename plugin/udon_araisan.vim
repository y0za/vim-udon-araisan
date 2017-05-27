if exists('g:loaded_udon_araisan')
  finish
endif
let g:loaded_udon_araisan = 1

command! -nargs=0 UdonAraisanStart call udon_araisan#start()
command! -nargs=0 UdonAraisanStop call udon_araisan#stop()
