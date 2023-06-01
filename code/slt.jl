# written by Kaan Kesgin on 29-05-2023 
# for the review of the paper 'Singular superlet transform achieves markedly improved time-frequency super-resolution for separating complex neural signals'
# in Nature Computational Science

# this script contains the code for performing superlet transform (SLT)

# import packages developed by the authors for the time-frequency decompostion
include("cwt.jl") 

# perform SLT on the input data (y), at frequencies (frange), sampling frequency (Fs), normalisation and step factor for increment in number of cycles
function slt(y, frange, Fs; baseCycle=3, norm="modulus-integral", step=1000, increment=1)
    N, M = length(y), length(frange) # get N points from the input data and M frequency points for correct number of points operations
    scalogram = zeros(Float32, N, M) # N points in time, M points in frequency

    Threads.@threads for i in 1:M
        o = 1 + frange[i]/step # number of cycles increase factor per frequency
        temp = ones(Float32, N); #generate temp for holding mean operation
        root = length([1:increment:o;]) # calculate number of mean operations

        for i_ord = 1:increment:o # cycles from 1 to o by increment
            w = morlet(frange[i], baseCycle*i_ord, Fs; norm) # generate the wavelet

            # some wavelets can be unreasonably small due to rounding of the tRange, we skip those
            if length(w)<3
                root-=1
                continue
            end

            temp .*= ( 2 * abs2.( convSizeCorrected(y,w) ) ).^(1/root) #perform the GM operation for the frequency
        end

        scalogram[:, i] = temp;
    end
    return scalogram 
end