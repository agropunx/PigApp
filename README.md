# PigApp Demo

## App Description
Voice Processing demo application built in matlab.
This app is focused on the estimation of the state of fatigue from the processeing of human voice recordings of patient undergoing a physical stress trial.

The stress trial consist in the continuos as-quick-as-you-can repetition of a single word, where the primary data collected is the number and distribution of the words said during different apneas periods (i.e. the time taken by patients between two consecutive breath-ins).

Steps:
1- Within the GUI, Load from file or Record from the wathever defined pc audio input (built in, audiocard..) .wav file, for a given user defined duration (sec)
<<<<<<< HEAD
2- Compute Analysis (get word and apneas distribution over time)
3- Explore, Export or Save Data

The app comes with a simple GUI (Matlab Class)
=======
2- Compute Analysis (get word and apneas distribution over time, then perform apnea spectral analisys and basic signal statistics)
3- Explore, Export or Save Data

The app comes with a simple GUI built on MATLAB appdesigner tool.

## Install
The app had been compiled to run as a standalone desktop app for Linux.
In order to install simply download and launch the file in /for-redistribution/ folder. 
The app require Matlab Runtime installed on the running machine (the web downloader should start automatically when main installer starts, however you can download from here:https://www.mathworks.com/products/compiler/matlab-runtime.html)

The MATLAB .prj file is also given, so the code it can be access through MATLAB Appdesigner
>>>>>>> c9783198abe10ce782634904ec35a80b814923fd

## Additional Notes
The app implement state of the art rVAD (robust Voice Activity Detection - http://kom.aau.dk/~zt/online/rVAD/) algorithm developed by Zheng-Hua Tan (Department of Electronic Systems, Aalborg University, Denmark - zt@es.aau.dk).
The main functions had been tweaked in order to adequate get the fast transition of voice during this specific trial.

