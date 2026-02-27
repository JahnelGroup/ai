# ai

This repo may serve many purposes; for now we're starting with a shared collection of skills useful to JGers.

## Skills
The repo is modeled after https://github.com/anthropics/skills. To learn more about how skills work, visit that repository and check out the suite of example skills they've hosted.
For information about the Agent Skills standard, see agentskills.io.

# Using these skills

This repo contains shared skills for Claude integrations. To set up:

1. Clone the repo:
   git clone git@github.com:JahnelGroup/ai.git
   cd ai

2. Run the install script:
   ./install.sh

This will create symlinks from your local ~/.claude/skills/ to the cloned skills here. If ~/.claude/ doesn't exist, it will be created.

To update skills later:
   ./update.sh  # Or just git pull && ./install.sh