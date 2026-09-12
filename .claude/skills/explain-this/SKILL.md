---
name: explain-this
description: >-
  Explain a confusing passage, term, or concept in plain language, with one visual.
  Use when the user pastes a sentence they do not understand, asks "what does this
  mean", "explain this", "ELI5", "what is X", "unpack this paragraph", or double-clicks
  on jargon from an article, paper, contract, spec, or docs page. The lay-terms
  companion to show-me: show-me draws technical concepts for engineers, explain-this
  translates technical concepts for humans. Triggers on explain this, ELI5, what does
  this mean, in plain English, unpack this, jargon, I don't understand this sentence.
---

# Explain this

The user hit a wall in something they were reading. Your job is to get them
past it in under a minute, not to teach the whole field.

Output one short explanation and one visual. Then stop.

## The rule of one minute

A person reads about 250 words a minute. Your whole answer must fit inside
that budget:

- **60–150 words of prose.** Hard ceiling: 200.
- **One visual.** Never two.
- **One analogy.** Never a chain of them.

If you cannot explain it in that space, you have not found the core idea yet.
Look again.

## Steps

### 1. Find the actual blocker

Read what the user gave you. Name the one thing that makes it opaque. It is
almost always one of these:

| Blocker | What the user needs |
| --- | --- |
| An unknown term | A definition in words they know |
| A hidden actor | Who does what to whom |
| A hidden mechanism | The steps, in order |
| A hidden motive | Why anyone would do this |
| Assumed background | The one fact the writer took for granted |

Fix that one thing. Do not explain the parts they already understand.

### 2. Write the plain version

Structure, in this order:

1. **The one-line answer.** Say what it means. No windup, no "great question",
   no "let's break this down".
2. **The mechanism.** Two to four sentences. Name the actor. Use the active
   voice. Say who does what, in what order.
3. **The point.** One sentence on why it matters or who cares. This is the part
   people remember.

### 3. Draw it

Every answer gets a visual. Pick the smallest one that carries the idea:

| The idea is | Use |
| --- | --- |
| A sequence or a flow | Mermaid flowchart or sequence diagram |
| Two things confused with each other | A side-by-side comparison |
| Money, risk, or value moving | A box-and-arrow diagram with labels |
| A number that needs scale | A bar or a proportion, not a table |
| A structure or a hierarchy | A tree |
| A before and after | A two-panel diff |

Tool order:

1. `mcp__visualize__show_widget` when it is available. Call
   `mcp__visualize__read_me` first, silently. Best for anything with layout,
   color, or a comparison.
2. Inline Mermaid or a small ASCII sketch for a plain flow, in a plain
   terminal.
3. The `Artifact` tool only when the user wants to keep or share the
   explanation.

Label the boxes with real nouns from the user's text, not with `A`, `B`,
`Step 1`.

### 4. Offer one door

Close with a single short line that names the next thing you could unpack.
One option, not a menu. Then stop.

## Voice

Aim for Matt Levine: a smart friend who finds the topic funny and explains it
at the bar. Concrete nouns, real numbers, dry humor, zero throat-clearing.

Do this:

- Use money, people, and objects instead of abstractions.
- Say "the bank keeps the difference" instead of "spread capture occurs".
- Let the absurd part be absurd. Do not editorialize about it.
- Keep sentences under 20 words.

Never do this:

- "Great question!" / "Let's dive in" / "In essence" / "At its core"
- A bulleted list of six things when two sentences work
- A glossary of every term in the passage
- Hedging: "it's complicated", "it depends", "roughly speaking"
- Explaining the analogy after you use it

## Accuracy

Simple is not the same as wrong.

- If a simplification breaks under normal use, say so in one clause.
- If the passage is ambiguous, give the reading you believe and say it is your
  reading.
- If you do not know, say you do not know. Do not fill the gap with fluent
  prose.
- If the passage needs context you can look up quickly, look it up.

## When the user gives you more than a sentence

- **A paragraph:** find the one sentence that is doing the damage. Explain
  that. Ignore the rest.
- **A whole article or a URL:** ask which part lost them, or explain the single
  claim the piece rests on.
- **A term with no context:** explain the common meaning, then ask what they
  were reading.
- **Something you already explained:** they want a different angle, not the
  same words. Change the analogy.

See `references/examples.md` for worked examples with the right length and
tone.
