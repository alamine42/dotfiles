---
name: consolidate
description: Document solved problems to build searchable knowledge. Use after fixing bugs, solving tricky issues, or learning something that future sessions should know.
---

# /consolidate

Document recently solved problems to compound team knowledge. Creates structured documentation in `docs/solutions/` with YAML frontmatter for searchability.

## When to Use

Use this skill when:
- You just fixed a non-trivial bug
- You discovered a workaround or gotcha
- You learned something about the codebase that isn't documented
- A debugging session revealed useful insights
- You want future Claude sessions to benefit from what you just learned

**Preconditions:**
- Problem must be solved (not in-progress)
- Solution verified working
- Non-trivial issue (skip simple typos or one-line fixes)

## Workflow

### Step 1: Gather Context

Review the current conversation to extract:
1. **What was the problem?** (symptoms, error messages, unexpected behavior)
2. **What was the root cause?** (why it happened)
3. **What was the solution?** (code changes, configuration, commands)
4. **What files were involved?**
5. **How can we prevent this in the future?**

### Step 2: Classify the Problem

Determine the category based on the problem type:

**Bug Categories:**
- `build-errors/` - Compilation, bundling, dependency issues
- `test-failures/` - Test setup, flaky tests, assertion issues
- `runtime-errors/` - Exceptions, crashes, undefined behavior
- `performance-issues/` - Slow queries, memory leaks, bottlenecks
- `database-issues/` - Migrations, queries, connection problems
- `ui-bugs/` - Layout, styling, interaction issues
- `integration-issues/` - API, third-party services, auth
- `logic-errors/` - Incorrect behavior, edge cases

**Knowledge Categories:**
- `best-practices/` - Patterns, conventions, recommended approaches
- `workflow-tips/` - Developer experience, tooling, shortcuts
- `architecture/` - System design decisions, trade-offs
- `gotchas/` - Non-obvious behavior, common mistakes

### Step 3: Ensure Directory Structure Exists

If this is the first time using `/consolidate` in a project, create the directory structure:

```bash
mkdir -p docs/solutions/{build-errors,test-failures,runtime-errors,performance-issues,database-issues,ui-bugs,integration-issues,logic-errors,best-practices,workflow-tips,architecture,gotchas}
```

### Step 4: Check for Related Docs

Search `docs/solutions/` for potentially related documentation:

```bash
# Search for related terms in existing docs
grep -r "relevant-keyword" docs/solutions/ 2>/dev/null || echo "No existing docs found"
```

If highly related docs exist, consider updating them instead of creating a new file.

### Step 5: Create the Document

Create a new file at `docs/solutions/{category}/{slug}.md` with this structure:

**For Bugs:**

```markdown
---
title: "Brief descriptive title"
category: "{category}"
date: "{YYYY-MM-DD}"
tags: [relevant, tags, here]
files: [path/to/affected/files]
---

# {Title}

## Problem

Describe what was happening. Include:
- Error messages (exact text)
- Symptoms observed
- Steps to reproduce (if known)

## Root Cause

Explain why this happened. What was the underlying issue?

## Solution

Describe the fix. Include:
- Code changes (with file paths)
- Configuration changes
- Commands run

```{language}
// Relevant code snippet showing the fix
```

## Prevention

How to avoid this in the future:
- [ ] Add test for this case
- [ ] Update documentation
- [ ] Add linting rule
- [ ] Other preventive measures

## Related

- Links to related docs, issues, or PRs
```

**For Knowledge:**

```markdown
---
title: "Brief descriptive title"
category: "{category}"
date: "{YYYY-MM-DD}"
tags: [relevant, tags, here]
---

# {Title}

## Context

When does this knowledge apply? What situation prompted learning this?

## Guidance

The actual knowledge, best practice, or insight. Be specific and actionable.

## Examples

```{language}
// Code examples demonstrating the guidance
```

## References

- Links to official docs, discussions, or related materials
```

### Step 6: Verify Discoverability

Ensure the knowledge store is discoverable by checking if `CLAUDE.md` or `AGENTS.md` mentions the docs/solutions directory. If not, add a brief reference:

```markdown
## Knowledge Base

See `docs/solutions/` for documented problems and solutions. Search with:
- `grep -r "keyword" docs/solutions/`
- Browse categories: build-errors, runtime-errors, best-practices, etc.
```

## File Naming Convention

Use kebab-case slugs that describe the problem:
- `fix-webpack-chunk-loading-error.md`
- `handle-prisma-connection-timeout.md`
- `understanding-nextjs-app-router-caching.md`

## Example Session

```
User: "That fixed it! The tests are passing now."

Claude: I'll document this solution using /consolidate.

[Creates docs/solutions/test-failures/fix-jest-esm-import-error.md]

Done! Documented the Jest ESM configuration fix in docs/solutions/test-failures/fix-jest-esm-import-error.md
```

## Output

After running this skill, you should have:
1. A new markdown file in `docs/solutions/{category}/`
2. Proper YAML frontmatter for searchability
3. Clear problem/solution documentation
4. Prevention steps to avoid recurrence
