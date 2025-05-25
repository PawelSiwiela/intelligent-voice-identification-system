# Intelligent Voice Identification System

A neural network-based system for voice pattern recognition and identification, focusing on vowel recognition and voice command analysis using advanced adaptive filtering techniques.

## Project Description

This intelligent system analyzes and identifies voice patterns using:

- **Adaptive signal filtering** (LMS, NLMS, RLS)
- **Advanced audio feature extraction** (FFT, MFCC, envelope analysis)
- **Neural network classification** (feedforward networks)
- **Comprehensive logging and monitoring** system

The system works with two types of audio samples:

1. **Simple sounds** (vowels: a, e, i)
2. **Complex voice commands** (word pairs: turn on/off light, open/close door, etc.)

### 🚀 Main Features

- ✅ Advanced audio processing with adaptive filters
- ✅ Automatic filter parameter optimization
- ✅ 18+ characteristic signal features extraction
- ✅ Data normalization and preprocessing
- ✅ Neural network training with validation
- ✅ Results visualization and confusion matrices
- ✅ Detailed logging and debugging system
- ✅ Graphical progress interface
- ✅ Error handling and process interruption support

## Requirements

- **MATLAB R2023b** or newer
- **Signal Processing Toolbox**
- **Neural Network Toolbox** (Deep Learning Toolbox)
- **Statistics and Machine Learning Toolbox**

## Project Structure

```
intelligent-voice-identification-system/
├── main.m                           # 🚀 Main launcher script
├── README.md                        # 📖 Project documentation
├── .gitignore                       # 🚫 Git ignore rules
│
├── src/                             # 📂 Source code
│   ├── core/                        # 🧠 Core system functions
│   │   ├── voiceRecognition.m       # Main recognition logic
│   │   ├── loadAudioData.m          # Data loading and processing
│   │   └── trainNeuralNetwork.m     # Neural network training
│   │
│   ├── audio/                       # 🎵 Audio processing
│   │   ├── preprocessAudio.m        # Preprocessing and feature extraction
│   │   ├── applyAdaptiveFilters.m   # Adaptive filters implementation
│   │   ├── optimizeAdaptiveFilterParams.m # Parameter optimization
│   │   └── normalizeFeatures.m      # Feature normalization
│   │
│   ├── utils/                       # 🔧 Utility functions
│   │   ├── writeLog.m               # Logging system
│   │   ├── logInfo.m, logError.m    # Logging functions
│   │   ├── closeLog.m               # Log finalization
│   │   └── displayFinalSummary.m    # Results summary
│   │
│   └── gui/                         # 🖥️ Graphical interface
│       ├── createProgressWindow.m   # Progress window
│       ├── updateProgress.m         # Progress updates
│       └── stopProcessing.m         # Process termination
│
├── data/                            # 📊 Audio samples
│   ├── simple/                      # Simple sounds (vowels)
│   │   ├── a/                       # Vowel 'a' samples
│   │   │   ├── normalnie/           # Normal speaking pace
│   │   │   │   ├── Dźwięk 1.wav
│   │   │   │   ├── Dźwięk 2.wav
│   │   │   │   ├── ...
│   │   │   │   └── Dźwięk 10.wav
│   │   │   └── szybko/              # Fast speaking pace
│   │   │       ├── Dźwięk 1.wav
│   │   │       ├── Dźwięk 2.wav
│   │   │       ├── ...
│   │   │       └── Dźwięk 10.wav
│   │   │
│   │   ├── e/                       # Vowel 'e' samples
│   │   │   ├── normalnie/           # Normal pace (10 files)
│   │   │   └── szybko/              # Fast pace (10 files)
│   │   │
│   │   └── i/                       # Vowel 'i' samples
│   │       ├── normalnie/           # Normal pace (10 files)
│   │       └── szybko/              # Fast pace (10 files)
│   │
│   └── complex/                     # Complex voice commands
│       ├── Drzwi/                   # Door commands
│       │   ├── Otwórz drzwi/        # "Open door" command
│       │   │   ├── normalnie/       # Normal pace
│       │   │   │   ├── Dźwięk 1.wav
│       │   │   │   ├── ...
│       │   │   │   └── Dźwięk 10.wav
│       │   │   └── szybko/          # Fast pace (10 files)
│       │   │
│       │   └── Zamknij drzwi/       # "Close door" command
│       │       ├── normalnie/       # Normal pace (10 files)
│       │       └── szybko/          # Fast pace (10 files)
│       │
│       ├── Odbiornik/               # Receiver commands
│       │   ├── Włącz odbiornik/     # "Turn on receiver"
│       │   │   ├── normalnie/       # Normal pace (10 files)
│       │   │   └── szybko/          # Fast pace (10 files)
│       │   └── Wyłącz odbiornik/    # "Turn off receiver"
│       │       ├── normalnie/       # Normal pace (10 files)
│       │       └── szybko/          # Fast pace (10 files)
│       │
│       ├── Światło/                 # Light commands
│       │   ├── Włącz światło/       # "Turn on light"
│       │   │   ├── normalnie/       # Normal pace (10 files)
│       │   │   └── szybko/          # Fast pace (10 files)
│       │   └── Wyłącz światło/      # "Turn off light"
│       │       ├── normalnie/       # Normal pace (10 files)
│       │       └── szybko/          # Fast pace (10 files)
│       │
│       └── Temperatura/             # Temperature commands
│           ├── Zwiększ temperaturę/ # "Increase temperature"
│           │   ├── normalnie/       # Normal pace (10 files)
│           │   └── szybko/          # Fast pace (10 files)
│           └── Zmniejsz temperaturę/ # "Decrease temperature"
│               ├── normalnie/       # Normal pace (10 files)
│               └── szybko/          # Fast pace (10 files)
│
└── output/                          # 📈 Results and output data
    ├── preprocessed/                # Processed data (.mat files)
    ├── networks/                    # Trained networks (.mat files)
    ├── results/                     # Analysis results
    └── logs/                        # Log files (.log)
```

### 📊 Data Summary

**Total Audio Samples:**

- **Simple sounds:** 3 vowels × 2 paces × 10 files = **60 samples**
- **Complex commands:** 4 categories × 2 commands × 2 paces × 10 files = **160 samples**
- **Grand total:** **220 audio samples**

**File Specifications:**

- **Format:** WAV
- **Sample Rate:** 44.1 kHz
- **Bit Depth:** 16-bit
- **Channels:** Mono
- **Naming Convention:** `Dźwięk X.wav` (where X = 1-10)

## Installation and Setup

### 1. Clone the repository

```bash
git clone https://github.com/PawelSiwiela/intelligent-voice-identification-system.git
cd intelligent-voice-identification-system
```

### 2. Audio Sample Preparation

Record or prepare audio samples following this structure:

**📋 Technical Requirements:**

- Format: **WAV**
- Sample Rate: **44.1 kHz**
- Bit Depth: **16-bit**
- Channels: **Mono**
- Duration: **1-3 seconds per sample**
- Naming: `Dźwięk 1.wav`, `Dźwięk 2.wav`, ..., `Dźwięk 10.wav`

**📂 Folder Structure:**

```
data/simple/[vowel]/[pace]/Dźwięk X.wav
data/complex/[category]/[command]/[pace]/Dźwięk X.wav
```

**🎤 Recording Guidelines:**

- **Simple sounds:** Clear pronunciation of vowels (a, e, i)
- **Complex commands:** Natural Polish voice commands
- **Two paces:** Normal speaking pace and fast speaking pace
- **Consistent quality:** Same microphone and environment for all recordings

### 3. Run the System

1. Open **MATLAB**
2. Navigate to the project directory
3. Execute the main script:

```matlab
main
```

### 4. System Configuration

In `src/core/voiceRecognition.m` you can adjust:

```matlab
% Processing parameters
noise_level = 0.1;         % Noise level (0.0-1.0)
num_samples = 10;          % Samples per category
use_vowels = true;         % Analyze vowels
use_complex = true;        % Analyze complex commands
normalize_features = true; % Normalize features

% Neural network parameters
hidden_layers = [15 8];    % Hidden layer architecture
epochs = 1500;             % Maximum epochs
goal = 1e-7;               % Target error
```

## System Output

### 📈 **Visualizations:**

- Confusion matrices
- Learning curves
- Predicted vs actual results comparison
- Per-category accuracy distribution

### 📝 **Output Files:**

- `output/preprocessed/loaded_audio_data_*.mat` - processed data
- `output/networks/trained_network_*.mat` - trained network
- `output/logs/voice_recognition_*.log` - detailed logs

### 📋 **Statistics:**

- Classification accuracy
- Data processing time
- Network training time
- Successful/failed loading counts
- Detailed per-category metrics (precision, recall, F1-score)

## 🎯 Example Results

```
📊 FINAL STATISTICS:
✅ Successful loads: 218/220 (99.1%)
🎯 Classification accuracy: 95.45%
⏱️ Processing time: 45.2s
🧠 Training time: 12.8s

📋 BEST PERFORMING CATEGORIES:
- Vowel 'a': 98.5% accuracy
- "Turn on light": 94.2% accuracy
- "Close door": 96.1% accuracy
```

## 🔍 Debugging and Logging

The system features an advanced logging system:

```matlab
% Logging levels:
logInfo('Basic information')        % ℹ️ INFO
logSuccess('Completed operations')  % ✅ SUCCESS
logWarning('Warnings')             % ⚠️ WARNING
logError('Critical errors')        % ❌ ERROR
logDebug('Technical details')      % 🔍 DEBUG (file only)
```

**Log location:** `output/logs/voice_recognition_YYYY-MM-DD_HH-MM-SS.log`

## 🚨 Troubleshooting

### **Error: "M_rls"**

- **Cause:** Audio signal too short for RLS filter
- **Solution:** Check if audio files have >100 samples
- **Logs:** Detailed information in `.log` file

### **Error: "Matrix dimensions"**

- **Cause:** Feature dimension mismatch between samples
- **Solution:** Check audio sample consistency

### **Low accuracy (<80%)**

- **Cause:** Insufficient training data or poor quality samples
- **Solution:** Increase `num_samples` or improve recording quality

## 🤝 Contributing

Contributions are welcome! You can submit:

- 🐛 **Bug reports**
- 💡 **Feature suggestions**
- 🔧 **Code improvements**
- 📖 **Documentation updates**

### How to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/NewFeature`)
3. Commit changes (`git commit -m 'Add new feature'`)
4. Push to branch (`git push origin feature/NewFeature`)
5. Open a Pull Request

## 📄 License

This project was created by **PS**. All rights reserved.

---

## 🎵 Intelligent Voice Identification System

**Advanced voice recognition system using artificial intelligence**

_Version: 2.0 | Last updated: 2025_
