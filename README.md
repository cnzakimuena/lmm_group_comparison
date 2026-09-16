# Linear Mixed-Effects Model for Group Comparison
Script to perform group comparisons using linear mixed-effects models ([Fan et al, 2011](https://doi.org/10.1167/iovs.10-7108)). Medical data from the PAPILA dataset ([Kovalyk et al, 2022](https://doi.org/10.1038/s41597-022-01388-1)) is used for demonstration. For a given model, the groups are designated as the fixed effect and subjects as the random effect. The model is given by the following equation,

$$
Y_{ij} = \beta_0 + \beta_1 \cdot \text{Group}_{ij} + u_{0i} + \epsilon_{ij}
$$

where $\beta_0$ is the intercept, $\beta_1$ is the fixed effect slope, $u_{0i}$ is the random effect for each subject ($i$), and $\epsilon_{ij}$ represents the residual error for each subject ($i$) and observation ($j$).

Dependencies installation:

```bash
renv::restore()
```

Usage:

```bash
source("lmm_group_comparison.R")
```

Cite As

[Nzakimuena, C. B., Solano, M. M., Marcotte-Collard, R., Lesk, M. R., & Costantino, S. (2025). Spatial and temporal changes in choroid morphology associated with long-duration spaceflight. Investigative Ophthalmology & Visual Science, 66(5), 17-17.](https://doi.org/10.1167/iovs.66.5.17)

### References

1. [Fan, Q., Teo, Y. Y., & Saw, S. M. (2011). Application of advanced statistics in ophthalmology. Investigative ophthalmology & visual science, 52(9), 6059-6065.](https://doi.org/10.1167/iovs.10-7108)
1. [Kovalyk, O., Morales-Sánchez, J., Verdú-Monedero, R., Sellés-Navarro, I., Palazón-Cabanes, A., & Sancho-Gómez, J. L. (2022). PAPILA: Dataset with fundus images and clinical data of both eyes of the same patient for glaucoma assessment. Scientific Data, 9(1), 291.](https://doi.org/10.1038/s41597-022-01388-1)
