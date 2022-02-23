//
//  Unit.swift
//  Empire
//
//  Created by sh95014 on 2/21/22.
//

import Foundation

protocol UnitClassProtocol {
    static var icon: String? { get }
}

class Unit: UnitClassProtocol {
    
    var owner: Player?
    var name: String
    var column: Int
    var row: Int
    var order: Order?
    
    class var icon: String? { return nil }
    class var initialProductionTurns: Int { 99999 }
    class var subsequentProductionTurns: Int { 99999 }
    class var movesPerTurn: Int { 0 }

    required init(_ name: String, column: Int, row: Int) {
        self.owner = nil
        self.name = name
        self.column = column
        self.row = row
    }
    
    class func canProduce() -> Bool { false }
    class func canMove(onto mapSquare: MapSquare) -> Bool { false }

    var canProduceShips = false
    func hasProduced(_ unitType: Unit.Type) -> Bool { false }
    func produce() -> Unit? { nil }

}

class AirUnit: Unit {
    
    override class func canMove(onto mapSquare: MapSquare) -> Bool { true }

}

class LandUnit: Unit {
    
    override class func canMove(onto mapSquare: MapSquare) -> Bool { mapSquare == .land }

}

class SeaUnit: Unit {
    
    override class func canMove(onto mapSquare: MapSquare) -> Bool { mapSquare == .sea }
    override class var movesPerTurn: Int { 2 }

}
