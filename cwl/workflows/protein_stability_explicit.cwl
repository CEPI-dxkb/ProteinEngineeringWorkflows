#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

label: "Protein Stability Engineering Pipeline (Explicit Tools)"
doc: |
  Combined workflow for protein engineering with explicit tool calls:
  1. Predicts structure using Boltz-2
  2. Runs proliNNator for proline mutation analysis
  3. Runs disulfiNNate for disulfide bond analysis

  Steps 2 and 3 run in parallel after structure prediction completes.

  Outputs include:
  - Predicted 3D structure (PDB/mmCIF)
  - Proline-annotated structure with B-factor scores
  - Disulfide-annotated structure with B-factor scores
  - CSV files with detailed scores
  - Summary reports for both analyses

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
    type:
      type: enum
      symbols: [pdb, mmcif]
    default: pdb
    doc: "Structure output format"

  proline_output_prefix:
    type: string
    default: "proline"
    doc: "Output prefix for proline analysis files"

  disulfide_output_prefix:
    type: string
    default: "disulfide"
    doc: "Output prefix for disulfide analysis files"

steps:
  structure_prediction:
    run: ../tools/boltz.cwl
    in:
      input_file: sequence_file
      use_msa_server: use_msa_server
      recycling_steps: recycling_steps
      diffusion_samples: diffusion_samples
      output_format: output_format
    out:
      - structure_file
      - all_outputs
      - confidence_scores

  proline_analysis:
    run: ../tools/prolinnator.cwl
    in:
      input_file: structure_prediction/structure_file
      output_prefix: proline_output_prefix
    out:
      - annotated_structure
      - scores_csv
      - summary

  disulfide_analysis:
    run: ../tools/disulfinnate.cwl
    in:
      input_file: structure_prediction/structure_file
      output_prefix: disulfide_output_prefix
    out:
      - annotated_structure
      - scores_csv
      - summary

outputs:
  predicted_structure:
    type: File
    outputSource: structure_prediction/structure_file
    doc: "Boltz-2 predicted structure"

  prediction_outputs:
    type: Directory
    outputSource: structure_prediction/all_outputs
    doc: "All Boltz-2 outputs including confidence scores"

  confidence_scores:
    type: File?
    outputSource: structure_prediction/confidence_scores
    doc: "Per-residue confidence from Boltz-2"

  proline_annotated_structure:
    type: File
    outputSource: proline_analysis/annotated_structure
    doc: "Structure with proline mutation scores as B-factors"

  proline_scores:
    type: File
    outputSource: proline_analysis/scores_csv
    doc: "Per-residue proline mutation scores (CSV)"

  proline_summary:
    type: File?
    outputSource: proline_analysis/summary
    doc: "Summary of top proline mutation candidates"

  disulfide_annotated_structure:
    type: File
    outputSource: disulfide_analysis/annotated_structure
    doc: "Structure with disulfide bond scores as B-factors"

  disulfide_scores:
    type: File
    outputSource: disulfide_analysis/scores_csv
    doc: "Cysteine pair disulfide bond scores (CSV)"

  disulfide_summary:
    type: File?
    outputSource: disulfide_analysis/summary
    doc: "Summary of top disulfide bond candidates"
