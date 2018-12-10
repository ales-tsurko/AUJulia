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
        
        AUAudioUnit.registerSubclass(JuliaOscillator.self, as: JuliaOscillator.audioComponentDescription(), name: "JuliaOscillator", version: UInt32.max)
        
        AVAudioUnitGenerator.instantiate(with: JuliaOscillator.audioComponentDescription(), options: []) {
            audioUnit, error in
            
            guard audioUnit != nil else {
                print("failed")
                return
            }
            
            self.audioUnit = audioUnit!.auAudioUnit as! JuliaOscillator
            
            self.engine.attach(audioUnit!)
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
        
        self.frequencyParameter = paramTree.value(forKey: "frequency") as? AUParameter
        self.amplitudeParameter = paramTree.value(forKey: "amplitude") as? AUParameter
        
        self.frequencySlider.minValue = Double(self.frequencyParameter.minValue)
        self.frequencySlider.maxValue = Double(self.frequencyParameter.maxValue)
        self.amplitudeSlider.minValue = Double(self.amplitudeParameter.minValue)
        self.amplitudeSlider.maxValue = Double(self.amplitudeParameter.maxValue)

        paramTree.token(byAddingParameterObserver: {
            address, value in
            DispatchQueue.main.async {
                if address == self.frequencyParameter.address {
                    self.frequencySlider.floatValue = self.frequencyParameter.value
                    self.frequencyValueLabel.stringValue = self.frequencyParameter.string(fromValue: nil)
                }
                else if address == self.amplitudeParameter.address {
                    self.amplitudeSlider.floatValue = self.amplitudeParameter.value
                    self.amplitudeValueLabel.stringValue = self.amplitudeParameter.string(fromValue: nil)
                }
            }
        })
        
        frequencySlider.floatValue = frequencyParameter.value
        amplitudeSlider.floatValue = amplitudeParameter.value
        frequencyValueLabel.stringValue = frequencyParameter.string(fromValue: nil)
        amplitudeValueLabel.stringValue = amplitudeParameter.string(fromValue: nil)
    }
    
    @IBAction func amplitudeSliderAction(sender: NSSlider) {
        amplitudeParameter.value = sender.floatValue
    }
    
    @IBAction func frequencySliderAction(sender: NSSlider) {
        frequencyParameter.value = sender.floatValue
    }
}

