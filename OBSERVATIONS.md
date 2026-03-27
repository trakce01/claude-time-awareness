# Observations

What we're seeing as we test time awareness in real sessions.

## Time awareness ≠ time-shaped behavior (2026-03-26)

Claude can see the clock and announce it. Initially, seeing time didn't change how it worked. It still explored broadly, drafted multiple options, asked open questions with minutes left. The data alone wasn't enough.

To address this, added a CLAUDE.md guideline framing time as context that shapes decisions, not just a number to announce.

**Update (2026-03-27):** Within active budgets, behavior is improving. Claude now makes scoping calls based on time ("7 min left, let's flag these instead of investigating"). The gap has shifted: within a budget, behavior is improving. But Claude doesn't always catch natural time cues to start a budget in the first place.

## Budget activation from natural language is inconsistent (2026-03-27)

Claude catches some time cues ("I have 2 hours") but misses others ("we only have 10mins for this", "have a meeting in 10mins"). The mechanism works once active. The detection is the weak link.
