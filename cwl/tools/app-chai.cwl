#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

label: "App-ChaiLab - BV-BRC Chai-1 Application"
doc: |
  BV-BRC application wrapper for Chai-1 structure prediction.
  Uses App-ChaiLab.pl service script for BV-BRC integration.

  This tool is designed for use within the BV-BRC infrastructure
  and handles workspace file operations automatically.

requirements:
  DockerRequirement:
    dockerPull: dxkb/chai-bvbrc:latest-gpu
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
            "num_samples": $(inputs.num_samples),
            "use_msa_server": $(inputs.use_msa_server),
            "use_templates": $(inputs.use_templates),
            "output_format": "$(inputs.output_format)"
          }
      - $(inputs.input_file)

baseCommand: [perl, /kb/module/service-scripts/App-ChaiLab.pl]

arguments:
  - /kb/module/app_specs/ChaiLab.json
  - params.json

inputs:
  input_file:
    type: File
    doc: "Input FASTA file with sequence(s)"

  output_path:
    type: string
    default: "./output"
    doc: "Output directory path"

  num_samples:
    type: int
    default: 1
    doc: "Number of structure samples to generate"

  use_msa_server:
    type: boolean
    default: true
    doc: "Use MSA server for alignments"

  use_templates:
    type: boolean
    default: true
    doc: "Use template structures from server"

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
