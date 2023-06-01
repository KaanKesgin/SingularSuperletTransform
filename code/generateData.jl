# written by Kaan Kesgin on 29-05-2023 
# for the review of the paper 'Singular superlet transform achieves markedly improved time-frequency super-resolution for separating complex neural signals'
# in Nature Computational Science

# this script contains the code for generating the synthetic data (used in figure 2a-b-c in the aforementioned paper)

# import the necessary standard packages
using NPZ #for laoding the default data in figure 2c

# import packages developed by the authors 
include("waveletHelper.jl") # for calling morlet wavelets in function generateSimpleBursts


# this function generates complex bursts signal that mimics an extracellular neural environment in terms of the signal generated
# parameter load set the true leaves function without generating the random burst, it simply loads the data shown in 2c
# otherwise it generates numPackets amount of randomly positioned random bursts sampled from:
#                                                                       - frequencies sampled from      freqs
#                                                                       - number of cycles sampled from cLen
#                                                                       - amplitudes sampled from       amp
# for the total duration of duration (s)
function generateComplexBursts(duration, numPackets, freqs, cLen, amp, Fs; load=true, dataDir=[])

    if load==true #only relevant for the review process and will be removed for github
        y = npzread(joinpath(dataDir,"randBurst2c.npz"))
    else
        t =  [0:1/Fs:duration;] # define the time points for the signal
        y = zeros(Float32, length(t))

        for i = 1:numPackets
            burstFrequency = rand(freqs) #randomly sample from the given frequency range
            burstDuration = rand(cLen)*cld(Fs,burstFrequency) #generate a random duration with respect to number of cycles
        
            while burstDuration>=length(t) # perform the operation again if anything exceeds the duration
                burstFrequency = rand(freqs)
                burstDuration = rand(amp)*cld(Fs,burstFrequency)
            end
        
            burstStart = rand(1:length(t)-burstDuration) #make sure the starting point for the burst does not cause exeeding the duration of the signal
            burst = rand([1:5;])*sin.(2*pi*burstFrequency*t)[burstStart:burstStart+burstDuration-1] #create the burst
        
            y[burstStart:burstStart+burstDuration-1] += burst # sum the burst to the data
        
        end
    end

    return y
end


# this function generates a chirp signal that is overlaid by the length of the input chirp parameters
# chirp parameters is a vector of 2 chirp parameters that consist of: (chirpStart, chirpEnd) x N where N is the number of chirps
# duration defines the duration of the chirps
function generateChirp(chirpParameters, duration, Fs)

    t = [0:1/Fs:duration;] # time points for constructing the chirp, we assume chirp duration is the same for all chirps
    y = zeros(Float32, length(t))

    for i = 1:length(chirpParameters)
        currentChirpStart, currentChirpEnd = chirpParameters[i] #get the chirp parameters
        chirpRate = (currentChirpEnd-currentChirpStart)/duration #rate of current chirp
        @. y += sin( 2*pi*( (chirpRate/2) * t^2 + currentChirpStart * t) ) #sum up the generated chirps
    end

    return y
end


# this function generates simple neighboring bursts
# these bursts are hard coded into the data for demonstration purposes, so no parameters are given to the function other than the sampling rate
function generateSimpleBursts(Fs)

    t = [0:1/Fs:0.04;] # assign the time window where the signal will be defined in (s), 0.04 s is 40 ms
    y = zeros(ComplexF32, length(t)) # array for holding the bursts

    #create first packet
    burstFrequency1 = 300 #frequency of the first two neighboring bursts
    packet1 = 1.5*morlet(burstFrequency1, 3, Fs, norm="unit") # central frequency, number of cycles and sampling rate given as parameters
    burstDuration1 = cld(length(packet1),2) # note that in waveletHelper the duration of the wavelet is defined as twice the Nc/(2Fc)
    packet1 = packet1[cld(burstDuration1,2):end-cld(burstDuration1,2)] #trim the wavelet into ~5 std


    packet1_start1 = findfirst(x->x>0.002,t) #starting point for the burst 1
    y[packet1_start1+1:packet1_start1+burstDuration1-1] += packet1 #insert the first burst 

    packet1bStart = packet1_start1+burstDuration1-1 - cld(burstDuration1,3) # spacing between two bursts is 1/3 rd of the burst duration
    y[packet1bStart+1:packet1bStart+burstDuration1-1] += packet1 # add the second burst

    ####################################################################################
    #create second (middle) packet, check comments above for detailed description of parameters and methodology
    # burst 1 for the second packet
    burstFrequency2a = 1250
    packet2a = morlet(burstFrequency2a, 6, Fs, norm="unit") #parameters described above
    burstDuration2a = cld(length(packet2a),2)
    packet2a = packet2a[cld(burstDuration2a,2):end-cld(burstDuration2a,2)] #trim the wavelet into ~5 std

    packet2_start1 = findfirst(x->x>0.021,t)
    y[packet2_start1+1:packet2_start1+burstDuration2a-1] += packet2a # add the first burst of the second (middle) packet

    # burst 2 for the second packet
    burstFrequency2b = 1725
    packet2b = morlet(burstFrequency2b, 6, Fs, norm="unit")
    burstDuration2b = cld(length(packet2b),2)
    packet2b = packet2b[cld(burstDuration2b,2):end-cld(burstDuration2b,2)] #trim the wavelet into ~5 std

    packet2bStart = packet2_start1+burstDuration2b-1  - cld(burstDuration2b,2)# spacing between two bursts is 1/3 rd of the burst duration
    y[packet2bStart+1:packet2bStart+burstDuration2b-1] += packet2b # add the second burst of the second (middle) packet

    #create third packet
    burstFrequency3 = 2300
    burstDuration3 = 5*cld(Fs,burstFrequency3)
    packet3 = 1.2*sin.(2*pi*burstFrequency3*t)[1:burstDuration3]

    packet3_start1 = findfirst(x->x>0.032,t)
    y[packet3_start1:packet3_start1+burstDuration3-1] += packet3
    
    return y

end