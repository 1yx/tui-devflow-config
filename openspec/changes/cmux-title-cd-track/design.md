## Context

当前 cmux workspace title 仅在 fish 启动时由 `_cmux_meta_poll` 的首航刷新设置一次（`basename $PWD`）。用户在 workspace 内 `cd` 后 title 不变，sidebar 显示过时信息。

cmux 的 workspace 概念是 worktree/branch 级别，一个 workspace 内有多个 pane/surface，各自有独立 fish 进程。需要选择哪个进程负责 title 更新——选择"第一个 surface"作为 title holder。

## Goals / Non-Goals

**Goals:**
- workspace title 实时跟踪第一个 surface 的 PWD
- 多 pane/surface 环境下只有一个 fish 实例负责 title 更新（避免竞争）
- polling 函数与 cd hook 共享 PWD 信息
- 非项目目录（无 `.git`/`openspec`/`specs`）时 title 不更新

**Non-Goals:**
- 不追踪所有 surface 的 PWD（仅第一个 surface）
- 不改变 description 行为（description 已由 polling 正确管理）
- 不引入外部依赖（使用 fish 原生 `flock` 替代方案或文件锁检测）

## Decisions

### 1. File-lock title holder 选举

使用 `/tmp/cmux-title-lock-$CMUX_WORKSPACE_ID` 文件作为互斥锁。第一个 fish 实例通过 `mv` 原子操作创建锁文件并写入自己的 PID，后续实例检测到锁文件已存在则跳过。

**替代方案**: 使用 `flock`（需要 coreutils）。**选择 mv 的原因**: `mv` 是原子操作，无需外部依赖，macOS 原生支持。

实现：`mv` 创建 temp file → rename 到 lock path。若 rename 失败（文件已存在），说明已有 title holder。

### 2. PWD 文件共享路径

使用 `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID` 存储 title holder 当前 PWD。cd hook 写入，polling 函数读取。

**替代方案**: 使用 fish universal variable。**选择文件的原因**: polling 运行在独立 fish 进程（`nohup fish -c`），无法共享 fish 变量。

### 3. cd hook 使用 `--on-variable PWD`

Fish 原生支持 `--on-variable PWD` 事件监听，无需额外工具。

### 4. 项目目录守卫

cd hook 触发时检查新 PWD 下是否存在 `.git`、`openspec`、`specs` 之一。若均不存在，跳过 title 更新，保持当前 title 不变。

### 5. 清理策略

`__cmux_meta_cleanup`（已有 `--on-event fish_exit`）扩展逻辑：若当前进程是 title holder，删除 lock 文件和 PWD 文件。这样下一个 fish 启动时可重新选举。

## Risks / Trade-offs

- **[Stale lock file]** → fish 异常退出（kill -9）时 lock 文件残留，后续 fish 无法成为 title holder。缓解：lock 文件包含 PID，新 fish 可检查该 PID 是否仍存活，若已死则强制接管。
- **[PWD 文件竞态]** → cd hook 写入和 polling 读取并发执行，可能读到不完整路径。缓解：写入同一个 tmpfile 再 rename（原子写入），读取方读到的一定是完整的旧值或新值。
- **[/tmp 清理]** → 重启后 `/tmp` 可能被清理，lock 和 PWD 文件消失。这反而是期望行为——重启后重新选举。
