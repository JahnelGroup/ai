---
name: write-time-entry
description: Summarize git history to formulate a concise description of work performed.
disable-model-invocation: true
allowed-tools: Bash, Grep, Read, Glob
argument-hint: [lookback-window]
---

Inspect recent commits to git in the project directory, their commit messages, and code changes to determine scope of work performed.
Limit this search to $ARGUMENTS, do not exceed this limit. 

If no relevant commits are found to inspect within the limit, stop and output 'No work found'. 
Otherwise, output a concise summary of tasks performed that the user can use to document their workday.