if status is-interactive
 # Add to PATH
    set -Ux fish_user_paths $HOME/bin $fish_user_paths
    # Commands to run in interactive sessions can go here
    alias ls="eza --icons=always"
    alias ll="eza -llag --icons=always"
    alias snvim='sudo -E nvim'
    alias cg='cd $(git root)'
    source ~/.config/fish/kanagawa-paper.fish
end

#if status is-interactive
#and not set -q TMUX
#    exec tmux
#end


# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/marcel/.lmstudio/bin
# End of LM Studio CLI section

