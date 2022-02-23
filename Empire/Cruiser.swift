//
//  Cruiser.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

class Cruiser: SeaUnit {
    
    override class var icon: String? { "cruiser" }
    override class var initialProductionTurns: Int { 60 }
    override class var subsequentProductionTurns: Int { 50 }

}
