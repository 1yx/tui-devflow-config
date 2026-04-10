# ~/.config/fish/functions/_cmux_meta_poll.fish

function _cmux_meta_poll --description 'Background polling: refresh cmux workspace description from openspec/speckit changes'
    set -l last_desc ""

    # First-run refresh (首航刷新): set title + description
    cmux workspace-action --action rename --title (basename $PWD) >/dev/null 2>&1

    set -l desc ""
    if test -d openspec
        for c in (ls -rt openspec/changes 2>/dev/null | string match -v 'archive')
            if test -z "$desc"
                set desc "• $c"
            else
                set desc "$desc
• $c"
            end
        end
    else if test -d specs
        for d in (ls specs/ 2>/dev/null | string replace -r '^\d+-' '')
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
        cmux workspace-action --action set-description --description "" >/dev/null 2>&1
    end
    set last_desc "$desc"

    # Polling loop
    while true
        sleep 10

        # Auto-exit if no longer in a project directory
        if not test -d .git; and not test -d openspec
            return
        end

        # Build description
        set desc ""
        if test -d openspec
            for c in (ls -rt openspec/changes 2>/dev/null | string match -v 'archive')
                if test -z "$desc"
                    set desc "• $c"
                else
                    set desc "$desc
• $c"
                end
            end
        else if test -d specs
            for d in (ls specs/ 2>/dev/null | string replace -r '^\d+-' '')
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
            cmux workspace-action --action set-description --description "" >/dev/null 2>&1
        end

        set last_desc "$desc"
    end
end

function __cmux_meta_cleanup --on-event fish_exit
    if set -q _cmux_meta_pid
        kill $_cmux_meta_pid 2>/dev/null
    end
end
