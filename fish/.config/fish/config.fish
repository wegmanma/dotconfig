if status is-interactive
    # Commands to run in interactive sessions can go here
    alias ls="eza --icons=always"
    source /home/marcel/.config/fish/kanagawa-paper.fish
end

if status is-interactive
and not set -q TMUX
    exec tmux
end

