//
//  Game.swift
//  Empire
//
//  Created by sh95014 on 2/21/22.
//

import Foundation

enum GameUI {
    case nothing
    case presentProductionMenu
    case requestMovementOrder
    case moveUnit
}

class Game {
    
    let map = Map()
    var units = Array<Unit>()
    var players = Array<Player>()
    var currentPlayerIndex = 0
    var turn: Int = 1
    
    init() {
        // create cities
        for _ in 0..<50 {
            repeat {
                let column = Int.random(in: 0..<map.width)
                let row = Int.random(in: 0..<map.height)
                if map.squareAt(column: column, row: row) == .land {
                    let city = City("City \(column)-\(row)", column: column, row: row)
                    city.canProduceShips = map.hasPort(column: column, row: row)
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
    }
    
    var currentPlayer: Player {
        return players[currentPlayerIndex]
    }

    func nextAction() -> (GameUI, Unit?) {
        print("nextAction()")
        
        // see if any unit need orders
        for unit in units.filter({ $0.owner === currentPlayer }) {
            print("- \(unit)")
            if unit.order == nil {
                if type(of: unit).canProduce() {
                    print("-- needs production orders")
                    return (.presentProductionMenu, unit)
                } else {
                    print("-- needs movement orders")
                    return (.requestMovementOrder, unit)
                }
            } else if unit.order is SkipTurnOrder {
                // head on to next turn without orders
                print("-- skip turn")
            } else if let produceUnitOrder = unit.order as? ProduceUnitOrder {
                let turnsRequired = unit.hasProduced(produceUnitOrder.unitType) ?
                    produceUnitOrder.unitType.subsequentProductionTurns :
                    produceUnitOrder.unitType.initialProductionTurns
                if turn - produceUnitOrder.turnStarted >= turnsRequired {
                    if let newUnit = unit.produce() {
                        newUnit.owner = currentPlayer
                        units.append(newUnit)
                        
                        // automatically renew the production order
                        unit.order = ProduceUnitOrder(produceUnitOrder.unitType, turn: turn)
                        print("-- produced \(newUnit)")
                    }
                } else {
                    let turnsLeft = turnsRequired - (turn - produceUnitOrder.turnStarted)
                    print("-- \(turnsLeft) turns left to produce \(produceUnitOrder.unitType)")
                }
            } else if let moveOrder = unit.order as? MoveOrder {
                if unit.column != moveOrder.column || unit.row != moveOrder.row {
                    // keep moving
                    print("-- keep moving towards (\(moveOrder.column), \(moveOrder.row))")
                    return (.moveUnit, unit)
                } else {
                    // arrived
                    print("-- arrived at (\(moveOrder.column), \(moveOrder.row))")
                    unit.order = nil
                }
            }
        }
        
        return (.nothing, nil)
    }
    
    func nextTurn() {
        turn += 1
        print("nextTurn() - \(turn)")
    }
    
}
