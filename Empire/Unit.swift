//
//  Unit.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

protocol UnitClassProtocol {
    static var icon: String? { get }
}

class Unit: UnitClassProtocol {
    
    var owner: Player?
    var name: String
    var x: Int
    var y: Int
    class var icon: String? { return nil }
    
    init(_ name: String, x: Int, y: Int) {
        self.owner = nil
        self.name = name
        self.x = x
        self.y = y
    }
    
}
