//
//  JuliaOscillatorKernel.hpp
//  AUJuliaFramework
//
//  Created by Ales Tsurko on 30.09.15.
//  Copyright © 2015 Ales Tsurko. All rights reserved.
//

#include <fstream>
#include <string>
#include <sstream>
#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"
#include "julia.h"

const float twopi = 2 * M_PI;

enum {
    ParamFrequency = 0,
    ParamAmplitude = 1
};

class OscillatorDSPKernel : public DSPKernel {
private:
    // MARK: Member Variables
    int numberOfChannels;
    float sampleRate = 44100.0;
    float maxFrequency;
    float reciprocalOfMaxFrequency;
    
    AudioBufferList* outBufferListPtr = nullptr;
    
    jl_function_t *sin_osc;
    
public:
    // Parameters.
    ParameterRamper frequencyRamper = 440.0 / 44100.0;
    ParameterRamper amplitudeRamper = 0.99;
    
    // MARK: Member Functions
    OscillatorDSPKernel() {}
    
    void init(int channelCount, double inSampleRate) {
        numberOfChannels = channelCount;
        sampleRate = float(inSampleRate);
        maxFrequency = sampleRate/2.0;
        reciprocalOfMaxFrequency = 1.0 / maxFrequency;
        
        jl_init_with_image("AUJulia.app/Contents/Frameworks/AUJuliaFramework.framework", "Versions/A/Resources/julia/lib/sys-debug.dylib");
        
        jl_eval_string("print(\"Julia is here\\n\")");
        
        std::ifstream julstr("aujulia.jl");
        std::stringstream buffer;
        buffer << julstr.rdbuf();
        
        std::string ss = buffer.str();
        
        printf("%s", ss.c_str());
        
        jl_eval_string(ss.c_str());
        
        sin_osc = jl_get_function(jl_main_module, "sin_osc");
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case ParamFrequency:
                frequencyRamper.set(clamp(value * reciprocalOfMaxFrequency, 0.0f, 1.0f));
                break;
                
            case ParamAmplitude:
                amplitudeRamper.set(clamp(value, 0.0f, 1.0f));
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case ParamFrequency:
                return frequencyRamper.goal() * maxFrequency;
                
            case ParamAmplitude:
                return amplitudeRamper.goal();
                
            default: return 0.0f;
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case ParamFrequency:
                frequencyRamper.startRamp(clamp(value * reciprocalOfMaxFrequency, 0.0f, 1.0f), duration);
                break;
                
            case ParamAmplitude:
                amplitudeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;
        }
    }
    
    void setOutputBuffer(AudioBufferList* outBufferList) {
        outBufferListPtr = outBufferList;
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            float amplitude = amplitudeRamper.goal();
            float frequency = frequencyRamper.goal() * maxFrequency;
            
            jl_value_t* jfreq = jl_box_float64(frequency);
            jl_value_t* jamp = jl_box_float64(amplitude);
            jl_value_t* jval = jl_call2(sin_osc, jfreq, jamp);
            
            float value = float(jl_unbox_float64(jval));
            
            for (int channel = 0; channel < numberOfChannels; ++channel) {
                float* out = (float*)outBufferListPtr->mBuffers[channel].mData;
                
                out[frameIndex] = value;
            }
        }
    }
};
