---
type: proposal
schema_version: 1
created: 2026-04-19T10:00
name: intent-extraction-user
status: exploration
session: null
---

# Intent Extraction — User Lens

A meta-analysis from the v1.0.0 conversation: what if storytime extracted
short statements of intent from each user prompt, tagged them by storytime
role/lens, and aggregated them over time? This document captures the
extraction exercise and the design space it opens.

## Source

Performed against the last 12 prompts of the v1-consolidation conversation
(the session that produced storytime v1.0.0). Each prompt was reduced to a
short intent statement, then labeled with the storytime lens(es) that
seemed to be driving it.

## Extracted intents

| # | Source prompt | Intent statement | Driving lens | Type |
|---|--------|------------------|--------------|------|
| 1 | "if you were to run an example analysis..." | Reflect on the conversation as data | @owner + @platform | meta |
| 2 | "yes, docs and site" | Approve doc-update scope | @owner | approval |
| 3 | "are the docs fully up to date?" | Audit doc freshness | @critic + @educator | verify |
| 4 | "make it so" | Approve v1.0 plan, dispatch buildout | @owner | approval |
| 5 | "swarm it... use commits as history" | Liberate to act with commits as record | @owner + @operator | dispatch |
| 6 | "commit and then full swarm" | Ship milestone, parallel buildout | @owner | dispatch |
| 7 | "remaining open questions: 1-5..." | Resolve 5 calibration questions | @platform + @owner | resolve |
| 8 | "open questions: 1-8..." | Resolve 8 design decisions | @owner + @platform + @operator | resolve |
| 9 | "thats what i wanted it to always be... 1.0.0 synthesis" | Declare unifying vision | @owner [strong] | vision |
| 10 | "aside: remembrance is almost a wakeup doc + consolidation prompt" | Refine remembrance shape | @owner + @platform | refine |
| 11 | "heres a thought, lets discuss... sleep-function-like approach" | Propose architectural pivot | @owner + @domain | vision |
| 12 | "commit and increment then run critic" | Ship + critical review | @owner + @critic | dispatch+verify |

## Tally by lens

```
@owner       11 / 12   ████████████████████████████  primary driver
@platform     6 / 12   ███████████████  UX awareness
@critic       3 / 12   ████████  verification + contestation
@operator     3 / 12   ████████  mechanics + ship discipline
@domain       1 / 12   ███  memory-science analog
@educator     1 / 12   ███  doc clarity worry
@skeptic      0 / 12     —  no "do we need this?" challenges this session
```

**Observation:** the user is a strong @owner with @platform flavor.
**Zero @skeptic prompts** in this session — the user is in *build mode*,
not *question-the-build mode*. The cohort assembled (anchor + tide +
arbor + drift + compass + forge + lattice + beacon) had @skeptic [drift]
but the user themselves never operated from that lens. That is a missing
internal voice that the cohort had to provide.

## Tally by type

```
approval/dispatch    4 / 12   ████████████  largest bucket — trust mode
resolve              2 / 12   ██████  decision packets
vision/proposal      2 / 12   ██████  load-bearing direction-setters
refine               1 / 12   ███
verify               2 / 12   ██████
meta                 1 / 12   ███
```

The session arc: **vision → resolve → approve → dispatch → verify → meta**.
A complete creative cycle in 12 turns.

## Why aggregating intent over time would be valuable

1. **Lens self-knowledge.** "You drive from @owner 73% of the time" is data
   the user can't get any other way. Surfaces a blind spot — the absence of
   @skeptic in this session is invisible without aggregation.

2. **Project archetype emergence.** Repos cluster by lens balance. A founder
   repo is @owner-heavy; a maintenance repo skews @critic; a security audit
   repo wants @skeptic. Storytime could recommend cohort composition based
   on the user's actual lens history per repo type.

3. **Lens drift = phase change.** When a project's user-lens shifts from
   @platform to @operator, the project moved from "design" to "ship." That's
   a phase transition the user might not notice in real time. Aggregation
   surfaces it.

4. **Remembrance gets richer.** Today's wakeup says "what you were working
   on." Add lens distribution and it says "what mode you were in." Faster
   re-entry — you reconstruct your *headspace*, not just the project state.

5. **Tutorial graduation gets honest.** V1-013 friction signals are inferred
   (impatience, skim-approvals). Direct intent extraction is *evidence*, not
   inference. A user whose last 20 prompts read "swarm it" / "make it so" /
   "ship" is empirically in `auto` tier, not `tutorial`.

6. **Persona-mismatch detection.** If the user drives 80% from @critic but
   their cohort is mostly @owner + @systems, the team's lenses don't reflect
   the user's working lens. Storytime could flag: "you've been driving as
   @critic for weeks; consider hiring a permanent @critic specialist."

7. **Decision provenance gains a dimension.** Every V1-NNN decision currently
   records *which persona drove*. Adding "user-lens at the time" lets future-
   you read the decision log and remember not just what but *who I was* when
   I made it.

## What fits in scope (not previously named)

8. **The user IS a persona.** Implicitly. Currently anonymous, but every
   session has a user-lens that interacts with the cohort. v1.x could
   promote this: `@user` becomes a participant with an evolving codename
   and `acquired_context`, just like cohort members. Their own intent-
   extraction history becomes their `acquired_context`.

9. **Intents-as-micro-decisions.** Some user prompts ARE decisions, just
   unsealed. "swarm it" is a working-style decision. "no humans" was a
   naming-policy decision. These could surface as candidate decisions in
   the thread — *"detected an implicit decision: 'commits as natural
   milestones for parallel work'. Promote to V1-NNN?"*

10. **Conversation-as-artifact, partial capture.** Storytime captures
    decisions and phase outputs but loses the conversation that produced
    them. Intent extraction is a way to keep a thin shadow of the conversation
    without storing the whole transcript — the *intent backbone* of the
    discussion survives even when the prose doesn't.

11. **Cross-session intent threading.** "You said in session X two months
    ago that you wanted Y." Hard to surface today. With an intent ledger
    per repo, this becomes a query: `decisions-view.sh --user-intents
    --since=2026-01`. Useful for retros and for catching unfinished business.

12. **Skill telemetry from intent gaps.** Recurring user intents that DON'T
    have a skill behind them are signal. "swarm it" implies dispatch
    confidence — could become `/storytime-swarm`. "show me what's NOT chosen"
    implies option-visibility preference — could become a default in
    post-breakout pause output.

13. **Lens-aware automation.** Tutorial mode could specialize: a user driving
    heavily from @owner needs different scaffolding than one driving from
    @platform. Tutorial-plus annotations could match the user's lens —
    explain to an @owner in architectural terms, to an @operator in
    reliability terms.

14. **The "absent voice" warning.** Every session, log which lenses the user
    *didn't* operate from. After N sessions where @skeptic is absent, surface:
    "@skeptic hasn't fired in your driving lens for 3 weeks. Consider whether
    something is being underchallenged." This is the most useful version of
    "team blind spots" detection.

## Risks

- **Surveillance feel.** Even local, "the system reads how you talk" can feel
  weird. Has to be opt-in, viewable, deletable.
- **Misclassification.** Intent labels are fuzzy. Single misread that says
  "you don't operate from @critic" when you do is corrosive to trust.
  Confidence values, easy correction, soft surfacing.
- **Self-fulfilling categorization.** If the system tells you "you're an
  @owner," you lean into it and atrophy other muscles. Worse if it auto-tunes
  the cohort to mirror you — your blind spots get amplified, not covered.
- **Privacy across collaborators.** If a repo has multiple users, whose
  intent counts? Per-user files? Aggregate? Nuance.

## Concrete proposal (small, v1.1+ candidate)

- **`.storytime/intents.md`** — append-only log per repo. Each user prompt →
  one or two short intent statements + lens labels. Entirely local.
- **`scripts/intents-view.sh`** — same shape as `decisions-view.sh`. Query
  lens distribution, filter by date, by topic, by type.
- **Surface in `/storytime-status`** — show lens distribution under "your
  driving lens" subsection. Surface absent voices.
- **Feed into remembrance** — the wakeup note gains a "you were operating
  mostly from @owner this session" line.
- **Feed into tutorial graduation** — direct intent evidence overrides
  inferred friction signals.

## Load-bearing reframe

The most valuable insight from this analysis: **the user-as-persona** (item
#8). If `@user` is a first-class lens with `acquired_context`, items 4, 6,
7, 9, 10, 13, 14 all fall out naturally. That is the load-bearing reframe
— not "track intents" but "the user has a lens too, and storytime should
know it."

## Companion documents

- `intent-extraction-roles.md` — same analysis applied to role-driven
  intents in storytime documents (cross-reference)
- `intent-visualization.md` — visualization sketches for adherence and
  active-attention window
