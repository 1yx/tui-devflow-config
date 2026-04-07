# ~/.config/fish/functions/dev-init.fish
function dev-init
    # Step 1: Initialize spec tool (auto-detect)
    if command -q openspec
        openspec init --tools claude
    else if command -q specify
        specify init (basename $PWD)
    else
        echo "No spec tool found. Install OpenSpec or SpecKit first."
        echo "  OpenSpec:  npm install -g @fission-ai/openspec@latest"
        echo "  SpecKit:   uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
        return 1
    end

    # Initialize 3-pane layout
    dev-layout-init

    echo ""
    echo "Step 1/5 done. Run 'dev specify <name>' to start a change."
end
