//
//  Bomber.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

class Bomber: AirUnit {
    
    override class var icon: String? { "bomber" }
    override class var initialProductionTurns: Int { 20 }
    override class var subsequentProductionTurns: Int { 18 }

}
