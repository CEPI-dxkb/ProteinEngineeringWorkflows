#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

label: "Chai-1 Structure Prediction"
doc: |
  Predicts protein structure using Chai-1 from Chai Labs.
  Supports proteins, DNA, RNA, and ligands.
  Outputs PDB/mmCIF structure files.

requirements:
  DockerRequirement:
    dockerPull: dxkb/chai-bvbrc:latest-gpu
  ResourceRequirement:
    coresMin: 4
    ramMin: 65536  # 64 GB
    tmpdirMin: 10240
  InlineJavascriptRequirement: {}

baseCommand: [chai-lab]

inputs:
  input_file:
    type: File
    inputBinding:
      position: 1
    doc: "Input FASTA file with sequence(s)"

  output_dir:
    type: string
    default: "chai_output"
    inputBinding:
      prefix: --output-dir
    doc: "Output directory name"

  num_samples:
    type: int
    default: 1
    inputBinding:
      prefix: --num-samples
    doc: "Number of structure samples to generate"

  use_msa_server:
    type: boolean
    default: true
    inputBinding:
      prefix: --use-msa-server
    doc: "Use MSA server for alignments"

  use_templates:
    type: boolean?
    inputBinding:
      prefix: --use-templates
    doc: "Use template structures from server"

  pocket_constraints:
    type: File?
    inputBinding:
      prefix: --pocket-constraints
    doc: "JSON file with pocket constraints"

  output_format:
    type:
      type: enum
      symbols: [pdb, mmcif]
    default: pdb
    inputBinding:
      prefix: --output-format
    doc: "Output structure format"

outputs:
  structure_file:
    type: File
    outputBinding:
      glob: $(inputs.output_dir)/**/*.$(inputs.output_format)
    doc: "Predicted structure file"

  all_outputs:
    type: Directory
    outputBinding:
      glob: $(inputs.output_dir)
    doc: "All output files including scores"

  pae_scores:
    type: File?
    outputBinding:
      glob: $(inputs.output_dir)/**/*pae*.json
    doc: "Predicted aligned error scores"

hints:
  cwltool:CUDARequirement:
    cudaVersionMin: "11.0"
    cudaComputeCapability: "7.0"
    cudaDeviceCountMin: 1
