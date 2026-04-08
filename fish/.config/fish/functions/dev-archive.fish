# ~/.config/fish/functions/dev-archive.fish
function dev-archive
    # Set workflow stage
    dev-workspace-meta --stage archive

    set -l branch (git branch --show-current)

    # Ensure no uncommitted changes
    if test -n (git status --porcelain)
        echo "Uncommitted changes found. Commit them first."
        return 1
    end

    # Archive (OpenSpec only)
    if command -q openspec
        echo "OpenSpec: run /opsx:archive in Claude to finalize specs."
    end

    # Push (no push until this step)
    git push -u origin $branch
    cmux notify --title "Push complete" \
        --body "$branch was pushed. Open a PR next."

    # Close workspace
    set -l ws (cmux current-workspace)
    cmux close-workspace --workspace $ws

    # Remove worktree
    wt remove

    echo ""
    echo "Step 5/5 done. Change archived, branch pushed, worktree removed."
end
