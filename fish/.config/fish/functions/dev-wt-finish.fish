# ~/.config/fish/functions/dev-wt-finish.fish
function dev-wt-finish
    set branch (git branch --show-current)

    # 1. Ensure there are no uncommitted changes.
    if test -n (git status --porcelain)
        cmux notify --title "dev wt finish" \
            --body "There are uncommitted changes. Commit them first."
        return 1
    end

    # 2. Push the branch and remind the user to open a PR.
    git push -u origin $branch
    cmux notify --title "Push complete" \
        --body "$branch was pushed. Open a PR next."

    # 3. Close the current workspace.
    set ws (cmux current-workspace)
    cmux close-workspace --workspace $ws

    # 4. Remove the worktree via worktrunk.
    wt remove
end
