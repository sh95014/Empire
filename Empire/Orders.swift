//
//  Orders.swift
//  Empire
//
//  Created by Steven Huang on 2/22/22.
//

import Foundation

class Order {
    
}

class ProduceUnitOrder: Order {
    
    var unitType: Unit.Type
    var turnsLeft: Int
    
    init(_ previousProduction: ProduceUnitOrder?, unitType: Unit.Type) {
        self.unitType = unitType
        if (previousProduction?.unitType != unitType) {
            turnsLeft = unitType.initialProductionTurns
        } else {
            turnsLeft = unitType.subsequentProductionTurns
        }
    }
    
}

class MoveOrder: Order {
    
}
