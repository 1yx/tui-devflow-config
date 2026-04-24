# ~/.config/fish/functions/_cmux_meta_refresh.fish

function _cmux_meta_refresh --description 'Refresh cmux workspace title and description on prompt'
    if not set -q CMUX_WORKSPACE_ID
        return
    end

    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$git_root"
        return
    end

    set -l ws_id (string replace -a '-' '_' $CMUX_WORKSPACE_ID)
    set -l bn_var "_cmux_meta_bn_$ws_id"
    set -l desc_var "_cmux_meta_desc_$ws_id"
    set -l basename (basename "$git_root")

    # --- Title ---
    set -l cached_bn
    if set -q $bn_var
        set cached_bn $$bn_var
    end
    if test "$basename" != "$cached_bn"
        set -g $bn_var "$basename"

        # Read current title from text output: "* workspace:6  Title  [selected]"
        set -l ws_line (cmux list-workspaces 2>/dev/null | string match -r '^\*')
        set -l current_title ""
        if test -n "$ws_line"
            set current_title (string replace -r '^\*\s+workspace:\S+\s+' '' -- $ws_line | string replace -r '\s+\[selected\]$' '')
        end

        if test -z "$current_title"; or string match -q '📁*' "$current_title"
            cmux workspace-action --action rename --title "📁 $basename" >/dev/null 2>&1
        end
    end

    # --- Description ---
    set -l desc ""
    if test -d "$git_root/openspec/changes"
        for c in (ls "$git_root/openspec/changes" 2>/dev/null | string match -v 'archive')
            if test -z "$desc"
                set desc "• $c"
            else
                set desc "$desc
• $c"
            end
        end
    end

    set -l cached_desc
    if set -q $desc_var
        set cached_desc $$desc_var
    end

    if test "$desc" != "$cached_desc"
        set -g $desc_var "$desc"
        if test -n "$desc"
            cmux workspace-action --action set-description --description "$desc" >/dev/null 2>&1
        else
            cmux workspace-action --action clear-description >/dev/null 2>&1
        end
    end
end
