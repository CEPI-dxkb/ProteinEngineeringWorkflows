#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

label: "disulfiNNate - Disulfide Bond Analysis"
doc: |
  Identifies cysteine pairs suitable for engineered disulfide bonds.

  Disulfide bonds are covalent cross-links that reduce conformational
  entropy of the unfolded state, increasing protein stability by
  2-5 kcal/mol per bond.

  Output scores represent probability (0-1 range) that a Cys pair
  would form a favorable disulfide bond geometry.

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

baseCommand: [disulfinnate]

inputs:
  input_file:
    type: File
    inputBinding:
      position: 1
    doc: "Input PDB or mmCIF structure file"

  output_prefix:
    type: string
    default: "disulfide"
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

  max_distance:
    type: float?
    inputBinding:
      prefix: --max-distance
    doc: "Maximum Cα-Cα distance to consider (default: 8.0 Å)"

outputs:
  annotated_structure:
    type: File
    outputBinding:
      glob: "$(inputs.output_prefix)_disulfide.pdb"
    doc: "PDB with B-factors indicating disulfide potential"

  scores_csv:
    type: File
    outputBinding:
      glob: "$(inputs.output_prefix)_disulfide.csv"
    doc: "Cysteine pair scores for disulfide bond formation"

  summary:
    type: File?
    outputBinding:
      glob: "$(inputs.output_prefix)_disulfide_summary.txt"
    doc: "Summary of top disulfide bond candidates"

hints:
  cwltool:CUDARequirement:
    cudaVersionMin: "11.0"
    cudaComputeCapability: "7.0"
    cudaDeviceCountMin: 1
