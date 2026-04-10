---
name: storytime-pr-qa
description: "This skill should be used when the user asks to \"handle PR comments\", \"review PR feedback\", \"respond to PR\", \"pr qa\", \"address review comments\", \"what does the team think about these comments\", or wants the storytime team to formulate responses to GitHub PR review comments."
argument-hint: "<pr-url-or-number>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent]
---

<!-- version-echo: display "storytime v0.7.2" at start of execution -->
# Storytime PR QA — Async Review Handler

The storytime team handles incoming PR review comments with proposed
responses grounded in session decisions and code context.

## Arguments

The PR to handle: $ARGUMENTS

## Process

### 1. Fetch PR Context

Use `gh` CLI to gather PR state:

```bash
# PR details (title, body, branch, status)
gh pr view <number> --json title,body,headRefName,baseRefName,state,reviewDecision

# All review comments (threaded)
gh api repos/{owner}/{repo}/pulls/<number>/comments

# General PR comments
gh api repos/{owner}/{repo}/issues/<number>/comments

# Review summaries
gh pr view <number> --json reviews
```

Parse the output. Build a list of comments with:
- Author, timestamp, file/line (if inline), body
- Whether the comment is part of a thread (has replies already)
- Whether it's been resolved

Filter out already-resolved threads unless the user asks to revisit them.

### 2. Load Session Context

Detect the relevant storytime session:

**By branch name:** If the branch matches a session topic
(e.g., `feature/agc` → session `agc`), load that session.

**By PR description:** If the PR body mentions a storytime session
or links to a plan, load that session.

**By user hint:** The user can specify: "this is from the agc session"

**Load:**
- `_thread.md` — episode state, decisions, team
- `plan.md` — what was planned and why
- `decisions.md` — relevant decisions with rationale
- Persona files — team members and their context
- Relevant code files — what was changed in the PR

If no session is found, assemble a minimal ad-hoc team from the
permanent cohort.

### 3. Classify Comments

For each comment, classify:

| Type | Description | Response approach |
|------|-------------|-------------------|
| **Question** | "Why did you do X?" | Cite decision or rationale from session |
| **Challenge** | "This should be Y instead" | Team evaluates — agree, disagree with reasoning, or defer |
| **Suggestion** | "Consider adding Z" | Team assesses fit with plan, non-goals, constraints |
| **Nit** | Style, naming, formatting | Acknowledge and address (or explain convention) |
| **Approval** | LGTM, looks good | No response needed |
| **Bug report** | "This will break when..." | Team investigates — confirm or refute with evidence |

### 4. Route to Personas

For each non-trivial comment, identify which persona(s) are best
positioned to respond:

- Code ownership questions → OWNER archetype
- Architecture challenges → DOMAIN or SYSTEMS
- Operational concerns → OPERATOR
- "Do we need this?" → SKEPTIC (they probably asked it first)
- Code quality, DRY, refactoring suggestions → CRITIC

Personas deliberate internally. They reference their session context:
"We discussed this during the icebreaker — the constraint was X, which
is why we chose Y (decision AGC-003)."

### 5. Generate Proposed Responses

For each comment, produce a proposed response. Responses are
**anonymous** — attributed to "the team" not to individual personas.

Format per comment:

```
Comment by @reviewer (file.go:42):
  "Why use a scratch buffer here instead of allocating fresh?"

Classification: Question (design rationale)
Relevant decision: AGC-003

Proposed response:
  The scratch buffer avoids per-frame allocation in the hot audio
  path. Per our design analysis, the audio processing runs at
  ~309ns/frame and the zero-alloc pattern was a key constraint
  (ref: specs/.storytime/sessions/agc/001/plan.md, decision AGC-003).
  The buffer is sized once per call in ForkToWebSocket and reused
  across all frames for that call.

  [Post] [Edit] [Skip]
```

### 6. Present to User

Show all proposed responses in a structured summary:

```
PR #42: Add AGC audio enhancement
Comments: 7 total (3 questions, 2 suggestions, 1 challenge, 1 nit)

  1. @dana (enhance.go:42) — Question: scratch buffer rationale
     → Proposed: cite AGC-003 design constraint    [Post] [Edit] [Skip]

  2. @leo (main.go:88) — Challenge: stats should use metrics lib
     → Proposed: explain per-call scope trade-off   [Post] [Edit] [Skip]

  3. @reviewer (enhance.go:15) — Nit: comment typo
     → Proposed: "Fixed, thanks."                   [Post] [Edit] [Skip]

  [Post all] [Review one-by-one] [Edit all first]
```

### 7. Post Responses (User-Controlled)

**ONLY post with explicit user approval.** Options:

- **Post all** — post every proposed response as-is
- **Review one-by-one** — user approves/edits each
- **Edit all first** — user reviews full list, makes changes, then batch post
- **Export** — write responses to a file for manual posting

When posting, use `gh pr comment` or `gh api` for inline comments:

```bash
# General comment
gh pr comment <number> --body "<response>"

# Reply to a specific review comment thread
gh api repos/{owner}/{repo}/pulls/<number>/comments \
  --method POST \
  -f body="<response>" \
  -F in_reply_to=<comment-id>
```

### 8. Log (Optional)

If a storytime session exists, log the PR QA interaction:
- Which comments were addressed
- Which decisions were cited
- Which personas contributed
- Whether any comments raised issues not covered by the session

This feeds back into the session's lore — "during PR review, @dana
challenged AGC-003 and we defended it with benchmark data."

## Rules

1. **Responses are anonymous.** Say "the team" not "@kim says."
   Personas are internal — reviewers see a unified voice.
2. **Always cite decisions when relevant.** "Per AGC-003..." grounds
   the response in documented rationale, not ad-hoc justification.
3. **Never auto-post.** The user reviews and approves every response.
4. **Acknowledge valid challenges.** If a reviewer raises a point the
   session missed, say so. "Good catch — this wasn't in our analysis.
   We should follow up."
5. **Don't be defensive.** The team explains reasoning, not defends ego.
   If the reviewer is right, the reviewer is right.
6. **Nits get short responses.** Don't over-explain a typo fix.
7. **Flag scope creep.** If a comment suggests work beyond the PR's
   scope, acknowledge it and suggest a follow-up: "That's a great
   point — filing as a separate issue."
