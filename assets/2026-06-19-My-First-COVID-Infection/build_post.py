#!/usr/bin/env python3
"""Build the 'My First COVID Infection' blog post draft from captured X threads.

Re-runnable. Parses twitter/raw/*.md, keeps only @famulare_mike tweets, trims
cross-thread pointer-replies / "unrolled version" stubs / empty tweets, orders
the threads by start time (tweets within a thread in posting order), rewrites
media paths to site-absolute, asserts every referenced image exists, and writes
the Jekyll draft to _drafts/.

Run from anywhere:  uv run assets/2026-06-19-My-First-COVID-Infection/build_post.py
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

ASSET_DIRNAME = "2026-06-19-My-First-COVID-Infection"
HANDLE = "@famulare_mike"

SCRIPT = Path(__file__).resolve()
ASSET_ROOT = SCRIPT.parent
REPO_ROOT = ASSET_ROOT.parent.parent
RAW_DIR = ASSET_ROOT / "twitter" / "raw"
MEDIA_DIR = ASSET_ROOT / "twitter" / "media"
OUT_PATH = REPO_ROOT / "_drafts" / f"{ASSET_DIRNAME}.md"
MEDIA_URL_BASE = f"/assets/{ASSET_DIRNAME}/twitter/media"

# Cross-thread pointer-replies that re-announce other threads (see plan).
# "Unrolled version" stubs and the empty tweet are dropped by pattern below.
DROP_IDS = {
    "1893371676470948207",  # "Round 2: it's airborne! [link]"  -> dup of thread #3 head
    "1894125749160051119",  # "Brief interlude ... Far UV-C [link]" -> dup of thread #4 head
    "1894834624272179463",  # "review these nearly odorless candles [link]"
    "1895617567722729601",  # "New COVID personal science thread [link]" -> dup of thread #5 head
    "1895617673398260101",  # "Next thread: relative infectiousness [link]" -> dup of thread #6 head
}
UNROLLED_STUB = "You can read the unrolled version of this thread here:"

BLOCK_RE = re.compile(r"^## (?:Top-level tweet|Reply): (\d+)\s*$")
IMG_RE = re.compile(r"!\[Image\]\(\.\./media/(.+?)\)\s*$")

FRONTMATTER = f"""---
layout: post
title: My First COVID Infection (personal science, reposted from Twitter)
tags: repost COVID-19 personal-science aerosols masks viral-load rapid-tests paxlovid
---"""

INTRO = (
    "<!-- PLACEHOLDER INTRO — rewrite in your own voice -->\n"
    "From time to time I repost old Twitter/X threads here for posterity. In "
    "February 2025 I caught COVID for the first time and, feeling well enough to "
    "be curious, ran a series of at-home experiments on my own viral load and "
    "infectiousness: cutting up N-95s into rapid tests, capturing exhaled virus "
    "in a HEPA filter overnight, and turning rapid-test photos into "
    "semi-quantitative viral-load curves. I posted them as a handful of threads "
    "over about nine days. They're collected below in the order I posted them, "
    "lightly trimmed — other people's replies and the cross-thread “next "
    "thread →” pointers are removed; everything I wrote is verbatim."
)

FOOTER = (
    "___\n\n"
    "For attribution, please cite this work as:\n\n"
    "`Famulare (2026, Jun 19). My First COVID Infection. Retrieved from "
    "https://famulare.github.io/2026/06/19/My-First-COVID-Infection.html.`"
)


@dataclass
class Tweet:
    id: str
    author: str
    time_s: str
    text: str
    media: list[str] = field(default_factory=list)

    @property
    def dt(self) -> datetime:
        return datetime.fromisoformat(self.time_s.replace("Z", "+00:00"))


def parse_file(path: Path) -> list[Tweet]:
    lines = path.read_text(encoding="utf-8").splitlines()
    tweets: list[Tweet] = []
    i, n = 0, len(lines)
    while i < n:
        m = BLOCK_RE.match(lines[i])
        if not m:
            i += 1
            continue
        tid = m.group(1)
        i += 1
        while i < n and lines[i].strip() == "":   # blank line before metadata
            i += 1
        author = time_s = ""
        while i < n and lines[i].startswith("- "):
            line = lines[i]
            if line.startswith("- Author:"):
                author = line[len("- Author:"):].strip()
            elif line.startswith("- Time:"):
                time_s = line[len("- Time:"):].strip()
            i += 1
        body: list[str] = []
        media: list[str] = []
        in_media = False
        while i < n and not BLOCK_RE.match(lines[i]):
            stripped = lines[i].strip()
            if stripped == "---":          # block separator
                i += 1
                continue
            if stripped == "Media:":
                in_media = True
                i += 1
                continue
            if in_media:
                im = IMG_RE.match(stripped)
                if im:
                    media.append(im.group(1))
                i += 1
                continue
            body.append(lines[i])
            i += 1
        tweets.append(Tweet(tid, author, time_s, "\n".join(body).strip(), media))
    return tweets


def keep(t: Tweet) -> bool:
    if HANDLE not in t.author:
        return False
    if t.id in DROP_IDS:
        return False
    if t.text.startswith(UNROLLED_STUB):
        return False
    if t.text == "" or t.text.strip().lower() == "[no text]":
        return False
    return True


def render_tweet(t: Tweet) -> str:
    block = f"<!-- {t.id} · {t.time_s} -->\n\n{t.text}"
    for fn in t.media:
        assert (MEDIA_DIR / fn).exists(), f"missing media file: {fn}"
        block += f"\n\n![Image]({MEDIA_URL_BASE}/{fn})"
    return block


def main() -> None:
    threads = []  # (head_dt, head_id, source_url, [kept tweets])
    for path in sorted(RAW_DIR.glob("*.md")):
        tweets = parse_file(path)
        head = tweets[0]
        kept = [t for t in tweets if keep(t)]
        source_url = f"https://x.com/famulare_mike/status/{head.id}"
        threads.append((head.dt, head.id, source_url, kept, len(tweets)))
    threads.sort(key=lambda x: x[0])

    sections, total_kept = [], 0
    print(f"{'thread':>20}  kept / total  dropped ids")
    for head_dt, head_id, source_url, kept, total in threads:
        total_kept += len(kept)
        dropped = total - len(kept)
        print(f"{head_id:>20}  {len(kept):>4} / {total:<4}  -{dropped}")
        date = head_dt.strftime("%B %-d, %Y")
        header = f"<!-- thread {head_id} · {source_url} -->\n*Posted {date}.*"
        body = "\n\n".join(render_tweet(t) for t in kept)
        sections.append(f"{header}\n\n{body}")

    body = "\n\n".join(f"---\n\n{s}" for s in sections)
    doc = f"{FRONTMATTER}\n\n{INTRO}\n\n{body}\n\n{FOOTER}\n"

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(doc, encoding="utf-8")
    n_media = sum(len(t.media) for _, _, _, kept, _ in threads for t in kept)
    print(f"\nwrote {OUT_PATH.relative_to(REPO_ROOT)}")
    print(f"  {len(sections)} threads, {total_kept} tweets, {n_media} images")


if __name__ == "__main__":
    main()
