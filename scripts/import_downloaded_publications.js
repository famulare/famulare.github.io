#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');
const manifestPath = path.join(repoRoot, 'assets', 'publication-mirror', 'manifest.json');
const builderPath = path.join(__dirname, 'build_publication_manifest.js');

const imports = [
  {
    section: 'Journal Articles',
    number: 7,
    source: '/Users/famulare/Downloads/Famulare et al._2016_Sabin Vaccine Reversion in the Field a Comprehensive Analysis of Sabin-Like Poliovirus Isolates in.pdf',
    destination: 'assets/publication-mirror/Famulare_et_al_2016_Sabin_vaccine_reversion_in_the_field.pdf',
  },
  {
    section: 'Journal Articles',
    number: 9,
    source: '/Users/famulare/Downloads/Kroiss et al._2017_Evaluating cessation of the type 2 oral polio vaccine by modeling pre- and post-cessation detection.pdf',
    destination: 'assets/publication-mirror/Kroiss_et_al_2017_Evaluating_cessation_of_type_2_oral_polio_vaccine.pdf',
  },
  {
    section: 'Journal Articles',
    number: 9,
    source: '/Users/famulare/Downloads/1-s2.0-S0264410X17311362-mmc1.docx',
    destination: 'assets/publication-mirror/supplements/Kroiss_et_al_2017_supplement.docx',
    supplementUrl: 'https://ars.els-cdn.com/content/image/1-s2.0-S0264410X17311362-mmc1.docx',
  },
  {
    section: 'Journal Articles',
    number: 18,
    source: '/Users/famulare/Downloads/1-s2.0-S1931312820305746-main.pdf',
    destination: 'assets/publication-mirror/Valesano_et_al_2021_Early_evolution_of_oral_poliovirus_vaccine.pdf',
  },
  {
    section: 'Journal Articles',
    number: 24,
    source: '/Users/famulare/Downloads/jamapediatrics_chung_2021_oi_210036_1632764433.85951.pdf',
    destination: 'assets/publication-mirror/Chung_et_al_2021_Comparison_of_symptoms_and_RNA_levels_in_children_and_adults.pdf',
  },
  {
    section: 'Journal Articles',
    number: 24,
    source: '/Users/famulare/Downloads/poi210036supp1_prod_1632764433.86452.pdf',
    destination: 'assets/publication-mirror/supplements/Chung_et_al_2021_supplement.pdf',
    supplementUrl: 'https://jamanetwork.com/journals/jamapediatrics/articlepdf/2780963/poi210036supp1_prod_1632764433.86452.pdf',
  },
];

for (const item of imports) {
  if (!fs.existsSync(item.source)) throw new Error(`Missing download: ${item.source}`);
  const destination = path.join(repoRoot, item.destination);
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  fs.copyFileSync(item.source, destination);
  if (fs.statSync(destination).size === 0) throw new Error(`Empty imported file: ${item.destination}`);
  if (item.destination.toLowerCase().endsWith('.pdf')) {
    const header = fs.readFileSync(destination).subarray(0, 5).toString();
    if (header !== '%PDF-') throw new Error(`Imported file is not a PDF: ${item.destination}`);
  }
  console.log(`Imported ${path.basename(item.source)} -> ${item.destination}`);
}

const built = spawnSync(process.execPath, [builderPath], { cwd: repoRoot, encoding: 'utf8' });
process.stdout.write(built.stdout || '');
process.stderr.write(built.stderr || '');
if (built.status !== 0) process.exit(built.status || 1);

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
for (const item of imports) {
  const key = `${item.section}:${item.number}`;
  const record = manifest.records.find((candidate) => `${candidate.section}:${candidate.number}` === key);
  if (!record) throw new Error(`Manifest record not found: ${key}`);
  const provenance = `user-supplied Downloads/${path.basename(item.source)}`;
  if (item.supplementUrl) {
    record.supplements = record.supplements || [];
    const supplement = { url: item.supplementUrl, local_file: item.destination };
    if (!record.supplements.some((candidate) => candidate.local_file === item.destination)) {
      record.supplements.push(supplement);
    }
  } else {
    record.acquired_from = provenance;
  }
}

fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
console.log(`Registered ${imports.length} supplied files in ${path.relative(repoRoot, manifestPath)}.`);
