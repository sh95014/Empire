//
//  Orders.swift
//  Empire
//
//  Created by Steven Huang on 2/22/22.
//

import Foundation

class Order {
    
}

class ProduceUnit: Order {
    
    var unitType: Unit.Type
    
    init(_ unitType: Unit.Type) {
        self.unitType = unitType
    }
    
}

class Move: Order {
    
}
