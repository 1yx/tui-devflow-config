# TUI Dev OS Dotfiles

这个仓库使用 GNU Stow 管理 dotfiles。每个顶级目录都是一个独立 package，通过 Stow 链接到 `$HOME` 后生效。

## 需要的软件

建议安装这些工具：

- `cmux`
- `ghostty`
- `fish`
- `helix`
- `yazi`
- `lazygit`
- `starship`
- `worktrunk`
- `jq`
- `stow`

## Homebrew 安装

以下命令基于本机 CLI 校验过的包名编写：

```bash
brew install --cask cmux ghostty
brew install fish helix yazi lazygit starship worktrunk jq stow shellcheck
```

补充说明：

- `cmux` 是 cask。
- `ghostty` 是 cask。
- `worktrunk` 安装后提供 `wt` 命令。
- 如果你还没把 `fish` 设为登录 shell，只是作为终端默认 shell 使用，也不影响本仓库配置。

## 设置 Fish 为默认 Shell

```bash
echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

## 仓库布局

仓库已经是标准 Stow 布局，例如：

```text
ghostty/.config/ghostty/config
helix/.config/helix/config.toml
yazi/.config/yazi/yazi.toml
fish/.config/fish/config.fish
starship/.config/starship.toml
lazygit/.config/lazygit/config.yml
git/.config/git/config
worktrunk/.config/worktrunk/config.toml
claude/.claude/settings.json
```

## 使用 Stow 同步到 HOME

在仓库根目录执行：

```bash
# 先看将要创建哪些链接
stow -n -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude

# 确认无冲突后正式执行
stow -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
```

如果后续修改了配置，重新同步：

```bash
stow -R -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
```

如果需要撤销某个 package：

```bash
stow -D -v --target="$HOME" fish
```

## 生效方式

同步完成后：

- Ghostty、Fish、Helix、Yazi、LazyGit、Starship、Git、worktrunk 会在下一次启动对应程序时读取新配置。
- `claude` 会读取 `~/.claude/settings.json` 和 `~/.claude/hooks/`。
- 已经打开的终端或应用通常需要重启，才能完全应用新配置。

## Stow 同步后补充

Stow 只创建符号链接，不会保留执行权限。同步完成后需手动添加：

```bash
chmod +x ~/.claude/hooks/*
```

如果 Fish 配置中没有 Starship 初始化，需手动确认 `~/.config/fish/config.fish` 包含：

```fish
starship init fish | source
```
