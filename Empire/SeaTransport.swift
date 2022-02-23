//
//  SeaTransport.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

class SeaTransport: SeaUnit {
    
    override class var icon: String? { "transport-ship" }
    override class var initialProductionTurns: Int { 36 }
    override class var subsequentProductionTurns: Int { 30 }

}
