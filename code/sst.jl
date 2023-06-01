# written by Kaan Kesgin on 29-05-2023 
# for the review of the paper 'Singular superlet transform achieves markedly improved time-frequency super-resolution for separating complex neural signals'
# in Nature Computational Science

# this script contains the code for performing singular superlet transform (SST)

# import packages developed by the authors for the base helper functions
include("waveletHelper.jl") 

# construct the singular superlet with central frequency (Fc), number of cycles (Nc), sampling frequency (Fs) and normalisation
# normalisation is defined as "modulus-integral", for multi-cycle bursts
#                             "unit"            , for generation/plotting purposes
#                             "frequency-sqrt" , for single cycle bursts
function singularSuperlet(Fc, Nc, Fs; norm="modulus-integral")
    tRange = getWaveletTimeRange(Fc, Nc, Fs) # get the time range where the wavelet is defined

    timeCancelFactor = 1/(Nc/(2*Fc))^2
    envelope = @. ( -log(timeCancelFactor * (tRange)^2 ) ) * exp( - (timeCancelFactor * tRange^2 )^( 2*log(Nc) )  ) # generate the envelope/temporal decay

    wavelet = @. envelope * exp(im * 2*pi*Fc * tRange) # generate superlet
    
    return normalize(wavelet, envelope, norm, Fc)
end

# perform SST on the input data (y), at frequencies (frange), sampling frequency (Fs) and normalisation
function sst(y, frange, Fs; baseCycle=3, norm="modulus-integral", step=1000)
    N, M = length(y), length(frange) # get N points from the input data and M frequency points for correct number of points operations
    scalogram = zeros(Float32, N, M) # N points in time, M points in frequency

    Threads.@threads for i in 1:M
        o = 1 + frange[i]/step # number of cycles increase factor per frequency
        w = singularSuperlet(frange[i], baseCycle*o, Fs; norm) # generate the wavelet
        scalogram[:,i] =  2 * abs2.( convSizeCorrected(y, w) ) #apply convolution operation and correct for the resultant size
    end
    return scalogram #rotate from time*frequency to frequency*time (helps heatmap plotting)
end