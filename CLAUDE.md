# ClaudeCodeSystem Setup Repo

This is the setup repository for the Claude Code Personal Assistant System. It is NOT a vault -- it contains the templates, examples, and setup commands used to build a vault.

## If the user opens Claude Code in this folder

Guide them to type `/onboard` to begin setup. The slash commands are in `.claude/commands/` and are ready to use.

## If this folder is inside an Obsidian vault (bootstrap mode)

The user may have downloaded this repo and dropped it inside their existing notes folder. Detect this by checking:
1. Does a parent directory contain `.obsidian/` or other vault files?
2. Is this folder nested (e.g., `Brain/ClaudeCodeSystem-main/` or `Brain/ClaudeCodeSystem/`)?

If yes, **bootstrap automatically**:

1. Identify the vault root (the directory containing `.obsidian/` or the nearest parent that looks like a vault root).
2. Copy all files from this repo's `.claude/commands/` to the vault root's `.claude/commands/`:
   ```
   mkdir -p <vault_root>/.claude/commands/
   cp .claude/commands/*.md <vault_root>/.claude/commands/
   ```
3. Tell the user: "I found the setup files and copied the commands to your vault. You can now type `/onboard` to begin, or I can start it for you."
4. Offer to start `/onboard` immediately.

## If the user just says "set me up" or "help me get started"

Read `.claude/commands/onboard.md` from this repo and execute it directly. The user does not need to know about slash commands to get started.

## After setup is complete

This repo is no longer needed. Everything gets copied into the user's vault during `/onboard`. The `/finish` command offers to archive this folder.
