# PigApp

## Description
Matlab implentation of a digital signal processing standalone application.
This app is focused on the estimation of the state of fatigue from the processeing of human voice recordings of patient undergoing a physical stress trial.

The stress trial consist in the continuos as-quick-as-you-can repetition of a single word, where the primary data collected is the number and distribution of the words said during different apneas periods (i.e. the time taken by patients between two consecutive breath-ins).

Steps:
1- Within the GUI, Load from file or Record from the wathever defined pc audio input (built in, audiocard..) .wav file, for a given user defined duration (sec)
2- Compute Analysis (get word and apneas distribution over time, then perform apnea spectral analisys and signal statistics)
3- Explore, Export or Save Data

The app comes with a simple GUI built on MATLAB appdesigner tool.

## Additional Notes

The app uses state of the art rVAD (robust Voice Activity Detection - http://kom.aau.dk/~zt/online/rVAD/) algorithm developed Zheng-Hua Tan (Department of Electronic Systems, Aalborg University, Denmark - zt@es.aau.dk).
The main functions had been tweaked in order to adequate get the fast transition of voice during this specific trial.

## OS and installantion
The app had been compiled to run as a standalone desktop app for Linux and Windows OS.
The app require Matlab Runtime installed on the running machine (you can download from here:https://www.mathworks.com/products/compiler/matlab-runtime.html)


