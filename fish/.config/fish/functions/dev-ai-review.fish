# ~/.config/fish/functions/dev-ai-review.fish
function dev-ai-review
    cld -p "Review current branch against main for: bugs, performance issues, readability problems. Read the code and provide specific feedback."
end
