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

## Agent Setup Instructions

When an AI Agent is invoked to set up this environment, it MUST execute the following steps strictly:

### 1. Pre-flight Checks
- **OS Requirement**: Verify the OS is macOS (`uname -s` == `Darwin`). If not, halt and inform the user.
- **Homebrew**: Verify `brew` is installed (`command -v brew`). If missing, halt and ask the user to install it.
- **Current Shell**: Check the current shell (`echo $SHELL`). If it is not `fish`, inspect and record the user's current shell configuration (e.g., `.zshrc`, `.bashrc` aliases, exports, and paths). The agent must then adapt and recreate these configurations in `fish` syntax during the setup.

### 2. Dependencies Installation
Install the required toolchain using Homebrew:
```bash
# Core TUI tools
brew install stow helix yazi lazygit fish starship
```

**Install OpenSpec**:
OpenSpec requires Node.js. The agent MUST check for a Node.js environment and guide the user to install it if missing. Then, install OpenSpec globally:
```bash
npm install -g @fission-ai/openspec@latest
```
*Note: If the user prefers a different package manager (e.g., pnpm, yarn), the agent should adapt accordingly.*

**Install specialized tools**:
```bash
# Install cmux
brew tap manaflow-ai/cmux
brew install --cask cmux

# Install worktrunk
brew install worktrunk
wt config shell install
```

### 3. Worktree Directory Structure
The agent MUST actively present the following options to the user and ask for their preference. This project relies on `worktrunk` to manage isolation and parallel workflows:

- **Option A: Sibling/Flat (Recommended)**
  Worktrees are created alongside the main repository (e.g., `../tui.feature-auth`).
  *Best for*: Complete isolation and parallel AI Agent execution.
  *Setup Command*: `wt config set path_template "../{{.RepoName}}.{{.BranchName}}"`

- **Option B: Nested/Hidden**
  Worktrees are kept within a sub-directory of the main repository (e.g., `.worktrees/feature-auth`).
  *Best for*: Keeping the project self-contained in one parent folder.
  *Setup Command*: `wt config set path_template ".worktrees/{{.BranchName}}"`

The agent MUST configure the user's chosen `path_template` using `wt config set`.

### 4. Stow Deployment
- **Pre-check & Backup**: Before symlinking, check if any target directories (e.g., `~/.config/helix`, `~/.config/fish`) exist as real directories/files. If so, back them up by appending a `.bak` extension to the original path. If a `.bak` file/directory already exists at that location, the agent MUST halt and alert the user to prevent overwriting previous backups.
- **Config Merging**: After backing up, the agent MUST attempt to merge the user's existing configurations for **ALL tools** (e.g., Helix, Yazi, LazyGit, Git, Fish) into the corresponding files **within the cloned repository's directory**. This ensures the repo's defaults and user's preferences are combined before deployment.
- **Conflict Resolution**: If a conflict arises during merging (e.g., conflicting keybinds or aliases), the agent MUST NOT make a silent choice. Instead, ask the user an open-ended question to determine the desired behavior for that specific tool's configuration.
- **Deployment**: Execute the Stow commands from the root of this repository (dry-run first to verify):
  ```bash
  stow -n -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
  stow -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
  ```

### 5. Post-setup & Initialization
- **Shell Registration**: Ensure Fish is registered in `/etc/shells`. Prompt the user to set Fish as the default shell: `chsh -s $(which fish)`.
- **Keymap Regeneration**: The agent MUST regenerate `KEYMAP.md` based on the final merged configurations. During this process, the agent must perform a **collision check** across all tools (e.g., ensuring a Helix shortcut doesn't conflict with a global or cmux shortcut). If conflicts are found, the agent must notify the user and guide them through a resolution.
- **Keymap Reference**: Explicitly remind the user to read the updated `KEYMAP.md`. This file serves as the single-page checksheet for the entire TUI environment (cmux, Helix, Yazi, LazyGit, etc.) and contains all custom overrides.
- **Smoke Tests**: Run the validation commands (e.g., `hx --health`, `stow --version`, `cmux --help`) to ensure a successful setup.
- **Git Identity Check**: Check the current global Git configuration (`git config --global user.name` and `git config --global user.email`). If they are still the default placeholder values (e.g., `YOUR_NAME` or `your@email.com`), the agent MUST guide the user to set their actual Git identity.
- **Dev Workflow Summary**: Explain the custom `dev` Fish functions provided (e.g., `dev init`, `dev wt new`, `dev ai loop`, `dev ai commit`). These functions drive the OpenSpec workflow. The agent MUST advise the user that these are templates and should be modified in `fish/.config/fish/functions/` to match their specific team or project requirements.

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
