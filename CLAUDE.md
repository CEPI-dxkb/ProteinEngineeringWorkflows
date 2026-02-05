# Protein Engineering Workflows

## Project Overview

CWL workflows combining BV-BRC protein structure prediction tools (Boltz-2, Chai-1) with stability analysis (stabiliNNator) for protein engineering applications.

## Key Components

### CWL Tools (`cwl/tools/`)
- `boltz.cwl` - Boltz-2 structure prediction (YAML/FASTA → PDB/mmCIF)
- `chai.cwl` - Chai-1 structure prediction (FASTA → PDB/mmCIF)
- `stabilinnator.cwl` - Stability analysis (PDB → annotated PDB with B-factors)

### CWL Workflows (`cwl/workflows/`)
- `protein_stability_pipeline.cwl` - Main pipeline: Boltz → stabiliNNator
- `protein_stability_with_chai.cwl` - Alternative: Chai-1 → stabiliNNator

### Docker Images
- `dxkb/boltz-bvbrc:latest-gpu` - Boltz-2 with GPU support
- `dxkb/chai-bvbrc:latest-gpu` - Chai-1 with GPU support
- `dxkb/stabilinnator-bvbrc:latest-gpu` - stabiliNNator with GPU support

## Development Notes

### Running Workflows
```bash
# With cwltool
cwltool cwl/workflows/protein_stability_pipeline.cwl examples/crambin_job.yml

# With Toil (for HPC)
toil-cwl-runner cwl/workflows/protein_stability_pipeline.cwl examples/crambin_job.yml
```

### Testing
```bash
./tests/test_pipeline.sh --quick  # Fast validation
./tests/test_pipeline.sh          # Full test with real predictions
```

### File Format Notes
- Boltz prefers YAML input format for complex molecules (constraints, ligands)
- Chai-1 uses FASTA format
- stabiliNNator accepts both PDB and mmCIF
- Output B-factors are in 0-1 range (not standard 0-100 crystallographic B-factors)

## Related Repositories

- CEPI infrastructure: `/Users/me/Development/CEPI`
- Individual app containers in CEPI docker/ directory
