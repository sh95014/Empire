//
//  Player.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

class Player {
    
    var name: String?
    var hasVisited: [[Bool]]

    init(mapWidth: Int, mapHeight: Int) {
        hasVisited = [[Bool]](repeating: [Bool](repeating: false, count: mapWidth), count: mapHeight)
    }
    
    func visit(x: Int, y: Int) {
        for xOffset in -1...1 {
            for yOffset in -1...1 {
                if (0...hasVisited.count).contains(y + yOffset) && (0...hasVisited[0].count).contains(x + xOffset) {
                    hasVisited[y + yOffset][x + xOffset] = true
                }
            }
        }
    }
    
    func capture(_ unit: Unit) {
        unit.owner = self
        visit(x: unit.x, y: unit.y)
    }
    
}
