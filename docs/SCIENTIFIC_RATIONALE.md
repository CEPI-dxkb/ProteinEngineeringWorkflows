# Scientific Rationale

## Why Combine Structure Prediction with Stability Analysis?

Protein engineering for improved stability traditionally requires:
1. **Experimental structure** - X-ray crystallography or cryo-EM (expensive, slow)
2. **Computational analysis** - Identify stabilizing mutations
3. **Experimental validation** - Express, purify, characterize mutants

This workflow accelerates the process by:
1. **Predicted structure** - AI-based structure prediction (fast, no wet lab)
2. **Automated stability analysis** - ML-based identification of stabilizing sites
3. **Prioritized candidates** - Focus experimental effort on high-scoring positions

## Structure Prediction: Boltz-2 vs Chai-1

### When to Use Boltz-2 (Default)
- Complex molecules with constraints or covalent modifications
- Protein-ligand complexes requiring affinity prediction
- When YAML input format is preferred for flexibility
- Multi-chain complexes with specific interaction requirements

### When to Use Chai-1
- Simple protein sequences in FASTA format
- When template-based modeling via server is desired
- When Chai-1's specific prediction characteristics are preferred

Both predictors achieve similar accuracy for standard proteins.

## Stability Analysis: stabiliNNator

### proliNNator - Proline Mutation Prediction

**Scientific Basis:**
Proline has a unique cyclic structure that restricts backbone φ angle to ~-60°. Introducing proline:
- Reduces backbone entropy in the unfolded state
- Stabilizes the folded state relative to unfolded
- Works best at positions with compatible backbone angles

**Algorithm:**
Deep learning model trained on experimental stability data predicts which residues would benefit from Pro substitution.

**Interpretation:**
- Score 0.0-0.3: Low probability - mutation likely destabilizing
- Score 0.3-0.6: Moderate - worth experimental testing
- Score 0.6-1.0: High probability - strong stabilization candidate

**Caveats:**
- Avoid positions in secondary structure elements (α-helix, β-sheet cores)
- Proline disrupts hydrogen bonding patterns
- Check for steric clashes after mutation

### disulfiNNate - Disulfide Bond Engineering

**Scientific Basis:**
Disulfide bonds are covalent cross-links between cysteine residues that:
- Reduce conformational entropy of unfolded state
- Can increase ΔG_folding by 2-5 kcal/mol per bond
- Most effective when linking regions far apart in sequence

**Algorithm:**
ML model predicts Cβ-Cβ distances and χ1/χ2 dihedral compatibilities for potential Cys pairs.

**Interpretation:**
- Score 0.0-0.3: Low probability - geometry incompatible
- Score 0.3-0.6: Moderate - may require backbone adjustments
- Score 0.6-1.0: High probability - favorable geometry

**Ideal Disulfide Geometry:**
- Cα-Cα distance: 4.4-6.8 Å
- Cβ-Cβ distance: 3.5-4.5 Å
- χ3 dihedral: ±90°

**Caveats:**
- Introducing 2 Cys mutations (or 1 if native Cys exists)
- Requires oxidizing conditions for bond formation
- May affect protein expression if formed incorrectly

## Workflow Design Considerations

### Why Sequential Execution?

The workflow runs structure prediction before stability analysis because:
1. stabiliNNator requires 3D coordinates as input
2. Stability scores depend on the predicted conformation
3. No parallelization benefit - must be sequential

### Output Integration

The B-factor column in the output PDB contains stability scores:
- Enables visualization in molecular graphics software (PyMOL, ChimeraX)
- Color by B-factor shows stabilization potential
- High B-factor residues = high engineering priority

### Confidence Filtering

Consider filtering stability predictions by structure confidence:
- Low pLDDT regions may have incorrect conformations
- Stability predictions in disordered regions less reliable
- Focus engineering on well-predicted structured regions

## References

1. Boltz-2: [Chai/Boltz paper]
2. Chai-1: [Chai Labs paper]
3. Proline stabilization: Matthews, B.W. (1987) Biochemistry
4. Disulfide engineering: Dombkowski, A.A. (2003) Protein Engineering
5. stabiliNNator methodology: [stabiliNNator paper]
