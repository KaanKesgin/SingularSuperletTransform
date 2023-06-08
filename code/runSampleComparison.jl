# written by Kaan Kesgin on 31-05-2023 

# this script contains the code for generating synthetic data and performing comparisons between CWT and SST
# alternatively one can load their own data at line 30

# import the necessary standard packages
using Plots #for plotting
using Measures #for formatting the plot


# import packages developed by the authors for the time-frequency decomposition
include("generateData.jl")
include("cwt.jl")
include("sst.jl")

const Fs = 30000; #sampling rate
const frange = [1:1:3000;]

# define parameters for generating the complex burst data
numPackets = 50          # generate numPackets amount of randomly positioned random bursts
duration   = 0.05        # for the total duration of duration (in seconds)
freqs      = [1:1500;]   # with frequencies sampled from freqs (in Hz)
cLen       = [1:5;]      # number of cycles sampled from cLen
amp        = [1:5;]      # mplitudes sampled from amp

# define variables relating to TF methods
step      = 250 # adaptive parameter for number of cycles increment per frequency band
norm      = "frequency-sqrt" # normalisation type

y = generateComplexBursts(duration, numPackets, freqs, cLen, amp, Fs) #load==true will throw an error if data folder is not provided (ie: for Github)
# alternatively one can also load their own data in the above line and perform the comparisons
# pay attention to the sampling rate (Fs, line 15) and the frequency range of interest (frange, line 16) if you're loading your own data

println("finished generating the data")

# perform TF decomposition on complex bursts
yCWT = cwt(y, frange, Fs, norm=norm, step=step)
ySST = sst(y, frange, Fs, norm=norm, step=step)
println("finished TF decomposition of the complex bursts")


#################################### plotting ####################################
println("plotting")
t = [0:1/Fs:length(y)/Fs;][1:end-1]

pComplexBurstsTime = plot(t, y, legend=false, yaxis=false, xticks=false, grid=false, ylabel="amplitude [a.u]", xlims=(t[1], t[end]))
pComplexBurstsCWT  = heatmap(t, frange, permutedims(yCWT), color=:jet, legend=false, xaxis=false, xticks=false, grid=false, ylabel="CWT", xlims=(t[1], t[end]))
pComplexBurstsSST  = heatmap(t, frange, permutedims(ySST), color=:jet, legend=false,  grid=false, ylabel="SST", xlabel="time", xlims=(t[1], t[end]))

plot(pComplexBurstsTime, pComplexBurstsCWT, pComplexBurstsSST, link=:x, layout=grid(3,1), size=(1200,1000), margins=5.0mm)