if status is-interactive
    # eval (~/homebrew/bin/brew shellenv)

    # ASDF configuration code
    if test -z $ASDF_DATA_DIR
        set _asdf_shims "$HOME/.asdf/shims"
    else
        set _asdf_shims "$ASDF_DATA_DIR/shims"
    end

    # Do not use fish_add_path (added in Fish 3.2) because it
    # potentially changes the order of items in PATH
    if not contains $_asdf_shims $PATH
        set -gx --prepend PATH $_asdf_shims
    end
    set --erase _asdf_shims

    abbr -a gd git diff
    abbr -a gdc git diff --cached
    abbr -a gs git status
    abbr -a lol git log --graph --decorate --pretty=oneline --abbrev-commit
    abbr -a lola git log --graph --decorate --pretty=oneline --abbrev-commit --all
end
