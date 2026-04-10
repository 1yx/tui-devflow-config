## Context

当前 cmux workspace title 仅在 fish 启动时由 `_cmux_meta_poll` 的首航刷新设置一次（`basename $PWD`）。用户在 workspace 内 `cd` 后 title 不变，sidebar 显示过时信息。

cmux 的 workspace 概念是 worktree/branch 级别，一个 workspace 内有多个 pane/surface，各自有独立 fish 进程。需要一个机制让 title 跟踪"第一个 surface"的项目目录名。

## Goals / Non-Goals

**Goals:**
- workspace title 跟踪最早启动的 surface 所在的 git 项目根目录名
- surface 关闭后自动 fallback 到次早的 surface
- 所有 cmux rename 调用集中在 `_cmux_meta_poll` 统一处理
- 非 git 目录时 title 不更新

**Non-Goals:**
- 不追踪所有 surface 的 PWD（只追踪"第一个"）
- 不改变 description 行为（description 已由 polling 正确管理）
- 不引入外部依赖
- 不在 cd hook 中调用任何 cmux 命令

## Decisions

### 1. Self-report 模式：每个 surface 写自己的 PWD 文件

每个 fish 实例在 cd 时将自己的项目根目录名写入 per-surface 文件。无 file-lock、无 title holder 选举。polling 进程通过注册文件的创建时间排序确定"第一个 surface"，读取其 PWD 文件作为 title。

**替代方案**: file-lock title holder 选举。**选择 self-report 的原因**: surface 关闭时无需 fallback 机制，下一个 surface 自动上位；无锁意味着无 stale lock 问题。

### 2. 注册文件 + PWD 文件双文件模式

每个 surface 维护两个文件：
- `/tmp/cmux-reg-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID` — 注册文件，fish 启动时创建一次，永不修改。mtime 等于 surface 启动时间。
- `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID` — PWD 文件，cd 时原子覆写（tmpfile + mv），内容为 `basename (git rev-parse --show-toplevel)`。

**原因**: PWD 文件需要原子覆写（tmpfile + mv），`mv` 创建新 inode 导致 birth time 变化。单独的注册文件保持原始创建时间不变，`ls -rt` 排序准确反映 surface 启动顺序。

### 3. 使用 `git rev-parse --show-toplevel` 取项目根目录名

title 使用 `basename (git rev-parse --show-toplevel)` 而非 `basename $PWD`。确保在子目录中 cd 时 title 不跳变，始终显示项目根目录名。worktree 场景下 basename 自然包含分支后缀（如 `myapp-feature-auth`）。

非 git 目录：`git rev-parse` 失败时 cd hook 跳过写入，title 保持不变。

### 4. cd hook 仅写文件，不调用 cmux

cd hook 的唯一职责是将项目根目录名原子写入 PWD 文件。所有 `cmux rename` 调用统一由 `_cmux_meta_poll` 轮询进程处理。

**原因**: 避免在 cd 路径上引入外部进程调用延迟；polling 已有 diff-skip 机制，天然适合统一处理所有 cmux IPC。

### 5. Polling 确定"第一个 surface"的方式

```bash
ls -rt /tmp/cmux-reg-$CMUX_WORKSPACE_ID-* | head -1  # 取最老的注册文件
# 从文件名提取 surface UUID → 读对应 PWD 文件 → cmux rename
```

### 6. 清理策略

每个 fish 实例在 `fish_exit` 时删除自己的注册文件和 PWD 文件。无需判断是否是 title holder，直接删即可。

## Risks / Trade-offs

- **[Title 更新延迟]** → cd 后 title 最长 10s 才更新（polling 周期）。这是设计取舍：cd hook 零延迟写文件，但 cmux rename 由 polling 周期驱动。
- **[PWD 文件竞态]** → cd hook 写入和 polling 读取并发执行。缓解：原子写入（tmpfile + rename），读取方一定读到完整值。
- **[/tmp 清理]** → 重启后 `/tmp` 可能被清理，注册文件消失。期望行为——重启后各 surface 重新注册。
- **[UUID 与 cmux CLI ID 不一致]** → `$CMUX_SURFACE_ID` 是 UUID，cmux CLI 用数字 ID。本方案不需要两者关联，因为排序和查找全基于文件名中的 UUID，不依赖 cmux CLI 的 surface 查询。
