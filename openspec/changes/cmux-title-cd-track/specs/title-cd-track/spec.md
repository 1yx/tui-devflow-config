## ADDED Requirements

### Requirement: Per-surface registration and PWD files
每个 cmux workspace 中的 fish 实例 SHALL 在启动时创建注册文件 `/tmp/cmux-reg-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID`（空文件）。每个实例 SHALL 注册 `--on-variable PWD` cd hook，在 PWD 变化时将 `basename (git rev-parse --show-toplevel)` 原子写入 `/tmp/cmux-pwd-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID`。

#### Scenario: Fish instance starts in cmux workspace
- **WHEN** fish 实例在 cmux workspace 中启动
- **THEN** SHALL 创建注册文件 `/tmp/cmux-reg-$CMUX_WORKSPACE_ID-$CMUX_SURFACE_ID`
- **THEN** SHALL 创建初始 PWD 文件（写入当前 git 项目根目录名）

#### Scenario: Fish instance starts outside cmux
- **WHEN** fish 实例在普通终端启动（无 `$CMUX_WORKSPACE_ID`）
- **THEN** SHALL NOT 创建任何注册或 PWD 文件

### Requirement: cd hook writes project root name only
cd hook SHALL 仅执行文件写入操作，SHALL NOT 调用任何 cmux 命令。当 PWD 变化时，SHALL 执行 `git rev-parse --show-toplevel`，若成功则将 `basename` 结果原子写入 PWD 文件。若 `git rev-parse` 失败（非 git 目录），SHALL 跳过写入，PWD 文件保持不变。

#### Scenario: cd into a git project directory
- **WHEN** fish 实例执行 `cd` 进入 git 仓库内的目录
- **THEN** PWD 文件 SHALL 被更新为 `basename (git rev-parse --show-toplevel)` 的结果
- **THEN** cd hook SHALL NOT 调用 cmux rename

#### Scenario: cd into a non-git directory
- **WHEN** fish 实例执行 `cd` 进入非 git 目录（`git rev-parse` 失败）
- **THEN** PWD 文件 SHALL NOT 被更新
- **THEN** workspace title SHALL 保持不变

#### Scenario: cd within same git project
- **WHEN** fish 实例在同一 git 仓库内的子目录间 cd
- **THEN** `basename (git rev-parse --show-toplevel)` 结果不变
- **THEN** PWD 文件值不变

### Requirement: PWD file atomic write
cd hook 写入 PWD 文件时 SHALL 使用原子操作（先写临时文件再 rename），确保 polling 进程不会读到不完整内容。

#### Scenario: Concurrent write and read
- **WHEN** cd hook 正在写入 PWD 文件，同时 polling 函数正在读取
- **THEN** polling 函数 SHALL 读到完整的旧值或完整的新值
- **THEN** SHALL NOT 读到截断或不完整的值

### Requirement: Polling determines first surface by registration file age
`_cmux_meta_poll` 轮询进程 SHALL 在每个周期通过 `ls -rt /tmp/cmux-reg-$CMUX_WORKSPACE_ID-*` 确定最早注册的 surface。从注册文件名提取 surface UUID，读取对应的 PWD 文件。若 PWD 值与上次不同，SHALL 调用 `cmux workspace-action --action rename --title <value>`。所有 cmux rename 调用 SHALL 仅由 polling 进程执行。

#### Scenario: First surface's PWD changed
- **WHEN** polling 读取到第一个 surface 的 PWD 文件内容与上次不同
- **THEN** SHALL 调用 `cmux rename --title <new value>`
- **THEN** SHALL 更新本地缓存值

#### Scenario: First surface's PWD unchanged
- **WHEN** polling 读取到第一个 surface 的 PWD 文件内容与上次相同
- **THEN** SHALL NOT 调用 cmux rename（diff skip）

#### Scenario: No registration files exist
- **WHEN** polling 发现无注册文件（所有 surface 已关闭）
- **THEN** SHALL NOT 调用 cmux rename
- **THEN** SHALL 保持当前 title 不变

#### Scenario: First surface exits, second becomes first
- **WHEN** 第一个 surface 关闭并清理其注册文件
- **THEN** polling SHALL 在下一个周期发现新的第一个注册文件
- **THEN** SHALL 读取新第一个 surface 的 PWD 文件并更新 title

### Requirement: Per-surface cleanup on fish exit
每个 fish 实例退出时 SHALL 删除自己的注册文件和 PWD 文件，无需判断是否是"第一个 surface"。

#### Scenario: Any fish instance exits
- **WHEN** fish 进程退出（fish_exit 事件）
- **THEN** 该实例的注册文件 SHALL 被删除
- **THEN** 该实例的 PWD 文件 SHALL 被删除

#### Scenario: Fish instance outside cmux exits
- **WHEN** 非 cmux 环境的 fish 进程退出
- **THEN** 无文件需要清理（未创建过文件）
