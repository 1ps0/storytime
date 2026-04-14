---
type: breakout
schema_version: 1
created: 2026-04-13T11:50
session: v1-consolidation
episode: 001
topic: v1-consolidation
subtopic: friction-calibration
driver: "@platform [compass]"
supporters: ["@educator [beacon]"]
supporters_who_spoke: ["@educator [beacon]"]
status: complete
---

# Breakout 5 — Tutorial Friction Signal Calibration

## Problem

V1-013 resolves that tutorial exit is adaptive: the LLM watches for friction signals (impatience, skim-approvals, confusion, encumbrance) and proposes stepping down to a lower automation tier. What the proposal does NOT specify is **what counts as a signal and at what threshold**.

Two failure modes to avoid:

1. **Premature graduation (false positive).** A user eager to learn, approving quickly because they're engaged, saying "ok, proceed" as a natural affirmative — not because they're encumbered — gets auto-graduated before they've learned the framework. Beacon's worry: we trained them to approve, then took the explanations away.
2. **Stranded (false negative).** A user who is clearly comfortable — modifying commit messages, naming personas correctly — stays in tutorial-level prompting forever because calibration is too lax. They turn storytime off rather than endure the hand-holding.

Third failure mode, under-discussed in V1-013:

3. **Struggling user graduated anyway.** If we only watch for confidence signals, we miss the opposite: a confused user, backing out of prompts, asking "what does this mean?" — they need *more* scaffolding, not less. The LLM should detect struggle and **stay** in tutorial, possibly with richer explanations.

Beacon's pedagogical framing of the whole breakout:

> Users who graduate because the LLM proposes it are passive graduates. Users who graduate because they understand the framework well enough to say "I've got this" are active graduates. Active graduates stick; passive graduates churn when they hit something unfamiliar and find no scaffolding. The signals matter less than the **ritual of asking** the user if they feel ready.

## Signal catalog

Each row is a friction signal. Signals point toward graduation (confidence) or retention (struggle). Thresholds are conservative starting points — dogfooding refines them.

| Signal                         | Pattern                                                                                                           | Direction | Suggested threshold                           | Notes                                                                  |
|--------------------------------|-------------------------------------------------------------------------------------------------------------------|-----------|-----------------------------------------------|------------------------------------------------------------------------|
| Impatience                     | Response time between prompt and approval shrinks; recent median < 30% of baseline (first N=3 prompts same skill) | graduate  | 8 prompts showing pattern, same skill         | Needs baseline — first 3 prompts establish the user's normal pace      |
| Skim approval                  | User approves verbatim (no edit, no question, no pause) for N consecutive prompts in same skill                   | graduate  | 6 consecutive                                 | Reset counter on any edit, question, or defer                          |
| Short-affirmative encumbrance  | Approvals consistently 1-3 tokens ("yes", "ok", "proceed", "just do it", "go") with no engagement                 | graduate  | 8 across same skill                           | Contrast with substantive approvals ("yes, but also rename X")         |
| Explicit request               | User says "stop holding my hand", "less prompting", "just do it without asking", "get out of tutorial"            | graduate  | 1 occurrence                                  | Hard signal. Match on intent, not exact wording.                       |
| Clarifying-question repeat     | User asks a question (e.g., "what's a breakout?") that the most recent tutorial explanation already answered      | retain    | 2 in same skill                               | Suggests tutorial text isn't landing — stay, but refresh framing       |
| Backing-out pattern            | User chooses `defer`, `pause`, or `cancel` more than N times in a skill session                                   | retain    | 3 in one session of same skill                | Indicates overwhelm — scaffold more, don't less                        |
| Meta-confusion                 | User asks "why are you asking me this?" or "what does this do?" about a tutorial prompt                           | retain    | 1 occurrence, triggers richer explanation     | Don't demote tutorial — enrich it                                      |
| Self-reported struggle         | User says "I don't get this", "confused", "what's going on"                                                       | retain    | 1 occurrence                                  | Hard signal the other direction                                        |
| Deliberate modification        | User edits commit messages, adjusts personas, renames breakouts — operating the framework                         | graduate  | 4 modifications across same skill             | Strongest positive signal: user is steering, not just approving        |

### Composite rules

- **Graduation requires agreement across multiple signals.** No single signal graduates a user. Concrete: proposing step-down requires EITHER (a) explicit request, OR (b) two graduate-direction signals hitting threshold in the same skill.
- **Any retain signal blocks graduation for N=5 prompts.** A confusion event resets the graduation-candidacy clock.
- **Retain signals can UPGRADE the tutorial.** Two retain signals in one session → LLM offers richer explanation, not quieter. This is the "tutorial-plus" case.

## Options for calibration

### Option A — Silent threshold ladder

LLM silently tracks signals per skill. When graduate-direction thresholds hit, it automatically drops the automation level one step (tutorial → guided) and tells the user afterward ("I've moved you to guided mode since you seemed comfortable — say 'back to tutorial' to return").

- **Pros.** Zero friction, no decision burden. Matches "commit confirmation learns" pattern from V1-009.
- **Cons.** Beacon objects hard: passive graduation. User doesn't know WHY they graduated, can't internalize the framework. Risk of surprise ("why is the LLM not asking me anymore?").
- **Reversibility.** Config flag flips back, but user may not know to ask.

### Option B — Proposed step-down (user confirms) [strong]

When graduate-direction thresholds hit, the LLM **proposes** the step-down with a named rationale. User confirms, defers, or refuses. Default: stay in tutorial until the user says otherwise.

Prompt shape (draft):

> You've approved the last 6 breakout-start prompts without modification and your response times are getting faster. You look comfortable with how breakouts work. Want to drop to `guided` mode for breakouts? In guided mode, I'll skip the "ready to proceed?" pause but still prompt on critical decisions.
>
> `[yes, graduate]  [not yet]  [explain what changes]  [stay in tutorial]`

- **Pros.** Active graduation. User understands the change. Beacon's concern addressed. Rationale is pedagogical — names the pattern observed. "Explain what changes" option teaches the framework by naming the quieter mode's behavior.
- **Cons.** Adds a prompt to graduate, which is itself a tutorial-style interaction. Slightly more friction than silent promotion.
- **Reversibility.** The prompt itself names the way back.

### Option C — User-initiated only (no LLM proposal)

The LLM tracks signals but **never proposes** — only answers when the user asks "am I ready to graduate?" or explicitly says "step me down." Signals accumulate in a visible status ("you've approved N breakouts with no modification").

- **Pros.** Maximum user agency. No surprise. Signal accumulation becomes a visible teaching tool — user sees what patterns the framework notices.
- **Cons.** Passive users stay in tutorial indefinitely. Defeats adaptive exit. V1-007's "as trust develops, dial down" never actually happens unless the user knows to dial.
- **Reversibility.** N/A — user drove it both ways.

### Option D — Hybrid: proposal at threshold + visible progress [recommended]

Combine B and C: the LLM proposes step-down at threshold (Option B), AND exposes signal accumulation on demand ("how close am I to graduating?"). Users who want agency can check status; users who want to be led get the proposal.

- **Pros.** Covers both user types. Pedagogical (visible counters teach the framework). Beacon satisfied — graduation is a conversation, not a demotion.
- **Cons.** More surface area. Requires small "automation status" command or inline query support.

## Recommendation

**Option D — hybrid proposal + visible progress.**

The LLM proposes step-down at threshold (Option B mechanics), AND makes signal accumulation queryable via a `/storytime-status` extension — a small block showing "tutorial graduation progress: 4/6 skim-approvals, 2/4 deliberate modifications, 0 retain signals in this session."

**Per-skill graduation, not global.** Completing tutorial for `/storytime-breakout` graduates the user from breakout tutorials only; `/storytime-buildout` starts in tutorial mode the first time the user runs it. Reason: skills have different mental models. Someone fluent in breakouts may still be new to buildouts. Global graduation is available as an explicit escape hatch ("graduate me from all tutorials") but not automatic.

**Graduation is always reversible** via `/storytime tutorial <skill>` which re-enables tutorial mode for that skill. The proposal prompt (Option B wording) always names this escape route so the user knows they can come back.

**Retain signals are first-class.** When two retain signals hit in one session, the LLM proposes **tutorial-plus** (richer explanations, more "why are we doing this?" context) — treating struggle as a signal to act on, not an absence of confidence.

**Initial thresholds (subject to dogfooding):**

- Impatience: 8 prompts in same skill, recent median < 30% of baseline
- Skim approval: 6 consecutive
- Short-affirmative: 8 across same skill
- Explicit request: 1 (hard trigger)
- Deliberate modification: 4 across same skill
- Graduation composite: explicit-request OR (two graduate signals at threshold AND no retain signals in last 5 prompts)
- Retain trigger: 2 retain signals → propose tutorial-plus

### Complexity

**C = 8.** In prose: non-trivial but bounded. Signals require the LLM to maintain per-skill counters across a session, which means a small state block in the thread or a companion file — roughly the same shape as the "commit confirmation adapts" state under V1-009, and can probably share infrastructure. Detection logic is LLM introspection (no regex or hard parsing), so it's prompted behavior, not code. The proposal UX is one new prompt template per skill. Tutorial-plus is a variant of existing tutorial wording. The hardest part is calibration itself — thresholds need real usage data, which is a dogfooding problem, not a spec problem. Ship conservative defaults, iterate.

### Scale

**S = 5 (skills touched).** In prose: every skill that uses the automation ladder needs to know about the tutorial tier and the four graduate-direction signals plus the two retain signals. That's the five user-facing skills most likely to run in tutorial mode — `/storytime`, `/storytime-breakout`, `/storytime-buildout`, `/storytime-converge`, `/storytime-retro`. Utility skills (`/storytime-lint`, `/storytime-status`, `/storytime-undo`) probably skip tutorial entirely. One shared reference file (`references/tutorial-signals.md`) describes the catalog and composite rules; each skill loads it and applies. No per-skill custom signal logic — the catalog is the contract.

## Citations

- `docs/proposals/v1-consolidation.md:478-482` — V1-013 resolution text (adaptive tutorial exit)
- `docs/proposals/v1-consolidation.md:450-453` — V1-007 tutorial-first onboarding
- `docs/proposals/v1-consolidation.md:459-464` — V1-009 commit confirmation adapts to user patterns (shares infrastructure pattern)
- `docs/proposals/v1-consolidation.md:499-502` — open question: friction signal calibration (this breakout's subject)
- `skills/storytime/references/automation.md:1-38` — existing automation levels that tutorial extends
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:74-78` — compass's framing of bidirectional calibration risk
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:100-115` — constraints: earning-its-keep, kill switch, migration first-class

## Open questions returned to CONVERGE

1. **Where is the signal-counter state stored?** Options: in `_thread.md` under a `tutorial_progress` field, in a separate `.storytime/tutorial-state.md`, or in-memory per session with no persistence. Persistence matters across compacts and session restarts — if counters reset at every compact, thresholds never hit for long sessions.
2. **Does tutorial-plus need new content, or is it existing tutorial text verbosity + extra "why" annotations?** Beacon prefers "why" annotations (teaching) over repetition. Needs a wording pass.
3. **Retention-mode escalation.** If tutorial-plus still produces retain signals, what next? Does the LLM propose a human-help mode ("do you want to pair with someone / look at examples")? Or accept that the framework may not fit this user right now?
4. **Thresholds are reasoned guesses.** Numbers (6, 8, 2, 4) are defaults, not evidence-based. Should v1.0 ship with a telemetry opt-in to aggregate signal-to-graduation ratios across users? Or per-install only, on the honor system of "report back to the project"?
5. **Interaction with V1-009 (commit confirmation learning).** Both systems watch user patterns and adapt prompting. Do they share state? Do their thresholds compose (skim-approving 6 commits + skim-approving 6 breakouts = double graduation)? Or is each skill's adaptation independent? Recommendation leans independent but needs confirmation.

## Participants

- **@platform [compass]** (driver) — Named the bidirectional risk, drafted the signal catalog, proposed Option D as the hybrid preserving user agency while avoiding stranded-forever. Held the line that graduation must be per-skill, not global by default, because skills have different mental models.
- **@educator [beacon]** (supporter) — Challenged silent graduation (Option A) as pedagogically empty. Insisted graduation is a conversation: the prompt must name the pattern observed, offer an "explain what changes" path, and make the escape route visible. Reframed retain signals as first-class inputs (tutorial-plus), not just absence-of-confidence. Core contribution: users who understand WHY they graduated are the ones who stick; passive graduates churn.
