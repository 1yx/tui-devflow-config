# ~/.config/fish/functions/dev-specify.fish
function dev-specify --argument name
    if test -z "$name"
        echo "Usage: dev specify <change-name>"
        return 1
    end

    # Create worktree + workspace + layout
    wt switch -c $name
    dev-layout-init

    # Run spec tool explore/proposal phase (auto-detect)
    if command -q openspec
        echo "OpenSpec: run /opsx:explore then /opsx:propose \"$name\" in Claude."
    else if command -q specify
        specify specify $name
        specify clarify
    else
        echo "No spec tool found."
        return 1
    end

    echo ""
    echo "Step 2/5 done. Run 'dev plan' to generate technical plan."
end
