## MODIFIED Requirements

### Requirement: Auto-set workspace metadata on fish startup
fish interactive 启动时，若检测到 `$CMUX_WORKSPACE_ID` 环境变量存在，系统 SHALL 自动启动 `_cmux_meta_poll` 后台轮询进程设置 workspace 的 title 和 description。每个 fish 实例 SHALL 创建注册文件并通过 cd hook 将 `basename (git rev-parse --show-toplevel)` 写入 per-surface PWD 文件。polling 进程 SHALL 按注册文件创建时间确定第一个 surface，读取其 PWD 文件并调用 `cmux rename` 更新 title。所有 cmux 调用 SHALL 通过 `>/dev/null 2>&1` 静默输出，不向终端输出任何信息。

#### Scenario: Open project in cmux
- **WHEN** 用户在 cmux 中打开一个 workspace，fish shell 启动
- **THEN** 该 fish 实例 SHALL 创建注册文件和初始 PWD 文件
- **THEN** polling 进程 SHALL 读取第一个 surface 的 PWD 文件设置 title
- **THEN** workspace description SHALL 被设置为 change/spec 列表（不含 folder name 前缀）
- **THEN** 终端 SHALL NOT 显示任何 cmux 输出信息

#### Scenario: Title tracks git root via cd hook and polling
- **WHEN** 第一个 surface 的 fish 实例执行 cd 进入另一个 git 项目目录
- **THEN** cd hook SHALL 将 `basename (git rev-parse --show-toplevel)` 写入 PWD 文件
- **THEN** polling 进程 SHALL 在下一个周期读取并调用 cmux rename 更新 title

#### Scenario: First surface closes, title falls back
- **WHEN** 第一个 surface 关闭并清理注册文件
- **THEN** polling 进程 SHALL 自动切换到次早的 surface 的 PWD 文件
- **THEN** workspace title SHALL 更新为新的第一个 surface 的项目根目录名

#### Scenario: Open project outside cmux
- **WHEN** 用户在普通终端（无 `$CMUX_WORKSPACE_ID`）中启动 fish
- **THEN** 不执行任何 workspace metadata 设置
