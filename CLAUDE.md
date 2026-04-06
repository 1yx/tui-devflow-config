# TUI Dev OS — AI + TUI 开发环境设计规范

## 层级映射（cmux 概念 → 语义）

```
Window    → 项目（macOS 窗口，⌘⇧N 新建，每个窗口有独立 sidebar 和 workspace）
Workspace → Git Worktree / Branch（侧边栏 tab，独立 pane 布局）
Pane      → 任务分区（⌘D 右分 / ⌘⇧D 下分，⌥⌘+方向键导航）
Surface   → 工具 tab（⌘T 新建，⌘[ / ⌘] / ⌃1-9 导航，每个 surface 独立终端会话）
```

### 映射示例

| cmux 概念  | 语义              | 示例                                    |
|-----------|-------------------|-----------------------------------------|
| Window    | 项目              | myapp                                   |
| Workspace | worktree / branch | myapp · main, myapp · feat/auth         |
| Pane      | 任务分区          | editor / agent / files                  |
| Surface   | 工具 tab          | agent pane: [claude] [test] [build]     |

### cmux 实际 CLI 命令速查

```bash
# Workspace 管理
cmux list-workspaces [--json]
cmux new-workspace                              # 创建 workspace
cmux select-workspace --workspace <id>           # 切换 workspace
cmux current-workspace                           # 当前 workspace
cmux close-workspace --workspace <id>            # 关闭 workspace

# Surface / Split
cmux new-split right|down                        # 分割 pane
cmux list-surfaces                               # 列出 surface
cmux focus-surface --surface <id>                # 聚焦 surface

# 状态 / 通知
cmux set-status <key> <status> --icon <icon> --color <hex>
cmux clear-status <key>
cmux list-status
cmux set-progress <0.0-1.0> --label <label>
cmux clear-progress
cmux notify --title <title> --body <body> --subtitle <subtitle>
```

---

## 标准布局（3-pane 非对称）

每个 workspace 固定 3-pane 布局：

```
┌──────────────────────────┬──────────────┐
│                          │  claude │
│       Helix              │  (AI Agent)  │
│       (code)             │              │
│                          ├──────────────┤
│                          │ Yazi/LazyGit │
│                          │ (files/git)  │
└──────────────────────────┴──────────────┘
```

### 职责分区

| Pane   | 工具         | 职责               |
|--------|-------------|--------------------|
| 左侧   | Helix       | 唯一代码编辑入口    |
| 右上   | claude | 唯一 AI 接口       |
| 右下   | Yazi/LazyGit | 文件管理 + 版本控制 |

所有操作必须经过这三个 pane 之一。
pane 比例通过 cmux 拖拽调整后保存，不在脚本中写死百分比。

---

## 命令体系（dev CLI + OpenSpec）

### 命令全集

```bash
# 环境管理（dev CLI / fish function）
dev init             # 初始化项目：cmux window + 默认 workspace + 布局
dev wt new <name>    # 创建 worktree + workspace + 布局（worktrunk + cmux 联动）
dev wt go <name>     # 切换到指定 workspace
dev wt finish        # 收尾：push、通知、关 workspace、移除 worktree
dev ai loop          # AI 编码循环：claude 分析 → 生成 → review diff
dev ai commit        # AI 生成 conventional commit message（带人工确认）
dev ai review        # AI review 当前分支代码（bugs/performance/readability）

# 规格驱动开发（OpenSpec）
/opsx:propose "desc" # 规划：生成 proposal → specs → design → tasks 全部产物
/opsx:continue       # 逐个产物渐进式规划
/opsx:ff             # 快速生成所有规划产物（不启动对话）
/opsx:apply          # 执行：按 tasks.md 逐项实现
/opsx:archive        # 归档：合并 specs、归档变更文件夹
```

### OpenSpec 与 dev CLI 的关系

```
dev wt new <branch>          ← 创建隔离环境
    ↓
/opsx:propose "需求描述"      ← 规格驱动规划（proposal → specs → design → tasks）
    ↓
/opsx:apply                  ← 按任务清单实现
    ↓                          （实现过程中 Agent 自动通过 cmux hooks 上报状态）
dev ai loop                  ← 编码循环：claude 分析 → patch → Helix 精修
    ↓
dev ai commit                ← AI 生成 commit message → 人工确认 → 提交
    ↓
dev ai review                ← AI review 当前分支
    ↓
/opsx:archive                ← 归档变更，specs 合并到 specs/ 目录
    ↓
dev wt finish                ← 推送 + 关 workspace + 移除 worktree
```

### OpenSpec 目录结构

```
openspec/
  config.yaml                # 项目配置（schema / context / rules）
  changes/
    <change-name>/
      proposal.md            # 为什么做、改什么
      specs/
        <domain>/spec.md     # 需求 + 场景（Given/When/Then）
      design.md              # 技术方案
      tasks.md               # 实现清单
    archive/
      <date>-<change-name>/  # 已归档变更
specs/                       # 系统行为源 of truth，从 changes 合并而来
```

### OpenSpec 配置：`openspec/config.yaml`

```yaml
schema: spec-driven

context: |
  TUI Dev OS: cmux + Helix + claude + Yazi + LazyGit + Fish + Starship + Stow
  层级: Window(项目) → Workspace(worktree/branch) → Pane(任务分区) → Surface(工具tab)
  布局: 3-pane 非对称（左 Helix 65%, 右上 claude, 右下 Yazi/LazyGit）
  Worktree 管理: worktrunk (wt switch/remove/merge)
  状态上报: cmux set-progress / set-status / notify
  编辑器: Helix, 版本控制: LazyGit, 文件管理: Yazi, Shell: Fish

rules:
  proposal:
    - 评估对现有 cmux workspace 布局的影响
    - 说明涉及哪些 pane 和工具
  specs:
    - 使用 Given/When/Then 格式描述场景
    - 区分人类操作和 Agent 自动操作
  design:
    - 列出需要修改的 fish function / config 文件路径
    - 如涉及 cmux CLI 调用，引用实际 API 命令
  tasks:
    - 每个任务不超过 2 小时
    - 每个任务标注在哪个 pane 执行（editor / agent / files）
```

### 项目初始化：`dev init`

```fish
# ~/.config/fish/functions/dev-init.fish
function dev-init
    # 1. 初始化 OpenSpec（生成 openspec/ 目录、.claude/skills、slash commands）
    openspec init --tools claude

    # 2. 创建 cmux workspace
    cmux new-workspace

    # 3. 初始化 3-pane 布局
    dev-layout-init

    echo "项目已初始化。各 pane 手动启动工具后，运行 /opsx:propose 开始第一个变更。"
end
```

### 入口函数：`dev wt new <branch>`
# ~/.config/fish/functions/dev-wt-new.fish
function dev-wt-new
    set branch $argv[1]
    if test -z "$branch"
        echo "Usage: dev wt new <branch-name>"
        return 1
    end

    # 1. worktrunk 创建 worktree 并切换（路径: ../<project>-<branch>）
    wt switch -c $branch

    # 2. 在 cmux 创建新 workspace
    cmux new-workspace

    # 3. 初始化 3-pane 布局（仅创建 pane 结构，手动启动工具）
    dev-layout-init

    echo "布局已就绪。启动工具后，在 agent pane 运行 /opsx:propose 开始规划。"
end
```

### 布局初始化：`dev-layout-init`

```fish
# ~/.config/fish/functions/dev-layout-init.fish
function dev-layout-init
    # 当前 workspace 已有 1 个 pane（左侧 editor 区域）
    # 创建右侧分割 → 右上 pane（agent）
    cmux new-split right

    # 在右侧 pane 创建下方分割 → 右下 pane（files/git）
    # 先聚焦到右侧 pane，再向下分割
    cmux new-split down

    # 切回左侧 pane（第一个 pane）
    # 使用 ⌥⌘← 快捷键逻辑或 cmux focus-surface 聚焦
    echo "3-pane 布局已创建，请手动在各 pane 启动工具"
end
```

> **注意**：cmux 没有 send-keys / rename-tab / rename-workspace 等 CLI 命令。
> 布局函数只负责创建 pane 结构，工具启动需手动完成。
> pane 比例通过拖拽调整后由 cmux 保存。

### 收尾函数：`dev wt finish`

```fish
# ~/.config/fish/functions/dev-wt-finish.fish
function dev-wt-finish
    set branch (git branch --show-current)

    # 1. 确认无未提交内容
    if test -n (git status --porcelain)
        cmux notify --title "dev wt finish" \
            --body "还有未提交更改，请先 commit"
        return 1
    end

    # 2. push + 提示开 PR
    git push -u origin $branch
    cmux notify --title "推送完成" \
        --body "$branch 已推送，记得开 PR"

    # 3. 获取当前 workspace ID 并关闭
    set ws (cmux current-workspace)
    cmux close-workspace --workspace $ws

    # 4. worktrunk 移除 worktree
    wt remove
end
```

---

## AI 自动化

### AI 编码循环：`dev ai loop`

```fish
# ~/.config/fish/functions/dev-ai-loop.fish
function dev-ai-loop
    set diff (git diff)
    claude -p "Review this change, suggest improvements, and output a patch:\n$diff"
end
```

### AI Commit（带人工确认）：`dev ai commit`

```fish
# ~/.config/fish/functions/dev-ai-commit.fish
function dev-ai-commit
    set diff (git diff --staged)
    if test -z "$diff"
        echo "No staged changes. Run 'git add' first."
        return 1
    end

    set msg (claude -p "Write a conventional commit message for these changes. Output only the message, nothing else:\n$diff")

    # 人工确认后再提交
    echo "生成的 commit message:"
    echo "  $msg"
    echo ""
    read --prompt "commit? [y/N]: " confirm
    if test "$confirm" = "y" -o "$confirm" = "Y"
        git commit -m "$msg"
    else
        echo "已取消"
    end
end
```

### AI Review：`dev ai review`

```fish
# ~/.config/fish/functions/dev-ai-review.fish
function dev-ai-review
    claude -p "Review current branch against main for: bugs, performance issues, readability problems. Read the code and provide specific feedback."
end
```

### SOP 全流程闭环

```
dev wt new <branch>                  [agent pane] 创建隔离环境
    ↓
/opsx:propose "需求"                 [agent pane] proposal → specs → design → tasks
    ↓                            （你 review 各产物，在 Helix 中确认）
/opsx:apply                         [agent pane] 按 tasks.md 逐项实现
    ↓                            （Agent 自动 cmux set-progress 上报进度）
dev ai loop                         [agent → editor] 编码循环：patch → Helix 精修
    ↓
dev ai commit                       [agent pane] AI message → 人工确认 → 提交
    ↓
dev ai review                       [agent pane] AI review 当前分支
    ↓
/opsx:archive                       [agent pane] 归档变更，specs 合并
    ↓
dev wt finish                       [agent pane] push → 关 workspace → 移除 worktree
```

---

## CLAUDE.md hooks — Agent 自动上报状态

在项目 `CLAUDE.md` 中写入以下指令，claude 会在执行过程中自动更新 cmux 状态。
所有命令名已对照 cmux 实际 API 验证：

```markdown
## cmux hooks

当你开始一个子任务时执行：
  cmux set-progress 0.3 --label "分析代码中..."
  cmux set-status "task" "分析代码" --icon "hammer"

当你完成代码修改时执行：
  cmux set-progress 0.7 --label "修改完成，等待 review"
  cmux set-status "task" "修改完成" --icon "pencil"

当你完成后执行：
  cmux set-progress 1.0 --label "完成"
  cmux set-status "task" "done" --icon "checkmark.circle" --color "#00CC66"
  cmux notify --title "claude" --body "任务完成，请 review"
```

> **注意**：cmux 没有 `new-surface` CLI 命令。Agent 需要并行子任务时，
> 通过 ⌘T（手动）在 pane 内新建 surface，或直接在当前 surface 中顺序执行。

---

## 状态感知机制

### 双层感知：cmux 宏观 + Starship 微观

```
                    ┌─────────────────────────────────┐
                    │       cmux sidebar（宏观）        │
                    │  · workspace 列表 / 通知环       │
                    │  · Agent 进度条 0.0 → 1.0       │
                    │  · 状态 pill（当前子任务 + 图标） │
                    │  · 系统通知                       │
                    └─────────────────────────────────┘
                              ↕ 互补
                    ┌─────────────────────────────────┐
                    │     Starship prompt（微观）       │
                    │  · 当前 git branch               │
                    │  · dirty / staged / ahead/behind │
                    │  · 语言 runtime 版本             │
                    │  · 目录视觉标识                   │
                    └─────────────────────────────────┘
```

不需要切 pane 就能通过 prompt 感知当前上下文，
不需要切 workspace 就能通过侧边栏感知全局进度。

### cmux 侧边栏 + 通知

| 机制 | 说明 |
|------|------|
| 侧边栏 workspace tab | 显示 workspace 列表，当前 workspace 高亮 |
| 通知环 | 任务完成时 workspace tab 亮蓝色通知环 |
| 进度条 | Agent 通过 `cmux set-progress` 上报 0.0 → 1.0 |
| 状态 pill | Agent 通过 `cmux set-status` 显示当前子任务和图标 |
| 系统通知 | `cmux notify` 触发 macOS Notification Center |

### cmux 原生快捷键

```
⌘⇧N         新建窗口（Window）
⌘D          右分割 pane
⌘⇧D         下分割 pane
⌥⌘ + 方向键   pane 间导航
⌘T          新建 surface（pane 内 tab）
⌘[ / ⌘]     surface 间切换
⌃1-⌃9       按 tab 编号切换 surface
⌘⇧P         命令面板（搜索所有操作）
```

---

## 工具间联动配置

### 配置文件：项目目录 → HOME 映射

本仓库采用标准 GNU Stow 布局。每个顶级目录都是一个独立 package，通过 `stow --target="$HOME" <package>` 链接到 HOME。

#### 项目目录结构

```
tui/                                    # 本项目（配置源）
├── ghostty/
│   └── .config/ghostty/config
├── helix/
│   └── .config/helix/config.toml
├── yazi/
│   └── .config/yazi/
├── fish/
│   └── .config/fish/
├── starship/
│   └── .config/starship.toml
├── lazygit/
│   └── .config/lazygit/config.yml
├── git/
│   └── .config/git/config
├── worktrunk/
│   └── .config/worktrunk/config.toml
├── claude/
│   └── .claude/
└── CLAUDE.md
```

#### Stow 同步命令

在项目根目录执行：

```bash
# 先 dry-run 看将要创建的链接
stow -n -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude

# 确认无冲突后执行
stow -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude

# 配置更新后可重跑 restow
stow -R -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
```

#### XDG 兼容说明

LazyGit 和 Git 在 macOS 上默认不走 `~/.config/`，需要 Fish 环境变量强制：

```fish
# 已写入 fish/.config/fish/config.fish
set -gx XDG_CONFIG_HOME ~/.config           # LazyGit 读取此变量
set -gx GIT_CONFIG_GLOBAL ~/.config/git/config  # Git 读取此变量
```

claude 硬编码 `~/.claude/`，无法改为 XDG 路径，是唯一例外。

### 用户习惯：Emacs 风格光标控制

Ctrl+A/E/B/F/N/P 全链路无冲突。Helix insert mode 已在 `helix/.config/helix/config.toml` 中配置。
Fish / claude / cmux / Yazi / LazyGit 原生支持或不使用这些组合键。

### 工具间联动要点

以下联动已写入对应配置文件，此处仅记录设计意图：

| 联动 | 配置文件 | 效果 |
|------|---------|------|
| Yazi → Helix | `yazi/.config/yazi/keymap.toml` | 按 `e` 在 Helix 中打开文件 |
| Helix → LazyGit | `helix/.config/helix/config.toml` | `Ctrl+G` 呼出 LazyGit |
| LazyGit → Helix | `lazygit/.config/lazygit/config.yml` | 按 `e` 用 Helix 打开 diff 文件 |
| Fish 环境变量 | `fish/.config/fish/config.fish` | EDITOR/GIT_EDITOR/VISUAL 统一指向 hx |
| Starship prompt | `starship/.config/starship.toml` | git branch + dirty 标记 + 语言环境 |
| worktrunk 路径 | `worktrunk/.config/worktrunk/config.toml` | `../<project>-<branch>` 平铺模板 |
| Stow 部署 | dotfiles package | 统一管理 HOME 下的符号链接 |

### 配置自检命令

在项目根目录执行以下命令，可逐个检查配置是否通过。

```bash
# Ghostty（内建 show-config；当前环境未安装 ghostty 时会失败）
ghostty +show-config --default --docs >/dev/null

# Stow（确认命令可用）
stow --version

# Helix（显式加载项目配置）
hx --config "$(pwd)/helix/.config/helix/config.toml" --health

# Yazi（Yazi 没有独立 validate 子命令，使用自定义配置目录做 smoke test）
YAZI_CONFIG_HOME="$(pwd)/yazi/.config/yazi" yazi --debug

# Fish（语法检查）
fish -n fish/.config/fish/config.fish
fish -n fish/.config/fish/functions/*.fish

# LazyGit（LazyGit 没有独立 lint 子命令，显式加载项目配置做 smoke test）
lazygit --use-config-file "$(pwd)/lazygit/.config/lazygit/config.yml" --debug

# Starship（显式加载项目配置）
STARSHIP_CONFIG="$(pwd)/starship/.config/starship.toml" starship explain

# worktrunk（通过 XDG_CONFIG_HOME 指向项目配置）
XDG_CONFIG_HOME="$(pwd)/worktrunk/.config" wt config show >/dev/null

# Git（直接解析项目内 git config）
git config --file "$(pwd)/git/.config/git/config" --list >/dev/null

# Claude settings / hook
jq empty claude/.claude/settings.json
bash -n claude/.claude/hooks/cmux-notify.sh
```

说明：
- `Ghostty`、`Yazi`、`LazyGit` 当前没有稳定的独立 lint 命令，上面给的是最可靠的加载/启动级 smoke test。
- `yazi --debug` 和 `lazygit --debug` 会进入交互界面；重点是确认启动时没有配置解析错误。
- `wt config show` 会读取 `XDG_CONFIG_HOME/worktrunk/config.toml`，因此这里把 `XDG_CONFIG_HOME` 指到了 `$(pwd)/worktrunk/.config`。

### 快捷键查看方法

在项目根目录执行以下命令，可查看各工具的帮助入口、默认配置或当前项目自定义键位来源。

```bash
# cmux（无 CLI 可直接打印全部快捷键；先看命令面，再回到本文档的“cmux 原生快捷键”）
cmux --help

# Ghostty（当前环境未安装 ghostty 时会失败；查看完整生效配置，再结合其中的 keybind 配置项）
ghostty +show-config

# Helix（CLI 只提供帮助和教程入口；完整默认键位以 tutor / 内置帮助为准）
hx --help
hx --tutor

# Yazi（CLI 不提供“打印全部快捷键”；项目自定义键位看仓库 keymap）
yazi --help
sed -n '1,200p' yazi/.config/yazi/keymap.toml

# Fish（shell 本身没有统一“快捷键总表”命令；交互里用 bind 查看当前绑定）
fish --help
fish -C bind -C exit

# LazyGit（查看帮助和默认配置；键位以应用内 help 面板为准）
lazygit --help
lazygit --config

# Starship（无快捷键体系；只打印 prompt 配置）
starship --help
STARSHIP_CONFIG="$(pwd)/starship/.config/starship.toml" starship print-config

# worktrunk（无快捷键体系；查看 CLI 子命令）
wt --help

# Git（无统一快捷键体系；查看可用子命令）
git help -a

# Stow（无快捷键体系；查看 CLI 选项）
stow --help

# Claude（无 CLI 可打印快捷键；项目内只维护 settings / hooks）
jq . claude/.claude/settings.json
find claude/.claude/hooks -maxdepth 1 -type f | sort
```

说明：
- `cmux`、`Ghostty`、`Helix`、`Yazi`、`LazyGit` 的完整默认快捷键，主要还是看应用内 help / tutorial / command palette；CLI 通常只能给帮助入口，不能一次性导出完整键位表。
- `Fish`、`Starship`、`worktrunk`、`Git`、`Stow`、`Claude` 这几类不是典型 TUI 键位驱动工具，所以这里列的是“查看交互命令或配置入口”的命令，不是完整键位表。
- 项目自定义键位目前主要集中在 `helix/.config/helix/config.toml` 和 `yazi/.config/yazi/keymap.toml`。

---

## 并行开发

利用 worktrunk + cmux workspace + OpenSpec 实现多线程开发：

```bash
# 同时开 3 个 worktree，每个自动创建 cmux workspace + 3-pane 布局
dev wt new feature/login
dev wt new feature/payment
dev wt new fix/api-crash

# 在每个 workspace 的 agent pane 中独立运行 OpenSpec 流程
# workspace 1: /opsx:propose "实现登录系统"
# workspace 2: /opsx:propose "实现支付模块"
# workspace 3: /opsx:propose "修复 API 崩溃"

# 每个 agent 独立执行 /opsx:apply，通过 cmux hooks 上报各自进度
# 你只看侧边栏通知环，完成时切过去 review
```
