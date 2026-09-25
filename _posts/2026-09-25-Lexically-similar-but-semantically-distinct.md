---
layout: post
title: Lexically similar but semantically distinct
tags: ai musings
---

Inspired by [this thread from Anshul Kundaje](https://x.com/anshulkundaje/status/2103547258402979924), I want to store here for eternity [my brief rant](https://x.com/famulare_mike/status/2103576973243232367) about one of the most important reasons deep scientific reasoning is especially difficult for LLMs. Enjoy!

“Lexically similar but semantically distinct.” This is the core challenge of LLMs for science. LLM intelligence derives from correlations between lexicon and semantics. The more overloaded the terminology in your field, the more LLMs randomly walk away from your intended meaning.

This shows up in my field, epidemiological modeling, across the many subtly different concepts of “immunity” or “R-naught” that change the precise meaning of very similar wordings, distinguished only by sparse long-distance correlations across a corpus.

These are the hardest problems for LLMs to maintain coherence across by virtue of the architecture and the sparsity of the statistical signal. LLMs have gotten better at this and will likely continue to do so, but it is the hardest problem.

Standard software and math specifically do not have this problem because of how software languages are defined and math is formalized. There is much less non-equivalent semantic diversity for similar lexical choices by construction. And so they are much easier for LLMs.

Would other fields benefit from tighter lexical ↔ semantic mappings? Almost certainly. And I suspect the AI-rich scientific future will give us this cheaply as the agents invent it for themselves. But we’re not there yet for most fields and so LLMs underperform.

___

For attribution, please cite this work as:

`Famulare (2026, Sep 25). Lexically similar but semantically distinct. Retrieved from https://famulare.github.io/2026/09/25/Lexically-similar-but-semantically-distinct.html.`
