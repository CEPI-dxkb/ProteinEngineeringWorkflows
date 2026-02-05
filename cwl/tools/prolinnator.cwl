#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

label: "proliNNator - Proline Mutation Analysis"
doc: |
  Identifies residues that would benefit from proline mutation.

  Proline's cyclic structure restricts backbone φ angle to ~-60°,
  reducing backbone entropy in the unfolded state and stabilizing
  the folded protein.

  Output B-factors represent probability scores (0-1 range).
  Higher scores indicate better candidates for Pro substitution.

requirements:
  DockerRequirement:
    dockerPull: dxkb/stabilinnator-bvbrc:latest-gpu
  ResourceRequirement:
    coresMin: 2
    ramMin: 16384
    tmpdirMin: 1024
  InitialWorkDirRequirement:
    listing:
      - $(inputs.input_file)

baseCommand: [prolinnator]

inputs:
  input_file:
    type: File
    inputBinding:
      position: 1
    doc: "Input PDB or mmCIF structure file"

  output_prefix:
    type: string
    default: "proline"
    inputBinding:
      prefix: --output
      position: 2
    doc: "Output file prefix"

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
      glob: "$(inputs.output_prefix)_proline.pdb"
    doc: "PDB with B-factors replaced by proline mutation scores"

  scores_csv:
    type: File
    outputBinding:
      glob: "$(inputs.output_prefix)_proline.csv"
    doc: "Per-residue proline mutation scores"

  summary:
    type: File?
    outputBinding:
      glob: "$(inputs.output_prefix)_proline_summary.txt"
    doc: "Summary of top proline mutation candidates"

hints:
  cwltool:CUDARequirement:
    cudaVersionMin: "11.0"
    cudaComputeCapability: "7.0"
    cudaDeviceCountMin: 1
