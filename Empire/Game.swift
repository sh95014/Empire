//
//  Game.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

class Game {
    
    let map = Map()
    var units = Array<Unit>()
    var players = Array<Player>()
    var currentPlayerIndex: Int
    
    init() {
        // create cities
        for _ in 0..<50 {
            repeat {
                let x = Int.random(in: 0..<map.width)
                let y = Int.random(in: 0..<map.height)
                if map.squareAt(x: x, y: y) == .land {
                    let city = City("City \(x)-\(y)", x: x, y: y)
                    units.append(city)
                    break
                }
            } while true
        }
        
        // give each player a starting city
        for i in 0..<1 {
            let player = Player(mapWidth: map.width, mapHeight: map.height)
            player.name = "Player \(i + 1)"
            player.capture(units[i])
            players.append(player)
        }
        
        currentPlayerIndex = 0
    }
    
    var currentPlayer: Player {
        return players[currentPlayerIndex]
    }

}
