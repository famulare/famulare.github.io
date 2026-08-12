#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');
const manifest = JSON.parse(fs.readFileSync(path.join(repoRoot, 'assets', 'publication-mirror', 'manifest.json'), 'utf8'));

function normalize(value) {
  return value
    .toLowerCase()
    .replace(/\\[a-z]+\{([^}]*)\}/g, '$1')
    .replace(/[^a-z0-9]+/g, ' ')
    .split(/\s+/)
    .filter((word) => word.length > 2)
    .filter((word) => !['the', 'and', 'for', 'with', 'from', 'into', 'using', 'among'].includes(word));
}

function crossref(doi) {
  const result = spawnSync('/usr/bin/curl', [
    '-L', '--fail', '--max-time', '60', '-sS',
    `https://api.crossref.org/works/${encodeURIComponent(doi)}`,
  ], { encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 });
  if (result.status !== 0) return null;
  try {
    return JSON.parse(result.stdout).message || null;
  } catch {
    return null;
  }
}

function citationListsTitle(citation) {
  const afterDate = citation.replace(/^.*?\)\.\s+/, '');
  const journalOrIdentifier = afterDate.search(/\\emph\{|\\textit\{|doi:|https?:\/\//);
  if (journalOrIdentifier < 0) return true;
  return afterDate.slice(0, journalOrIdentifier).trim().length > 10;
}

const checked = [];
for (const record of manifest.records.filter((item) => /^10\./.test(item.identifier) && item.section !== 'Public Health Reports')) {
  const metadata = crossref(record.identifier);
  if (!metadata) {
    checked.push({ key: `${record.section}:${record.number}`, doi: record.identifier, status: 'unavailable' });
    continue;
  }
  const citationWords = new Set(normalize(record.citation_text));
  const titleWords = normalize((metadata.title || [])[0] || '');
  const overlap = titleWords.length ? titleWords.filter((word) => citationWords.has(word)).length / titleWords.length : 0;
  if (!citationListsTitle(record.citation_text)) {
    checked.push({
      key: `${record.section}:${record.number}`,
      doi: record.identifier,
      status: 'title-not-listed',
      authoritative_title: (metadata.title || [])[0] || '',
    });
    continue;
  }
  checked.push({
    key: `${record.section}:${record.number}`,
    doi: record.identifier,
    status: overlap >= 0.5 ? 'match' : 'review',
    overlap: Number(overlap.toFixed(3)),
    authoritative_title: (metadata.title || [])[0] || '',
  });
}

const summary = {
  checked: checked.length,
  match: checked.filter((item) => item.status === 'match').length,
  review: checked.filter((item) => item.status === 'review').length,
  unavailable: checked.filter((item) => item.status === 'unavailable').length,
  title_not_listed: checked.filter((item) => item.status === 'title-not-listed').length,
  reviews: checked.filter((item) => item.status === 'review'),
  unavailable_records: checked.filter((item) => item.status === 'unavailable'),
  title_not_listed_records: checked.filter((item) => item.status === 'title-not-listed'),
};
console.log(JSON.stringify(summary, null, 2));
if (summary.review) process.exitCode = 1;
