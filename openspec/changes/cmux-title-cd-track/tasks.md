## 1. Create CD Hook Function

- [x] 1.1 Create `fish/.config/fish/functions/_cmux_title_cd_hook.fish` — contains `_cmux_title_cd_hook` (cd handler with `--on-variable PWD`) and `__cmux_title_cleanup` (per-surface file cleanup on fish_exit)
- [x] 1.2 Implement registration file creation on function load: `touch /tmp/cmux-reg-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID`
- [x] 1.3 Implement initial PWD file write on function load: compute `basename (git rev-parse --show-toplevel 2>/dev/null)`, atomic write to `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID`; skip if git rev-parse fails
- [x] 1.4 Implement cd hook: on PWD change, compute `basename (git rev-parse --show-toplevel 2>/dev/null)`, atomic write to PWD file; skip if git rev-parse fails. cd hook SHALL NOT call any cmux commands
- [x] 1.5 Implement `__cmux_title_cleanup` on `--on-event fish_exit`: delete `/tmp/cmux-reg-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID` and `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID` (unconditional, no holder check needed)

## 2. Update Polling Function

- [x] 2.1 In `_cmux_meta_poll.fish`: add `_last_title` variable for title diff skip
- [x] 2.2 In polling loop: `ls -rt /tmp/cmux-reg-$CMUX_WORKSPACE_ID-* 2>/dev/null | head -1` to find first surface registration file
- [x] 2.3 Extract surface UUID from registration file path, construct corresponding PWD file path, read its content
- [x] 2.4 Diff skip: if PWD content equals `_last_title`, skip; otherwise call `cmux workspace-action --action rename --title "$content" >/dev/null 2>&1` and update `_last_title`
- [x] 2.5 Handle no registration files: if `ls` returns nothing, skip title update (keep current title)
- [x] 2.6 Remove the initial `cmux workspace-action --action rename --title (basename $PWD)` from first-run refresh — instead, run the same first-surface detection logic on first run with fallback to `basename $PWD` if no PWD files exist yet

## 3. Update config.fish

- [x] 3.1 In the cmux auto-metadata block: call `_cmux_title_cd_hook` (triggers registration + initial PWD write) before launching `_cmux_meta_poll &`
- [x] 3.2 Ensure `>/dev/null 2>&1` on the polling launch (already present, verify)

## 4. Verify

- [x] 4.1 Run `fish -n fish/.config/fish/functions/_cmux_title_cd_hook.fish` to verify syntax
- [x] 4.2 Run `fish -n fish/.config/fish/functions/_cmux_meta_poll.fish` to verify syntax
- [x] 4.3 Run `fish -n fish/.config/fish/config.fish` to verify syntax
- [x] 4.4 Restow fish package: `stow -R -v --target="$HOME" fish`
- [x] 4.5 Test: open cmux with 2 surfaces, verify sidebar title matches first surface's project; close first surface, verify title falls back to second surface within 10s; cd in second surface to another project, verify title updates within 10s
