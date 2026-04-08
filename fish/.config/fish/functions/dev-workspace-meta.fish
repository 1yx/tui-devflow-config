# ~/.config/fish/functions/dev-workspace-meta.fish
function dev-workspace-meta --description 'Set cmux workspace metadata (title, description, status pill)'
    argparse 't/title=' 'd/description=' 's/stage=' 'i/icon=' -- $argv
    or return 1

    # Set title (branch name)
    if set -q _flag_title
        cmux workspace-action --action rename --title "$_flag_title"
    end

    # Set description (openspec change name)
    if set -q _flag_description
        cmux workspace-action --action set-description --description "$_flag_description"
    end

    # Set status pill (workflow stage)
    if set -q _flag_stage
        set -l icon $_flag_icon
        if test -z "$icon"
            switch $_flag_stage
                case init
                    set icon house
                case specify
                    set icon magnifyingglass
                case plan
                    set icon list.clipboard
                case implement
                    set icon hammer
                case archive
                    set icon archivebox
            end
        end
        cmux set-status stage "$_flag_stage" --icon "$icon"
    end
end
