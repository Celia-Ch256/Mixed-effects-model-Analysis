# Mixed-effects-model-Analysis

## Mixed-effects modelling of stiffness–displacement relationships across single-cell measurements

This repository provides a MATLAB implementation for analyzing stiffness–displacement relationships using linear mixed-effects models.

The script is designed for single-cell mechanical measurements, where multiple measurements are collected from individual cells across different biological replicates. The mixed-effects model accounts for both cell-to-cell variability and biological replicate variation, avoiding statistical bias caused by non-independent measurements.

## Model

The implemented model is:

```text
stiffness ~ displacement
           + (1|Replicate)
           + (1|Replicate:CellID)
```

where:

- `stiffness`: cellular stiffness measurements
- `displacement`: mechanical displacement values
- `Replicate`: biological replicate-level random effect
- `CellID`: individual cell-level random effect nested within replicates

## Input Data

The input dataset should contain:

| Variable | Description |
|----------|-------------|
| Replicate | Biological replicate ID |
| CellID | Individual cell ID |
| displacement | Measured displacement |
| stiffness | Calculated stiffness |

## Output

The program provides:

- Fixed-effect coefficient of displacement
- 95% confidence interval
- p-value
- Mixed-effects model fitting results

## Requirements

- MATLAB R2020b or later
- Statistics and Machine Learning Toolbox

## Application

This framework is suitable for analyzing hierarchical single-cell biomechanics datasets, including stiffness measurements obtained from AFM, optical tweezers, and other mechanical characterization methods.




