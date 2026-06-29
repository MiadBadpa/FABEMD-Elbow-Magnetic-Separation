# FABEMD-Elbow-Magnetic-Separation
MATLAB implementation of FABEMD-Elbow for automatic multiscale magnetic anomaly separation
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
- Signal Processing Toolbox (optional, for additional utilities)

## 🚀 Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/[your-username]/FABEMD-Elbow-Magnetic-Separation.git
   cd FABEMD-Elbow-Magnetic-Separation
