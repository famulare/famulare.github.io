#!/usr/bin/env node

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');
const manifestPath = path.join(repoRoot, 'assets', 'publication-mirror', 'manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const userAgent = 'famulare.github.io publication mirror/1.0';

const pmcIds = new Map([
  ['Journal Articles:1', 'PMC13133864'],
  ['Journal Articles:4', 'PMC3721832'],
  ['Journal Articles:5', 'PMC4492342'],
  ['Journal Articles:8', 'PMC5610141'],
  ['Journal Articles:13', 'PMC7542952'],
  ['Journal Articles:14', 'PMC7206929'],
  ['Journal Articles:15', 'PMC7315848'],
  ['Journal Articles:16', 'PMC7286545'],
  ['Journal Articles:17', 'PMC7810035'],
  ['Journal Articles:18', 'PMC7815045'],
  ['Journal Articles:19', 'PMC7929037'],
  ['Journal Articles:21', 'PMC8158963'],
  ['Journal Articles:23', 'PMC8733893'],
  ['Journal Articles:24', 'PMC8491103'],
  ['Journal Articles:28', 'PMC9047245'],
  ['Journal Articles:29', 'PMC9114981'],
  ['Journal Articles:30', 'PMC9856230'],
  ['Journal Articles:31', 'PMC10015104'],
  ['Journal Articles:32', 'PMC10491863'],
  ['Journal Articles:33', 'PMC11298812'],
  ['Preprints:4', 'PMC8845514'],
]);

const explicitSupplements = new Map([
  ['Preprints:3', [
    'https://www.medrxiv.org/content/medrxiv/early/2021/09/28/2021.05.31.21258018/DC1/embed/media-1.pdf?download=true',
  ]],
]);

function runCurl(args, outputPath = null) {
  const allArgs = ['-L', '--fail', '--retry', '2', '--max-time', '120', '-A', userAgent, ...args];
  if (outputPath) allArgs.push('-o', outputPath);
  return spawnSync('/usr/bin/curl', allArgs, { encoding: 'utf8', maxBuffer: 20 * 1024 * 1024 });
}

function getText(url) {
  const result = runCurl(['-sS', url]);
  return result.status === 0 ? result.stdout : '';
}

function absoluteUrl(href, base) {
  try {
    return new URL(href, base).toString();
  } catch {
    return null;
  }
}

function discoverSupplementUrls(pageUrl) {
  const html = getText(pageUrl);
  if (!html) return [];
  const hrefs = [...html.matchAll(/(?:href|src)=["']([^"']+)["']/gi)].map((match) => match[1]);
  return hrefs
    .map((href) => absoluteUrl(href, pageUrl))
    .filter(Boolean)
    .filter((url) => /supp|supplement|mmc|additional|extended|dataset|data[-_]/i.test(url))
    .filter((url) => /\.(?:pdf|zip|xlsx?|csv|docx?)(?:[?#]|$)/i.test(url));
}

function filenameFor(url, index) {
  let name = new URL(url).pathname.split('/').pop() || `supplement-${index}.pdf`;
  name = decodeURIComponent(name).replace(/[^A-Za-z0-9._-]+/g, '_');
  if (!/\.[A-Za-z0-9]{2,5}$/.test(name)) name += '.pdf';
  return name;
}

function looksLikeHtml(filePath) {
  return /^<!doctype html|^<html/i.test(fs.readFileSync(filePath, 'utf8').slice(0, 64));
}

const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'famulare-supplements-'));
let acquired = 0;

for (const record of manifest.records) {
  const key = `${record.section}:${record.number}`;
  const pmcid = pmcIds.get(key);
  const pages = [
    ...(pmcid ? [`https://pmc.ncbi.nlm.nih.gov/articles/${pmcid}/`] : []),
    ...([...explicitSupplements.keys()].includes(key) ? [`https://www.medrxiv.org/content/10.1101/${record.identifier.slice('10.1101/'.length)}v2`] : []),
  ];
  const urls = [
    ...(explicitSupplements.get(key) || []),
    ...pages.flatMap(discoverSupplementUrls),
  ];
  const uniqueUrls = [...new Set(urls)];
  if (!uniqueUrls.length) continue;
  const existing = new Set((record.supplements || []).map((item) => item.url));
  for (const [index, url] of uniqueUrls.entries()) {
    if (existing.has(url)) continue;
    const temporary = path.join(tmpRoot, `${record.section}-${record.number}-${index}.bin`);
    const result = runCurl([url], temporary);
    if (result.status !== 0 || !fs.existsSync(temporary) || fs.statSync(temporary).size === 0 || looksLikeHtml(temporary)) continue;
    const local = path.join(
      'assets',
      'publication-mirror',
      'supplements',
      `${record.section.toLowerCase().replace(/[^a-z0-9]+/g, '-')}-${record.number}-${filenameFor(url, index + 1)}`,
    );
    const destination = path.join(repoRoot, local);
    fs.mkdirSync(path.dirname(destination), { recursive: true });
    fs.copyFileSync(temporary, destination);
    record.supplements.push({ url, local_file: local });
    acquired += 1;
    console.log(`OK ${key} supplement <- ${url}`);
  }
}

manifest.generated_at = new Date().toISOString();
fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
console.log(`Acquired ${acquired} supplementary files; manifest updated.`);
