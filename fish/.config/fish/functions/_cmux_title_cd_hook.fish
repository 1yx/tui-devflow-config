# ~/.config/fish/functions/_cmux_title_cd_hook.fish

# Write git root path to per-surface PWD file (atomic write via tmpfile + mv)
function __cmux_write_pwd_file --description 'Write git root path to per-surface PWD file'
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$git_root"
        return
    end
    set -l pwd_file "/tmp/cmux-pwd-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID"
    set -l tmp_file "$pwd_file.tmp.$fish_pid"
    echo -n "$git_root" > "$tmp_file"
    mv "$tmp_file" "$pwd_file"
end

# CD hook: on PWD change, update per-surface PWD file
function _cmux_title_cd_hook --on-variable PWD --description 'Update per-surface PWD file on directory change'
    __cmux_write_pwd_file
end

# Per-surface cleanup on fish exit
function __cmux_title_cleanup --on-event fish_exit
    rm -f "/tmp/cmux-reg-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID" "/tmp/cmux-pwd-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID" 2>/dev/null
end
