#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

label: "Protein Stability Engineering Pipeline (BV-BRC App Scripts)"
doc: |
  Combined workflow for protein engineering using BV-BRC App scripts.

  This workflow uses the official BV-BRC application wrappers:
  - App-Boltz.pl for structure prediction
  - App-StabiliNNator.pl for stability analyses

  Designed for integration with BV-BRC infrastructure and workspace
  file handling.

  Steps:
  1. Predicts structure using App-Boltz.pl
  2. Runs App-StabiliNNator.pl (proline mode) for proline mutation analysis
  3. Runs App-StabiliNNator.pl (disulfide mode) for disulfide bond analysis

  Steps 2 and 3 run in parallel after structure prediction completes.

requirements:
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  sequence_file:
    type: File
    doc: "Input YAML or FASTA file with protein sequence(s)"

  use_msa_server:
    type: boolean
    default: true
    doc: "Use MSA server for sequence alignments"

  recycling_steps:
    type: int
    default: 3
    doc: "Number of Boltz recycling steps"

  diffusion_samples:
    type: int
    default: 1
    doc: "Number of structure samples to generate"

  output_format:
    type: string
    default: "pdb"
    doc: "Structure output format (pdb or mmcif)"

steps:
  structure_prediction:
    run: ../tools/app-boltz.cwl
    in:
      input_file: sequence_file
      use_msa_server: use_msa_server
      recycling_steps: recycling_steps
      diffusion_samples: diffusion_samples
      output_format: output_format
    out:
      - structure_file
      - all_outputs

  proline_analysis:
    run: ../tools/app-prolinnator.cwl
    in:
      input_file: structure_prediction/structure_file
    out:
      - annotated_structure
      - scores_csv
      - all_outputs

  disulfide_analysis:
    run: ../tools/app-disulfinnate.cwl
    in:
      input_file: structure_prediction/structure_file
    out:
      - annotated_structure
      - scores_csv
      - all_outputs

outputs:
  predicted_structure:
    type: File
    outputSource: structure_prediction/structure_file
    doc: "Boltz-2 predicted structure"

  prediction_outputs:
    type: Directory
    outputSource: structure_prediction/all_outputs
    doc: "All Boltz-2 outputs"

  proline_annotated_structure:
    type: File
    outputSource: proline_analysis/annotated_structure
    doc: "Structure with proline mutation scores as B-factors"

  proline_scores:
    type: File
    outputSource: proline_analysis/scores_csv
    doc: "Per-residue proline mutation scores (CSV)"

  proline_outputs:
    type: Directory
    outputSource: proline_analysis/all_outputs
    doc: "All proline analysis outputs"

  disulfide_annotated_structure:
    type: File
    outputSource: disulfide_analysis/annotated_structure
    doc: "Structure with disulfide bond scores as B-factors"

  disulfide_scores:
    type: File
    outputSource: disulfide_analysis/scores_csv
    doc: "Cysteine pair disulfide bond scores (CSV)"

  disulfide_outputs:
    type: Directory
    outputSource: disulfide_analysis/all_outputs
    doc: "All disulfide analysis outputs"
