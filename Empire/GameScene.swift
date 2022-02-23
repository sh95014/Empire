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
        createMap(scale: 1.5)
        
        let clickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleClick(recognizer:)))
        view.addGestureRecognizer(clickGestureRecognizer)

        let doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleDoubleClick(recognizer:)))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        view.addGestureRecognizer(doubleClickGestureRecognizer)
    }

    func createMap(scale: Double) {
        let mapLayer = SKSpriteNode()
        mapLayer.name = "map"
        
        if let game = game {
            let columns = game.map.width
            let rows = game.map.height
            let gameTileSet = SKTileSet(named: "GameTileSet")!
            let tileSize = CGSize(width: 16, height: 16)
        
            let terrainLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            terrainLayer.name = "terrain"
            terrainLayer.xScale = scale
            terrainLayer.yScale = -scale
            mapLayer.addChild(terrainLayer)
  
            let seaTiles = gameTileSet.tileGroups.first { $0.name == "Sea" }
            let landTiles = gameTileSet.tileGroups.first { $0.name == "Land" }
            for row in 0..<rows {
                for column in 0..<columns {
                    switch game.map.squareAt(x: column, y: row) {
                    case .land:
                        terrainLayer.setTileGroup(landTiles, forColumn: column, row: row)
                    case .sea:
                        terrainLayer.setTileGroup(seaTiles, forColumn: column, row: row)
                    }
                }
            }
        
            let unitLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            unitLayer.name = "units"
            unitLayer.xScale = scale
            unitLayer.yScale = -scale
            mapLayer.addChild(unitLayer)

            let cityTiles = gameTileSet.tileGroups.first { $0.name == "City" }
            for city in game.units.filter({ $0 is City }) {
                unitLayer.setTileGroup(cityTiles, forColumn: city.x, row: city.y)
            }
            
            let blackTiles = gameTileSet.tileGroups.first { $0.name == "Black" }
            let coverLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            coverLayer.name = "cover"
            coverLayer.xScale = scale
            coverLayer.yScale = -scale
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
                        coverLayer.setTileGroup(nil, forColumn: column, row: row)
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
        // show the unit in focus
        if let unit = focusUnit,
           let unitLayer = childNode(withName: "map/units") as? SKTileMapNode {
            print("yScale1 = \(unitLayer.yScale)")
            let gameTileSet = SKTileSet(named: "GameTileSet")!
            let unitTiles = gameTileSet.tileGroups.first { $0.name == String(describing: type(of: unit)) }
            unitLayer.setTileGroup(unitTiles, forColumn: unit.x, row: unit.y)
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(focusTock), userInfo: nil, repeats: false)
        }
    }

    @objc func focusTock() {
        // hide the unit in focus, either by showing the terrain below or a city
        if let unit = focusUnit,
           let game = game,
           let unitLayer = childNode(withName: "map/units") as? SKTileMapNode {
            print("yScale2 = \(unitLayer.yScale)")
            let gameTileSet = SKTileSet(named: "GameTileSet")!
            let city = game.units.filter({ $0 is City && $0.x == unit.x && $0.y == unit.y })
            if city.count > 0 {
                let cityTiles = gameTileSet.tileGroups.first { $0.name == "City" }
                unitLayer.setTileGroup(cityTiles, forColumn: unit.x, row: unit.y)
            } else {
                unitLayer.setTileGroup(nil, forColumn: unit.x, row: unit.y)
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

        if let mapLayer = childNode(withName: "map"),
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode {
            location.x = (location.x - mapLayer.position.x) / terrainLayer.xScale
            location.y = (location.y - mapLayer.position.y) / terrainLayer.yScale
            let column = terrainLayer.tileColumnIndex(fromPosition: location)
            let row = terrainLayer.tileRowIndex(fromPosition: location)
            
            setPointer(column: column, row: row)
        }
    }
    
    func setPointer(column: Int, row: Int) {
        // set pointer position, creating one if necessary
        if let mapLayer = childNode(withName: "map"),
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode {
            if mapLayer.childNode(withName: "pointer") == nil {
                let pointerSprite = SKSpriteNode(imageNamed: "pointer")
                pointerSprite.name = "pointer"
                mapLayer.addChild(pointerSprite)
            }
            if let pointerSprite = mapLayer.childNode(withName: "pointer") as? SKSpriteNode {
                var center = terrainLayer.centerOfTile(atColumn: column, row: row)
                center.x *= terrainLayer.xScale
                center.y *= terrainLayer.yScale
                pointerSprite.position = center
                
                pointerSprite.xScale = terrainLayer.xScale * 2
                pointerSprite.yScale = terrainLayer.yScale * 2
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
            location.x = (location.x - mapLayer.position.x) / terrainLayer.xScale.magnitude
            location.y = (location.y - mapLayer.position.y) / terrainLayer.yScale.magnitude
            let rows = game.map.height
            let column = terrainLayer.tileColumnIndex(fromPosition: location)
            let row = rows - terrainLayer.tileRowIndex(fromPosition: location) - 1
            
            game.currentPlayer.visit(x: column, y: row)
            updateMap()
        }
    }

}
