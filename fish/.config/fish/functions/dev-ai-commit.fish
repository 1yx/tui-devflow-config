# ~/.config/fish/functions/dev-ai-commit.fish
function dev-ai-commit
    set diff (git diff --staged)
    if test -z "$diff"
        echo "No staged changes. Run 'git add' first."
        return 1
    end

    set msg (cld -p "Write a conventional commit message for these changes. Output only the message, nothing else:\n$diff")

    # Require manual confirmation before committing.
    echo "Generated commit message:"
    echo "  $msg"
    echo ""
    read --prompt "commit? [y/N]: " confirm
    if test "$confirm" = "y" -o "$confirm" = "Y"
        git commit -m "$msg"
    else
        echo "Cancelled."
    end
end
