---
description: After completing tasks that modify files, append a summary to the daily work log
alwaysApply: true
---

# Work Log Post-Hook

After completing a task that **produces artifacts** — whether modifying code (creates, edits, or deletes files) or producing external artifacts (Notion pages, JIRA updates, GitLab MRs, etc.) — append a brief phrase to the daily work log.

## When to Log

- After files are actually modified (not read-only exploration or answering questions)
- After creating or updating external artifacts via MCP tools (Notion docs, JIRA tickets, GitLab MRs, etc.)
- One phrase per completed task/request
- Do not log the act of writing the log entry itself

## How to Write the Entry

1. Read `~/.config/work-log/STYLE.md` for formatting rules. If it doesn't exist, create it using work-log/STYLE.md.example.
2. Read `~/.config/work-log/YYYY-MM-DD.md` (today's date). If it doesn't exist, create it.
3. Append the new phrase to the end, separated by a comma and space.
