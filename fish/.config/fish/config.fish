if status is-interactive
    # Commands to run in interactive sessions can go here
    alias ls="eza --icons=always"
    source ~/.config/fish/kanagawa-paper.fish
end

if status is-interactive
and not set -q TMUX
    exec tmux
end


# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/marcel/.lmstudio/bin
# End of LM Studio CLI section

