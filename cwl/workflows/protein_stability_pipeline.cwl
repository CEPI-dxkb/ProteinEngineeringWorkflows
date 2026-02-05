#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

label: "Protein Stability Engineering Pipeline (Boltz)"
doc: |
  Combined workflow for protein engineering:
  1. Predicts structure using Boltz-2
  2. Analyzes stability using stabiliNNator

  Outputs include:
  - Predicted 3D structure (PDB/mmCIF)
  - Stability-annotated structure with B-factor scores
  - Proline mutation candidates (CSV)
  - Disulfide bond candidates (CSV)
  - Engineering summary report

requirements:
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

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

  predict_affinity:
    type: boolean
    default: false
    doc: "Predict binding affinity (for complexes)"

  analysis_type:
    type:
      type: enum
      symbols: [proline, disulfide, both]
    default: both
    doc: "Type of stability analysis: proline, disulfide, or both"

  output_format:
    type:
      type: enum
      symbols: [pdb, mmcif]
    default: pdb
    doc: "Structure output format"

steps:
  structure_prediction:
    run: ../tools/boltz.cwl
    in:
      input_file: sequence_file
      use_msa_server: use_msa_server
      recycling_steps: recycling_steps
      diffusion_samples: diffusion_samples
      predict_affinity: predict_affinity
      output_format: output_format
    out:
      - structure_file
      - all_outputs
      - confidence_scores

  stability_analysis:
    run: ../tools/stabilinnator.cwl
    in:
      input_file: structure_prediction/structure_file
      analysis_type: analysis_type
    out:
      - annotated_structure
      - proline_scores
      - disulfide_scores
      - summary_report

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

  stability_annotated_structure:
    type: File
    outputSource: stability_analysis/annotated_structure
    doc: "Structure with stability scores as B-factors"

  proline_candidates:
    type: File?
    outputSource: stability_analysis/proline_scores
    doc: "Residues ranked for proline mutation"

  disulfide_candidates:
    type: File?
    outputSource: stability_analysis/disulfide_scores
    doc: "Cysteine pairs ranked for disulfide bonds"

  engineering_summary:
    type: File?
    outputSource: stability_analysis/summary_report
    doc: "Summary of top engineering candidates"
