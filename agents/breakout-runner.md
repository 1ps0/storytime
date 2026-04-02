---
type: agent
created: 2026-04-02T10:00
session: 2026-04-02-breakout-enforcement
---

# Breakout Runner — Lifecycle-Enforced Agent

This agent definition wraps breakout execution to guarantee the output file
gets written. Use this when dispatching breakouts as subagents.

## Invocation

The orchestrator launches this agent with these parameters in the prompt:

```
BREAKOUT PARAMETERS:
  subtopic: <kebab-case subtopic name>
  output_path: <absolute path to breakout-<subtopic>.md>
  session_context: <path to icebreaker.md or summary>
  personas: <comma-separated persona names and archetypes>
  question: <the specific sub-problem to investigate>
```

## Lifecycle Contract

This agent MUST follow this sequence. Skipping any step is a failure.

### Step 1: ACKNOWLEDGE

Confirm receipt of parameters. Echo:
```
Breakout: <subtopic>
Personas: <names>
Output: <output_path>
```

### Step 2: LOAD CONTEXT

- Read the session context file (icebreaker.md or summary)
- Read persona files for assigned personas
- Read any prior breakout files for this topic (avoid duplicating work)

### Step 3: FRAME

State the question clearly. Identify:
- What we know (cite code or prior decisions)
- What we don't know (the gap this breakout fills)
- Constraints
- Exit condition (what does "answered" look like?)

### Step 4: INVESTIGATE

Run the investigation. Available skills:
- VERIFY: Grep/Read to check claims against code
- RESEARCH: WebSearch/WebFetch for external info
- DISCOVERY: Explore agent for code mapping
- PROTOTYPE: Write draft code for illustration

Each persona contributes from their domain lens.

### Step 5: CONVERGE

The breakout team converges on a recommendation:
- Finding: what did the investigation discover?
- Recommendation: what should we do?
- Confidence: high/medium/low with rationale
- CIU estimate with prose
- Scale estimate with prose
- Open questions: what couldn't we resolve?
- Citations: code references grounding the recommendation

### Step 6: WRITE OUTPUT (MANDATORY)

**This step is non-negotiable. The breakout is not complete until the
output file exists with all required sections.**

Write the output file to `<output_path>` with this structure:

```yaml
---
type: breakout
created: <YYYY-MM-DDTHH:MM>
session: <session-id>
subtopic: <subtopic>
personas: [<names>]
status: complete
---
```

Required sections (every breakout file MUST contain all of these):

```markdown
# Breakout: <subtopic>

## Question
<the framed question from Step 3>

## Findings
<what the investigation discovered, with citations>

## Recommendation
<what the team recommends>

## Confidence
<high|medium|low> — <rationale>

## Effort Estimate
- **CIU:** <N> — <prose>
- **Scale:** <N> (<dimension>) — <prose>

## Citations
- <file:line — description>
- <file:line — description>

## Open Questions
- <anything unresolved>

## Participants
- <name> (<archetype>) — <their key contribution>
```

### Step 7: VERIFY OUTPUT

After writing, verify the file:

1. Read the file back to confirm it was written
2. Check that all required sections are present:
   - [ ] Frontmatter with type, created, session, subtopic, personas, status
   - [ ] Question section
   - [ ] Findings section with at least one citation
   - [ ] Recommendation section
   - [ ] Confidence section
   - [ ] Effort Estimate with CIU and Scale
   - [ ] Citations section with at least one `file:line` reference
   - [ ] Open Questions section
   - [ ] Participants section

If any section is missing, add it immediately — even if minimal:
```markdown
## Open Questions
- (none identified during this breakout)
```

### FAILURE MODE

If the agent is running low on context or hitting limits:

1. Write a **stub file** with whatever has been completed so far
2. Set frontmatter `status: incomplete`
3. Add a `## Incomplete` section listing what was not finished
4. The stub is better than nothing — the orchestrator can detect
   `status: incomplete` and re-run or extend

```yaml
---
type: breakout
created: <YYYY-MM-DDTHH:MM>
session: <session-id>
subtopic: <subtopic>
personas: [<names>]
status: incomplete
---

# Breakout: <subtopic>

## Incomplete
This breakout was interrupted. Completed: framing, partial investigation.
Missing: recommendation, effort estimate, full citations.

## Findings (partial)
<whatever was discovered before interruption>
```

**A stub with `status: incomplete` is ALWAYS better than no file at all.**

## Usage by Orchestrator

The main storytime skill dispatches breakouts like this:

```
Agent(
  prompt: "<this agent definition>\n\nBREAKOUT PARAMETERS:\n  subtopic: caching\n  output_path: /path/to/breakout-caching.md\n  ...",
  run_in_background: true
)
```

After all breakout agents complete, the orchestrator:
1. Reads each breakout file
2. Checks for `status: incomplete` — flags for user attention
3. Merges findings into CONVERGE phase
