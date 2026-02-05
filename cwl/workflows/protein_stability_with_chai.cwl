#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

label: "Protein Stability Engineering Pipeline (Chai-1)"
doc: |
  Combined workflow for protein engineering using Chai-1:
  1. Predicts structure using Chai-1
  2. Analyzes stability using stabiliNNator

  Use this variant when:
  - You have FASTA input (Chai-1 native format)
  - You need template-based modeling via server
  - You prefer Chai-1's prediction characteristics

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
    doc: "Input FASTA file with protein sequence(s)"

  use_msa_server:
    type: boolean
    default: true
    doc: "Use MSA server for sequence alignments"

  use_templates:
    type: boolean
    default: true
    doc: "Use template structures from server"

  num_samples:
    type: int
    default: 1
    doc: "Number of structure samples to generate"

  pocket_constraints:
    type: File?
    doc: "Optional JSON file with pocket constraints"

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
    run: ../tools/chai.cwl
    in:
      input_file: sequence_file
      use_msa_server: use_msa_server
      use_templates: use_templates
      num_samples: num_samples
      pocket_constraints: pocket_constraints
      output_format: output_format
    out:
      - structure_file
      - all_outputs
      - pae_scores

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
    doc: "Chai-1 predicted structure"

  prediction_outputs:
    type: Directory
    outputSource: structure_prediction/all_outputs
    doc: "All Chai-1 outputs including PAE scores"

  pae_scores:
    type: File?
    outputSource: structure_prediction/pae_scores
    doc: "Predicted aligned error from Chai-1"

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
