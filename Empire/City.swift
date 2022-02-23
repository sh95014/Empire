//
//  City.swift
//  Empire
//
//  Created by sh95014 on 2/21/22.
//

import Foundation

class City: Unit {
    
    var producedTypes: [Unit.Type] = [ ]
    
    override class var icon: String? { "city" }
    override class func canProduce() -> Bool { true }

    override func hasProduced(_ unitType: Unit.Type) -> Bool {
        producedTypes.contains { $0 == unitType }
    }
    
    override func produce() -> Unit? {
        if let produceOrder = order as? ProduceUnitOrder {
            if !producedTypes.contains(where: { $0 == produceOrder.unitType }) {
                producedTypes.append(produceOrder.unitType)
            }
            return produceOrder.unitType.init("NEW!", column: column, row: row)
        }
        return nil
    }

}
