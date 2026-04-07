# ~/.config/fish/functions/dev-init.fish
function dev-init
    # 1. Initialize spec tool (auto-detect installed tool).
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

    # 2. Initialize the default 3-pane layout in the current workspace.
    dev-layout-init

    echo "Project initialized. Start the tools in each pane, then run dev ai spec <name> for the first change."
end
