# ~/.config/fish/functions/dev-ai-loop.fish
function dev-ai-loop
    set diff (git diff)
    cld -p "Review this change, suggest improvements, and output a patch:\n$diff"
end
