# Intelligent Voice Identification System

A neural network-based system for voice pattern recognition and identification, focusing on vowel recognition and word pair analysis.

## Project Description

This intelligent system analyzes and identifies voice patterns using:

- Adaptive signal filtering (LMS, NLMS, RLS)
- Audio feature extraction
- Neural network classification

The system works with two types of audio samples:

1. Simple sounds (vowels: a, e, i)
2. Complex sounds (word pairs)

### Main Features:

- Advanced audio processing and filtering
- Voice pattern recognition
- Adaptive noise reduction
- Neural network learning and classification
- Comprehensive results visualization

## Requirements

- MATLAB R2023b or newer
- Signal Processing Toolbox
- Neural Network Toolbox
- Statistics and Machine Learning Toolbox

## Project Structure

```
intelligent-voice-identification-system/
├── voiceRecognition.m                # Main script for voice pattern recognition
├── preprocessAudio.m                 # Audio preprocessing and feature extraction
├── applyAdaptiveFilters.m            # Implementation of adaptive filters (LMS, NLMS, RLS)
├── normalizeFeatures.m               # Feature normalization functions
├── optimizeAdaptiveFilterParams.m    # Optimization of filter parameters
├── .gitignore                        # Git ignore file
├── README.md                         # Project documentation
└── data/                             # Audio samples directory
    ├── simple/                       # Simple sounds (vowels)
    └── complex/                      # Complex sounds (word pair)
```

## Installation and Setup

1. Clone the repository

```bash
git clone https://github.com/YourUsername/intelligent-voice-identification-system.git
cd intelligent-voice-identification-system
```

2. Install required MATLAB toolboxes:

   - Signal Processing Toolbox
   - Neural Network Toolbox
   - Statistics and Machine Learning Toolbox

3. Prepare the audio samples directory structure:

```
data/
├── simple/                # Simple sounds
│   ├── a/
│   │   └── a - normalnie/
│   │       └── Dźwięk {1..10}.wav
│   ├── e/
│   │   └── e - normalnie/
│   │       └── Dźwięk {1..10}.wav
│   └── i/
│       └── i - normalnie/
│           └── Dźwięk {1..10}.wav
└── complex/              # Word pairs
    └── pairs/
        └── Dźwięk {1..10}.wav
```

4. Record or prepare audio samples:

   - Simple sounds: Record vowels (a, e, i) in normal speaking voice
   - Complex sounds: Record word pairs
   - All recordings should be:
     - WAV format
     - 44.1 kHz sampling rate
     - 16-bit depth
     - Mono channel

5. Configure MATLAB paths:

   - Open MATLAB
   - Navigate to the project directory
   - Add project folder and subfolders to MATLAB path:

   ```matlab
   addpath(genpath('path/to/project'));
   ```

6. Run the main script:

```matlab
voiceRecognition.m
```

7. Check the output:
   - Preprocessed data will be saved in 'preprocessed_data.mat'
   - Trained network will be saved in 'trained_network.mat'
   - Results visualization will be displayed automatically

## System Output

The analysis provides:

- Voice pattern visualizations
- Feature distribution charts
- Classification confusion matrix
- Learning curve progression
- Detailed recognition statistics
- Performance metrics for both simple and complex sounds

## Results

The system generates comprehensive analysis including:

- Pattern recognition accuracy
- Voice feature distribution
- Classification performance matrix
- Per-sample statistics:
  - Recognition precision
  - Pattern recall rate
  - F1-Score metrics

## Contributing

Contributions are welcome. Please feel free to submit:

- Bug reports
- Feature requests
- Code improvements
- Documentation updates

## License

This project was created by PS. All rights reserved.
