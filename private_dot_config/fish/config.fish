# Disable greeting
set -g fish_greeting ""

if status is-interactive
# Commands to run in interactive sessions can go here
#  fastfetch
end

fish_vi_key_bindings

fastfetch

alias python python3

alias pip pip3

# cht.sh cheat sheet
fish_add_path ~/bin
alias cht "cht.sh"


# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
