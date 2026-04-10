# ~/.config/fish/functions/_cmux_meta_poll.fish

function _cmux_meta_poll --description 'Background polling: refresh cmux workspace description and title from openspec/speckit changes'
    set -l last_desc ""
    set -l last_title ""

    # Helper: read first surface's git root path from PWD file
    # Returns empty string if no registration files found
    function __poll_first_path --description 'Get git root path from first surface PWD file'
        set -l reg_files (ls -rt /tmp/cmux-reg-$CMUX_WORKSPACE_ID-* 2>/dev/null)
        if test (count $reg_files) -eq 0
            return
        end
        set -l first_reg $reg_files[1]
        set -l pwd_file (string replace 'cmux-reg-' 'cmux-pwd-' "$first_reg")
        if test -f "$pwd_file"
            cat "$pwd_file"
        end
    end

    # First-run refresh (首航刷新): set title + description
    set -l project_path (__poll_first_path)
    if test -z "$project_path"
        set project_path $PWD
    end
    set -l title (basename "$project_path")
    cmux workspace-action --action rename --title "$title" >/dev/null 2>&1
    set last_title "$title"

    # Build description inline (avoid fish command substitution splitting newlines)
    set -l desc ""
    if test -d "$project_path/openspec"
        for c in (ls -rt "$project_path/openspec/changes" 2>/dev/null | string match -v 'archive')
            if test -z "$desc"
                set desc "• $c"
            else
                set desc "$desc
• $c"
            end
        end
    else if test -d "$project_path/specs"
        for d in (ls "$project_path/specs/" 2>/dev/null | string replace -r '^\d+-' '')
            if test -n "$d"
                if test -z "$desc"
                    set desc "• $d"
                else
                    set desc "$desc
• $d"
                end
            end
        end
    end

    if test -n "$desc"
        cmux workspace-action --action set-description --description "$desc" >/dev/null 2>&1
    else
        cmux workspace-action --action clear-description >/dev/null 2>&1
    end
    set last_desc "$desc"

    # Polling loop
    while true
        sleep 2

        # Read first surface's project path
        set project_path (__poll_first_path)
        if test -z "$project_path"
            continue
        end

        # Update title if project changed
        set title (basename "$project_path")
        if test "$title" != "$last_title"
            cmux workspace-action --action rename --title "$title" >/dev/null 2>&1
            set last_title "$title"
        end

        # Build description inline (avoid fish command substitution splitting newlines)
        set desc ""
        if test -d "$project_path/openspec"
            for c in (ls -rt "$project_path/openspec/changes" 2>/dev/null | string match -v 'archive')
                if test -z "$desc"
                    set desc "• $c"
                else
                    set desc "$desc
• $c"
                end
            end
        else if test -d "$project_path/specs"
            for d in (ls "$project_path/specs/" 2>/dev/null | string replace -r '^\d+-' '')
                if test -n "$d"
                    if test -z "$desc"
                        set desc "• $d"
                    else
                        set desc "$desc
• $d"
                    end
                end
            end
        end

        # Diff skip: only update if content changed
        if test "$desc" = "$last_desc"
            continue
        end

        # Update or clear description
        if test -n "$desc"
            cmux workspace-action --action set-description --description "$desc" >/dev/null 2>&1
        else
            cmux workspace-action --action clear-description >/dev/null 2>&1
        end

        set last_desc "$desc"
    end
end

function __cmux_meta_cleanup --on-event fish_exit
    if set -q _cmux_meta_pid
        kill $_cmux_meta_pid 2>/dev/null
        rm -f "/tmp/cmux-poll-$CMUX_WORKSPACE_ID" 2>/dev/null
    end
end
