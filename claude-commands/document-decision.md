# Document Decision

Help the user document an architectural or strategic decision using ADR (Architectural Decision Records) format.

## Steps

1. **Check if decision records exist in this project:**
   - Look for `docs/decisions/` folder
   - If it doesn't exist, offer to create the structure first

2. **If structure doesn't exist, create it:**
   ```
   docs/decisions/
   ├── README.md          # Index of all decisions
   ├── _template.md       # Template for new decisions
   ```

   Use this README.md content:
   ```markdown
   # Decision Records

   This folder contains Architectural Decision Records (ADRs) documenting key technical and strategic decisions.

   ## Purpose
   - Long-term memory for AI assistants working on this project
   - Onboarding context for new developers
   - Historical reference for why things are the way they are

   ## Statuses
   - **Accepted** - Decision made and in effect
   - **Superseded** - Replaced by a newer decision
   - **Deprecated** - No longer relevant

   ## Index

   | # | Decision | Date | Status |
   |---|----------|------|--------|

   ---
   *Copy `_template.md` to create new decisions.*
   ```

   Use this _template.md content:
   ```markdown
   # ADR-XXXX: [Short Title]

   **Date:** YYYY-MM-DD
   **Status:** Accepted | Superseded | Deprecated
   **Deciders:** [Names]

   ## Context
   What is the issue motivating this decision?

   ## Decision
   What is the change we're making?

   ## Rationale
   - Reason 1
   - Reason 2

   ## Alternatives Considered
   ### Alternative A
   Why rejected.

   ## Consequences
   ### Positive
   - Benefit 1

   ### Negative
   - Tradeoff 1

   ## Revisit If
   - Condition that would trigger reconsideration
   ```

3. **If structure exists, gather decision details:**
   - Ask: "What decision do you want to document?"
   - Ask: "What was the context/problem?"
   - Ask: "What alternatives were considered?"
   - Ask: "What's the rationale for this choice?"

4. **Create the decision file:**
   - Determine the next number from existing files
   - Create `docs/decisions/NNNN-short-title.md`
   - Update the index in `docs/decisions/README.md`

5. **Optionally update CLAUDE.md:**
   - If CLAUDE.md exists but doesn't reference decisions, suggest adding:
     ```markdown
     # Decision Records
     Key decisions are documented in `docs/decisions/`. Read these before making architectural changes.
     ```

6. **Commit the changes** if the user approves.
