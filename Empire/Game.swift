//
//  Game.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Foundation

enum GameUI {
    case nothing
    case presentProductionMenu
    case requestMovementOrder
}

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

    func nextAction() -> (GameUI, Unit?) {
        // see if any units need orders
        for unit in units.filter({ $0.owner === currentPlayer }) {
            if unit.order == nil {
                if type(of: unit).canProduce() {
                    return (.presentProductionMenu, unit)
                } else {
                    return (.requestMovementOrder, unit)
                }
            }
        }
        
        // see if any orders need to be executed
        for unit in units.filter({ $0.owner === currentPlayer }) {
            if let produceOrder = unit.order as? ProduceUnitOrder {
                produceOrder.turnsLeft = produceOrder.turnsLeft - 1
                if produceOrder.turnsLeft <= 0 {
                    // produced a new unit!
                    let newUnit = produceOrder.unitType.init("NEW!", x: unit.x, y: unit.y)
                    newUnit.owner = currentPlayer
                    units.append(newUnit)
                    unit.order = ProduceUnitOrder(produceOrder, unitType: produceOrder.unitType)
                }
            }
        }
        
        return (.nothing, nil)
    }
    
}
