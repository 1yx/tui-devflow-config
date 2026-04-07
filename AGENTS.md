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

**Install spec-driven development tool (choose one)**:
The agent **MUST** ask the user which spec tool they prefer:

- **OpenSpec** (requires Node.js):
  ```bash
  npm install -g @fission-ai/openspec@latest
  ```
- **SpecKit** (requires Python/uv):
  ```bash
  uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
  ```

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
- **Pre-check & Backup**: Before symlinking, check if any of the following paths exist as real directories/files (not symlinks):
  ```
  ~/.config/ghostty
  ~/Library/Application Support/com.mitchellh.ghostty
  ~/.config/fish
  ~/.config/helix
  ~/.config/yazi
  ~/.config/lazygit
  ~/Library/Application Support/lazygit
  ~/.config/starship.toml
  ~/.gitconfig
  ~/.config/git/config
  ~/.config/git/ignore
  ~/.config/worktrunk
  ~/.claude
  ~/Library/Application Support/Claude/claude_desktop_config.json
  ```
  For each existing path, apply the following logic:
  1. **`.bak` exists and is identical to the original** (`diff -rq <path> <path>.bak` returns 0): The user already ran `backup_configs.sh`. Safe to delete the original and proceed.
  2. **`.bak` exists but differs from the original**: Halt and alert the user — a previous backup exists but has diverged. Re-running backup would overwrite it. Ask the user how to proceed (e.g., keep existing `.bak`, back up to a new name like `.bak2`, or skip).
  3. **No `.bak` exists**: Run `bash backup_configs.sh` from the repo root to create backups, then delete the original config paths that are real directories (not symlinks) so that Stow can create symlinks in their place.
- **Config Merging**: After backing up, the agent MUST attempt to merge the user's existing configurations for **ALL tools** (e.g., Helix, Yazi, LazyGit, Git, Fish) into the corresponding files **within the cloned repository's directory**. This ensures the repo's defaults and user's preferences are combined before deployment.
- **Conflict Resolution**: If a conflict arises during merging (e.g., conflicting keybinds or aliases), the agent MUST NOT make a silent choice. Instead, ask the user an open-ended question to determine the desired behavior for that specific tool's configuration.
- **Deployment**: Execute the Stow commands from the root of this repository (dry-run first to verify):
  ```bash
  stow -n -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
  stow -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk claude
  ```

### 5. Post-setup & Initialization

#### Shell Registration
Ensure Fish is registered in `/etc/shells`. Prompt the user to set Fish as the default shell: `chsh -s $(which fish)`.

#### Keymap Regeneration
The agent MUST regenerate `KEYMAP.md` based on the final merged configurations. During this process, the agent must perform a **collision check** across all tools (e.g., ensuring a Helix shortcut doesn't conflict with a global or cmux shortcut). If conflicts are found, the agent must notify the user and guide them through a resolution.

#### Keymap Reference
Explicitly remind the user to read the updated `KEYMAP.md`. This file serves as the single-page checksheet for the entire TUI environment (cmux, Helix, Yazi, LazyGit, etc.) and contains all custom overrides.

#### Smoke Tests
Run the validation commands (e.g., `hx --health`, `stow --version`, `cmux --help`) to ensure a successful setup.

#### Git Identity Setup
The repo tracks a placeholder template at `git/.config/git/config` (`YOUR_NAME` / `your@email.com`). If these values are still placeholders, the agent **MUST** guide the user through:
1. Edit `git/.config/git/config` with real name and email
2. `stow -R -v --target="$HOME" git`
3. `git update-index --assume-unchanged git/.config/git/config` (prevents personal info from being committed)

#### Claude Code Configuration
The agent **MUST** ask the user to choose one of three provider switching methods:

**Option A: `cld` (built-in fish function)**
The repo includes `fish/.config/fish/functions/cld.fish` — a single fish function with provider argument.
```
cld glm "prompt"    # Use GLM provider
cld kimi            # Use Kimi provider
cld proxy           # Use custom proxy
```
Edit `cld.fish` with real API keys and base URLs, then protect it:
```bash
git update-index --assume-unchanged fish/.config/fish/functions/cld.fish
```

**Option B: claude-code-router (`ccr`)**
A proxy router that routes Claude Code requests to different providers by task type. Install and configure:
```bash
npm install -g @musistudio/claude-code-router
ccr start           # Starts proxy on 127.0.0.1:3456
ccr code            # Launch claude through router
```
Config at `~/.claude-code-router/config.json`. Supports per-task-type model routing, `/model provider,model` switching inside claude, and `ccr ui` web dashboard.

**Option C: cc-switch**
A desktop app (Tauri 2) for one-click provider switching across Claude Code, Codex, Gemini CLI, etc. Install:
```bash
brew tap farion1231/ccswitch && brew install --cask cc-switch
```
Since cc-switch exposes provider endpoints but has no CLI, use the built-in `cld.fish` to set `ANTHROPIC_BASE_URL` to cc-switch's local proxy. Edit the `ccswitch` case in `cld.fish` to point to cc-switch's endpoint.

#### Spec-Driven Development
The agent **MUST** ask the user to choose one of two spec-driven development tools:

**Option A: OpenSpec**
An AI-native spec-driven development framework. Install:
```bash
npm install -g @fission-ai/openspec@latest
```
Initialize in the project: `openspec init --tools claude`. Workflow: `/opsx:propose` → specs → design → tasks → `/opsx:apply` → implement → `/opsx:archive` to finalize and merge specs into `specs/` directory.

 Changes are stored in `openspec/changes/<name>/`.

**Option B: SpecKit (GitHub)**
Spec-driven development with a constitution-first workflow. Install:
```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```
Initialize in the project: `specify init <project_name>`. Workflow: `/speckit.specify` → `/speckit.clarify` → /speckit.plan` → `/speckit.tasks` → /speckit.implement`. SpecKit starts from a constitution (project principles) and moves sequentially through specify → clarify → plan → tasks → implement.

 Spec artifacts are stored in `.spe-kit/` directory.

 Configuration at `.spe-kit/constitution.md`.

#### Dev Workflow Summary
The repo provides a unified 5-step `dev` workflow that maps to both OpenSpec and SpecKit:

| Step | Command | OpenSpec | SpecKit |
|------|---------|----------|---------|
| 1. init | `dev init` | `openspec init` | `specify init` |
| 2. specify | `dev specify <name>` | `/opsx:explore` → `/opsx:propose` | `specify specify` → `clarify` |
| 3. plan | `dev plan` | (already in propose) → review-doc | `specify plan` → `tasks` → review-doc |
| 4. implement | `dev implement` | `/opsx:apply` → review-code → commit | `specify implement` → review-code → commit |
| 5. archive | `dev archive` | `/opsx:archive` → push → close → remove | push → close → remove |

Flow:
```
dev init              ← Step 1: spec tool init + 3-pane layout
dev specify <name>    ← Step 2: wt new + layout + explore + proposal
dev plan              ← Step 3: plan + tasks + review-doc + commit
dev implement         ← Step 4: apply + review-code + commit
dev archive           ← Step 5: archive + push + close workspace + remove worktree
```

Key behaviors:
- **`dev specify`** creates a worktree (`wt switch -c`) and initializes the 3-pane layout.
- **`dev plan`** generates technical plan, then runs `review-doc` (AI reviews spec documents) and commits.
- **`dev implement`** applies changes, then runs `review-code` (AI reviews code diff) and commits.
- **`dev archive`** pushes to remote, closes the cmux workspace, and removes the worktree (`wt remove`).
- Commits happen after `review-doc` (step 3) and `review-code` (step 4), but push only happens in `archive` (step 5).

The `dev` commands use `cld` for AI prompts. The agent **MUST** advise the user that these are templates and should be modified in `fish/.config/fish/functions/` to match their specific team or project requirements.

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
