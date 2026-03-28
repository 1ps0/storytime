# Storytime Backlog

Enhancement ideas, organized by theme. Items move to the top of
their section as they become more urgent or well-defined.

---

## Workflow Enhancements

- **Branching narratives.** When the team reaches a fork (two viable
  approaches), run both as parallel breakouts and present a
  side-by-side comparison slide.

- **Conflict resolution protocol.** When two personas disagree and
  neither yields, escalate to the user with a structured "here's
  what A thinks, here's what B thinks, here's what's at stake."

- **Warm-start sessions.** When revisiting a topic, auto-generate
  the "Previously on..." section from the decision log and last
  session summary. Skip SURVEY if the codebase hasn't changed.

- **Progressive detail.** Let the user set a depth level (sketch /
  standard / deep). Sketch produces team + 1-page plan. Deep
  produces full breakouts with prototypes and benchmarks.

- **Checkpoint saves.** At each phase transition, save a snapshot
  so the session can be resumed if interrupted. Currently a
  long session is all-or-nothing.

## Persona System

- **Persona performance tracking.** Track which personas' predictions
  came true vs which were wrong. Over time, calibrate how much
  weight to give each persona's opinions on different topics.

- **Persona templates by domain.** Pre-built persona definitions
  for common domains: frontend, backend, mobile, data, security,
  devops, ML. User picks from menu instead of defining from scratch.

- **Persona inheritance.** A "senior backend" persona inherits from
  a "backend" template but adds seniority-specific traits (skepticism
  about rewrites, preference for incremental changes).

- **Persona voices in commit messages.** When committing code that
  resulted from a Storytime session, optionally include which
  personas contributed to the decision in the commit message body.
  Creates a traceable link from git history to the narrative.

- **Persona disagreement log.** Track cases where a persona was
  overruled. Useful for retrospectives: "Raj warned about X and
  we ignored it — turns out Raj was right."

## Integration

- **GitHub PR integration.** When a Storytime plan leads to a PR,
  auto-link the PR description to the spec directory. Include a
  summary of the decisions that drove the implementation.

- **CI citation validation.** Run `validate-citations.sh` as a
  CI check. Fail the build (or warn) when Storytime documents
  reference code that no longer exists.

- **Slack/Discord notifications.** Post a summary to a channel
  when a Storytime session completes. Useful for team visibility
  when the permanent cohort represents real team members.

- **Decision search.** A tool or skill that searches across all
  decision logs for a keyword. "What did we decide about caching?"
  → returns all decisions mentioning caching with links.

- **Export formats.** Export plan.md as: PDF (via pandoc), Confluence
  page, Notion page, GitHub wiki page. ASCII art survives all of
  these.

## Multi-Repo / Distribution

- **Plugin registry.** Publish storytime to a Claude Code plugin
  marketplace or GitHub releases so other projects can install it
  without cloning the repo.

- **Shared cohort across repos.** A "meta-cohort" that lives outside
  any single repo (e.g., in `~/.storytime/cohort/`) and represents
  org-level expertise. Project-level cohorts override or extend.

- **Org-level decision graph.** Aggregate decisions across repos
  into a single graph. "Show me all security-related decisions
  across all projects." Requires a lightweight indexing service
  or a local aggregation script.

- **Template marketplace.** Share persona templates, workflow
  configurations, and visual aid styles across teams. "Install the
  security-review template" → gets a pre-built team for security
  audits.

## Output Quality

- **Smarter visual aids.** Detect when a table would be better than
  a diagram, or when a flow chart would be better than a list.
  Currently all visual decisions are implicit.

- **Citation density scoring.** Rate each document section by how
  well-cited it is. Flag sections that make claims without evidence.

- **Reading time estimates.** Add "~5 min read" to document headers
  based on word count and visual aid density.

- **Diff-friendly output.** Structure documents so that git diffs
  are meaningful. Avoid long lines that create noisy diffs when
  one word changes.

## Developer Experience

- **`/storytime status`** — Show current state: active cohort,
  recent sessions, pending specialist contracts, stale citations.

- **`/storytime diff <topic>`** — Show what changed between the
  original plan and the current code. Like a continuous retro.

- **`/storytime replay <session>`** — Re-read a past session and
  summarize the key decisions and rationale. Quick refresher.

- **Onboarding mode.** New team member reads through Storytime
  narratives to understand why the codebase is shaped the way it
  is. Better than reading code comments alone.

- **Interactive mode improvements.** Let the user "rewind" a
  conversation to a specific beat and re-run from there with
  different constraints. "What if we HAD included FreeSWITCH?"

## Experimental

- **Real-person mapping.** Map personas to actual team members.
  Kim represents the real Kim's domain knowledge. When the real
  Kim reviews a PR, Storytime can pre-populate their likely
  concerns based on the persona's history.

- **Audio narration.** Generate a podcast-style audio version of
  the icebreaker using text-to-speech with different voices per
  persona. For teams that prefer listening over reading.

- **Live collaboration.** Multiple users in a Claude Code session
  each "inhabit" a persona and contribute their real expertise
  through that lens. Hybrid human-AI team discussion.

- **Decision impact scoring.** After implementation, measure which
  decisions had the most impact (positive or negative) on the
  outcome. Feed this back into persona calibration.
