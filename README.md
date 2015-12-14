# AUJulia
Just proof of concept generating audio with the Julia programming language using CoreAudio. It's not so fast as C++, but performance can be improved by optimising the Julia code and replacing some parts with C++. The code used for the sine oscillator is in ```aujulia.jl```. The generating block is in ```process``` method of the ```OscillatorDSPKernel``` class declared in the ```JuliaOscillatorKernel.hpp```.

It's under the MIT. So feel free to use it in your own projects. Since the Julia is a very simple technical language the possible field is fast audio DSP prototypes.
Also because the oscillator itself is a framework, you can easily include it in an Objective-C or Swift project. AUJulia.app is an example of such usage.
