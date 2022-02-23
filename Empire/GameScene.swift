//
//  GameScene.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import SpriteKit

class GameScene: SKScene, NSGestureRecognizerDelegate {
    
    var game: Game?
    var focusUnit: Unit?
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        
        createMap(scale: 2)
        
        let clickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleClick(recognizer:)))
        view.addGestureRecognizer(clickGestureRecognizer)

        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleDoubleClick(recognizer:)))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        view.addGestureRecognizer(doubleClickGestureRecognizer)
    }

    func createMap(scale: Double) {
        let mapLayer = SKSpriteNode()
        mapLayer.name = "map"
        mapLayer.anchorPoint = CGPoint.zero
        mapLayer.position = CGPoint.zero
        
        if let game = game {
            let columns = game.map.width
            let rows = game.map.height
            let gameTileSet = SKTileSet(named: "GameTileSet")!
            let tileSize = CGSize(width: 16, height: 16)
        
            let terrainLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            terrainLayer.anchorPoint = CGPoint.zero
            terrainLayer.name = "terrain"
            terrainLayer.setScale(scale)
            mapLayer.addChild(terrainLayer)
  
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
            mapLayer.addChild(unitLayer)

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
            mapLayer.addChild(coverLayer)

            addChild(mapLayer)
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
    
    func focus(_ unit: Unit) {
        setPointer(column: unit.x, row: unit.y)
        focusUnit = unit
        focusTick()
    }
    
    @objc func focusTick() {
        if let unit = focusUnit,
           let game = game,
           let unitLayer = childNode(withName: "map/units") as? SKTileMapNode {
            let rows = game.map.height
            let gameTileSet = SKTileSet(named: "GameTileSet")!
            let unitTiles = gameTileSet.tileGroups.first { $0.name == String(describing: type(of: unit)) }
            unitLayer.setTileGroup(unitTiles, forColumn: unit.x, row: rows - unit.y - 1)
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(focusTock), userInfo: nil, repeats: false)
        }
    }

    @objc func focusTock() {
        if let unit = focusUnit,
           let game = game,
           let unitLayer = childNode(withName: "map/units") as? SKTileMapNode {
            let rows = game.map.height
            let gameTileSet = SKTileSet(named: "GameTileSet")!
            for city in game.units.filter({ $0 is City }) {
                if city.x == unit.x && city.y == unit.y {
                    let cityTiles = gameTileSet.tileGroups.first { $0.name == "City" }
                    unitLayer.setTileGroup(cityTiles, forColumn: city.x, row: rows - city.y - 1)
                } else {
                    unitLayer.setTileGroup(nil, forColumn: city.x, row: rows - city.y - 1)
                }
            }
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(focusTick), userInfo: nil, repeats: false)
        }
    }

    @objc func handleClick(recognizer: NSClickGestureRecognizer) {
        if recognizer.state != .ended {
            return
        }

        let recognizorLocation = recognizer.location(in: recognizer.view!)
        var location = convertPoint(fromView: recognizorLocation)

        if let game = game,
           let mapLayer = childNode(withName: "map"),
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode {
            location.x = (location.x - mapLayer.position.x) / terrainLayer.xScale
            location.y = (location.y - mapLayer.position.y) / terrainLayer.yScale
            let column = terrainLayer.tileColumnIndex(fromPosition: location)
            let row = terrainLayer.tileRowIndex(fromPosition: location)
            
            setPointer(column: column, row: game.map.height - row - 1)
        }
    }
    
    func setPointer(column: Int, row: Int) {
        // set pointer position, creating one if necessary
        if let game = game,
           let mapLayer = childNode(withName: "map"),
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode {
            if mapLayer.childNode(withName: "pointer") == nil {
                let pointerSprite = SKSpriteNode(imageNamed: "pointer")
                pointerSprite.name = "pointer"
                mapLayer.addChild(pointerSprite)
            }
            if let pointerSprite = mapLayer.childNode(withName: "pointer") as? SKSpriteNode {
                var center = terrainLayer.centerOfTile(atColumn: column, row: game.map.height - row - 1)
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
           let mapLayer = childNode(withName: "map"),
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode {
            location.x = (location.x - mapLayer.position.x) / terrainLayer.xScale
            location.y = (location.y - mapLayer.position.y) / terrainLayer.yScale
            let rows = game.map.height
            let column = terrainLayer.tileColumnIndex(fromPosition: location)
            let row = rows - terrainLayer.tileRowIndex(fromPosition: location) - 1
            
            game.currentPlayer.visit(x: column, y: row)
            updateMap()
        }
    }

}
