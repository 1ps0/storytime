# Storytime Primer

## What It Is

Storytime is a Claude Code plugin that turns "figure out what to build"
into a structured process. Instead of you writing a spec alone, you
describe a problem and storytime assembles a team of domain-expert
personas who discuss it, investigate the code, debate tradeoffs, and
produce a plan — all grounded in your actual codebase.

The output isn't a wish list. It's a plan with:
- Code citations (`file:line`) for every technical claim
- ASCII diagrams and slide decks
- Numbered decisions with rationale
- Non-goals (why we're NOT doing X)
- Measurable success criteria
- Effort estimates (CIU + Scale, never time)

## Why It Exists

Writing specs is one of those things everyone knows they should do and
nobody wants to. The usual failure modes:

1. **Skip the spec.** Jump into code. Realize three days in that the
   approach doesn't work. Start over.
2. **Write a thin spec.** A page of bullet points that doesn't address
   the hard questions. Ship it and discover the hard questions in prod.
3. **Write a fat spec.** A 20-page doc that nobody reads. The code
   diverges from it by day two.

Storytime addresses these by making the spec process interactive,
code-grounded, and fast. A session takes 5-15 minutes and produces
a plan that's actually anchored to the codebase.

## The Core Idea

**Personas are domain-expert lenses, not characters.** When storytime
creates "Kim the architect" or "Leo the SRE," they're not role-playing.
They're structured perspectives that ensure the plan considers:

- Who owns this code? (OWNER)
- What happens when it breaks at 3am? (OPERATOR)
- What's the domain expertise required? (DOMAIN)
- What are the system constraints? (SYSTEMS)
- Do we actually need this? (SKEPTIC)

Each persona reads your code, cites specific files and lines, and argues
from evidence. If two personas disagree, that's signal — the plan needs
to address the tension.

## How It Works

```
You: /storytime "quiet callers aren't getting picked up by speech recognition"

Storytime:
  1. Surveys your codebase (what exists, what's relevant)
  2. Assembles a team (3-7 personas covering the problem's domains)
  3. Runs an icebreaker (team discusses the status quo, grounded in code)
  4. Executes breakouts (parallel deep dives on sub-problems)
  5. Converges on a plan (ASCII slides, decisions, roadmap)
  6. Presents for review (you challenge, they defend or revise)
```

The team persists. Next time you run storytime in the same repo, the
personas remember what they decided before. They evolve as the codebase
evolves. Decisions accumulate in an append-only log.

## Episodes and Warm Start

Sessions are episodes of an ongoing story. When you revisit a topic,
storytime synthesizes a "previously on..." narrative from the living
state of documents, persona histories, and git history. You get a card
like:

```
╔═══════════════════════════════════════════════════╗
║  Previously on AGC                                ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║  Kim noticed quiet callers vanishing in Nova      ║
║  Sonic's input. Dana traced it through            ║
║  ForkToWebSocket. Raj spec'd DSP math at          ║
║  -40/-20 dBFS with a scratch buffer for zero      ║
║  allocs. Leo got his kill switch and per-call      ║
║  stats. 309ns/frame against a 1ms budget.         ║
║                                                   ║
╠═══════════════════════════════════════════════════╣
║  Team: Kim, Dana, Leo                             ║
║  Episodes: 1 (last: 2026-03-24)                   ║
║  Decisions: AGC-001 through AGC-006               ║
║  Codebase drift: 4 commits, 2 in pkg/enhance/    ║
╠═══════════════════════════════════════════════════╣
║  Continue · Retro · New sub-topic · Reset         ║
╚═══════════════════════════════════════════════════╝
```

You're caught up in 10 seconds. Pick a direction and go.

## What Makes It Different

**vs writing specs by hand:** Storytime is interactive. The team asks
questions you wouldn't have thought of. An OPERATOR asks "what's the
kill switch?" before you write a line of code.

**vs ADRs:** ADRs document decisions after the fact. Storytime generates
decisions as part of the design process, with code citations and persona
rationale built in.

**vs Kiro/Speckit:** Those tools focus on project management formatting.
Storytime focuses on the conversation that produces the spec — the
investigation, debate, and evidence gathering.

**vs just asking Claude:** Storytime structures the conversation through
domain-specific lenses. Instead of one voice, you get 3-7 perspectives
that ground claims in code and challenge each other. The output is
persistent, traceable, and builds on itself across sessions.

## The Lore Engine

Over time, storytime builds a living narrative for your codebase. Decision
logs, persona evolution, session histories, and episode threads accumulate
into a body of lore that tells the story of why your code is shaped the
way it is. New team members can read it. Future sessions reference it.
The code tells you what exists — storytime tells you why.

## When To Use It

- **New feature design** — "we need caching for the API layer"
- **Architecture decisions** — "should we split this service?"
- **Bug investigation** — "quiet speakers aren't getting recognized"
- **Refactoring planning** — "this module needs to be cleaned up"
- **Onboarding context** — "how did this system get to its current state?"
- **Post-implementation review** — "did the plan match what we built?"

## When Not To Use It

- Quick bug fixes that don't need a plan
- Purely mechanical changes (rename, reformat, dependency update)
- When you already know exactly what to build and just need to type it
