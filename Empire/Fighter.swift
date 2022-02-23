//
//  Fighter.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

class Fighter: AirUnit {
    
    override class var icon: String? { "fighter" }
    override class var initialProductionTurns: Int { 12 }
    override class var subsequentProductionTurns: Int { 10 }

}
