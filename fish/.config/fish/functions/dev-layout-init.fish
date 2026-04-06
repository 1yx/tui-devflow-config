# ~/.config/fish/functions/dev-layout-init.fish
function dev-layout-init
    # Name the initial surface for the upper-left file pane.
    set -l first_pane (cmux list-panes | string match -r -g '.*(pane:[0-9]+).*' | head -1)
    set -l file_surface (cmux list-pane-surfaces --pane $first_pane | string match -r -g '.*(surface:[0-9]+).*' | head -1)
    cmux rename-tab --surface $file_surface file

    # Create the right-side editor pane.
    set -l editor_surface (cmux new-split right | string match -r -g '.*(surface:[0-9]+).*')
    cmux rename-tab --surface $editor_surface editor

    # Split the active left pane downward to create the lower-left agent pane.
    set -l agent_surface (cmux new-split down | string match -r -g '.*(surface:[0-9]+).*')
    cmux rename-tab --surface $agent_surface agent

    # Return focus to the first pane on the left.
    cmux focus-pane --pane $first_pane

    echo "3-pane layout created. Start the tools manually in each pane."
end
