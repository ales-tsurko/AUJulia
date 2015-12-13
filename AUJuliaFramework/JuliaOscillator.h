//
//  JuliaOscillator.h
//  AUJuliaFramework
//
//  Created by Ales Tsurko on 30.09.15.
//  Copyright © 2015 Ales Tsurko. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

@interface JuliaOscillator : AUAudioUnit

@property AVAudioFormat *format;

+ (AudioComponentDescription)audioComponentDescription;

@end