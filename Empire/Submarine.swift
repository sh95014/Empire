//
//  Submarine.swift
//  Empire
//
//  Created by sh95014 on 2/21/22.
//

import Foundation

class Submarine: SeaUnit {
    
    override class var icon: String? { "submarine" }
    override class var initialProductionTurns: Int { 30 }
    override class var subsequentProductionTurns: Int { 25 }

}
