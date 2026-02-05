#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

label: "App-Boltz - BV-BRC Boltz-2 Application"
doc: |
  BV-BRC application wrapper for Boltz-2 structure prediction.
  Uses App-Boltz.pl service script for BV-BRC integration.

  This tool is designed for use within the BV-BRC infrastructure
  and handles workspace file operations automatically.

requirements:
  DockerRequirement:
    dockerPull: dxkb/boltz-bvbrc:latest-gpu
  ResourceRequirement:
    coresMin: 4
    ramMin: 65536
    tmpdirMin: 10240
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: params.json
        entry: |
          {
            "input_file": "$(inputs.input_file.path)",
            "output_path": "$(inputs.output_path)",
            "diffusion_samples": $(inputs.diffusion_samples),
            "recycling_steps": $(inputs.recycling_steps),
            "use_msa_server": $(inputs.use_msa_server),
            "predict_affinity": $(inputs.predict_affinity),
            "output_format": "$(inputs.output_format)"
          }
      - $(inputs.input_file)

baseCommand: [perl, /kb/module/service-scripts/App-Boltz.pl]

arguments:
  - /kb/module/app_specs/Boltz.json
  - params.json

inputs:
  input_file:
    type: File
    doc: "Input YAML or FASTA file with sequence(s)"

  output_path:
    type: string
    default: "./output"
    doc: "Output directory path"

  use_msa_server:
    type: boolean
    default: true
    doc: "Use MSA server for alignments"

  recycling_steps:
    type: int
    default: 3
    doc: "Number of recycling steps"

  diffusion_samples:
    type: int
    default: 1
    doc: "Number of diffusion samples to generate"

  predict_affinity:
    type: boolean
    default: false
    doc: "Predict binding affinity (if applicable)"

  output_format:
    type: string
    default: "pdb"
    doc: "Output structure format (pdb or mmcif)"

outputs:
  structure_file:
    type: File
    outputBinding:
      glob: "output/**/*.$(inputs.output_format)"
    doc: "Predicted structure file"

  all_outputs:
    type: Directory
    outputBinding:
      glob: "output"
    doc: "All output files"

hints:
  cwltool:CUDARequirement:
    cudaVersionMin: "11.0"
    cudaComputeCapability: "7.0"
    cudaDeviceCountMin: 1
