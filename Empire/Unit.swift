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
    var order: Order?
    
    class var icon: String? { return nil }
    class var initialProductionTurns: Int { 99999 }
    class var subsequentProductionTurns: Int { 99999 }

    init(_ name: String, x: Int, y: Int) {
        self.owner = nil
        self.name = name
        self.x = x
        self.y = y
    }
    
    class func canProduce() -> Bool { false }
    class func canMove(onto mapSquare: MapSquare) -> Bool { false }

}

class AirUnit: Unit {
    
    override class func canMove(onto mapSquare: MapSquare) -> Bool { true }

}

class LandUnit: Unit {
    
    override class func canMove(onto mapSquare: MapSquare) -> Bool { mapSquare == .land }

}

class SeaUnit: Unit {
    
    override class func canMove(onto mapSquare: MapSquare) -> Bool { mapSquare == .sea }

}
