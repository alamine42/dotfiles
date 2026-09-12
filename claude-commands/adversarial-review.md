Adversarial design review of the current feature's plan. This catches architecture flaws, missing edge cases, UX gaps, and task plan issues BEFORE implementation begins.

> **Tracker:** Check the project's CLAUDE.md for whether task tracking is **Beads** (`bd` CLI) or **Linear** (`mcp__linear-server__*` tools; team/workspace named there). CLAUDE.md is authoritative — a leftover `.beads/` dir may remain after a migration, so don't infer from directories. Mapping: epic ↔ Linear project or parent issue; task ↔ issue/sub-issue. Run every tracker read/write below through that tracker.

Three review modes:
- **Claude workflow review** (default, no extra cost): parallel adversarial reviewers + independent refutation pass, run via the Workflow tool.
- **Quick review** (`quick` argument): the Claude review without the refutation pass — fastest and cheapest, but noisier since unverified findings pass through.
- **Codex review** (paid, OpenAI API): reserved for high-stakes features, or when the user passes `codex` as an argument.

## Step 1: Gather Context

Identify the current feature being worked on by checking:
1. Git branch name and recent commits
2. In-progress tasks in the tracker (`bd list`, or Linear `list_issues` with `state="In Progress"`)
3. Any PLAN.md, DESIGN.md, SPEC.md, TODO.md, or architecture docs
4. Recent plan files or design discussions in the repo

If you can't determine what feature is being planned, ask the user.

## Step 2: Ensure Design Artifacts Exist

Verify that there are design artifacts to review: PLAN.md, DESIGN.md, SPEC.md, TODO.md, ARCHITECTURE.md, and docs/ equivalents. Also note relevant tracker tasks.

If no design artifacts exist, create a new design artifact for the feature (markdown file) named specifically for this feature, saved under docs/.

Collect the full list of artifact file paths — the review engine needs them explicitly.

## Step 3: Choose the Review Engine

**If the user passed `quick`:** skip the high-stakes classification and the Codex offer entirely. Run Step 3A with `quick: true` in the workflow args — reviewers fan out as usual, but all findings pass through without refutation. If the feature looks high-stakes anyway, mention that a full or Codex review would be a better fit, but honor the quick request.

Otherwise, classify the feature as **high-stakes** if it touches any of:
- Authentication, authorization, or session handling
- Payments, billing, or money movement
- Data migrations, schema changes, or anything that can lose/corrupt user data
- Security boundaries (sandboxing, permissions, secrets, PII handling)
- Public API contracts or breaking changes consumers depend on
- Foundational architecture that many future features will build on

**If high-stakes (or the user passed `codex`):** tell the user why it qualifies and confirm they want to spend money on a Codex review. On yes, run Step 3B. On no, fall back to Step 3A.

**Otherwise:** run Step 3A (Claude workflow review). Do not ask permission — this is the default, no-cost path.

## Step 3A: Claude Workflow Review (default)

Run this via the Workflow tool, passing the artifact paths, a one-paragraph feature summary, and `quick: true/false` via `args` (as a real JSON object, not a string). Adapt the lens prompts if the feature obviously demands a different mix (e.g. add a `security` lens for anything near a trust boundary).

```js
export const meta = {
  name: 'adversarial-design-review',
  description: 'Adversarial design review: parallel lens reviewers, findings attacked by independent refuters',
  phases: [
    { title: 'Review', detail: 'one adversarial reviewer per lens' },
    { title: 'Verify', detail: 'independent refuters attack each CRITICAL/WARNING finding' },
  ],
}

const FINDINGS_SCHEMA = {
  type: 'object', required: ['findings'],
  properties: { findings: { type: 'array', items: {
    type: 'object', required: ['severity', 'title', 'detail'],
    properties: {
      severity: { enum: ['CRITICAL', 'WARNING', 'SUGGESTION', 'PRAISE'] },
      title: { type: 'string' },
      detail: { type: 'string', description: 'Concrete failure scenario or gap, referencing the specific artifact section' },
      artifact: { type: 'string', description: 'File the finding is about' },
    },
  } } },
}

const VERDICT_SCHEMA = {
  type: 'object', required: ['refuted', 'reason'],
  properties: { refuted: { type: 'boolean' }, reason: { type: 'string' } },
}

const files = args.artifacts.join(', ')
const brief = `Feature: ${args.summary}\nRead these design artifacts in full before reviewing: ${files}. Also check the project's tracker for the task plan if relevant (\`bd list\` for Beads, or Linear via mcp__linear-server__list_issues — the project's CLAUDE.md says which). You are reviewing the DESIGN, not implementation code.`

const LENSES = [
  { key: 'architecture', focus: 'architecture flaws: wrong abstractions, coupling that will hurt later, scalability/performance dead-ends, missing failure handling, integration risks with the existing codebase' },
  { key: 'edge-cases', focus: 'missing edge cases: empty/error/concurrent states, race conditions, partial failures, retries, idempotency, data validation gaps, states the plan never mentions' },
  { key: 'ux', focus: 'UX gaps: unclear flows, missing loading/error/empty states, confusing interactions, accessibility, and mismatches between what users need and what the plan builds' },
  { key: 'task-plan', focus: 'task plan issues: missing tasks, wrong sequencing/dependencies, underestimated work, missing testing or rollout steps, scope that should be cut or split' },
]

const results = await pipeline(
  LENSES,
  l => agent(
    `${brief}\n\nYou are an adversarial design reviewer. Your ONLY job is to find reasons this design fails, seen through this lens: ${l.focus}.\nBeing agreeable is a failure mode — hunt for what the author missed, assumed, or hand-waved. Every CRITICAL/WARNING must include a concrete failure scenario. You may also include PRAISE findings for genuinely load-bearing good decisions worth preserving, but earn them.`,
    { label: `review:${l.key}`, phase: 'Review', schema: FINDINGS_SCHEMA }
  ),
  review => parallel(review.findings.map(f => () => {
    if (args.quick || f.severity === 'SUGGESTION' || f.severity === 'PRAISE') return Promise.resolve({ ...f, confirmed: true })
    return parallel([1, 2].map(i => () =>
      agent(
        `${brief}\n\nA reviewer claims this design flaw (${f.severity}): "${f.title}" — ${f.detail}\nYour job is to REFUTE it. Check the artifacts: is it already handled, based on a misreading, not actually a problem, or too speculative to act on? Default to refuted=true if the claim doesn't hold up against the actual text of the artifacts.`,
        { label: `verify:${f.title.slice(0, 40)}`, phase: 'Verify', schema: VERDICT_SCHEMA, effort: 'high' }
      )))
      .then(votes => {
        const v = votes.filter(Boolean)
        return { ...f, confirmed: v.length === 0 || v.some(x => !x.refuted), refutations: v.filter(x => x.refuted).map(x => x.reason) }
      })
  }))
)

const all = results.filter(Boolean).flat().filter(Boolean)
const confirmed = all.filter(f => f.confirmed)
const killed = all.filter(f => !f.confirmed)
log(`${confirmed.length} findings survived refutation, ${killed.length} killed`)
return { confirmed, killed }
```

Treat `confirmed` as the review output. Show the user the confirmed findings grouped by severity, and briefly note how many candidate findings were killed in refutation (they can ask to see them).

## Step 3B: Codex Review (high-stakes only)

Execute the design-review script, passing any non-standard files via `-f`:

```
design-review -C "$PWD" [-f extra-file.md ...]
```

Show the full review output to the user. If the script fails, show the error and help troubleshoot. For high-stakes features, you may additionally run Step 3A and merge both sets of findings — the two engines catch different blind spots.

## Step 4: Incorporate Feedback

Go through each confirmed finding from the review:
- **CRITICAL** findings: Incorporate immediately. These represent fundamental flaws.
- **WARNING** findings: Incorporate. These would cause bugs or tech debt.
- **SUGGESTION** findings: Incorporate if they meaningfully improve quality.
- **PRAISE** findings: Note these — preserve what the review highlighted as good.

Update the relevant design artifacts (PLAN.md, SPEC.md, tracker tasks, etc.) directly. If the review identifies missing tasks, create them in the tracker. If it identifies missing edge cases, add them to the plan.

## Step 5: Summary

Present a concise summary titled "Design Review Complete: " + a name for the feature with:
1. **Engine used** — Claude workflow (full or quick) or Codex; for a full Claude review, how many findings survived vs. were killed in refutation; for a quick review, note that findings are unverified
2. **Verdict** — Was the design ready, needs revisions, or needs rethinking?
3. **Changes made** — Bullet list of what you changed based on the feedback
4. **Findings ignored** — Any suggestions you skipped and why (if any)
5. **Updated plan** — The revised plan/design in full, so the user can see the final version

Ask the user if they're satisfied with the revised design or want another review pass.
