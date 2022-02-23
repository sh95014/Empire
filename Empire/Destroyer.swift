//
//  Destroyer.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

class Destroyer: SeaUnit {
    
    override class var icon: String? { "destroyer" }
    override class var initialProductionTurns: Int { 24 }
    override class var subsequentProductionTurns: Int { 20 }

}
