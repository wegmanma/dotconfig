if status is-interactive
    # Commands to run in interactive sessions can go here
    alias ls="eza --icons=always"
    alias ll="eza -llag icons=always"
    alias snvim='sudo -E nvim'
    source ~/.config/fish/kanagawa-paper.fish
end

if status is-interactive
and not set -q TMUX
    exec tmux
end

