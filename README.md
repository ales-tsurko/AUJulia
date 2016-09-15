# AUJulia
Generating audio with the Julia programming language using CoreAudio. Just proof of concept. It's not so fast as C++, but performance can be improved by optimising the Julia code and by replacing some parts with C++. The code, that used for the sine oscillator, is in ```aujulia.jl```. The generating block is in the ```process``` method of the ```OscillatorDSPKernel``` class, that declared in the ```JuliaOscillatorKernel.hpp```.

It's under the MIT. So feel free to use it in your own projects. Since the Julia is a very simple technical language, the possible field is audio DSP fast prototyping.
Also since the oscillator itself is a framework, you can easily embed it in an Objective-C or Swift project. AUJulia.app is an example of such usage.
