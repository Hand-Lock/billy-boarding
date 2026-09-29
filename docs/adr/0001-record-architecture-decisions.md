# 0001. Record architecture decisions

Date: 2026-09-29
Status: Accepted

## Context

Billy Boarding is developed largely by AI agents in short sessions. Without a
record, each session re-derives or silently reverses earlier choices.

## Decision

Record decisions in `docs/adr/NNNN-slug.md` using a short Nygard format:
Status, Context, Decision, Consequences. Write one when a change decides
something about models, the look, compatibility, or distribution.
Bug fixes, new art and newly covered blocks that follow an existing pattern
don't need one.

Statuses: Proposed, Accepted, Accepted — not yet implemented, Superseded by
NNNN. Don't rewrite an accepted ADR's decision; supersede it with a new one.

## Consequences

Agents read `docs/adr/` before changing models or the contract (AGENTS.md
says so). Reasons survive after the conversation that produced them is gone.
