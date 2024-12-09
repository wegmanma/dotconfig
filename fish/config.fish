if status is-interactive
    # Commands to run in interactive sessions can go here
    source /home/marcel/.config/fish/kanagawa-paper.fish
end

if status is-interactive
and not set -q TMUX
    exec tmux
end
