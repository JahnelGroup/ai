# ai

This repo may serve many purposes; for now we're starting with a shared collection of skills useful to JGers.

## Skills
The repo is modeled after https://github.com/anthropics/skills. To learn more about how skills work, visit that repository and check out the suite of example skills they've hosted.
For information about the Agent Skills standard, see agentskills.io.

## Installation

1. Clone the repo:
   ```bash
   git clone git@github.com:JahnelGroup/ai.git
   cd ai
   ```

2. Run the install script for your platform:
   ```bash
   ./install.sh cursor   # symlinks skills to ~/.cursor/skills/
   ./install.sh claude    # symlinks skills to ~/.claude/skills/
   ```

## Updating

Pulls the latest changes from main and refreshes symlinks:
```bash
./update.sh cursor
./update.sh claude
```
