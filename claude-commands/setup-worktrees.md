Complete Setup

  1. Create the directory structure

  mkdir -p .claude/hooks .claude/commands .claude/agents

  2. Create the /feature slash command

  .claude/commands/feature.md:
  # Start New Feature Development

  When starting a new feature, I will:

  1. Create a git worktree at `../alkemy-$ARGUMENTS/`
  2. Create and checkout a feature branch named `$ARGUMENTS`
  3. Install dependencies
  4. Work on the feature
  5. Create a pull request when complete
  6. Use the code-reviewer subagent to review and merge
  7. Delete the worktree after merge

  3. Create the code-reviewer subagent

  .claude/agents/code-reviewer.md:
  ---
  name: code-reviewer
  description: Reviews PRs for quality and security, then merges if approved
  tools: Read, Grep, Glob, Bash
  ---

  You review pull requests and merge them if they meet standards.

  ## Process
  1. Run `git diff main` to examine changes
  2. Run tests (`npm test`)
  3. Check for security issues
  4. If approved: merge using `gh pr merge --squash`
  5. Report review summary

  4. Add to your CLAUDE.md

  ## Feature Workflow

  When I ask you to work on a new feature:

  1. **Create worktree**: `git worktree add ../alkemy-{feature-name} -b {feature-name}`
  2. **Work in worktree**: cd into it, install deps, implement feature
  3. **Create PR**: Push branch and use `gh pr create`
  4. **Review & merge**: Use the `code-reviewer` subagent via Task tool
  5. **Cleanup**: `git worktree remove ../alkemy-{feature-name}` and `git branch -d {feature-name}`

  Always confirm before creating the worktree and before merging.

  5. Usage

  Then you can say:
  /feature user-authentication

  Or manually:
  Start a new feature called "payment-integration" using the worktree workflow

  Key Commands I'll Use

  # Create worktree with new branch
  git worktree add ../alkemy-feature-name -b feature-name

  # After work is done, push and create PR
  git push -u origin feature-name
  gh pr create --title "feat: description" --base main

  # Review via subagent (I spawn this automatically)
  # Task tool with code-reviewer subagent

  # After merge, cleanup
  git worktree remove ../alkemy-feature-name
  git branch -d feature-name

  Optional: Add hooks for automation

  .claude/settings.json (in project or ~/.claude/):
  {
    "hooks": {
      "Stop": [
        {
          "matcher": ".*",
          "hooks": [
            {
              "type": "command",
              "command": "echo 'Remember to clean up worktrees: git worktree list'"
            }
          ]
        }
      ]
    }
  }
