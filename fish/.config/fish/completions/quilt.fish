function __fish_quilt_add_completions
    set -l files (command ls -1)
    for f in $files
        echo $f
    end
end

complete -c quilt -n '__fish_seen_subcommand_from add' -a '(__fish_quilt_add_completions)'

