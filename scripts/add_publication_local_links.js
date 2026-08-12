#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');

const repoRoot = path.resolve(__dirname, '..');
const cvPath = path.join(repoRoot, 'assets', 'Famulare_CV.tex');
const manifestPath = path.join(repoRoot, 'assets', 'publication-mirror', 'manifest.json');
const siteRoot = 'https://famulare.github.io/';
const sections = new Set([
  'Preprints',
  'Journal Articles',
  'Public Health Reports',
  'Conference Proceedings',
]);

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const records = new Map(manifest.records.map((record) => [`${record.section}:${record.number}`, record]));
let source = fs.readFileSync(cvPath, 'utf8');
const sectionMatches = [...source.matchAll(/\\sectiontitle\{([^}]*)\}/g)];
let added = 0;

for (let index = sectionMatches.length - 1; index >= 0; index -= 1) {
  const sectionMatch = sectionMatches[index];
  const section = sectionMatch[1];
  if (!sections.has(section)) continue;
  const start = sectionMatch.index + sectionMatch[0].length;
  const nextSection = source.slice(start).search(/\\sectiontitle\{/);
  const end = nextSection < 0 ? source.length : start + nextSection;
  let body = source.slice(start, end);
  body = body.replace(/\\item\[\{\[([0-9]+)\]\}\][\s\S]*?(?=\n\s*\\item\[\{\[|\n\s*\\end\{items\})/g, (block, number) => {
    const record = records.get(`${section}:${number}`);
    if (!record) return block;
    const withoutMirrorLinks = block
      .replace(/;?\s*\\href\{https:\/\/famulare\.github\.io\/assets\/publication-mirror\/[^}]+\}\{\[(?:local PDF|local PDF unavailable|supplement [0-9]+)\]\}/g, '')
      .replace(/;?\s*\\textit\{\[local PDF unavailable\]\}/g, '');
    block = withoutMirrorLinks;
    if (record.status !== 'mirrored') {
      return `${block.replace(/\s*$/, '')}; \\textit{[local PDF unavailable]}`;
    }
    const links = [`\\href{${siteRoot}${encodeURI(record.local_pdf)}}{[local PDF]}`];
    for (const [supplementIndex, supplement] of (record.supplements || []).entries()) {
      links.push(`\\href{${siteRoot}${encodeURI(supplement.local_file)}}{[supplement ${supplementIndex + 1}]}`);
    }
    added += 1;
    return `${block.replace(/\s*$/, '')}; ${links.join('; ')}`;
  });
  source = `${source.slice(0, start)}${body}${source.slice(end)}`;
}

fs.writeFileSync(cvPath, source);
console.log(`Added local links to ${added} CV entries.`);
