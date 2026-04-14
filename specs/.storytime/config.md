---
type: config
created: 2026-03-29T16:00
updated: 2026-04-14T12:00
schema_version: 1
---

# core
mode: native
default_mode: inline
automation: tutorial              # tutorial | manual | guided | auto (v1.0)
team_size: project-appropriate    # bias small; sized to the work
max_team_size: 12                 # hard ceiling, override required
max_concurrent_breakouts: 10
default_core: [owner, operator, critic]
naming: codename                  # non-human by default
driving_persona: required         # one driver per leg
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"
auto_update_personas: true

# v1.0 consolidation
pause_mode: model-introspection   # model-introspection (default) | threshold
dreams_enabled: false             # V1-004 off by default
post_commit_hook: disabled        # V1-028 opt-in
remembrance_load_on_compact: true # V1-029 post-/compact first action
commit_learning: enabled          # V1-014 adaptive quieter prompts
tutorial_graduation: adaptive     # V1-013 per-skill friction detection
