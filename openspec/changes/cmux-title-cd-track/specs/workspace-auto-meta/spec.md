## MODIFIED Requirements

### Requirement: Auto-set workspace metadata on fish startup
fish interactive 启动时，若检测到 `$CMUX_WORKSPACE_ID` 环境变量存在，系统 SHALL 自动调用 `cmux workspace-action` 设置当前 workspace 的 title 和 description。title 设置 SHALL 在启动时执行一次，且通过 cd hook 持续跟踪第一个 surface 的 PWD 变化。所有 cmux 调用 SHALL 通过 `>/dev/null 2>&1` 静默输出，不向终端输出任何信息。

#### Scenario: Open project in cmux
- **WHEN** 用户在 cmux 中打开一个 workspace，fish shell 启动
- **THEN** workspace title SHALL 被设置为当前目录名（`basename $PWD`）
- **THEN** workspace description SHALL 被设置为 change/spec 列表（不含 folder name 前缀）
- **THEN** 终端 SHALL NOT 显示任何 cmux 输出信息

#### Scenario: Title tracks PWD via cd hook
- **WHEN** 第一个 surface 的 title holder 执行 cd 进入另一个项目目录
- **THEN** workspace title SHALL 更新为新的 `basename $PWD`
- **THEN** polling 函数 SHALL 通过 PWD 文件同步该变化

#### Scenario: Open project outside cmux
- **WHEN** 用户在普通终端（无 `$CMUX_WORKSPACE_ID`）中启动 fish
- **THEN** 不执行任何 workspace metadata 设置
