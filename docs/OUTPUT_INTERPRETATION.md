# Output Interpretation Guide

## Understanding stabiliNNator Scores

### B-factor Encoding

The annotated PDB file uses the B-factor column (columns 61-66) to store stability scores:
- **Original meaning**: Crystallographic B-factors measure atomic displacement (typically 10-60 Å²)
- **Our encoding**: Stability probability scores (0.0-1.0 range)

When visualizing, set your color scale to 0-1, not the default B-factor range.

## Proline Mutation Scores

### File Format: `*_proline.csv`

```csv
chain,residue_num,residue_name,score,recommendation
A,15,ALA,0.78,HIGH
A,23,GLY,0.65,MODERATE
A,42,SER,0.31,LOW
```

### Score Interpretation

| Score Range | Recommendation | Action |
|-------------|----------------|--------|
| 0.8 - 1.0 | VERY HIGH | Prioritize for experimental testing |
| 0.6 - 0.8 | HIGH | Strong candidate |
| 0.4 - 0.6 | MODERATE | Consider if other options limited |
| 0.2 - 0.4 | LOW | Likely neutral or destabilizing |
| 0.0 - 0.2 | VERY LOW | Avoid - likely destabilizing |

### Biological Considerations

**Good candidates:**
- Residues in loops connecting secondary structures
- Positions with φ ≈ -60° in the structure
- Flexible regions (high B-factor in original structure)

**Avoid:**
- Helix N-cap positions (Pro disrupts helix initiation)
- β-strand positions (Pro can't form main-chain H-bonds)
- Active site or binding interface residues
- Positions involved in conformational changes

### Visualization in PyMOL

```python
# Load the annotated structure
load stability_annotated.pdb

# Color by proline score
spectrum b, blue_white_red, minimum=0, maximum=1

# Show high-scoring residues
select proline_candidates, b > 0.6
show sticks, proline_candidates
```

## Disulfide Bond Scores

### File Format: `*_disulfide.csv`

```csv
chain1,res1,chain2,res2,distance,score,recommendation
A,23,A,67,4.2,0.85,HIGH
A,8,A,121,5.1,0.72,HIGH
A,45,A,89,6.8,0.45,MODERATE
```

### Score Interpretation

| Score Range | Meaning |
|-------------|---------|
| 0.8 - 1.0 | Excellent geometry - minimal backbone adjustment needed |
| 0.6 - 0.8 | Good geometry - may need minor refinement |
| 0.4 - 0.6 | Moderate - will require backbone changes |
| 0.2 - 0.4 | Poor - geometry unfavorable |
| 0.0 - 0.2 | Very poor - not recommended |

### Distance Guidelines

| Distance Type | Ideal Range | Notes |
|---------------|-------------|-------|
| Cα-Cα | 4.4 - 6.8 Å | Primary geometric constraint |
| Cβ-Cβ | 3.5 - 4.5 Å | For proper S-S bond |
| Sγ-Sγ | 2.0 - 2.1 Å | Final bond distance |

### Implementation Considerations

**Mutations required:**
- If both positions are non-Cys: 2 mutations (X→Cys, Y→Cys)
- If one position is native Cys: 1 mutation
- If natural Cys pair exists: Consider if correctly paired

**Expression considerations:**
- Disulfides form in oxidizing environments (periplasm, ER)
- Cytoplasmic expression may require refolding
- Consider SHuffle strains for cytoplasmic disulfide formation

### Visualization in PyMOL

```python
# Load structure
load stability_annotated.pdb

# Show potential disulfide pairs
select cys_pair1, (chain A and resi 23) or (chain A and resi 67)
show sticks, cys_pair1
distance disulfide_1, chain A and resi 23 and name CB, chain A and resi 67 and name CB
```

## Summary Report

### File Format: `*_summary.txt`

```
PROTEIN STABILITY ENGINEERING SUMMARY
=====================================
Input: my_protein.pdb
Analysis: proline + disulfide

TOP PROLINE CANDIDATES
----------------------
Rank  Position  Score  Notes
1     A:ALA15   0.78   Loop region, good φ angle
2     A:GLY23   0.65   Flexible loop
3     A:SER42   0.61   Turn position

TOP DISULFIDE CANDIDATES
-------------------------
Rank  Pair           Distance  Score  Notes
1     A:23-A:67      4.2 Å     0.85   Good geometry
2     A:8-A:121      5.1 Å     0.72   Requires 2 mutations

RECOMMENDATIONS
---------------
- A:ALA15→PRO: High confidence, loop position
- A:23+A:67→CYS: High confidence, minimal adjustment
- Consider combining mutations for additive effects
```

## Combining with Confidence Scores

### Filtering by Structure Quality

Structure prediction confidence (pLDDT) affects stability prediction reliability:

| pLDDT Range | Quality | Stability Prediction |
|-------------|---------|---------------------|
| 90-100 | Very high | Highly reliable |
| 70-90 | Confident | Reliable |
| 50-70 | Low | Use with caution |
| < 50 | Very low | Not recommended |

### Practical Workflow

1. Load predicted structure
2. Color by pLDDT to identify confident regions
3. Load stability-annotated structure
4. Focus on high-scoring positions in high-confidence regions
5. Cross-reference with biological knowledge

## Expected Results for Test Proteins

### Crambin (1CRN)
- Native disulfides: Cys3-Cys40, Cys4-Cys32, Cys16-Cys26
- Expected: High disulfide scores for native pairs
- Proline: Limited candidates (already compact)

### Lysozyme (1LYZ)
- Native disulfides: 4 pairs
- Expected: Variable stability landscape
- Known stabilizing mutations in literature for comparison
