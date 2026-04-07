# ~/.config/fish/functions/dev-implement.fish
function dev-implement
    # Step 4: Apply changes (auto-detect spec tool)
    if command -q openspec
        echo "OpenSpec: run /opsx:apply in Claude to implement tasks."
    else if command -q specify
        specify implement
    else
        echo "No spec tool found."
        return 1
    end

    # review-code: AI reviews code changes
    set -l diff (git diff)
    if test -n "$diff"
        echo "Reviewing code changes..."
        cld -p "Review this code change for: bugs, performance issues, readability problems, and adherence to the spec. Provide specific feedback:\n$diff"
    end

    # Commit code changes
    set -l staged (git diff --staged)
    if test -z "$staged"
        git add -A
        set staged (git diff --staged)
    end
    if test -n "$staged"
        set -l msg (cld -p "Write a conventional commit message for these code changes. Output only the message:\n$staged")
        echo "Commit message: $msg"
        read --prompt "commit? [y/N]: " confirm
        if test "$confirm" = "y" -o "$confirm" = "Y"
            git commit -m "$msg"
        else
            echo "Skipped commit."
        end
    else
        echo "No changes to commit."
    end

    echo ""
    echo "Step 4/5 done. Run 'dev archive' to finalize."
end
