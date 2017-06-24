//
//  FirstViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/9/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class PreheatViewController : UIViewController {
    let smallstep: Float = 2
    let largestep: Float = 25
    let crossover: Float = 100
    let tempdefault: Float = 350
    private var desiredTemp: Float = 250
    private var currentTemp: Float = 70
    private let model = ThermalModel()
    private var modelData: [ThermalModelParams] = []
    private var modelIndex: Int = 0
    
    var Tamb : Float {
        get {
            return model.Tamb
        }
        set (newTamb) {
            model.Tamb = quantize(temp: newTamb)
        }
    }
    
    var selectedModel: Int {
        get {
            return modelIndex
        }
        set (newIndex) {
            modelIndex = newIndex
            model.setfrom(params: modelData[modelIndex])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadModelData()
        modelIndex = 1
        Tamb = 72.0
        UpdateAmbientLimits()
        Reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func LoadModelData() {
        var theparams : ThermalModelParams
        
        theparams = ThermalModelParams(name: "Gas Oven")
        theparams.a *= 1.1
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Electric Oven")
        theparams.a *= 1.2
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Convection Oven")
        theparams.a *= 0.9
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Speed Oven")
        theparams.a *= 0.8
        modelData.append(theparams)
        
        theparams = ThermalModelParams(name: "Outdoor Grill")
        theparams.a *= 1.0
        modelData.append(theparams)
    }
    
    func quantize(temp:Float) -> Float {
        if temp < crossover {
            return smallstep*round(temp/smallstep)
        } else {
            return largestep*round(temp/largestep)
        }
    }
    
    private func colorfrom(frac:Float) -> UIColor {
        let fracfloat:CGFloat = CGFloat(frac)
        
        return UIColor(
            red: 0.5 - cos(3.1457*fracfloat)/2,
            green: 0,
            blue: 0.5 + cos(3.1457*fracfloat)/2,
            alpha: 1)
    }
    
    func SetCurrent(temp:Float) {
        currentTemp = quantize(temp: temp)
        currentTempLabel.text = String(Int(currentTemp))
        
        let maxtemp = currentTempSlider.maximumValue
        let mintemp = currentTempSlider.minimumValue
        let tempfrac = (temp - mintemp)/(maxtemp - mintemp)
        currentTempSlider.minimumTrackTintColor = colorfrom(frac:tempfrac)
        UpdateTime()
    }
    
    func SetDesired(temp:Float) {
        desiredTemp = quantize(temp: temp)
        desiredTempLabel.text = String(Int(desiredTemp))
        
        let maxtemp = desiredTempSlider.maximumValue
        let mintemp = desiredTempSlider.minimumValue
        let tempfrac = (temp - mintemp)/(maxtemp - mintemp)
        desiredTempSlider.minimumTrackTintColor = colorfrom(frac:tempfrac)
        UpdateTime()
    }
    
    func UpdateTime() {
        // Run model
        let minfrac = model.time(totemp: desiredTemp, fromtemp: currentTemp)
        
        // Update display
        let pretimemin = floor(minfrac)
        let pretimesec = round(60*(minfrac - pretimemin))
        minLabel.text = String(Int(pretimemin))
        
        var sectext : String
        if pretimesec < 10 {
            sectext = "0" + String(Int(pretimesec))
        } else {
            sectext = String(Int(pretimesec))
        }
        secLabel.text = sectext
    }
    
    func UpdateCurrent() {
        SetCurrent(temp: currentTempSlider.value)
    }
    
    func UpdateDesired() {
        SetDesired(temp: desiredTempSlider.value)
    }
    
    func UpdateAmbientLimits() {
        currentTempSlider.minimumValue = Tamb
        desiredTempSlider.minimumValue = Tamb + smallstep
            UpdateCurrent()
        if desiredTempSlider.value < (Tamb + smallstep) {
            desiredTempSlider.value = Tamb + smallstep
         }
        UpdateDesired()
    }
    
    func Reset() {
        currentTempSlider.value = currentTempSlider.minimumValue
        desiredTempSlider.value = tempdefault
        UpdateCurrent()
        UpdateDesired()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.initialTamb = Tamb
            var modelNames: [String] = []
            for themodel in modelData {
                modelNames.append(themodel.name)
            }
            settingsView.modelNames = modelNames
            settingsView.initialSelection = modelIndex
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        guard let source = segue.source as? SettingsViewController else { return }
        Tamb = source.Tamb
        UpdateAmbientLimits()
        modelIndex = source.selectedModel
        model.setfrom(params: modelData[modelIndex])
        UpdateTime()
    }
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var desiredTempLabel: UILabel!
    @IBOutlet weak var currentTempSlider: UISlider!
    @IBOutlet weak var desiredTempSlider: UISlider!
    
    @IBAction func CurrentTempChange(_ sender: UISlider) {
        UpdateCurrent()
    }
    
    @IBAction func DesiredTempChange(_ sender: UISlider) {
        UpdateDesired()
    }

    @IBAction func ResetButton(_ sender: UIButton) {
        Reset()
    }
}
