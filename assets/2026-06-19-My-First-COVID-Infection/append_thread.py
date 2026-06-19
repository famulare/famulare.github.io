#!/usr/bin/env python3
"""Append ONE captured X thread as a new section to the working blog draft.

Unlike the original (deleted) full-doc generator, this only *appends* a
formatted section just before the citation footer of the working .md. It never
rewrites existing, hand-edited content, so it is safe to run against the draft
as it evolves. Verbatim tweet text comes straight from the raw capture; the
thread-specific polish (cross-ref wording, link fixes, typos) is done by hand
afterward.

Usage:
  uv run .../append_thread.py <raw_thread.md> "<Section Heading>"
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

ASSET_DIRNAME = "2026-06-19-My-First-COVID-Infection"
HANDLE = "@famulare_mike"

SCRIPT = Path(__file__).resolve()
ASSET_ROOT = SCRIPT.parent
WORKING = ASSET_ROOT / "twitter" / "working" / f"{ASSET_DIRNAME}.md"
MEDIA_DIR = ASSET_ROOT / "twitter" / "media"
MEDIA_URL_BASE = "../media"
FOOTER_MARKER = "\n___\n"

UNROLLED_STUB = "You can read the unrolled version of this thread here:"
BLOCK_RE = re.compile(r"^## (?:Top-level tweet|Reply): (\d+)\s*$")
IMG_RE = re.compile(r"!\[Image\]\(\.\./media/(.+?)\)\s*$")


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


def parse(path: Path) -> list[Tweet]:
    lines = path.read_text(encoding="utf-8").splitlines()
    tweets, i, n = [], 0, len(lines)
    while i < n:
        m = BLOCK_RE.match(lines[i])
        if not m:
            i += 1
            continue
        tid = m.group(1)
        i += 1
        while i < n and lines[i].strip() == "":
            i += 1
        author = time_s = ""
        while i < n and lines[i].startswith("- "):
            if lines[i].startswith("- Author:"):
                author = lines[i][len("- Author:"):].strip()
            elif lines[i].startswith("- Time:"):
                time_s = lines[i][len("- Time:"):].strip()
            i += 1
        body, media, in_media = [], [], False
        while i < n and not BLOCK_RE.match(lines[i]):
            s = lines[i].strip()
            if s == "---":
                i += 1
                continue
            if s == "Media:":
                in_media = True
                i += 1
                continue
            if in_media:
                im = IMG_RE.match(s)
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
    if t.text.startswith(UNROLLED_STUB):
        return False
    if t.text == "" or t.text.strip().lower() == "[no text]":
        return False
    return True


def main() -> None:
    raw_path = Path(sys.argv[1]).resolve()
    heading = sys.argv[2]
    tweets = parse(raw_path)
    head = tweets[0]
    kept = [t for t in tweets if keep(t)]

    blocks = []
    for t in kept:
        block = t.text
        for fn in t.media:
            assert (MEDIA_DIR / fn).exists(), f"missing media file: {fn}"
            block += f"\n\n![Image]({MEDIA_URL_BASE}/{fn})"
        blocks.append(block)

    posted = f"https://x.com/famulare_mike/status/{head.id}"
    date = head.dt.strftime("%B %-d, %Y")
    section = f"## {heading}\n\n*[Posted]({posted}) {date}.*\n\n" + "\n\n".join(blocks)

    text = WORKING.read_text(encoding="utf-8")
    idx = text.index(FOOTER_MARKER)
    WORKING.write_text(text[:idx] + "\n\n" + section + "\n" + text[idx:], encoding="utf-8")

    n_media = sum(len(t.media) for t in kept)
    print(f"appended '## {heading}' ({date}): {len(kept)} tweets, {n_media} images")
    print(f"dropped {len(tweets) - len(kept)} (other-author / unrolled stub / empty)")


if __name__ == "__main__":
    main()
