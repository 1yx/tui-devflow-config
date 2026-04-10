## ADDED Requirements

### Requirement: Title holder election via file-lock
每个 cmux workspace 中，第一个启动的 fish 实例 SHALL 通过原子文件操作获取 `/tmp/cmux-title-lock-$CMUX_WORKSPACE_ID` 锁文件成为 title holder。后续 fish 实例 SHALL 检测到锁文件已存在且 holder PID 存活时，跳过 title holder 选举。锁文件 SHALL 包含 holder 的 PID。

#### Scenario: First fish instance in workspace
- **WHEN** workspace 中第一个 fish 实例启动，且锁文件不存在
- **THEN** 该实例 SHALL 成功创建锁文件并写入自身 PID
- **THEN** 该实例 SHALL 成为 title holder

#### Scenario: Subsequent fish instances in workspace
- **WHEN** workspace 中后续 fish 实例启动，锁文件已存在且 holder PID 存活
- **THEN** 该实例 SHALL NOT 成为 title holder
- **THEN** 该实例 SHALL NOT 写入 PWD 文件或调用 cmux rename

#### Scenario: Stale lock takeover
- **WHEN** 锁文件存在但 holder PID 已不存在（进程已死）
- **THEN** 新 fish 实例 SHALL 删除旧锁文件，重新获取锁并成为 title holder

### Requirement: cd hook updates title on PWD change
title holder 的 fish 实例 SHALL 注册 `--on-variable PWD` 事件监听。当 PWD 变化时，SHALL 检查新目录是否为项目目录（存在 `.git`、`openspec`、`specs` 之一）。若是项目目录，SHALL 将新 PWD 写入 `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID` 文件并调用 `cmux workspace-action --action rename` 更新 title 为 `basename $PWD`。

#### Scenario: cd into a project directory
- **WHEN** title holder 执行 `cd` 进入包含 `.git` 的目录
- **THEN** PWD 文件 SHALL 被更新为新路径
- **THEN** workspace title SHALL 被设置为 `basename $PWD`

#### Scenario: cd into a non-project directory
- **WHEN** title holder 执行 `cd` 进入不包含 `.git`、`openspec`、`specs` 的目录
- **THEN** PWD 文件 SHALL NOT 被更新
- **THEN** workspace title SHALL 保持不变

#### Scenario: Non-holder cd
- **WHEN** 非 title holder 的 fish 实例执行 `cd`
- **THEN** 不执行任何 title 更新操作
- **THEN** 不写入 PWD 文件

### Requirement: PWD file atomic write
cd hook 写入 PWD 文件时 SHALL 使用原子操作（先写临时文件再 rename），确保 polling 进程不会读到不完整路径。

#### Scenario: Concurrent write and read
- **WHEN** cd hook 正在写入 PWD 文件，同时 polling 函数正在读取
- **THEN** polling 函数 SHALL 读到完整的旧路径或完整的新路径
- **THEN** SHALL NOT 读到截断或不完整的路径

### Requirement: Title holder cleanup on exit
title holder 的 fish 实例退出时 SHALL 删除锁文件和 PWD 文件，允许后续 fish 实例重新选举。

#### Scenario: Title holder exits normally
- **WHEN** title holder fish 进程退出（fish_exit 事件）
- **THEN** 锁文件 `/tmp/cmux-title-lock-$CMUX_WORKSPACE_ID` SHALL 被删除
- **THEN** PWD 文件 `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID` SHALL 被删除

#### Scenario: Non-holder exits
- **WHEN** 非 title holder 的 fish 进程退出
- **THEN** 锁文件和 PWD 文件 SHALL NOT 被修改
