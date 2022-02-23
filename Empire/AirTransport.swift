//
//  AirTransport.swift
//  Empire
//
//  Created by sh95014 on 2/21/22.
//

import Foundation

class AirTransport: AirUnit {
    
    override class var icon: String? { "air-transport" }
    override class var initialProductionTurns: Int { 18 }
    override class var subsequentProductionTurns: Int { 16 }
    override class var movesPerTurn: Int { 2 }

}
