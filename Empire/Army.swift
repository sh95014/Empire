//
//  Army.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

class Army: LandUnit {
    
    override class var icon: String? { "tank2" }
    override class var initialProductionTurns: Int { 6 }
    override class var subsequentProductionTurns: Int { 5 }

}
