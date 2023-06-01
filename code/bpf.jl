# written by Kaan Kesgin on 29-05-2023 
# for the review of the paper 'Singular superlet transform achieves markedly improved time-frequency super-resolution for separating complex neural signals'
# in Nature Computational Science

# this script contains the code for performing bandpass filtering

# import the necessary standard packages
using DSP #in order to perform fft operation we import the standard fftw package that exists in numerous other languages: https://www.fftw.org/


# perform bandpass filtering on the input data (y), between interval (lowBand, highBand), sampling frequency (Fs)
# filter is chosen as 5th order butterworth

function bandPassFilter(y, lowBand, highBand, Fs)
    responsetype = Bandpass(lowBand, highBand; fs=Fs)
    designmethod = Butterworth(5)
    return filt(digitalfilter(responsetype, designmethod), y)
end