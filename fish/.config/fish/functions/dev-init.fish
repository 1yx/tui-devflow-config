# ~/.config/fish/functions/dev-init.fish
function dev-init
    # 1. Initialize OpenSpec.
    openspec init --tools claude

    # 2. Initialize the default 3-pane layout in the current workspace.
    dev-layout-init

    echo "Project initialized. Start the tools in each pane, then run /opsx:propose for the first change."
end
