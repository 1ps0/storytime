---
type: config
created: 2026-03-29T16:00
---

mode: native
default_mode: inline
automation: guided
team_size: project-appropriate   # bias small; sized to the work
max_team_size: 12                # hard ceiling, override required
max_concurrent_breakouts: 10
default_core: [owner, operator, critic]
naming: codename                 # non-human by default
driving_persona: required        # one driver per leg
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"
auto_update_personas: true
