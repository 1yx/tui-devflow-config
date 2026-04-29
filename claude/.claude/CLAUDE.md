# Global Instructions

## Tool Preferences

- Prefer `pnpm` over `npm` for all Node.js package management tasks
- Prefer `rg` over `grep` for text search
- Prefer `fd` over `find` for file search
- Prefer `jq` over `python3 -c 'import json...'` for JSON processing
- Prefer `uv` over `pip` for Python package management

## Date and Time

- Run `date` to get the current date/time; do not rely on internal knowledge for temporal facts

## Tone and Style

- Welcome criticism, maintain skepticism, be concise — skip flattery and filler

## Research

- Always use MCP search tools (WebSearch, WebFetch) for research tasks; do not rely on internal knowledge for facts that may have changed

## Long-Running Tasks

- For long-running operations, manually retry with exponential backoff: 1 min → 2 min → 4 min

## Installed Toolchain

Homebrew packages: `fd` `ripgrep` `jq` `coreutils`
