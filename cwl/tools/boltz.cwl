#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

label: "Boltz-2 Structure Prediction"
doc: |
  Predicts protein structure using Boltz-2.
  Supports proteins, DNA, RNA, and ligands with optional constraints.
  Outputs PDB/mmCIF structure files.

requirements:
  DockerRequirement:
    dockerPull: dxkb/boltz-bvbrc:latest-gpu
  ResourceRequirement:
    coresMin: 4
    ramMin: 65536  # 64 GB
    tmpdirMin: 10240
  InlineJavascriptRequirement: {}

baseCommand: [boltz, predict]

inputs:
  input_file:
    type: File
    inputBinding:
      position: 1
    doc: "Input YAML or FASTA file with sequence(s)"

  output_dir:
    type: string
    default: "boltz_output"
    inputBinding:
      prefix: --out_dir
    doc: "Output directory name"

  use_msa_server:
    type: boolean
    default: true
    inputBinding:
      prefix: --use_msa_server
    doc: "Use MSA server for alignments"

  recycling_steps:
    type: int
    default: 3
    inputBinding:
      prefix: --recycling_steps
    doc: "Number of recycling steps"

  diffusion_samples:
    type: int
    default: 1
    inputBinding:
      prefix: --diffusion_samples
    doc: "Number of diffusion samples to generate"

  predict_affinity:
    type: boolean?
    inputBinding:
      prefix: --predict_affinity
    doc: "Predict binding affinity (if applicable)"

  output_format:
    type:
      type: enum
      symbols: [pdb, mmcif]
    default: pdb
    inputBinding:
      prefix: --output_format
    doc: "Output structure format"

outputs:
  structure_file:
    type: File
    outputBinding:
      glob: $(inputs.output_dir)/**/predictions/**/*.$(inputs.output_format)
    doc: "Predicted structure file"

  all_outputs:
    type: Directory
    outputBinding:
      glob: $(inputs.output_dir)
    doc: "All output files including confidence scores"

  confidence_scores:
    type: File?
    outputBinding:
      glob: $(inputs.output_dir)/**/predictions/**/*confidence*.json
    doc: "Per-residue confidence scores"

hints:
  cwltool:CUDARequirement:
    cudaVersionMin: "11.0"
    cudaComputeCapability: "7.0"
    cudaDeviceCountMin: 1
