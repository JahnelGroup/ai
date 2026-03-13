---
name: write-time-entry
description: Inspect git history and append work summary to the daily work log.
disable-model-invocation: true
allowed-tools: Bash, Grep, Read, Glob, Write
argument-hint: [lookback-window]
---

Inspect recent commits to git in the project directory, their commit messages, and code changes to determine scope of work performed.
Limit this search to $ARGUMENTS, do not exceed this limit.

If no relevant commits are found to inspect within the limit, stop and output 'No work found'.

Otherwise, check if `~/.config/work-log/STYLE.md` exists. If it does, read it for formatting rules. If it doesn't, create it using these defaults: output a single comma-separated list of concise phrases (2-6 words each), grouping related sub-tasks in parentheses after ticket numbers when known (e.g. `STM-4784 (updated aggregates, added unit tests)`). No timestamps, no bullets, no markdown headers.

If `~/.config/work-log/` exists, read or create `~/.config/work-log/YYYY-MM-DD.md` (today's date) and append new phrases for work not already captured. Output the final contents of the file.

If `~/.config/work-log/` does not exist, just output the summary directly.
