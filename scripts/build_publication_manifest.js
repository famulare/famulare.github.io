#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');

const repoRoot = path.resolve(__dirname, '..');
const cvPath = path.join(repoRoot, 'assets', 'Famulare_CV.tex');
const outputPath = path.join(repoRoot, 'assets', 'publication-mirror', 'manifest.json');

const sections = new Set([
  'Preprints',
  'Journal Articles',
  'Public Health Reports',
  'Conference Proceedings',
]);

const sectionSlug = {
  Preprints: 'preprint',
  'Journal Articles': 'journal',
  'Public Health Reports': 'public-health-report',
  'Conference Proceedings': 'proceedings',
};

const reportBasenames = new Map([
  ['1', 'nCoV_ incubation period distribution.pdf'],
  ['2', 'Situation Report_ first generation of local transmission outside of China.pdf'],
  ['3', '2019-nCoV_ preliminary estimates of the confirmed-case-fatality-ratio and infection-fatality-ratio, and initial pandemic risk assessment.pdf'],
  ['7', 'Physical_distancing_working_and_still_needed_to_prevent_COVID-19_resurgence.pdf'],
  ['13', 'new-technical-report.pdf'],
  ['21', 'Wear your mask and keep your distance! We need you to fight the surge of COVID-19 in King County – PUBLIC HEALTH INSIDER.pdf'],
  ['33', 'Alongside the ongoing transmission of COVID-19, common colds are on the rise in Seattle and King County – PUBLIC HEALTH INSIDER.pdf'],
  ['22', 'WA_Situation_Report_7_COVID-19_transmission_across_Washington_State.pdf'],
  ['30', 'WA_Situation_Report_13_COVID-19_transmission_across_Washington_State.pdf'],
]);

const readableBasenames = new Map([
  ['Journal Articles:7', 'Famulare_et_al_2016_Sabin_vaccine_reversion_in_the_field.pdf'],
  ['Journal Articles:9', 'Kroiss_et_al_2017_Evaluating_cessation_of_type_2_oral_polio_vaccine.pdf'],
  ['Journal Articles:18', 'Valesano_et_al_2021_Early_evolution_of_oral_poliovirus_vaccine.pdf'],
  ['Journal Articles:24', 'Chung_et_al_2021_Comparison_of_symptoms_and_RNA_levels_in_children_and_adults.pdf'],
]);

function decodeUrl(url) {
  try {
    return decodeURIComponent(url);
  } catch {
    return url;
  }
}

function filenameFromUrl(url) {
  const decoded = decodeUrl(url.split('?')[0]);
  const basename = decoded.slice(decoded.lastIndexOf('/') + 1);
  return basename && basename.toLowerCase().endsWith('.pdf') ? basename : null;
}

function hrefs(block) {
  return [...block.matchAll(/\\href\{([^}]*)\}/g)].map((match) => match[1]);
}

function identifierFromUrls(urls, block) {
  const doiUrl = urls.find((url) => url.includes('doi.org/'));
  if (doiUrl) return decodeUrl(doiUrl.split('doi.org/')[1]);
  const doiText = block.match(/\b10\.\d{4,9}\/[^^\s}]+/);
  if (doiText) return doiText[0].replace(/[.,]$/, '');
  const repositoryUrl = urls.find((url) => /arxiv|medrxiv|biorxiv/i.test(url));
  if (repositoryUrl) return decodeUrl(repositoryUrl);
  const reportUrl = urls.find((url) => /\.pdf(?:$|[?#])/i.test(url));
  if (reportUrl) return filenameFromUrl(reportUrl) || '';
  const dateMatch = block.match(/\b(19|20)\d{2}\b/);
  return dateMatch ? dateMatch[0] : '';
}

function displayText(block) {
  return block
    .replace(/\\href\{[^}]*\}\{([^}]*)\}/g, '$1')
    .replace(/\\textbf\{([^}]*)\}/g, '$1')
    .replace(/\\emph\{([^}]*)\}/g, '$1')
    .replace(/\\[A-Za-z]+(?:\[[^]]*\])?\{[^}]*\}/g, '')
    .replace(/\\[A-Za-z]+/g, '')
    .replace(/[{}]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function localPdfFor(section, number, urls) {
  const readableBasename = readableBasenames.get(`${section}:${number}`);
  if (readableBasename) return `assets/publication-mirror/${readableBasename}`;
  if (section === 'Public Health Reports') {
    if (reportBasenames.has(number)) {
      return `assets/publication-mirror/${reportBasenames.get(number)}`;
    }
    const reportUrl = urls.find((url) => /\.pdf(?:$|[?#])/i.test(url));
    const basename = reportUrl && filenameFromUrl(reportUrl);
    if (basename) return `assets/publication-mirror/${basename}`;
  }
  return `assets/publication-mirror/${sectionSlug[section]}-${String(number).padStart(2, '0')}.pdf`;
}

function uniqueSupplements(supplements = []) {
  const seen = new Set();
  return supplements.filter((supplement) => {
    const key = `${supplement.local_file || ''}\n${supplement.url || ''}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

const source = fs.readFileSync(cvPath, 'utf8');
const priorManifest = fs.existsSync(outputPath)
  ? JSON.parse(fs.readFileSync(outputPath, 'utf8'))
  : { records: [] };
const priorRecords = new Map(
  (priorManifest.records || []).map((record) => [`${record.section}:${record.number}`, record]),
);
const records = [];
for (const sectionMatch of source.matchAll(/\\sectiontitle\{([^}]*)\}/g)) {
  const section = sectionMatch[1];
  if (!sections.has(section)) continue;
  const start = sectionMatch.index + sectionMatch[0].length;
  const nextSection = source.slice(start).search(/\\sectiontitle\{/);
  const body = source.slice(start, nextSection < 0 ? source.length : start + nextSection);
  for (const itemMatch of body.matchAll(/\\item\[\{\[([0-9]+)\]\}\]([\s\S]*?)(?=\\item\[\{\[|$)/g)) {
    const number = itemMatch[1];
    const block = itemMatch[0];
    const urls = hrefs(block).filter((url) => !/^https:\/\/famulare\.github\.io\/assets\/publication-mirror\//i.test(url));
    const localPdf = localPdfFor(section, number, urls);
    const localExists = fs.existsSync(path.join(repoRoot, localPdf));
    const prior = priorRecords.get(`${section}:${number}`) || {};
    records.push({
      section,
      number: Number(number),
      identifier: identifierFromUrls(urls, block),
      source_urls: urls,
      local_pdf: localPdf,
      supplements: uniqueSupplements(prior.supplements || []),
      status: localExists ? 'mirrored' : prior.status === 'inaccessible' ? 'inaccessible' : 'to-acquire',
      citation_text: displayText(block),
      ...(prior.acquired_from ? { acquired_from: prior.acquired_from } : {}),
      ...(prior.candidate_urls ? { candidate_urls: prior.candidate_urls } : {}),
      ...(prior.acquisition_error && !localExists ? { acquisition_error: prior.acquisition_error } : {}),
    });
  }
}

records.sort((a, b) => {
  if (a.section !== b.section) return a.section.localeCompare(b.section);
  return a.number - b.number;
});

const manifest = {
  generated_from: 'assets/Famulare_CV.tex',
  generated_at: new Date().toISOString(),
  records,
};

fs.writeFileSync(outputPath, `${JSON.stringify(manifest, null, 2)}\n`);
console.log(`Wrote ${records.length} records to ${path.relative(repoRoot, outputPath)}`);
