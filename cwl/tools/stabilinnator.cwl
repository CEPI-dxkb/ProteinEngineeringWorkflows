#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

label: "stabiliNNator Stability Analysis"
doc: |
  Analyzes protein structure for stability engineering opportunities.

  proliNNator: Identifies residues that would benefit from proline mutation
  (reduces backbone flexibility, increases stability).

  disulfiNNate: Identifies cysteine pairs suitable for engineered disulfide
  bonds (cross-links that stabilize structure).

  Output B-factors represent probability scores (0-1 range).

requirements:
  DockerRequirement:
    dockerPull: dxkb/stabilinnator-bvbrc:latest-gpu
  ResourceRequirement:
    coresMin: 2
    ramMin: 16384  # 16 GB
    tmpdirMin: 1024
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.input_file)

baseCommand: []

arguments:
  - valueFrom: |
      ${
        if (inputs.analysis_type === "proline") {
          return "prolinnator";
        } else if (inputs.analysis_type === "disulfide") {
          return "disulfinnate";
        } else {
          return "run_both_analyses.sh";
        }
      }
    position: 0

inputs:
  input_file:
    type: File
    inputBinding:
      position: 1
    doc: "Input PDB or mmCIF structure file"

  output_prefix:
    type: string
    default: "stability"
    inputBinding:
      prefix: --output
      position: 2
    doc: "Output file prefix"

  analysis_type:
    type:
      type: enum
      symbols: [proline, disulfide, both]
    default: both
    doc: "Type of stability analysis to perform"

  chain:
    type: string?
    inputBinding:
      prefix: --chain
    doc: "Specific chain to analyze (default: all chains)"

  threshold:
    type: float?
    inputBinding:
      prefix: --threshold
    doc: "Score threshold for reporting candidates"

outputs:
  annotated_structure:
    type: File
    outputBinding:
      glob: "$(inputs.output_prefix)_annotated.pdb"
    doc: "PDB with B-factors replaced by stability scores"

  proline_scores:
    type: File?
    outputBinding:
      glob: "$(inputs.output_prefix)_proline.csv"
    doc: "Per-residue proline mutation scores"

  disulfide_scores:
    type: File?
    outputBinding:
      glob: "$(inputs.output_prefix)_disulfide.csv"
    doc: "Cysteine pair disulfide bond scores"

  summary_report:
    type: File?
    outputBinding:
      glob: "$(inputs.output_prefix)_summary.txt"
    doc: "Summary of top engineering candidates"

hints:
  cwltool:CUDARequirement:
    cudaVersionMin: "11.0"
    cudaComputeCapability: "7.0"
    cudaDeviceCountMin: 1
