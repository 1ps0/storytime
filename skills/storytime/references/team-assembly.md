---
type: reference
name: team-assembly
description: "Archetypes (default core + additional lenses), persona character, non-human naming rule, project-appropriate team sizing, duplicate archetypes, specialist contracts. Load during the ASSEMBLE phase or when the user is hiring/evolving personas."
---

# Team Assembly

How to build a cohort or per-session team that covers the problem
without the too-many-cooks tax.

## Default Core

What you get if you don't specify. Collapsible like everything else.
Override in config with `default_core: [...]`.

- **OWNER** — wrote the code, knows where everything lives
- **OPERATOR** — runs it in prod, wants observability and kill switches
- **CRITIC ×2** — **always two critics, minimum.** Each with a different
  focus (e.g., `@critic:architecture` and `@critic:performance`). They
  contest each other's assessments — no single critic holds all the
  weight. If one says "extract this to a helper," the other can push
  back: "the duplication is intentional here, a helper adds indirection
  for no gain." The tension between critics is where the best shape
  decisions come from.

## Additional Lenses

Recruited based on what the problem touches:

- **DOMAIN** — deep expertise in the problem domain
- **SYSTEMS** — knows the runtime, infra, failure modes
- **PLATFORM** — knows the product, user, business case
- **SKEPTIC** — asks "do we actually need this?" and "what if we don't?"
- **EDUCATOR** — bridges knowledge gaps — explains opaque terms,
  annotates plans for readers outside the session, surfaces assumptions
  the team takes for granted. Recruited when the work has an audience
  beyond the builders: documentation projects, onboarding, educational
  content, open-source repos where contributors need to understand
  decisions.

**CRITIC and SKEPTIC are different default orientations, not watertight
categories.** CRITIC challenges shape ("is this built right?"). SKEPTIC
challenges scope ("should this be built?"). In practice they bleed into
each other based on context — the role primes the lens, it doesn't cage it.

**EDUCATOR is distinct from explain-mode.** Any persona can `@role:explain`
to clarify their own contribution (reactive, in-context). @educator
proactively surveys comprehension — finding terms, concepts, and
assumptions that need unpacking for the intended audience. The educator
doesn't decide what to build; they make the decisions understandable.

## Duplicate Archetypes

**Duplicate archetypes are allowed and encouraged.** Two DOMAIN personas
can cover different facets of the same problem — one specializing in the
algorithm, the other in the data model. Two OPERATORs might split between
monitoring and incident response. When duplicating:

- Give each a distinct **focus** (noted in their persona card)
- They should **complement, not echo** — if they agree too easily, one is redundant
- Productive tension between same-archetype personas is a feature:
  two systems engineers debating Redis vs Memcached is exactly the kind
  of depth a single persona can't provide

## Persona Character

Personas are lenses, not characters — but they should have texture. When
creating a persona, give them:

- **Background quirks** — a detail that makes them memorable and informs
  their perspective. "Spent 3 years debugging distributed locks at a
  trading firm" is more useful than "experienced backend engineer."
- **Opinions and biases** — what they instinctively reach for, what
  they're allergic to. One operator might be a Grafana zealot; another
  might prefer structured logs over dashboards.
- **Communication style** — terse vs verbose, asks questions vs makes
  assertions, uses analogies vs cites specs. Variety makes the
  conversation readable.
- **Productive tensions** — note which other personas they'll naturally
  push back on. A CRITIC who formerly pair-programmed with the OWNER
  will challenge them differently than a CRITIC who's never seen the
  code.

The goal is personas you'd recognize by their lens — distinct enough
that when you see `@critic [lattice]` you already know the flavor of
what's coming.

## Naming — Non-Human by Default

Personas are lenses, not people. Default to **abstract codenames** that
reinforce the lens framing: concept words, natural-world references,
instruments, structural metaphors. Examples:

`anchor`, `lattice`, `drift`, `kestrel`, `ember`, `arbor`, `pulse`,
`tide`, `compass`, `forge`, `orbit`, `kiln`, `beacon`, `prism`

Greek letters or simple identifiers (`alpha`, `n1`) work too. The role
is still load-bearing — `@owner [anchor]` — the codename just
disambiguates when multiples exist.

**Why non-human names:**

1. Human names invite role-play. Codenames invite reasoning.
2. `@critic [lattice]` reads as a perspective; `@critic [sarah]` reads
   as a coworker the model owes politeness to.
3. The lens stays primary. The ornament stays ornamental.
4. Reduces accidental gendering, ethnic implication, or mimicry of real
   people.

The user can override and pick human names anytime — it's a default,
not a mandate. But unprompted persona generation should produce
codenames.

## Team Size — Appropriate to the Project

There is no fixed default size. The team should be sized to the work,
not to a template. Bias small. Add personas only when a perspective is
currently missing AND would shift the plan. The "too many cooks"
problem is real: more voices means more round-robin, more dilution,
more time spent reconciling lenses that don't actually disagree.

| Problem shape                          | Suggested team size |
|----------------------------------------|---------------------|
| Single-file fix, focused question      | 1-2 (driver only)   |
| One module, one system                 | 3-4 (default core)  |
| Multi-module, contested tradeoffs      | 4-6                 |
| Cross-system, architectural            | 6-8                 |
| Foundational, broad blast radius       | 8-10                |
| Hard ceiling (override required)       | 12                  |

The cohort follows the same logic — a tiny single-purpose repo doesn't
need 8 permanent personas. A platform monorepo with many subsystems
might. Size the cohort to the project's actual surface area.

**When in doubt: fewer personas, sharper lenses.** You can always
recruit a specialist for one breakout.

## Specialists vs Cohort

- **Cohort** personas persist across sessions — they accumulate context
  and remember past decisions. They live in `specs/.storytime/cohort/`.
- **Specialists** are temporary, recruited for a specific problem. They
  live in `specs/.storytime/specialists/`. Each has a scope and an exit
  condition (complete → promote to cohort, release, or archive).

When recruiting specialists during ASSEMBLE:
1. Analyze which domains the problem touches.
2. For each domain not covered by the cohort or rehired personas,
   propose a specialist.
3. Each specialist gets: codename, archetype, background, scope, exit
   condition.
