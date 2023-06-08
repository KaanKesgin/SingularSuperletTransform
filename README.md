# SingularSuperletTransform SST


Singular Superlet transform (SST)
====================================

The Singular Superlet Transform (SST) is a time-frequency decomposition method based on wavelet transform that can generate highly localised spectra.

_Please cite our research paper using when using SST in your research project._
> Jorntell, Henrik, and Kaan Kesgin. "Singular superlet transform achieves markedly improved time-frequency super-resolution for separating complex neural signals." bioRxiv (2023): 2023-02

Features
========

- Generates highly localized time-frequency spectrum for short-burst signals
- Same computational complexity as Continuous Wavelet Transform (CWT)
- Applicable in many domains ranging from audio and speech to extracellular neural spike analysis
- High performance Julia implementation [under development](https://github.com/KaanKesgin/SingularSuperletJL.jl), with quickstart quide below
- Python version [under development](https://github.com/KaanKesgin/SingularSuperletPY), with quickstart quide below
- MATLAB version [available](https://github.com/KaanKesgin/SingularSuperletMAT), with quickstart quide below

Synthetic example of figure 2
Neural data example from figure 1
Audio example from figure 3

Quickstart 
============

Julia
---

Python
---

MATLAB
---

Either git clone or download this repository, then add \your\download\directory\SingularSuperletTransform\code\MATLAB to your path
Then, you can either execute run.m for a quick start and a comnparison with CWT using randomly generated data or simply use your own data with:

```Matlab
%load your data
filename = "\path\to\your\data";  % define the path to your data
y        = load(filename);	  % load your data
Fs       = 1000;                  % define sampling rate in Hz, replace with the sampling rate of your file

%define parameters for singular superlet transform, consult the research paper above for further details
frange    = 1:1:1500;             % frequency range of interest for performing the time frequency decomposition
norm      = "frequency-sqrt";     % normalization to be used, options are: "modulus-integral", "unit", "frequency-sqrt" and "energy". Check the file normalize.m for further details
step      = 250;                  % adaptive parameter for number of cycles increment per frequency band
baseCycle = 3;                    % number of baseline cycles to build the adaptive increments on 

% perform time frequency decomposition
sstRez = sst(y, frange, Fs, baseCycle, norm, step); % perform sst,  returns the scalogram output that is timePoints x frequencyPoints
% cwtRez = cwt(y, frange, Fs, baseCycle, norm, step); % perform cwt,  uncomment if you wish to make comparisons with cwt, returns the scalogram output that is timePoints x frequencyPoints

```
