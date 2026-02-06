# Protein Engineering Workflows

## Project Overview

CWL workflows combining BV-BRC protein structure prediction tools (Boltz-2, Chai-1) with stability analysis (stabiliNNator) for protein engineering applications.

**Repository:** https://github.com/CEPI-dxkb/ProteinEngineeringWorkflows

## Key Components

### CWL Tools (`cwl/tools/`) - 9 total

#### Direct Command Tools
- `boltz.cwl` - Boltz-2 structure prediction (`boltz predict`)
- `chai.cwl` - Chai-1 structure prediction (`chai-lab`)
- `stabilinnator.cwl` - Combined stability analysis (dynamic command selection)
- `prolinnator.cwl` - Proline mutation analysis (`prolinnator`)
- `disulfinnate.cwl` - Disulfide bond analysis (`disulfinnate`)

#### BV-BRC App Script Tools
- `app-boltz.cwl` - Uses `App-Boltz.pl`
- `app-chai.cwl` - Uses `App-ChaiLab.pl`
- `app-prolinnator.cwl` - Uses `App-StabiliNNator.pl` (proline mode)
- `app-disulfinnate.cwl` - Uses `App-StabiliNNator.pl` (disulfide mode)

### CWL Workflows (`cwl/workflows/`) - 6 total

| Type | Boltz | Chai-1 |
|------|-------|--------|
| Simple (dynamic) | `protein_stability_pipeline.cwl` | `protein_stability_with_chai.cwl` |
| Explicit (parallel) | `protein_stability_explicit.cwl` | `protein_stability_explicit_chai.cwl` |
| App scripts | `protein_stability_app.cwl` | `protein_stability_app_chai.cwl` |

### Docker Images
- `dxkb/boltz-bvbrc:latest-gpu` - Boltz-2 with GPU support
- `dxkb/chai-bvbrc:latest-gpu` - Chai-1 with GPU support
- `dxkb/stabilinnator-bvbrc:latest-gpu` - stabiliNNator with GPU support

## Development Notes

### Running Workflows
```bash
# Simple pipeline (Boltz)
cwltool cwl/workflows/protein_stability_pipeline.cwl examples/crambin_job.yml

# Explicit parallel analysis (Chai-1)
cwltool cwl/workflows/protein_stability_explicit_chai.cwl examples/crambin_fasta_job.yml

# BV-BRC App script workflow
cwltool cwl/workflows/protein_stability_app.cwl examples/crambin_job.yml

# With Toil (for HPC)
toil-cwl-runner cwl/workflows/protein_stability_pipeline.cwl examples/crambin_job.yml
```

### Testing
```bash
./tests/test_pipeline.sh --quick  # Fast CWL validation (21 tests)
./tests/test_pipeline.sh          # Full test with real predictions
```

### CI/CD
GitHub Actions workflow validates all CWL files on push/PR to main.

### File Format Notes
- Boltz prefers YAML input format for complex molecules (constraints, ligands)
- Chai-1 uses FASTA format
- stabiliNNator accepts both PDB and mmCIF
- Output B-factors are in 0-1 range (not standard 0-100 crystallographic B-factors)

### Adding New Workflows
1. Create CWL file in `cwl/workflows/`
2. Run `cwltool --validate` to check syntax
3. Add to README Available Workflows table
4. Update Repository Structure section
5. Run `./tests/test_pipeline.sh --quick` to verify

## Related Repositories

- CEPI infrastructure: `/Users/me/Development/CEPI`
- Individual app containers in CEPI docker/ directory
- GitHub org: https://github.com/CEPI-dxkb
