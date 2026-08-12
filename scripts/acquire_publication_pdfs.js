#!/usr/bin/env node

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');
const manifestPath = path.join(repoRoot, 'assets', 'publication-mirror', 'manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const userAgent = 'famulare.github.io publication mirror/1.0';

const reportSources = {
  'Public Health Reports:22': 'https://iazpvnewgrp01.blob.core.windows.net/source/2021-02/reports/pdf/WA_Situation_Report_7_COVID-19_transmission_across_Washington_State.pdf',
  'Public Health Reports:30': 'https://iazpvnewgrp01.blob.core.windows.net/source/2021-02/reports/pdf/WA_Situation_Report_13_COVID-19_transmission_across_Washington_State.pdf',
};

const preprintCanonicalUrls = {
  'Preprints:2': 'https://www.medrxiv.org/content/medrxiv/early/2020/04/11/2020.04.08.20058487.full.pdf',
  'Preprints:3': 'https://www.medrxiv.org/content/medrxiv/early/2021/09/28/2021.05.31.21258018.full.pdf',
  'Preprints:7': 'https://www.biorxiv.org/content/early/2024/08/07/2024.08.07.607080.full.pdf',
};

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

function runCurl(args, outputPath = null) {
  const allArgs = ['-L', '--fail', '--retry', '2', '--max-time', '120', '-A', userAgent, ...args];
  if (outputPath) allArgs.push('-o', outputPath);
  return spawnSync('/usr/bin/curl', allArgs, { encoding: 'utf8', maxBuffer: 20 * 1024 * 1024 });
}

function getText(url) {
  const result = runCurl(['-sS', url]);
  return result.status === 0 ? result.stdout : '';
}

function isPdf(filePath) {
  try {
    return fs.readFileSync(filePath).subarray(0, 5).toString() === '%PDF-';
  } catch {
    return false;
  }
}

function doiFor(record) {
  if (record.section === 'Journal Articles' && record.number === 23) return '10.1016/j.lana.2021.100018';
  return record.identifier;
}

function directPreprintUrls(record) {
  const id = doiFor(record);
  if (record.section !== 'Preprints') return [];
  const canonical = preprintCanonicalUrls[`${record.section}:${record.number}`];
  if (id.startsWith('10.48550/arXiv.')) {
    return [`https://arxiv.org/pdf/${id.slice('10.48550/arXiv.'.length)}.pdf`];
  }
  if (id.startsWith('10.1101/')) {
    const repositoryId = id.slice('10.1101/'.length);
    const server = record.citation_text.toLowerCase().includes('biorxiv') ? 'biorxiv' : 'medrxiv';
    return [
      ...(canonical ? [canonical] : []),
      `https://www.${server}.org/content/${id}v2.full.pdf`,
      `https://www.${server}.org/content/${id}v1.full.pdf`,
      `https://www.${server}.org/content/${server}/early/${repositoryId.slice(0, 4)}-${repositoryId.slice(4, 6)}-${repositoryId.slice(6, 8)}/${repositoryId}.full.pdf`,
    ];
  }
  return [];
}

function repositoryFallbacks(record) {
  const key = `${record.section}:${record.number}`;
  const pmcid = pmcIds.get(key);
  const links = [];
  if (key === 'Conference Proceedings:1') links.push('https://arxiv.org/pdf/gr-qc/0702053.pdf');
  if (key === 'Conference Proceedings:2') links.push('https://proceedings.scipy.org/articles/majora-212e5952-00e.pdf');
  if (key === 'Journal Articles:2') links.push('https://arxiv.org/pdf/0902.2020.pdf');
  if (key === 'Journal Articles:4') links.push('https://www.jneurosci.org/content/33/30/12154.full.pdf');
  if (key === 'Journal Articles:7') links.push('https://journals.asm.org/doi/pdf/10.1128/jvi.01532-15?download=true');
  if (key === 'Journal Articles:9') links.push('https://www.sciencedirect.com/science/article/pii/S0264410X17311464/pdfft');
  if (key === 'Journal Articles:18') links.push('https://www.sciencedirect.com/science/article/pii/S1931312820305746/pdfft');
  if (key === 'Journal Articles:24') links.push('https://jamanetwork.com/journals/jamapediatrics/articlepdf/2780963/jamapediatrics_chung_2021_oi_210036_1632764433.85951.pdf?resultClick=1');
  if (key === 'Journal Articles:30') links.push('https://bedford.io/pdfs/papers/hansen-sars-cov-2-risk-factors.pdf');
  if (key === 'Journal Articles:33') links.push('https://eprints.gla.ac.uk/323783/2/323783.pdf');
  if (pmcid) {
    links.push(`https://europepmc.org/articles/${pmcid}?pdf=render`);
    links.push(`https://www.ncbi.nlm.nih.gov/pmc/articles/${pmcid}/pdf/`);
  }
  return links;
}

function crossrefLinks(record) {
  const doi = doiFor(record);
  if (!doi || !doi.startsWith('10.')) return { links: [], page: null };
  const json = getText(`https://api.crossref.org/works/${encodeURIComponent(doi)}`);
  if (!json) return { links: [], page: null };
  try {
    const message = JSON.parse(json).message || {};
    const links = (message.link || []).map((item) => item.URL).filter(Boolean);
    return { links, page: message.URL || `https://doi.org/${doi}` };
  } catch {
    return { links: [], page: null };
  }
}

function publisherFallbacks(record) {
  const doi = doiFor(record);
  const links = [];
  if (doi.startsWith('10.1038/')) links.push(`https://www.nature.com/articles/${doi.slice('10.1038/'.length)}.pdf`);
  if (doi.startsWith('10.1103/')) links.push(`https://journals.aps.org/pre/pdf/${doi}`);
  if (doi.startsWith('10.1523/')) links.push(`https://www.jneurosci.org/content/${record.number === 4 ? '33/30/12154' : ''}.full.pdf`);
  if (doi.startsWith('10.1186/')) links.push(`https://bmcinfectdis.biomedcentral.com/counter/pdf/${doi}.pdf`);
  if (doi.startsWith('10.1371/')) links.push(`https://journals.plos.org/${doi.includes('journal.pbio') ? 'plosbiology' : doi.includes('journal.pcbi') ? 'ploscompbiol' : 'plosone'}/article/file?id=${doi}&type=printable`);
  if (doi.startsWith('10.1098/')) links.push(`https://royalsocietypublishing.org/doi/pdf/${doi}`);
  if (doi.startsWith('10.1128/')) links.push(`https://journals.asm.org/doi/pdf/${doi}`);
  if (doi.startsWith('10.1007/')) links.push(`https://link.springer.com/content/pdf/${doi}.pdf`);
  return links;
}

function discoveryPages(record, crossrefPage, sourceUrls) {
  const pmcid = pmcIds.get(`${record.section}:${record.number}`);
  return [
    pmcid ? `https://europepmc.org/articles/${pmcid}` : null,
    crossrefPage,
    sourceUrls[0],
  ].filter(Boolean);
}

function absoluteUrl(href, base) {
  try {
    return new URL(href, base).toString();
  } catch {
    return null;
  }
}

function discoverSupplementUrls(pageUrl, mainUrl) {
  if (!pageUrl) return [];
  const html = getText(pageUrl);
  if (!html) return [];
  const hrefs = [...html.matchAll(/(?:href|src)=["']([^"']+)["']/gi)].map((match) => match[1]);
  const likely = hrefs
    .map((href) => absoluteUrl(href, pageUrl))
    .filter(Boolean)
    .filter((url) => url !== mainUrl)
    .filter((url) => /supp|supplement|mmc|additional|extended|dataset|data[-_]/i.test(url))
    .filter((url) => /\.(?:pdf|zip|xlsx?|csv|docx?)(?:[?#]|$)/i.test(url));
  return [...new Set(likely)];
}

function filenameForSupplement(url, index) {
  const pathname = new URL(url).pathname;
  let name = pathname.slice(pathname.lastIndexOf('/') + 1) || `supplement-${index}`;
  name = decodeURIComponent(name).replace(/[^A-Za-z0-9._-]+/g, '_');
  if (!/\.[A-Za-z0-9]{2,5}$/.test(name)) name += '.pdf';
  return name;
}

const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'famulare-publication-'));
let acquired = 0;
let failed = 0;

for (const record of manifest.records) {
  if (record.status === 'mirrored') continue;
  const key = `${record.section}:${record.number}`;
  const destination = path.join(repoRoot, record.local_pdf);
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  const crossref = crossrefLinks(record);
  const sourceUrls = record.source_urls || [];
  const candidates = [
    ...(reportSources[key] ? [reportSources[key]] : []),
    ...directPreprintUrls(record),
    ...sourceUrls.filter((url) => /\.pdf(?:$|[?#])/i.test(url)),
    ...crossref.links,
    ...repositoryFallbacks(record),
    ...publisherFallbacks(record),
  ].filter(Boolean);
  const uniqueCandidates = [...new Set(candidates)];
  record.candidate_urls = uniqueCandidates;
  let downloadedFrom = null;
  for (const [index, url] of uniqueCandidates.entries()) {
    const temporary = path.join(tmpRoot, `${record.section}-${record.number}-${index}.bin`);
    const result = runCurl([url], temporary);
    if (result.status === 0 && isPdf(temporary)) {
      fs.copyFileSync(temporary, destination);
      downloadedFrom = url;
      break;
    }
  }
  if (!downloadedFrom) {
    record.status = 'inaccessible';
    record.acquisition_error = 'No candidate URL returned a PDF';
    failed += 1;
    console.error(`FAILED ${key} ${record.identifier}`);
    continue;
  }
  record.status = 'mirrored';
  record.acquired_from = downloadedFrom;
  const supplementUrls = [...new Set(
    discoveryPages(record, crossref.page, sourceUrls)
      .flatMap((page) => discoverSupplementUrls(page, downloadedFrom)),
  )];
  for (const [index, supplementUrl] of supplementUrls.entries()) {
    const local = path.join('assets', 'publication-mirror', 'supplements', `${record.section.toLowerCase().replace(/[^a-z0-9]+/g, '-')}-${record.number}-${filenameForSupplement(supplementUrl, index + 1)}`);
    const destinationSupplement = path.join(repoRoot, local);
    fs.mkdirSync(path.dirname(destinationSupplement), { recursive: true });
    const temporary = path.join(tmpRoot, `supplement-${record.section}-${record.number}-${index}.bin`);
    const result = runCurl([supplementUrl], temporary);
    if (result.status === 0 && fs.statSync(temporary).size > 0 && !/^<!doctype html/i.test(fs.readFileSync(temporary, 'utf8').slice(0, 64))) {
      fs.copyFileSync(temporary, destinationSupplement);
      record.supplements.push({ url: supplementUrl, local_file: local });
    }
  }
  acquired += 1;
  console.log(`OK ${key} ${record.identifier} <- ${downloadedFrom}`);
}

manifest.generated_at = new Date().toISOString();
fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
console.log(`Acquired ${acquired}; failed ${failed}; manifest updated.`);
