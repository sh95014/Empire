//
//  GameScene.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import SpriteKit

class GameScene: SKScene, NSGestureRecognizerDelegate {
    
    var game: Game?
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        
        createMap(scale: 1)
        
        let clickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleClick(recognizer:)))
        view.addGestureRecognizer(clickGestureRecognizer)

        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleDoubleClick(recognizer:)))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        view.addGestureRecognizer(doubleClickGestureRecognizer)
    }

    func createMap(scale: Double) {
        let map = SKSpriteNode()
        map.name = "map"
        map.anchorPoint = CGPoint.zero
        map.position = CGPoint.zero
        
        if let game = game {
            let columns = game.map.width
            let rows = game.map.height
            let gameTileSet = SKTileSet(named: "GameTileSet")!
            let tileSize = CGSize(width: 16, height: 16)
        
            let terrainLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            terrainLayer.anchorPoint = CGPoint.zero
            terrainLayer.name = "terrain"
            terrainLayer.setScale(scale)
            map.addChild(terrainLayer)
  
            let seaTiles = gameTileSet.tileGroups.first { $0.name == "Sea" }
            let landTiles = gameTileSet.tileGroups.first { $0.name == "Land" }
            for row in 0..<rows {
                for column in 0..<columns {
                    switch game.map.squareAt(x: column, y: row) {
                    case .land:
                        terrainLayer.setTileGroup(landTiles, forColumn: column, row: rows - row - 1)
                    case .sea:
                        terrainLayer.setTileGroup(seaTiles, forColumn: column, row: rows - row - 1)
                    }
                }
            }
        
            let unitLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            unitLayer.anchorPoint = CGPoint.zero
            unitLayer.name = "units"
            unitLayer.setScale(scale)
            map.addChild(unitLayer)

            let cityTiles = gameTileSet.tileGroups.first { $0.name == "City" }
            for city in game.units.filter({ $0 is City }) {
                unitLayer.setTileGroup(cityTiles, forColumn: city.x, row: rows - city.y - 1)
            }
            
            let blackTiles = gameTileSet.tileGroups.first { $0.name == "Black" }
            let coverLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            coverLayer.anchorPoint = CGPoint.zero
            coverLayer.name = "cover"
            coverLayer.setScale(scale)
            coverLayer.fill(with: blackTiles)
            map.addChild(coverLayer)

            addChild(map)
            updateMap()
        }
    }
    
    func updateMap() {
        if let game = game,
           let coverLayer = childNode(withName: "map/cover") as? SKTileMapNode {
            let columns = game.map.width
            let rows = game.map.height
            let player = game.currentPlayer

            for row in 0..<rows {
                for column in 0..<columns {
                    if player.hasVisited[row][column] {
                        coverLayer.setTileGroup(nil, forColumn: column, row: rows - row - 1)
                    }
                }
            }
        }
    }
    
    @objc func handleClick(recognizer: NSClickGestureRecognizer) {
        if recognizer.state != .ended {
            return
        }

        let recognizorLocation = recognizer.location(in: recognizer.view!)
        var location = convertPoint(fromView: recognizorLocation)

        if let game = game,
           let map = childNode(withName: "map"),
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode {
            location.x = (location.x - map.position.x) / terrainLayer.xScale
            location.y = (location.y - map.position.y) / terrainLayer.yScale
            let column = terrainLayer.tileColumnIndex(fromPosition: location)
            let row = terrainLayer.tileRowIndex(fromPosition: location)
//            let rows = game.map.height
            
//            print("click \(column),\(row) \(worldMap[rows - row - 1][column])")
            
            // set pointer position, creating one if necessary
            if map.childNode(withName: "pointer") == nil {
                let pointerSprite = SKSpriteNode(imageNamed: "pointer")
                pointerSprite.name = "pointer"
                map.addChild(pointerSprite)
            }
            if let pointerSprite = map.childNode(withName: "pointer") as? SKSpriteNode {
                var center = terrainLayer.centerOfTile(atColumn: column, row: row)
                center.x *= terrainLayer.xScale
                center.y *= terrainLayer.yScale
                pointerSprite.position = center
                
                pointerSprite.setScale(terrainLayer.xScale * 2)
                pointerSprite.run(SKAction.scale(to: terrainLayer.xScale, duration: 0.07))
            }
        }
    }
    
    @objc func handleDoubleClick(recognizer: NSClickGestureRecognizer) {
        if recognizer.state != .ended {
            return
        }
        
        let recognizorLocation = recognizer.location(in: recognizer.view!)
        var location = convertPoint(fromView: recognizorLocation)

        if let game = game,
           let map = childNode(withName: "map"),
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode {
            location.x = (location.x - map.position.x) / terrainLayer.xScale
            location.y = (location.y - map.position.y) / terrainLayer.yScale
            let rows = game.map.height
            let column = terrainLayer.tileColumnIndex(fromPosition: location)
            let row = rows - terrainLayer.tileRowIndex(fromPosition: location) - 1
            
            game.currentPlayer.visit(x: column, y: row)
            updateMap()
        }
    }

}
