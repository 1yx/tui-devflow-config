## Why

Workspace title 仅在 fish 启动时设置一次（`basename $PWD`），后续用户 `cd` 到其他目录时 title 不会更新。当用户在 workspace 中导航到不同项目或子目录时，sidebar 仍显示初始目录名，造成认知不一致。需要让 title 实时跟踪第一个 surface 的实际 PWD，保持 sidebar 与当前工作上下文一致。

## What Changes

- 新增 file-lock 机制：每个 workspace 的第一个 fish 实例通过 `/tmp/cmux-title-lock-$CMUX_WORKSPACE_ID` 文件锁声称 "title holder"，后续 fish 实例不参与 title 更新
- 新增 `--on-variable PWD` cd hook：仅 title holder 执行，当 PWD 变化时检查项目目录标志（`.git` / `openspec` / `specs`），通过则调用 `cmux rename` 更新 workspace title
- 修改 `_cmux_meta_poll` 轮询函数：读取 `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID` 文件跟踪 title holder 的 PWD，在每次轮询周期同步 `cmux rename`
- 新增 fish_exit 清理：释放 file-lock，删除 PWD 文件

## Capabilities

### New Capabilities

- `title-cd-track`: workspace title 通过 cd hook 实时跟踪第一个 surface 的 PWD，包含 file-lock title holder 选举、PWD 文件共享、项目目录守卫、轮询同步

### Modified Capabilities

- `workspace-auto-meta`: title 设置从 "仅启动时一次" 变为 "启动时 + cd 跟踪"，polling 函数新增 PWD 文件读取和 `cmux rename` 调用

## Impact

- `fish/.config/fish/functions/_cmux_meta_poll.fish` — 轮询函数读取 PWD 文件并同步 rename
- `fish/.config/fish/functions/_cmux_title_cd_hook.fish` — 新增，cd hook + file-lock + PWD 写入
- `fish/.config/fish/config.fish` — 注册 cd hook（source hook 函数）
- `openspec/specs/workspace-auto-meta/spec.md` — 更新 title 行为要求
- `/tmp/cmux-title-lock-$CMUX_WORKSPACE_ID` — 新增临时文件（file-lock）
- `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID` — 新增临时文件（PWD 共享）
