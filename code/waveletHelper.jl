# written by Kaan Kesgin on 29-05-2023 
# for the review of the paper 'Singular superlet transform achieves markedly improved time-frequency super-resolution for separating complex neural signals'
# in Nature Computational Science

# this script contains the helper functions for shared operations in time-frequency transforms

# import the necessary standard packages
using FFTW #in order to perform fft operation we import the standard fftw package that exists in numerous other languages: https://www.fftw.org/

# return time range for constructing the wavelet based on:
#                               central frequency (Fc)
#                               number of cycles (Nc)
#                               sampling rate (Fs)
# resolution defines how many digits to round to (3 is millisecond, 0 is seconds)  
function getWaveletTimeRange(Fc, Nc, Fs)
    resolution = abs(Int(floor(log10(1/Fs))))-2
    t_edge = round(Nc/(2*Fc),digits=resolution)*2.0 # get the time range defined for the morlet wavelet with central frequency and number of cycles (in seconds, rounded to milisecond)
    return [-t_edge:1/Fs:t_edge;] .+  45e-2/Fs # create the time range for generating the wavelet
end

# convolves two time domain signals by multiplying in frequency domain, returns corretly shifted signal
function convolve(y,w)
    return fftshift( ifft( fft(y).*fft(w) ) )
end

# return time wavelet that is normalized to the envelope with respect to norm
function normalize(wavelet, envelope, norm, Fc)

    if norm=="modulus-integral"
        return wavelet / sum( abs.(envelope) )
    elseif norm=="unit"
        return wavelet / maximum( abs.(envelope) )
    elseif norm=="frequency-sqrt"
        return wavelet * sqrt(Fc) / sum( abs.(envelope) ) 
    elseif norm=="frequency-square"
        return wavelet * Fc / sum( abs.(envelope) ) 
    elseif norm=="energy"
        return wavelet / sum( abs2.(envelope) ) 
    else
        throw(DomainError(norm, "this norm is not defined, try \"modulus-integral\", \"unit\" or \"frequency-sqrt\""))
    end

end

# perform the convolution by performing a hard check on sizes
# if there are performance issues, this function should be modified, it mostly matters for small input data, low frequency combinations
# notice that regardless, this helps with cyclical convolution , also notice that size matching is required for convolution in freq domain
function convSizeCorrected(y, w)
    sizeData, sizeWavelet = length(y), length(w) # get number of points in the input data and wavelets
    fullSize = sizeData+sizeWavelet # get the full array size to prevent cyclical convolution
    fillerArrData, fillerArrWavelet = zeros(ComplexF32, fullSize), zeros(ComplexF32, fullSize) # generate fuller arrays
    midFiller, midData, midWavelet = cld(fullSize,2), cld(sizeData,2), cld(sizeWavelet,2) # get half points for relocating the data
    startData, startWavelet = midFiller-midData, midFiller-midWavelet # get the start points for relocation

    fillerArrData[startData:startData+sizeData-1] .= y # put data in size matching array
    fillerArrWavelet[startWavelet:startWavelet+sizeWavelet-1] .= w # put wavelet in size matching array

    return convolve( fillerArrData, fillerArrWavelet )[startData:startData+sizeData-1] # return response of input data to w(Fc)
end