# TUI Dev OS Keymap

这份文档汇总本仓库里已经明确配置，或项目文档里已经明确约定的快捷键与命令入口。

## 全局约定

### Emacs 风格光标控制

这套环境统一采用以下光标控制习惯：

| 按键 | 作用 |
|------|------|
| `Ctrl+A` | 到行首 |
| `Ctrl+E` | 到行尾 |
| `Ctrl+B` | 左移一个字符 |
| `Ctrl+F` | 右移一个字符 |
| `Ctrl+N` | 下一行 |
| `Ctrl+P` | 上一行 |

说明：

- Helix insert mode 已显式配置这些键。
- Fish / claude / cmux / Yazi / LazyGit 没有在本仓库里配置与这组键冲突的映射。

## cmux

项目文档里已经明确约定使用以下原生快捷键：

| 按键 | 作用 |
|------|------|
| `Cmd+Shift+N` | 新建窗口（Window） |
| `Cmd+D` | 向右分割 pane |
| `Cmd+Shift+D` | 向下分割 pane |
| `Option+Cmd+方向键` | 在 pane 间导航 |
| `Cmd+T` | 在当前 pane 内新建 surface |
| `Cmd+[` | 切到前一个 surface |
| `Cmd+]` | 切到后一个 surface |
| `Ctrl+1` 到 `Ctrl+9` | 按编号切换 surface |
| `Cmd+Shift+P` | 打开命令面板 |

## Ghostty

本仓库当前没有自定义 Ghostty 键位映射，使用 Ghostty 默认快捷键。

仓库里与 Ghostty 相关的实际配置：

- 默认 shell 为 `fish`
- 主题为 `Atom One Dark`

## Fish

### 命令入口

| 命令 | 作用 |
|------|------|
| `yy` | 启动 Yazi，并在退出后把 shell 切到 Yazi 最后所在目录 |

说明：

- 本仓库没有为 Fish 单独定义额外键盘快捷键。
- 主要键位习惯沿用 shell 默认行为和全局 Emacs 风格控制。

## Helix

### Normal Mode

| 按键 | 作用 |
|------|------|
| `Ctrl+G` | 运行 `lazygit` |
| `Ctrl+S` | 保存当前文件 |

### Insert Mode

| 按键 | 作用 |
|------|------|
| `Ctrl+A` | 到行首 |
| `Ctrl+E` | 到行尾 |
| `Ctrl+B` | 左移一个字符 |
| `Ctrl+F` | 右移一个字符 |
| `Ctrl+N` | 下一行 |
| `Ctrl+P` | 上一行 |

## Yazi

### 自定义键位

| 按键 | 作用 |
|------|------|
| `e` | 用 Helix 打开当前选中文件 |
| `E` | 打开 Helix，但不传当前文件 |

说明：

- 本仓库只显式定义了这两组 Yazi 自定义键位。
- 其他移动、选择、复制、重命名等操作沿用 Yazi 默认键位。

## LazyGit

本仓库没有重写 LazyGit 键位，使用 LazyGit 默认键位。

项目里与 LazyGit 相关的约定：

| 按键 | 作用 |
|------|------|
| `e` | 用 Helix 打开文件 / diff 文件 |

说明：

- 这个行为依赖 LazyGit 默认的 `e` 编辑动作，再由仓库配置把编辑器指定为 Helix。
- 额外支持按行打开与等待返回，但这些是编辑器命令配置，不是新的键位。

## Claude

本仓库没有为 `claude` 定义额外键位映射，使用 Claude Code 默认交互方式。

项目里与 Claude 相关的约定：

- hooks 会在任务结束或子任务结束时通过 `cmux notify` 发通知。

## Starship

Starship 是 prompt 主题配置，不提供仓库级快捷键。

## Git

本仓库没有定义 Git 快捷键或别名。

## worktrunk

本仓库没有定义 `wt` 的键盘快捷键。

常用命令入口：

| 命令 | 作用 |
|------|------|
| `wt switch -c <branch>` | 创建并切换到新 worktree |
| `wt switch <branch>` | 切换到已有 worktree |
| `wt remove` | 删除当前 worktree |

## dev CLI

这不是键位，但属于这套环境的常用入口命令：

| 命令 | 作用 |
|------|------|
| `dev init` | 初始化项目 workspace 与布局 |
| `dev wt new <name>` | 创建 worktree + workspace + 布局 |
| `dev wt finish` | 推送、关闭 workspace、移除 worktree |
| `dev ai loop` | AI 编码循环 |
| `dev ai commit` | 生成 commit message 并确认提交 |
| `dev ai review` | Review 当前分支 |
