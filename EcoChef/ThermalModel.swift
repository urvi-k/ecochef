//
//  ThermalModel.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/10/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import Foundation

struct ThermalModelParams {
    var name: String
    var a: Float
    var b: Float
    
    init(name: String) {
        self.init(name: name, a: 10, b: 500)
     }
    
    init(name: String, a: Float, b: Float) {
        self.name = name
        self.a = a
        self.b = b
    }
}

// Computational logic
class ThermalModel : CustomStringConvertible {
    var a: Float = 10.0  // RC time constant
    var b: Float = 500.0  // RH coefficient (s.s. temp above ambient)
    var Tamb: Float = 70.0  // T_ambient
    
    var description: String {
        return "ThermalModel: \((a, b)), Tambient = \(Tamb)"
    }
    
    // load from struct
    func setfrom(params:ThermalModelParams) {
        a = params.a
        b = params.b
    }
    
    // time in fractional minutes
    func time(totemp:Float) -> Float {
        return time(totemp:totemp, fromtemp:Tamb)
    }
    
    func time(totemp Tset:Float, fromtemp Tstart:Float) -> Float {
        if Tset > Tstart {
            return a * log((b + Tamb - Tstart)/(b + Tamb - Tset))
        } else {
            return a * log((Tamb - Tstart)/(Tamb - Tset))
        }
    }
    
    func tempAfterHeating(time t:Float, fromtemp Tstart:Float) -> Float {
        let Tinf = b + Tamb
        return Tinf - exp(-t/a)*(Tinf - Tstart)
    }
    
    func tempAfterCooling(time t:Float, fromtemp Tstart:Float) -> Float {
        return Tamb + exp(-t/a)*(Tstart - Tamb)
    }
}
