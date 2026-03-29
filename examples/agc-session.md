---
type: example
created: 2026-03-28T02:04
session: 2026-03-24-agc
---

# Example: AGC for VoIP Gateway

This is a real Storytime session run against the ai-sip-gateway
project on 2026-03-24. It demonstrates the full workflow from
problem statement through implemented code.

---

## The Problem

> "Quiet speakers on incoming SIP calls are not being picked up
> well by Amazon Nova Sonic."

## Team Assembled

| Persona | Archetype | Source     | Role                          |
|---------|-----------|------------|-------------------------------|
| Kim     | owner     | cohort     | Integration lead              |
| Dana    | systems   | cohort     | SIP/RTP boundary              |
| Leo     | operator  | cohort     | Observability                 |
| Raj     | domain    | specialist | Audio DSP algorithm design    |
| Mira    | platform  | specialist | ASR/ML acceptance criteria    |

## Key Moments

### Icebreaker: Dana grounds the discussion
> "The audio arrives as G.711 μ-law at 8 kHz. The diago PCM decoder
> gives us linear 16-bit PCM. That PCM goes straight to the WebSocket
> with zero processing."
> [cited: cmd/v1/main.go:391, :459]

### Icebreaker: Mira defines "good enough"
> "I want to see: a quiet speaker at -45 dBFS arrives at Nova Sonic
> at -20 dBFS. That's it."

### Breakout: Kim identifies zero-alloc path
> ProcessBytes allocates []float64 per frame. Fixed by reusing a
> scratch buffer on the struct (mutex already held).
> Result: 309ns/frame, 0 allocs/op.

### Convergence: Leo's "measure always" insight
> "Even if enhancement is disabled, we should still measure RMS.
> The telemetry alone is worth shipping."
> → Led to AGC-006: measure-only mode.

## Decisions Made

- **AGC-001:** -40/-20 dBFS thresholds
- **AGC-002:** ENHANCE_AUDIO env var kill switch
- **AGC-003:** Scratch buffer reuse
- **AGC-004:** SIP→Nova path only
- **AGC-005:** Per-call stats in call-end log
- **AGC-006:** Measure-only mode

## Code Delivered

```
pkg/enhance/enhance.go       ~250 lines   promoted from research/
pkg/enhance/enhance_test.go  ~200 lines   7 tests + 1 benchmark
pkg/config/config.go         +5 lines     ENHANCE_AUDIO env var
cmd/v1/main.go               +15 lines    enhancer creation + integration
```

## Specialist Disposition

- **Raj (DSP):** Contract complete. Eligible for promotion.
- **Mira (ASR/ML):** Contract complete. Eligible for promotion.

## What Made This Work

1. **Icebreaker prevented premature solutioning.** The team spent a
   full round establishing what exists before proposing changes.
2. **Non-goals prevented scope creep.** Raj explicitly listed what
   a "proper" AGC would include, then the team agreed to skip it.
3. **Leo's presence meant observability was first-class.** Without
   an operator persona, metrics would have been an afterthought.
4. **Code citations kept the conversation grounded.** Every claim
   about the codebase was verified against actual line numbers.
