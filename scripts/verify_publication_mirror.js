#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');
const cvPath = path.join(repoRoot, 'assets', 'Famulare_CV.tex');
const manifestPath = path.join(repoRoot, 'assets', 'publication-mirror', 'manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const source = fs.readFileSync(cvPath, 'utf8');
const pdfinfo = '/Users/famulare/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override/pdfinfo';
const errors = [];

function fileIsPdf(relativePath) {
  const absolute = path.join(repoRoot, relativePath);
  if (!fs.existsSync(absolute)) return false;
  return fs.readFileSync(absolute).subarray(0, 5).toString() === '%PDF-';
}

function validatePdf(relativePath) {
  if (!fileIsPdf(relativePath)) {
    errors.push(`not a PDF or missing: ${relativePath}`);
    return;
  }
  const result = spawnSync(pdfinfo, [path.join(repoRoot, relativePath)], { encoding: 'utf8' });
  if (result.status !== 0) errors.push(`pdfinfo failed: ${relativePath}`);
}

const recordsByKey = new Map();
for (const record of manifest.records) {
  const key = `${record.section}:${record.number}`;
  if (recordsByKey.has(key)) errors.push(`duplicate manifest record: ${key}`);
  recordsByKey.set(key, record);
  if (record.status === 'mirrored') validatePdf(record.local_pdf);
  if (record.status === 'inaccessible' && !record.acquisition_error) errors.push(`inaccessible record lacks reason: ${key}`);
  for (const supplement of record.supplements || []) {
    const absolute = path.join(repoRoot, supplement.local_file);
    if (!fs.existsSync(absolute) || fs.statSync(absolute).size === 0) errors.push(`missing supplement: ${supplement.local_file}`);
    if (/\.pdf$/i.test(supplement.local_file)) validatePdf(supplement.local_file);
  }
}

const expectedCounts = {
  Preprints: 7,
  'Journal Articles': 34,
  'Public Health Reports': 53,
  'Conference Proceedings': 2,
};
for (const [section, count] of Object.entries(expectedCounts)) {
  const actual = manifest.records.filter((record) => record.section === section).length;
  if (actual !== count) errors.push(`${section}: expected ${count}, found ${actual}`);
}

const localLinks = [...source.matchAll(/\\href\{(https:\/\/famulare\.github\.io\/assets\/publication-mirror\/[^}]+)\}/g)]
  .map((match) => decodeURIComponent(match[1].slice('https://famulare.github.io/'.length)));
const trackedAssets = new Set();
for (const record of manifest.records) {
  trackedAssets.add(record.local_pdf);
  for (const supplement of record.supplements || []) trackedAssets.add(supplement.local_file);
}
for (const localLink of localLinks) {
  if (!trackedAssets.has(localLink)) errors.push(`CV local link is not tracked: ${localLink}`);
  if (!fs.existsSync(path.join(repoRoot, localLink))) errors.push(`CV local link does not resolve locally: ${localLink}`);
}

const mainLocalLinks = localLinks.filter((link) => !link.includes('/supplements/'));
const mirroredCount = manifest.records.filter((record) => record.status === 'mirrored').length;
if (mainLocalLinks.length !== mirroredCount) errors.push(`CV has ${mainLocalLinks.length} main local links for ${mirroredCount} mirrored records`);

if (errors.length) {
  console.error(errors.join('\n'));
  process.exitCode = 1;
}
console.log(JSON.stringify({
  records: manifest.records.length,
  mirrored: mirroredCount,
  inaccessible: manifest.records.filter((record) => record.status === 'inaccessible').length,
  supplements: manifest.records.reduce((sum, record) => sum + (record.supplements || []).length, 0),
  local_links: localLinks.length,
  pdfs_validated: manifest.records.filter((record) => record.status === 'mirrored').length
    + manifest.records.flatMap((record) => record.supplements || []).filter((supplement) => /\.pdf$/i.test(supplement.local_file)).length,
  errors: errors.length,
}, null, 2));
