# ADR-0017 — Evidence-discipline review section + failure-direction red flag, backported

## Status

Accepted — 2026-08-21. Implements items 1–2 of
[#53](https://github.com/pdlourenco/disciplined-project-seed/issues/53) and
absorbs [#55](https://github.com/pdlourenco/disciplined-project-seed/issues/55);
maintainer-approved disposition (conversation, 2026-08-21). Operationalised in
[`docs/REVIEW_CONTEXT.md`](../../docs/REVIEW_CONTEXT.md) §"Evidence discipline"
and a new red-flag category. #53 item 3 deferred as
[#56](https://github.com/pdlourenco/disciplined-project-seed/issues/56).

## Context

`adigator-embedded` invented a `REVIEW_CONTEXT.md` section the seed had no
counterpart for: method-level discipline about whether a measurement is a fact
or an artifact of how it was taken. Every instance behind it came from
agent-to-agent review, where reviewer and author share reasoning habits and
therefore blind spots — a failure class that coordinates nothing between
parallel contributors and survives review by construction, which is why it
matters *more* at seed scale, not less. #53 delivered the section genericised
(the adopter's body text leaked seven project-specific references; the issue
rewrote them), with instances on both sides of the review boundary.

Separately, #55 surfaced that agent-side web-fetch tools which answer a prompt
using a smaller model return that model's summary, not the page — so quotes,
figures, and citations in the output are the summarizer's, with compression
and invention as failure modes. This is *documented tool mechanism*, not an
anecdote, which changes its evidence standing. Documented at
<https://code.claude.com/docs/en/tools> §"WebFetch tool behavior", retrieved
2026-08-22 via raw fetch of the page source: the tool "runs the prompt
against the content using a small, fast model. For most fetches, Claude
receives that model's answer, not the raw page"; the same section states
"This makes WebFetch lossy by design" and recommends `curl` via Bash for the
unprocessed page.

## Decision

1. **Absorb #53 items 1–2.** `REVIEW_CONTEXT.md` gains §"Evidence discipline —
   fact, or artifact of the measurement?" in the provided-prose band (between
   §"Verification vs validation" and §"Core principles"), and a new red-flag
   category: a guard whose stated failure direction has no test that puts it
   in that state. The red flag is rendered as provided prose rather than
   #53's proposed placeholder idiom: its body is portable across adopters
   (unlike the sibling categories, which name project-specific failure
   modes), so a commented-out version would be hidden text every adopter has
   to un-hide. The instantiation note stays a comment.
2. **The tells/instances split is the load-bearing convention.** Numbered
   tells stay generic and portable; project-specific citations accumulate
   under `### Instances (this project)`. The placeholder comment states the
   rule explicitly because the originating adopter failed to hold the line
   without it.
3. **#55 lands as the *summarizing-intermediary* tell** (a summarizing
   intermediary treated as a primary source) rather than as a standalone
   convention. It is admitted without the
   seed's two-instance bar because it rests on documented tool behaviour, not
   on the unverified anecdote that prompted it — the anecdote's statistics are
   cited nowhere.
4. **#53 item 3 (record-vs-guidance) is deferred** ([#56](https://github.com/pdlourenco/disciplined-project-seed/issues/56)):
   one instance, and the seed's norm for thin signals is a two-instance bar.
   #53's two Tier-2 candidates stay recorded in that issue with their
   one-more-instance triggers.

## Consequences

- The section is the natural future home for further method-level tells;
  additions are held to the two-instance bar #53 itself argues for, so the
  list doesn't grow faster than instances earn it.
- Adopters lift the section as-is and populate `### Instances` locally; the
  split keeps upstream/downstream sync a deletion rather than a rewrite.

## Alternatives considered

- **The summarizing-intermediary tell as a clause on *unchecked tool
  state***: lighter, but that tell is about tool *state* left unchecked,
  while the fetch-tool failure is the tool's *permanent mechanism* — and
  buried as a git-flavoured example it would not be recalled at research
  time, which is author-side, before review.
- **Deferring #55 for an in-repo instance:** rejected because the rule rests
  on documented mechanism; waiting would be rigor about the wrong thing.
- **Absorbing #53 item 3 now:** cheap, but one instance; taken, it would be
  the discipline list growing faster than evidence — the failure mode the
  section warns against.
