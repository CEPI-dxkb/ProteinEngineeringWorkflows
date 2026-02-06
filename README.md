# Protein Engineering Workflows

[![CI](https://github.com/CEPI-dxkb/ProteinEngineeringWorkflows/actions/workflows/ci.yml/badge.svg)](https://github.com/CEPI-dxkb/ProteinEngineeringWorkflows/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

CWL workflows combining protein structure prediction and stability analysis for protein engineering applications.

## Overview

This repository provides automated pipelines that combine:

```
Sequence → Structure Prediction → Stability Analysis → Engineering Candidates
           (Boltz-2 or Chai-1)     (stabiliNNator)
```

## Tool Capabilities

| Tool | Input | Output | Purpose |
|------|-------|--------|---------|
| **Boltz-2** | YAML/FASTA | PDB/mmCIF | Structure prediction with constraints |
| **Chai-1** | FASTA | PDB/mmCIF | Structure prediction |
| **stabiliNNator** | PDB/mmCIF | Annotated PDB | Stability analysis (proline/disulfide) |

## Available Workflows

| Workflow | Structure Tool | Stability Tools | Use Case |
|----------|---------------|-----------------|----------|
| `protein_stability_pipeline.cwl` | `boltz` | `stabilinnator` (dynamic) | Simple usage, single analysis |
| `protein_stability_with_chai.cwl` | `chai-lab` | `stabilinnator` (dynamic) | Chai-1 alternative |
| `protein_stability_explicit.cwl` | `boltz` | `prolinnator` + `disulfinnate` | Explicit parallel analysis |
| `protein_stability_explicit_chai.cwl` | `chai-lab` | `prolinnator` + `disulfinnate` | Chai-1 explicit parallel |
| `protein_stability_app.cwl` | `App-Boltz.pl` | `App-StabiliNNator.pl` × 2 | BV-BRC integration |
| `protein_stability_app_chai.cwl` | `App-ChaiLab.pl` | `App-StabiliNNator.pl` × 2 | BV-BRC Chai-1 integration |

## Quick Start

```bash
# Install cwltool
pip install cwltool

# Run the stability pipeline with Boltz
cwltool cwl/workflows/protein_stability_pipeline.cwl examples/crambin_job.yml

# Run the alternative pipeline with Chai-1
cwltool cwl/workflows/protein_stability_with_chai.cwl examples/crambin_fasta_job.yml

# Run explicit workflow (parallel proline + disulfide analysis)
cwltool cwl/workflows/protein_stability_explicit.cwl examples/crambin_job.yml

# Run Chai-1 explicit workflow
cwltool cwl/workflows/protein_stability_explicit_chai.cwl examples/crambin_fasta_job.yml

# Run BV-BRC App script workflow
cwltool cwl/workflows/protein_stability_app.cwl examples/crambin_job.yml
```

## Scientific Use Cases

### Therapeutic Protein Stabilization
Improve shelf-life and thermal stability of biologic drugs by identifying:
- Residues to mutate to proline (reduce flexibility)
- Cysteine pairs for engineered disulfide bonds

### Vaccine Antigen Design
Stabilize viral proteins for immunization:
- Prefusion conformation stabilization
- Disulfide bonds to lock desired states

### Enzyme Engineering
Create thermostable enzyme variants:
- Proline mutations away from active site
- Disulfide bonds in non-catalytic regions

## Outputs

### stabiliNNator B-factor Scores

| Analysis | Score Meaning |
|----------|---------------|
| **proliNNator** | Per-residue probability that proline mutation would stabilize |
| **disulfiNNate** | Per-cysteine pair probability for engineered disulfide bond |

Scores are in the 0-1 range; higher = better candidate for engineering.

## Repository Structure

```
ProteinEngineeringWorkflows/
├── cwl/
│   ├── tools/                        # Individual tool CWL definitions
│   │   ├── boltz.cwl                 # Boltz-2 direct command
│   │   ├── chai.cwl                  # Chai-1 direct command
│   │   ├── stabilinnator.cwl         # Combined stability (dynamic)
│   │   ├── prolinnator.cwl           # Proline analysis (explicit)
│   │   ├── disulfinnate.cwl          # Disulfide analysis (explicit)
│   │   ├── app-boltz.cwl             # App-Boltz.pl wrapper
│   │   ├── app-chai.cwl              # App-ChaiLab.pl wrapper
│   │   ├── app-prolinnator.cwl       # App-StabiliNNator.pl (proline)
│   │   └── app-disulfinnate.cwl      # App-StabiliNNator.pl (disulfide)
│   └── workflows/                    # Combined pipeline workflows
│       ├── protein_stability_pipeline.cwl      # Boltz → stabiliNNator
│       ├── protein_stability_with_chai.cwl     # Chai-1 → stabiliNNator
│       ├── protein_stability_explicit.cwl      # Boltz → prolinnator + disulfinnate
│       ├── protein_stability_explicit_chai.cwl # Chai-1 → prolinnator + disulfinnate
│       ├── protein_stability_app.cwl           # BV-BRC App script workflow (Boltz)
│       └── protein_stability_app_chai.cwl      # BV-BRC App script workflow (Chai-1)
├── examples/
│   ├── crambin_job.yml
│   ├── crambin_fasta_job.yml
│   ├── lysozyme_job.yml
│   └── test_sequences/
├── docs/
│   ├── SCIENTIFIC_RATIONALE.md
│   ├── USER_GUIDE.md
│   └── OUTPUT_INTERPRETATION.md
└── tests/
    └── test_pipeline.sh
```

## Tool Variants

### Direct Command Tools
Call the underlying tools directly:
- `boltz.cwl` → `boltz predict`
- `chai.cwl` → `chai-lab`
- `prolinnator.cwl` → `prolinnator`
- `disulfinnate.cwl` → `disulfinnate`

### BV-BRC App Script Tools
Use BV-BRC application wrappers for infrastructure integration:
- `app-boltz.cwl` → `App-Boltz.pl`
- `app-chai.cwl` → `App-ChaiLab.pl`
- `app-prolinnator.cwl` → `App-StabiliNNator.pl` (proline mode)
- `app-disulfinnate.cwl` → `App-StabiliNNator.pl` (disulfide mode)

## Requirements

- cwltool >= 3.1
- Docker (for running containerized tools)
- GPU with CUDA support (for structure prediction)
- 64-96 GB RAM (depending on protein size)

## License

MIT License
