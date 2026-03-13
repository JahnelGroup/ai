---
description: After completing tasks that modify files, append a summary to the daily work log
alwaysApply: true
---

# Work Log Post-Hook

After completing a task that **modifies code** (creates, edits, or deletes files), append a brief phrase to the daily work log.

## When to Log

- Only after files are actually modified (not read-only exploration or answering questions)
- One phrase per completed task/request
- Do not log the act of writing the log entry itself

## How to Write the Entry

1. Read `~/.config/work-log/STYLE.md` for formatting rules. If it doesn't exist, create it using work-log/STYLE.md.example.
2. Read `~/.config/work-log/YYYY-MM-DD.md` (today's date). If it doesn't exist, create it.
3. Append the new phrase to the end, separated by a comma and space.
