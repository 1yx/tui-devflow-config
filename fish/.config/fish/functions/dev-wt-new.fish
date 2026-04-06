# ~/.config/fish/functions/dev-wt-new.fish
function dev-wt-new
    set branch $argv[1]
    if test -z "$branch"
        echo "Usage: dev wt new <branch-name>"
        return 1
    end

    # 1. Create and switch to the worktree via worktrunk.
    wt switch -c $branch

    # 2. Initialize the 3-pane layout in the current workspace. Tool processes start manually.
    dev-layout-init

    echo "Layout is ready. Start the tools, then run /opsx:propose in the agent pane."
end
