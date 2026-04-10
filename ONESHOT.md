# One-shot Agent Setup (Opinionated Defaults)

This document provides a streamlined, zero-interaction setup path for AI Agents. It follows the core logic of `AGENTS.md` but skips all user prompts by applying the project's **Recommended Defaults**.

## Opinionated Defaults Table

| Choice | Default Selection | Reason |
|--------|-------------------|--------|
| **Spec Tool** | **SpecKit** (via `uv`) | Modern, fast installation, minimal Python dependencies. |
| **Worktree Path** | **Sibling/Flat** (`../{{ main_worktree }}.{{ branch }}`) | Best isolation for parallel AI Agent execution. |
| **Claude Provider** | **cld.fish** (built-in) | Zero external dependencies, native Fish integration. |
| **Permissions** | **Project Defaults** | Auto-approve the recommended `claude/.claude/settings.json`. |

## Execution Logic for Agents

When an Agent is instructed to perform a "One-shot Setup", it MUST execute these steps strictly without asking for confirmation:

### 1. Pre-flight & Core Install
- Verify macOS (`Darwin`) and `brew`.
- Install core toolchain: `brew install stow helix yazi lazygit fish starship uv`.
- Install `cmux`: `brew tap manaflow-ai/cmux && brew install --cask cmux`.
- Install `worktrunk`: `brew install worktrunk && wt config shell install`.
- **Fish Default**: Set Fish as default shell and ensure `brew shellenv` is in `fish/.config/fish/config.fish`.

### 2. Dependency Setup (Automatic)
- **SpecKit**: Execute `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git`.
- **Worktree Config**: Force set `worktree-path = "../{{ main_worktree }}.{{ branch }}"` in `worktrunk/.config/worktrunk/config.toml`.

### 3. Deployment (Forceful)
- **Backup**: Run `bash backup_configs.sh`.
- **Clean**: Delete any existing real directories/files (not symlinks) that conflict with Stow (see list in `AGENTS.md` §3).
- **Stow**: Execute `stow -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk cmux uv claude`.

### 4. Initialization
- **XDG & Git**: Ensure `XDG_CONFIG_HOME` and `GIT_CONFIG_GLOBAL` are exported in `config.fish`.
- **SpecKit Init**: Run `specify init (basename (pwd))` in the repository root.
- **Git Identity**: If `git/.config/git/config` contains placeholders, use `git config --global` values to fill them automatically, then run `git update-index --assume-unchanged git/.config/git/config`.
- **Keymap**: Generate `KEYMAP.md` based on current repo configs.

### 5. Validation (Smoke Tests)
- Run all smoke tests defined in `AGENTS.md` §5.
- If any test fails, attempt a one-time `stow -R` (restow) before reporting the error.

### 6. Completion
- Notify the user via `cmux notify` (if available) or standard output: 
  > "One-shot setup complete! Using SpecKit, Sibling Worktrees, and cld.fish. Open **cmux** to begin."
