# ~/.config/fish/functions/dev-plan.fish
function dev-plan
    # Set workflow stage
    dev-workspace-meta --stage plan

    # Step 3: Plan + tasks (auto-detect spec tool)
    if command -q openspec
        # OpenSpec: propose already generated design + tasks
        echo "OpenSpec: artifacts generated during propose."
    else if command -q specify
        specify plan
        specify tasks
    else
        echo "No spec tool found."
        return 1
    end

    # review-doc: AI reviews spec/design documents
    echo "Reviewing spec documents..."
    set -l spec_dir
    if test -d openspec/changes
        set spec_dir openspec/changes
    else if test -d .specify
        set spec_dir .specify
    end

    if test -n "$spec_dir"
        cld -p "Review the spec and design documents in $spec_dir for completeness, consistency, and feasibility. Check: Are all requirements covered? Are there contradictions? Is the design practical? Output specific issues and suggestions."
    end

    # Commit review-doc changes
    set -l diff (git diff --staged)
    if test -z "$diff"
        git add -A
        set diff (git diff --staged)
    end
    if test -n "$diff"
        set -l msg (cld -p "Write a conventional commit message for these spec/design changes. Output only the message:\n$diff")
        echo "Commit message: $msg"
        read --prompt "commit? [y/N]: " confirm
        if test "$confirm" = "y" -o "$confirm" = "Y"
            git commit -m "$msg"
        else
            echo "Skipped commit."
        end
    end

    echo ""
    echo "Step 3/5 done. Run 'dev implement' to start coding."
end
