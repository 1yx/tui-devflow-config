# ~/.config/fish/functions/dev-ai-spec.fish
function dev-ai-spec --argument name
    if test -z "$name"
        echo "Usage: dev ai spec <change-name>"
        return 1
    end

    # 1. Create worktree + workspace + layout
    dev-wt-new $name
    if test $status -ne 0
        return 1
    end

    # 2. Run spec tool to propose the change (auto-detect installed tool)
    if command -q openspec
        openspec propose $name
    else if command -q specify
        specify specify $name
    else
        echo "No spec tool found. Install OpenSpec or SpecKit first."
        return 1
    end
end
