//
//  Player.swift
//  Empire
//
//  Created by sh95014 on 2/21/22.
//

import Foundation

class Player {
    
    var name: String?
    var hasVisited: [[Bool]]

    init(mapWidth: Int, mapHeight: Int) {
        hasVisited = [[Bool]](repeating: [Bool](repeating: false, count: mapWidth), count: mapHeight)
    }
    
    func visit(column: Int, row: Int) {
        for columnOffset in -1...1 {
            for rowOffset in -1...1 {
                if (0...hasVisited.count).contains(row + rowOffset) && (0...hasVisited[0].count).contains(column + columnOffset) {
                    hasVisited[row + rowOffset][column + columnOffset] = true
                }
            }
        }
    }
    
    func capture(_ unit: Unit) {
        unit.owner = self
        visit(column: unit.column, row: unit.row)
    }
    
}
