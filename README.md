# tui-devflow-config

Agent-first dotfiles repo for a TUI dev workflow on macOS.

## Purpose

This repo manages config for:

- `cmux`
- `ghostty`
- `fish`
- `helix`
- `yazi`
- `lazygit`
- `starship`
- `git`
- `worktrunk`
- `claude`

It uses GNU Stow. Each top-level directory is one stow package.

## Important

Prefer using an agent to inspect and modify this repo.

Reason:

- the repo encodes workflow assumptions across multiple tools
- one change often affects fish functions, cmux behavior, and docs together
- agents should read `AGENTS.md` first, then edit the minimal set of files

## Repo Shape

```text
ghostty/.config/ghostty/config
fish/.config/fish/config.fish
fish/.config/fish/functions/
helix/.config/helix/config.toml
yazi/.config/yazi/
lazygit/.config/lazygit/config.yml
starship/.config/starship.toml
git/.config/git/config
worktrunk/.config/worktrunk/config.toml
claude/.claude/
AGENTS.md
```

## Deploy

From repo root:

```bash
stow -n -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
stow -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
```

Restow after edits:

```bash
stow -R -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
```

## Git Setup

Before using this repo, set your Git identity in [git/.config/git/config](/Users/dontaire/Repositories/tmp/tui/git/.config/git/config):

```gitconfig
[user]
    name = YOUR_NAME
    email = your@email.com
```

Then restow the `git` package:

```bash
stow -R -v --target="$HOME" git
git config --global user.name
git config --global user.email
```

## Requirements

Expected tools:

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

## Agent Notes

If you are an agent working in this repo:

1. Read `AGENTS.md` first.
2. Preserve the stow package layout.
3. Prefer small, coherent edits.
4. When changing workflow behavior, update the related fish functions and docs together.
