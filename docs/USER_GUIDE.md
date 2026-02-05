# User Guide

## Prerequisites

### Software Requirements
- Python 3.8+
- cwltool >= 3.1 (`pip install cwltool`)
- Docker (for containerized tools)
- NVIDIA GPU with CUDA 11.0+ (for structure prediction)

### Hardware Requirements
- RAM: 64-96 GB (structure prediction is memory-intensive)
- GPU: NVIDIA A100 or equivalent (40+ GB VRAM recommended)
- Storage: 10+ GB per job (for model weights and outputs)

## Installation

```bash
# Clone the repository
git clone https://github.com/your-org/ProteinEngineeringWorkflows.git
cd ProteinEngineeringWorkflows

# Install cwltool
pip install cwltool

# Verify Docker images are available
docker pull dxkb/boltz-bvbrc:latest-gpu
docker pull dxkb/chai-bvbrc:latest-gpu
docker pull dxkb/stabilinnator-bvbrc:latest-gpu
```

## Quick Start

### Running the Boltz Pipeline

```bash
# Navigate to repository
cd ProteinEngineeringWorkflows

# Run with crambin example
cwltool cwl/workflows/protein_stability_pipeline.cwl examples/crambin_job.yml

# Output files will be created in current directory
```

### Running the Chai-1 Pipeline

```bash
cwltool cwl/workflows/protein_stability_with_chai.cwl examples/crambin_fasta_job.yml
```

## Input Preparation

### For Boltz-2 (YAML Format)

```yaml
version: 1
sequences:
  - protein:
      id: my_protein
      sequence: MVLSPADKTNVKAAWGKVGAHAGEYGAEALERMFLSFPTTKTYFPHFDLSH
```

For complexes:
```yaml
version: 1
sequences:
  - protein:
      id: chain_A
      sequence: MVLSPADKTNVKAAWGKVGAHAGEYGAEALERMFLSFPTTKTYFPHFDLSH
  - protein:
      id: chain_B
      sequence: MVHLTPEEKSAVTALWGKVNVDEVGGEALGRLLVVYPWTQRFFESFGDLST
```

### For Chai-1 (FASTA Format)

```
>my_protein
MVLSPADKTNVKAAWGKVGAHAGEYGAEALERMFLSFPTTKTYFPHFDLSH
```

For complexes (multi-sequence FASTA):
```
>chain_A
MVLSPADKTNVKAAWGKVGAHAGEYGAEALERMFLSFPTTKTYFPHFDLSH
>chain_B
MVHLTPEEKSAVTALWGKVNVDEVGGEALGRLLVVYPWTQRFFESFGDLST
```

## Job Configuration

### Full Job File Options (Boltz)

```yaml
# Input sequence file
sequence_file:
  class: File
  path: /path/to/sequence.yaml

# Structure prediction options
use_msa_server: true      # Use MSA server (recommended for accuracy)
recycling_steps: 3        # Boltz recycling iterations
diffusion_samples: 1      # Number of structure samples
predict_affinity: false   # Affinity prediction for complexes
output_format: pdb        # pdb or mmcif

# Stability analysis options
analysis_type: both       # proline, disulfide, or both
```

### Full Job File Options (Chai-1)

```yaml
sequence_file:
  class: File
  path: /path/to/sequence.fasta

use_msa_server: true
use_templates: true       # Use template structures
num_samples: 1
pocket_constraints:       # Optional constraint file
  class: File
  path: /path/to/constraints.json
output_format: pdb

analysis_type: both
```

## Running on HPC

### With Toil (SLURM)

```bash
# Install Toil
pip install toil[cwl]

# Run with SLURM
toil-cwl-runner \
  --batchSystem slurm \
  --singularity \
  --jobStore ./jobstore \
  cwl/workflows/protein_stability_pipeline.cwl \
  examples/lysozyme_job.yml
```

### With SLURM Wrapper Script

```bash
#!/bin/bash
#SBATCH --job-name=protein_stability
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=96G
#SBATCH --gres=gpu:1
#SBATCH --time=4:00:00

module load cuda/11.8
module load singularity

cwltool \
  --singularity \
  --cachedir /scratch/$USER/cwl_cache \
  cwl/workflows/protein_stability_pipeline.cwl \
  my_job.yml
```

## Output Files

After successful execution, you'll have:

| File | Description |
|------|-------------|
| `*_predicted.pdb` | Boltz/Chai predicted structure |
| `*_annotated.pdb` | Structure with stability B-factors |
| `*_proline.csv` | Per-residue proline mutation scores |
| `*_disulfide.csv` | Cysteine pair disulfide scores |
| `*_summary.txt` | Top engineering candidates |

## Troubleshooting

### Out of Memory
- Reduce `diffusion_samples` to 1
- Disable MSA server for initial testing
- Use a machine with more RAM

### GPU Not Found
- Ensure NVIDIA drivers are installed
- Check `nvidia-smi` output
- Verify Docker has GPU access: `docker run --gpus all nvidia/cuda:11.8-base nvidia-smi`

### CWL Validation Errors
```bash
# Validate workflow syntax
cwltool --validate cwl/workflows/protein_stability_pipeline.cwl
```

### Docker Image Issues
```bash
# Check if images exist
docker images | grep dxkb

# Pull latest versions
docker pull dxkb/boltz-bvbrc:latest-gpu
```
