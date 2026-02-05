#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

label: "App-StabiliNNator (Disulfide) - BV-BRC Application"
doc: |
  BV-BRC application wrapper for disulfiNNate analysis.
  Uses App-StabiliNNator.pl service script with analysis_type=disulfide.

  This tool is designed for use within the BV-BRC infrastructure
  and handles workspace file operations automatically.

requirements:
  DockerRequirement:
    dockerPull: dxkb/stabilinnator-bvbrc:latest-gpu
  ResourceRequirement:
    coresMin: 2
    ramMin: 16384
    tmpdirMin: 1024
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: params.json
        entry: |
          {
            "input_file": "$(inputs.input_file.path)",
            "output_path": "$(inputs.output_path)",
            "analysis_type": "disulfide"
          }
      - $(inputs.input_file)

baseCommand: [perl, /kb/module/service-scripts/App-StabiliNNator.pl]

arguments:
  - /kb/module/app_specs/StabiliNNator.json
  - params.json

inputs:
  input_file:
    type: File
    doc: "Input PDB or mmCIF structure file"

  output_path:
    type: string
    default: "./output"
    doc: "Output directory path"

outputs:
  annotated_structure:
    type: File
    outputBinding:
      glob: "output/*_disulfide.pdb"
    doc: "PDB with disulfide bond scores as B-factors"

  scores_csv:
    type: File
    outputBinding:
      glob: "output/*_disulfide.csv"
    doc: "Cysteine pair disulfide bond scores"

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
