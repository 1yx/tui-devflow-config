## 1. Create Title CD Hook Function

- [ ] 1.1 Create `fish/.config/fish/functions/_cmux_title_cd_hook.fish` — contains `_cmux_title_cd_hook` (cd handler with `--on-variable PWD`) and `_cmux_acquire_title_lock` (file-lock election)
- [ ] 1.2 Implement file-lock election: write PID to temp file, `mv` to `/tmp/cmux-title-lock-$CMUX_WORKSPACE_ID`; if mv fails, check existing PID with `kill -0`, dead → unlink + retry
- [ ] 1.3 Implement PWD atomic write: write to `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID.tmp` then `mv` to `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID`
- [ ] 1.4 Implement project directory guard in cd hook: `test -d .git; or test -d openspec; or test -d specs` — skip if none exists
- [ ] 1.5 Implement cmux rename call in cd hook: `cmux workspace-action --action rename --title (basename $PWD) >/dev/null 2>&1`
- [ ] 1.6 Add `__cmux_title_cleanup` to `--on-event fish_exit`: if current PID matches lock file content, delete lock + PWD file

## 2. Update Polling Function

- [ ] 2.1 In `_cmux_meta_poll.fish` polling loop: read `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID` at each cycle; if content differs from last title PWD, call `cmux workspace-action --action rename --title (basename $content) >/dev/null 2>&1`
- [ ] 2.2 Skip PWD file read if file does not exist (no title holder yet)
- [ ] 2.3 Remove the initial `cmux workspace-action --action rename` from first-run refresh (title is now managed by cd hook + polling sync)

## 3. Update config.fish

- [ ] 3.1 In the cmux auto-metadata block: source/call `_cmux_acquire_title_lock` after launching `_cmux_meta_poll &`, so the first fish claims title holder
- [ ] 3.2 Add `>/dev/null 2>&1` to all new cmux calls in config.fish

## 4. Update Specs

- [ ] 4.1 Update `openspec/specs/workspace-auto-meta/spec.md` to reflect new title tracking behavior (cd hook + polling sync)

## 5. Verify

- [ ] 5.1 Run `fish -n fish/.config/fish/functions/_cmux_title_cd_hook.fish` to verify syntax
- [ ] 5.2 Run `fish -n fish/.config/fish/functions/_cmux_meta_poll.fish` to verify syntax
- [ ] 5.3 Run `fish -n fish/.config/fish/config.fish` to verify syntax
- [ ] 5.4 Restow fish package: `stow -R -v --target="$HOME" fish`
- [ ] 5.5 Test: open cmux, cd to another project directory, verify sidebar title updates within 10s
