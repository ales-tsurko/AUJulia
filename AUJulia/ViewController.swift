//
//  ViewController.swift
//  AUJulia
//
//  Created by Ales Tsurko on 05.12.15.
//  Copyright © 2015 Ales Tsurko. All rights reserved.
//

import Cocoa
import AVFoundation
import AUJuliaFramework

class ViewController: NSViewController {
    
    @IBOutlet weak var amplitudeSlider: NSSlider!
    @IBOutlet weak var frequencySlider: NSSlider!
    @IBOutlet weak var amplitudeValueLabel: NSTextField!
    @IBOutlet weak var frequencyValueLabel: NSTextField!
    
    var frequencyParameter: AUParameter!
    var amplitudeParameter: AUParameter!
    
    var audioUnit: JuliaOscillator!
    let engine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AUAudioUnit.registerSubclass(JuliaOscillator.self, asComponentDescription: JuliaOscillator.audioComponentDescription(), name: "JuliaOscillator", version: UInt32.max)
        
        AVAudioUnitGenerator.instantiateWithComponentDescription(JuliaOscillator.audioComponentDescription(), options: []) {
            audioUnit, error in
            
            guard audioUnit != nil else {
                print("failed")
                return
            }
            
            self.audioUnit = audioUnit!.AUAudioUnit as! JuliaOscillator
            
            self.engine.attachNode(audioUnit!)
            self.engine.connect(audioUnit!, to: self.engine.mainMixerNode, format: self.audioUnit!.format)
            
            do {
                try self.engine.start()
            } catch {
                print("Error: \(error)")
            }
        }
        
        linkParametersWithGUI()
    }
    
    func linkParametersWithGUI() {
        guard let paramTree = self.audioUnit!.parameterTree else { return }
        
        self.frequencyParameter = paramTree.valueForKey("frequency") as? AUParameter
        self.amplitudeParameter = paramTree.valueForKey("amplitude") as? AUParameter
        
        self.frequencySlider.minValue = Double(self.frequencyParameter.minValue)
        self.frequencySlider.maxValue = Double(self.frequencyParameter.maxValue)
        self.amplitudeSlider.minValue = Double(self.amplitudeParameter.minValue)
        self.amplitudeSlider.maxValue = Double(self.amplitudeParameter.maxValue)
        
        paramTree.tokenByAddingParameterObserver{
            address, value in
            dispatch_async(dispatch_get_main_queue()) {
                if address == self.frequencyParameter.address {
                    self.frequencySlider.floatValue = self.frequencyParameter.value
                    self.frequencyValueLabel.stringValue = self.frequencyParameter.stringFromValue(nil)
                }
                else if address == self.amplitudeParameter.address {
                    self.amplitudeSlider.floatValue = self.amplitudeParameter.value
                    self.amplitudeValueLabel.stringValue = self.amplitudeParameter.stringFromValue(nil)
                }
            }
        }
        
        frequencySlider.floatValue = frequencyParameter.value
        amplitudeSlider.floatValue = amplitudeParameter.value
        frequencyValueLabel.stringValue = frequencyParameter.stringFromValue(nil)
        amplitudeValueLabel.stringValue = amplitudeParameter.stringFromValue(nil)
    }
    
    @IBAction func amplitudeSliderAction(sender: NSSlider) {
        amplitudeParameter.value = sender.floatValue
    }
    
    @IBAction func frequencySliderAction(sender: NSSlider) {
        frequencyParameter.value = sender.floatValue
    }
}

