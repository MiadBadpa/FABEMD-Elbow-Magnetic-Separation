# FABEMD-Elbow: Fast and Fully-Automatic Scale Identification for Separation of Magnetic Anomaly in Complex Environments

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository contains the MATLAB implementation of the **FABEMD-Elbow** framework for automatic multiscale magnetic anomaly separation, as described in:

> **Badpa, M., Moradzadeh, A., Norouzi, G., & Roshandel Kahoo, A. (2026).** FABEMD-Elbow: Fast and Fully-Automatic Scale Identification for Separation of Magnetic Anomaly in Complex Environments. *Computers & Geosciences*.

## 📋 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Method Overview](#method-overview)
- [Code Structure](#code-structure)
- [Usage Examples](#usage-examples)
- [Output Files](#output-files)
- [Citation](#citation)
- [License](#license)
- [Contact](#contact)

## ✨ Features

- **Fully automatic** decomposition of magnetic grids using FABEMD
- **Objective IMF grouping** using automatic elbow-point detection
- **No user-defined thresholds** or manual intervention required
- **Adaptive selection** between `basic` and `regularized` modes
- **Robust performance** under varying noise conditions
- **Comprehensive diagnostics** (noise index, extrema density, gradient ratio)
- **Automatic report generation** (TXT, MAT, JPG, FIG formats)
- **Built-in correlation analysis** for validation

## 📦 Requirements

- MATLAB R2020a or later
- Image Processing Toolbox
- Signal Processing Toolbox (optional)

## 🚀 Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/MiadBadpa/FABEMD-Elbow-Magnetic-Separation.git
   cd FABEMD-Elbow-Magnetic-Separation
   ```

2. Add the `src/` folder to your MATLAB path:
   ```matlab
   addpath(genpath('FABEMD-Elbow-Magnetic-Separation/src/'))
   addpath(genpath('FABEMD-Elbow-Magnetic-Separation/scripts/'))
   ```

## ⚡ Quick Start

### Basic Usage

```matlab
% Load your magnetic grid (2D matrix)
load('your_magnetic_data.mat');  % variable 'image'

% Run adaptive FABEMD-Elbow framework
[imfs, info] = adaptive_fabemd(image, 20, 1);

% Get elbow point and depth components
[depth_results, elbow] = fabemd_depth_analysis(imfs, 'output_prefix');

% depth_results{1} = short-scale (Depth 1)
% depth_results{2} = long-scale (Depth 2)
```

### Using the Main Script

```matlab
% Run the interactive script
run_adaptive_fabemd
% Then select your .mat file containing the 2D magnetic grid
```

## 📁 Code Structure

```
src/
├── adaptive_fabemd.m          # Adaptive method selection
├── fabemd_basic.m             # Basic FABEMD implementation
├── fabemd_regularized.m       # Regularized FABEMD
├── fabemd_depth_analysis.m    # Depth analysis (basic)
├── fabemd_depth_analysis_regularized.m  # Depth analysis (regularized)
├── detect_elbow.m             # Automatic elbow-point detection
├── estimate_noise_index.m     # Noise index estimation
├── detrend_surface.m          # Polynomial trend removal
├── nn_min_distance.m          # Nearest-neighbor distance
└── make_odd_integer.m         # Utility function

scripts/
├── run_adaptive_fabemd.m      # Interactive main script
├── add_noise_and_trend.m      # Add synthetic noise
├── compute_depth_correlation.m # Correlation analysis
├── IMF_To_Lines.m             # Line profile extraction
└── Coordinate.m               # XYZ coordinate conversion
```

## 📤 Output Files

After running `run_adaptive_fabemd`, the following files are generated:

| File | Description |
|------|-------------|
| `Adaptive_Metadata.mat` | All diagnostic parameters |
| `Adaptive_Report_*.txt` | Human-readable report |
| `Original.*` | Original data image |
| `IMF_*.mat` | Each intrinsic mode function |
| `Residual.*` | Residual component |
| `*_PowerSpectrum.*` | IMF power spectrum with elbow |
| `*_Depth_1.*` | Short-scale (shallow) component |
| `*_Depth_2.*` | Long-scale (deep) component |

## 📊 Diagnostic Parameters

| Parameter | Description | Typical Range |
|-----------|-------------|---------------|
| Gradient Ratio | RMS gradient / data range | 0.01 - 0.05 |
| Extrema Density | Number of extrema / total pixels | 0.001 - 0.02 |
| Noise Index | FFT-based noise estimate | 0.002 - 0.38 |
| Elbow IMF | Automatic split point | 2 - 19 |

## 📝 Citation

If you use this code in your research, please cite:

```bibtex
@article{badpa2026fabemd,
  author    = {Badpa, M. and Moradzadeh, A. and Norouzi, G. and Roshandel Kahoo, A.},
  title     = {FABEMD-Elbow: Fast and Fully-Automatic Scale Identification for Separation of Magnetic Anomaly in Complex Environments},
  journal   = {Computers \& Geosciences},
  year      = {2026},
  doi       = {...}
}
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## 📧 Contact

**Corresponding Author:**  
Ali Moradzadeh  
📧 a_moradzadeh@ut.ac.ir  

**First Author:**  
Miad Badpa  
📧 miadbadpa@ut.ac.ir

## 🙏 Acknowledgments

The authors gratefully acknowledge Dr. Animesh Mandal and Dr. Shankho Niyogi for their foundational work on filter-assisted and fast BEMD, which inspired this study.
