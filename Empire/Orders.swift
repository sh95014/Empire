//
//  Orders.swift
//  Empire
//
//  Created by sh95014 on 2/22/22.
//

import Foundation

class Order {
    
}

class ProduceUnitOrder: Order {
    
    var unitType: Unit.Type
    var turnStarted: Int
    
    init(_ unitType: Unit.Type, turn: Int) {
        self.unitType = unitType
        turnStarted = turn
    }
    
}

class MoveOrder: Order {
    
    var column: Int
    var row: Int
    
    init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }
    
}

class SkipTurnOrder: Order {
}
