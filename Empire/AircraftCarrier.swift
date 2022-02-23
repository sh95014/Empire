//
//  AircraftCarrier.swift
//  Empire
//
//  Created by sh95014 on 2/21/22.
//

import Foundation

class AircraftCarrier: SeaUnit {
    
    override class var icon: String? { "carrier" }
    override class var initialProductionTurns: Int { 72 }
    override class var subsequentProductionTurns: Int { 60 }

}
