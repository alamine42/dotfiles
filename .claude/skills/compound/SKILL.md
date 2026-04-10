---
name: compound
description: "Document solved problems to build searchable knowledge. PROACTIVE: When you detect a non-trivial problem has been fixed (user says 'that worked', 'it's fixed', 'problem solved', 'working now', 'finally fixed', 'bug fixed'), ask 'Want me to document this fix with /compound?' Skip for trivial fixes like typos or syntax errors."
---

# Compound: Document Solutions

Each unit of engineering work should make subsequent units easier. This skill captures solved problems while context is fresh.

**The math:**
- Solving a problem: ~30 minutes
- Documenting it: ~5 more minutes
- Next occurrence: ~2 minutes

---

## When to use

Invoke this skill when:
- A bug has been fixed
- A tricky problem was solved
- You figured out something non-obvious
- A workaround was discovered
- Configuration issues were resolved

**Skip for trivial fixes** (typos, syntax errors, obvious one-liners).

---

## Process

### Step 1: Gather context from conversation

Extract from the current session:
- **Problem**: What was broken/not working?
- **Symptoms**: What did the user observe? (error messages, unexpected behavior)
- **Investigation**: What was tried that didn't work?
- **Root cause**: What was actually wrong?
- **Solution**: What fixed it? (include code if applicable)
- **Environment**: What versions/tools/context matter?

If critical context is missing, ask the user before proceeding.

### Step 2: Classify the problem

Determine the category:
- `build-errors` - compilation, bundling, dependency issues
- `test-failures` - failing tests, test setup issues
- `runtime-errors` - crashes, exceptions, panics
- `performance` - slow queries, memory issues, bottlenecks
- `database` - migrations, queries, data issues
- `security` - auth issues, vulnerabilities, permissions
- `ui-bugs` - visual issues, interaction problems
- `integration` - API issues, third-party service problems
- `config` - environment, settings, setup issues
- `logic` - business logic bugs, incorrect behavior

### Step 3: Check for existing solutions

Search `docs/solutions/` for similar issues:
```bash
grep -r "KEYWORD" docs/solutions/ 2>/dev/null || echo "No existing solutions found"
```

If similar solutions exist, ask user:
1. Create new doc with cross-reference?
2. Update existing doc?
3. Skip documentation?

### Step 4: Generate filename

Format: `[problem-slug]-[YYYY-MM-DD].md`
- Lowercase, hyphens for spaces
- Max 60 characters before date
- Example: `missing-env-variable-auth-2024-03-05.md`

### Step 5: Create the solution document

Create directory if needed:
```bash
mkdir -p docs/solutions/[category]
```

Write the document with this structure:

```markdown
---
date: YYYY-MM-DD
problem_type: [category from step 2]
component: [affected area/module]
symptoms:
  - [observable symptom 1]
  - [observable symptom 2]
root_cause: [brief technical cause]
severity: [critical|high|medium|low]
tags:
  - [relevant-tag-1]
  - [relevant-tag-2]
---

# [Problem Title]

## Problem

[1-2 sentence description of what was broken]

## Symptoms

[What the user observed - exact error messages, unexpected behaviors]

## What Didn't Work

[Investigation attempts that failed, and why they failed]

## Solution

[What fixed the problem - include code snippets with before/after if applicable]

## Why This Works

[Technical explanation of root cause and why the solution addresses it]

## Prevention

[How to avoid this in the future - checks, tests, patterns to follow]

## Related

[Links to related solutions or "None"]
```

### Step 6: Confirm with user

After creating, show the user:
- File path created
- Summary of what was documented
- Ask if they want to:
  1. View the full document
  2. Add to related solutions
  3. Continue working

---

## Quality standards

**Do include:**
- Exact error messages (copy-pasted)
- Specific file:line references
- Observable symptoms, not interpretations
- Failed investigation attempts
- Before/after code examples
- Prevention guidance

**Don't include:**
- Speculation about unrelated issues
- Overly verbose explanations
- Information not relevant to reproducing/solving

---

## Example output

`docs/solutions/config/missing-api-key-oauth-2024-03-05.md`:

```markdown
---
date: 2024-03-05
problem_type: config
component: authentication
symptoms:
  - "Error: OAuth token exchange failed"
  - Login button shows spinner indefinitely
root_cause: missing-env-variable
severity: high
tags:
  - oauth
  - environment
  - google-auth
---

# OAuth Login Failing Due to Missing API Key

## Problem

Google OAuth login was failing silently after users clicked "Sign in with Google".

## Symptoms

- `Error: OAuth token exchange failed` in server logs
- Browser console showed 401 on `/api/auth/callback/google`
- Login button spinner never resolved

## What Didn't Work

- Checked callback URL configuration (was correct)
- Verified Google Cloud Console settings (were correct)
- Restarted server (no change)

## Solution

The `GOOGLE_CLIENT_SECRET` environment variable was missing from production:

```bash
# Added to .env.production
GOOGLE_CLIENT_SECRET=xxx
```

Then redeployed with `railway up`.

## Why This Works

The OAuth flow requires the client secret to exchange the authorization code for tokens. Without it, the token exchange request was failing with 401.

## Prevention

- Add environment variable checklist to deployment docs
- Consider adding startup validation that checks required env vars:
  ```javascript
  const required = ['GOOGLE_CLIENT_ID', 'GOOGLE_CLIENT_SECRET'];
  required.forEach(key => {
    if (!process.env[key]) throw new Error(`Missing ${key}`);
  });
  ```

## Related

None
```

---

## Integration

This skill is standalone. Invoke with `/compound` after solving a problem.

The resulting docs in `docs/solutions/` become searchable knowledge:
- `grep -r "oauth" docs/solutions/` finds relevant past solutions
- YAML frontmatter enables filtering by problem_type, severity, tags
