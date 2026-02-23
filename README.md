# Decahedral_4D-STEM_2025

## Overview

Post-processing workflows for 4D-STEM strain mapping of decahedral nanoparticles.

This repository contains MATLAB scripts and a Jupyter notebook developed to analyze size-dependent pseudosymmetry and strain heterogeneity in five-twinned decahedral nanoparticles.

The code enables:

- Particle shape geometric measurement from μP-STEM HAADF images  
- 4D-STEM virtual dark field (VDF)–based particle masking  
- Azimuthal integration of lattice shear and rotation maps to calculate disclination misfit angle  
- Strain map post-processing and visualization  

The strain-mapping results processed in this repository are generated using the method described in:

Yuan, Renliang; Zhang, Jiong;  Zuo, Jian-Min "Lattice strain mapping using circular Hough transform for electron diffraction disk detection."  Ultramicroscopy *207*, **2019**, 112837.  (https://doi.org/10.1016/j.ultramic.2019.112837)

---

## Scientific Context

This repository accompanies the dataset:

Lin, Oliver; Lyu, Zhiheng; Ni, Hsu-Chih; Wang, Xiaokang; Jia, Yetong; Hwang, Chu-Yun; Yao, Lehan; Mandal, Sohini; Zuo, Jian-Min; Chen, Qian (2026).  Raw and Processed 4D-STEM Datasets for *"Each Grain Different in Its Own Way: Size-Dependent Pseudosymmetry in Five-Twinned Nanoparticles Mapped by 4D-STEM."*

Dataset DOI:  https://doi.org/10.13012/B2IDB-3832353_V1

Example data structure and sample files are available at the DOI above.

The associated manuscript is currently under revision at *Advanced Materials*. A detailed description of the experimental and analytical workflow is provided in the Supplementary Information of the manuscript.

---

## Requirements

### MATLAB

Tested with MATLAB R2024a.

Required toolboxes:

- Signal Processing Toolbox  
- Mapping Toolbox  
- Image Processing Toolbox  
- Statistics and Machine Learning Toolbox  

### Python (for `StrainMapProcessing.ipynb`)

Recommended environment:

- Python >= 3.9  
- numpy  
- scipy  
- matplotlib  
- h5py  
- pandas  
- jupyter  

---

## Repository Structure

- `ParticleShapeAnalysis/`  
- `AzimuIntegration.m`  
- `Masking.m`  
- `StrainMapProcessing.ipynb`  

---

## Script Descriptions

### ParticleShapeAnalysis

Developed by Dr. L. Yao

Performs geometric characterization of decahedral nanoparticles from image data.

#### Input

- 16-bit grayscale `.TIFF` images  
- One isolated particle per image (remove unwanted or overlapping particles prior to analysis)  
- All `.TIFF` images in the directory will be processed automatically  

All geometric measurements are computed in **pixels**.  
Pixel size calibration is defined during image acquisition and must be applied separately if conversion to physical units (e.g., nm) is required.

<details>
<summary><strong>Execution, Output, and Notes</strong></summary>

#### Execution

1. Place all 16-bit `.TIFF` images in the `ParticleShapeAnalysis/` directory.
2. Navigate to the directory in MATLAB.
3. Run the analysis script.

All `.TIFF` images in the directory will be processed sequentially.

#### Output

For each particle image:

- Geometric measurements are printed in the MATLAB command window.
- A processed `.tif` image is saved in the same directory.
- Output images include graphical annotations defining the extracted geometric quantities (e.g., edge length, tip truncation).

#### Notes

- Measurements are reported in pixels.
- Conversion to physical units must be performed separately using the known pixel size.
- Image contrast should be sufficient for reliable contour detection.
- Designed for isolated five-twinned decahedral nanoparticles.
- Segmentation and contour detection parameters can be fine-tuned within the script if necessary.

</details>

---

### AzimuIntegration.m

Performs azimuthal (angular) integration on real-space lattice shear and rotation maps obtained from 4D-STEM strain mapping.

#### Input

- MATLAB `.mat` files containing 2D real-space maps (Nx × Ny) of:
  - lattice shear (typically in %)
  - lattice rotation (typically in degrees)
- Maps are assumed to be grain-masked and combined after `Masking.m`.
- Requires the particle center provided by `Masking.m` (format as implemented in the code).

Shear/rotation units can be converted in the first part of the script if needed.

<details>
<summary><strong>Execution, Output, and Notes</strong></summary>

#### Execution

1. Ensure masked lattice shear/rotation maps (2D matrices) are available as `.mat` files.
2. Ensure the particle center from `Masking.m` is available in the required format.
3. Open MATLAB (tested in R2024a).
4. Run `AzimuIntegration.m` and set/confirm file paths and unit conversion options (if needed) in the first section of the script.

#### Output

- Figures showing azimuthally integrated values plotted versus angular angle (theta).
- Lattice shear and lattice rotation angular profiles are displayed side-by-side for comparison (as implemented in the script).

#### Notes

- This script operates on real-space strain-derived maps (shear/rotation), not diffraction patterns.
- Results depend critically on the particle center definition and coordinate convention used in `Masking.m`.
- Masked-out pixels should follow the convention expected by the script.
- Integration and plotting settings can be fine-tuned within the script if necessary.

</details>

---

### Masking.m

Generates particle and per-grain binary masks from virtual dark field (VDF) images for downstream strain-map analysis. A detailed description of the experimental and analytical workflow is provided in the Supplementary Information of the manuscript.

#### Input

- Grayscale VDF images in `.jpg` format for each grain, named as `<grainID>.jpg` (e.g., `3733.jpg`).
- A grayscale VDF image of the entire particle named `combined.jpg`.
- A user-defined list of five grain IDs in `grainIDs` (five-twinned decahedral nanoparticles).
- User-defined threshold values:
  - `grain_binary_thres` for grain mask binarization
  - `contour_binary_thres` for particle contour binarization
- Manually provided polygon coordinates for each grain (five grains total), using MATLAB image coordinates.

Coordinates are in pixels and follow MATLAB convention `(x, y)`.

<details>
<summary><strong>Execution, Output, and Notes</strong></summary>

#### Execution

1. Place all grain VDF `.jpg` images and `combined.jpg` in the same folder as `Masking.m`.
2. Set `grainIDs` (five grain IDs), `grain_binary_thres`, and `contour_binary_thres`.
3. Run the script to binarize each grain image and generate a combined grain mask.
4. Provide polygon coordinates (in MATLAB image coordinates) for each grain as required by the script.
5. Perform any manual refinements as instructed within the script.

#### Output

- Combined grain mask (variable: `Masking_Total`).
- Particle contour mask generated from `combined.jpg` (stored as a binary matrix in the MATLAB workspace; the script assigns a threshold-dependent variable name).
- Grain-specific masks generated during processing.

For downstream processing in `StrainMapProcessing.ipynb`, rename the finalized grain mask variables to:

- `Mask_<grainID>` (e.g., `Mask_3733`, `Mask_6311`, ...)

and save them in separate `.mat` files for import into the Jupyter notebook.

#### Notes

- Thresholds can be fine-tuned if needed to account for image contrast variations.
- This workflow assumes five grains corresponding to five-twinned decahedral nanoparticles.
- The script expects grayscale `.jpg` inputs and MATLAB coordinate conventions.

</details>

---

### StrainMapProcessing.ipynb

Jupyter notebook for post-processing and visualization of 4D-STEM strain-mapping results, including strain maps, pseudosymmetry maps, and displacement maps.

#### Input

The notebook requires:

- Diffraction disc coordinate file in `.mat` format generated by the 4D-STEM strain-mapping pipeline (https://doi.org/10.1016/j.ultramic.2019.112837).  
  - This file may be located in a different directory; the path is specified within the notebook.
- Grain labels (input manually within the notebook).
- Particle center coordinates (input manually within the notebook).

Coordinates are defined in **pixels**.  
The particle center is stored in MATLAB convention as `(x, y)` and converted appropriately for use in Python within the notebook.

<details>
<summary><strong>Execution, Output, and Notes</strong></summary>

#### Execution

1. Ensure the diffraction disc coordinate `.mat` file from the 4D-STEM strain-mapping pipeline is accessible.
2. Open `StrainMapProcessing.ipynb` in Jupyter.
3. Set file paths, grain labels, and particle center in the designated input cells.
4. Execute all cells sequentially from top to bottom.

The notebook is annotated, and the complete processing workflow can be reproduced by running all cells in order.

#### Output

The notebook generates:

- Strain maps  
- Pseudosymmetry maps  
- Displacement maps  
- Associated visualization figures  

All processed maps exist as numerical arrays within the notebook.  
Although automatic saving is not implemented by default, these arrays can be exported (e.g., as `.mat` files using `scipy.io.savemat` or other formats) if numerical output is required.

#### Notes

- Coordinates follow the original MATLAB convention `(x, y)` and are converted for Python indexing where necessary.
- All spatial quantities are in pixel units unless explicitly converted within the notebook.
- Consistency between grain labeling, particle center, and strain-mapping outputs is required.
- The workflow assumes inputs are produced by the referenced 4D-STEM strain-mapping program.

</details>
