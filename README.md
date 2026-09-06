# FMCW Radar Signal Processing Pipeline

![MATLAB](https://img.shields.io/badge/MATLAB-R2023b+-blue.svg)
![Simulink](https://img.shields.io/badge/Simulink-Simulation-success.svg)

## Overview
This repository contains a comprehensive Frequency Modulated Continuous Wave (FMCW) radar simulation and signal processing model. Developed using MATLAB and Simulink, the project simulates the complete radar signal chain—from Linear Frequency Modulation (LFM) chirp generation to target detection. 

The system leverages digital signal processing techniques to extract target range and radial velocity, featuring modular scripts for hardware-level analysis such as ADC gain calibration and bit-depth performance evaluation.

## Repository Structure

### Core Simulation & Project Files
*   **`Project_1.prj`**: The main MATLAB Project file. Open this to load all dependencies, path settings, and shortcut configurations for the radar model.
*   **`Model.slx`**: The primary Simulink system architecture. This model contains the block-level implementation of the radar transceiver, including Matched Filtering, Moving Target Indicator (MTI) cancellers, and Constant False Alarm Rate (CFAR) detection using sliding window taps.
*   **`radar_init.m`**: The master initialization script. Run this prior to simulation to populate the base workspace with critical parameters such as chirp bandwidth, sweep time, transmission power, and Time-Varying Gain (TVG) profiles.

### Signal Processing & Analysis Scripts
*   **`process_radar.m`**: The main execution script for processing the raw radar return data (beat frequencies) after simulation.
*   **`Range_Doppler_map.m`**: Generates a 2D FFT Range-Doppler visualization to simultaneously resolve the distance and velocity of detected targets.
*   **`windowing.m`**: Applies windowing functions (e.g., Hanning, Hamming, or Blackman) to the time-domain signal prior to FFT processing to mitigate spectral leakage and reduce sidelobe levels.

### Hardware Validation & Testing
*   **`calibrate_adc_gain.m`**: Script to calculate and calibrate the analog-to-digital converter (ADC) gain, ensuring accurate dynamic range for the digitized intermediate frequency (IF) signal.
*   **`run_bit_depth_sweep.m`**: Automates performance testing across various ADC bit depths to evaluate quantization noise limits and optimize the hardware design for digital ASIC implementation.

### Auxiliary Files
*   **`buildfile.m`**: Defines automated build tasks and testing routines for the MATLAB project.
*   **`Model.slxc`**: Compiled Simulink cache file (auto-generated to speed up simulation load times).
*   **`radar_init.asv`**: Autosave backup for the initialization script.
*   **`.gitattributes`**: Git configuration for line endings and repository language tracking.

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd <repository-name>
    ```

2.  **Open the Project:**
    Launch MATLAB and double-click `Project_1.prj` to load the environment.

3.  **Initialize Variables:**
    Run `radar_init.m` in the MATLAB command window to load the LFM chirp formulas, target definitions, and system parameters into the workspace.

4.  **Run the Simulink Model:**
    Open `Model.slx` and run the simulation to generate the target echo data.

5.  **Process Data:**
    Execute `process_radar.m` followed by `Range_Doppler_map.m` to visualize the final target detections.

## Key Technical Components
*   **Waveform Generation**: Synthesizes linear FMCW chirps optimized for specific range resolution requirements.
*   **Target Processing**: Extracts beat frequencies to calculate distance and utilizes phase shifts across multiple chirps to determine Doppler velocities.
*   **Quantization Analysis**: The included bit-depth sweeping tools allow for strict evaluation of Signal-to-Quantization-Noise Ratio (SQNR), directly supporting hardware engineering workflows.
