# Protein Engineering Workflows

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

## Quick Start

```bash
# Install cwltool
pip install cwltool

# Run the stability pipeline with Boltz
cwltool cwl/workflows/protein_stability_pipeline.cwl examples/crambin_job.yml

# Run the alternative pipeline with Chai-1
cwltool cwl/workflows/protein_stability_with_chai.cwl examples/crambin_fasta_job.yml
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
│   ├── tools/           # Individual tool CWL definitions
│   │   ├── boltz.cwl
│   │   ├── chai.cwl
│   │   └── stabilinnator.cwl
│   └── workflows/       # Combined pipeline workflows
│       ├── protein_stability_pipeline.cwl      # Boltz → stabiliNNator
│       └── protein_stability_with_chai.cwl     # Chai-1 → stabiliNNator
├── examples/
│   ├── crambin_job.yml
│   ├── lysozyme_job.yml
│   └── test_sequences/
├── docs/
│   ├── SCIENTIFIC_RATIONALE.md
│   ├── USER_GUIDE.md
│   └── OUTPUT_INTERPRETATION.md
└── tests/
    └── test_pipeline.sh
```

## Requirements

- cwltool >= 3.1
- Docker (for running containerized tools)
- GPU with CUDA support (for structure prediction)
- 64-96 GB RAM (depending on protein size)

## License

MIT License
