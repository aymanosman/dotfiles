function repo_get
    argparse --name=repo_get --ignore-unknown 'private' -- $argv
    or return
    set -l host $argv[1]
    set -l repo $argv[2]
    # Pop the first two arguments (host and repo)
    set argv $argv[3..-1]
    set -l target $HOME/git/$host/$repo
    set -l source

    if set -q _flag_private
        set source git@$host:$repo.git
    else
        set source https://$host/$repo.git
    end

    if ! set -q source
        echo "oops"
        return 1
    end

    if not test -d $target
        git clone $argv -- $source $target
    end

    and cd $target
end
