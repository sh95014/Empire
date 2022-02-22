//
//  Game.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

class Game {
    
    let map = Map()
    var cities = Array<Unit>()
    var players = Array<Player>()
    var currentPlayerIndex: Int
    
    init() {
        // create cities
        for _ in 0..<50 {
            repeat {
                let x = Int.random(in: 0..<map.width)
                let y = Int.random(in: 0..<map.height)
                if map.squareAt(x: x, y: y) == .land {
                    let city = City("City", x: x, y: y)
                    cities.append(city)
                    break
                }
            } while true
        }
        
        // give each player a starting city
        for i in 0..<6 {
            let player = Player(mapWidth: map.width, mapHeight: map.height)
            player.capture(cities[i])
            players.append(player)
        }
        
        currentPlayerIndex = 0
    }
    
    var currentPlayer: Player {
        return players[currentPlayerIndex]
    }

}
