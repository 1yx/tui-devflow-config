# TUI Dev Flow Config 

An Agent-based TUI development workflow based on **cmux + claude code + worktruck**.
Designed specifically for macOS. Configurations follow the **XDG Base Directory Specification** and are managed using GNU Stow.

## Principles

- **Tooling for Humans**: Prioritize out-of-the-box (OOTB) tools to serve human intent first.
- **Agent-First Flow**: Optimize every layer for seamless AI Agent interaction (context, specifications, and automation).
- **Frictionless Interaction**: Maintain full compatibility with **GNU Readline** (Emacs-style) keybindings while strictly avoiding shortcut collisions across the entire stack.

## Architecture (cmux)

![cmux Hierarchy](./cmux_hierarchy.svg)

This environment is built on a four-layer hierarchical structure provided by **cmux**, mapped to your development workflow:

| Layer | Semantic Mapping | Description |
|---|---|---|
| **Window** | **Project** | A standalone macOS window for a specific project. |
| **Workspace** | **Git Worktree** | A dedicated tab in the **left sidebar** per branch/directory. |
| **Pane** | **Tools** | Split views within a workspace (e.g., Editor, Git View, File Manager). |
| **Surface** | **Task** | **Horizontal tabs at the top of a pane** for switching sub-tasks. |

## ⚠️ Security & Backup Warning

**IMPORTANT**: This project is designed to allow AI Agents to automatically modify your local tool configurations (e.g., Helix, Fish, Git, etc.). 

Before proceeding, you **MUST** manually review and run the provided backup script to safeguard your current settings:

1. Review the `backup_configs.sh` script in this repository.
2. Run it locally:
   ```bash
   bash ./backup_configs.sh
   ```
This script will create `.bak` copies of your existing configuration files in their original locations without deleting them.

## 🚀 Quick Start

Copy this repository URL and send it to your AI Agent (e.g., Claude Code, Gemini CLI) with the following prompt:

> "Please read AGENTS.md from this repository and follow its specifications to help me install and configure this TUI development environment on my macOS."

## Core Components
   - **cmux**: Window and layout management
   - **Claude Code**: Code Agent
   - **OpenSpec**: Specification-driven project management
   - **worktrunk**: Management of **git worktree** driven workflows (one workspace per branch)
   - **Helix**: Core code editor
   - **Yazi**: Terminal file manager
   - **LazyGit**: Git interactive interface
   - **Fish & Starship**: Modern shell experience

---

For detailed design specifications and command systems, please refer to [AGENTS.md](./AGENTS.md).
