//
//  GameScene.swift
//  Empire
//
//  Created by sh95014 on 2/21/22.
//

import SpriteKit

class GameScene: SKScene, NSGestureRecognizerDelegate {
    
    var game: Game?
    var focusUnit: Unit?
    var focusCallback: (() -> Void)?
    var dragUnit: Unit?
    
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
        mapLayer.xScale = scale
        mapLayer.yScale = -scale
        
        if let game = game {
            let columns = game.map.width
            let rows = game.map.height
            let gameTileSet = SKTileSet(named: "GameTileSet")!
            let tileSize = CGSize(width: 16, height: 16)
        
            let terrainLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            terrainLayer.name = "terrain"
            mapLayer.addChild(terrainLayer)
  
            let seaTiles = gameTileSet.tileGroups.first { $0.name == "Sea" }
            let landTiles = gameTileSet.tileGroups.first { $0.name == "Land" }
            for row in 0..<rows {
                for column in 0..<columns {
                    switch game.map.squareAt(column: column, row: row) {
                    case .land:
                        terrainLayer.setTileGroup(landTiles, forColumn: column, row: row)
                    case .sea:
                        terrainLayer.setTileGroup(seaTiles, forColumn: column, row: row)
                    }
                }
            }
        
            let unitLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            unitLayer.name = "units"
            mapLayer.addChild(unitLayer)

            let cityTiles = gameTileSet.tileGroups.first { $0.name == "City" }
            for city in game.units.filter({ $0 is City }) {
                unitLayer.setTileGroup(cityTiles, forColumn: city.column, row: city.row)
            }
            
            let blackTiles = gameTileSet.tileGroups.first { $0.name == "Black" }
            let coverLayer = SKTileMapNode(tileSet: gameTileSet, columns: columns, rows: rows, tileSize: tileSize)
            coverLayer.name = "cover"
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
    
    func hideUnit(_ unit: Unit) {
        if  let game = game,
           let unitLayer = childNode(withName: "map/units") as? SKTileMapNode,
           let gameTileSet = SKTileSet(named: "GameTileSet") {
            let city = game.units.filter({ $0 is City && $0.column == unit.column && $0.row == unit.row })
            if city.count > 0 {
                let cityTiles = gameTileSet.tileGroups.first { $0.name == "City" }
                unitLayer.setTileGroup(cityTiles, forColumn: unit.column, row: unit.row)
            } else {
                unitLayer.setTileGroup(nil, forColumn: unit.column, row: unit.row)
            }
        }
    }
    
    func showUnit(_ unit: Unit) {
        if let unitLayer = childNode(withName: "map/units") as? SKTileMapNode,
           let gameTileSet = SKTileSet(named: "GameTileSet") {
            let unitTiles = gameTileSet.tileGroups.first { $0.name == String(describing: type(of: unit)) }
            unitLayer.setTileGroup(unitTiles, forColumn: unit.column, row: unit.row)
        }
    }
    
    func focus(_ unit: Unit, completion: @escaping () -> Void) {
        focusCallback = completion
        setPointer(column: unit.column, row: unit.row)
        focusUnit = unit
        focusTick()
    }
    
    @objc func focusTick() {
        // show the unit in focus
        if let unit = focusUnit,
           let unitLayer = childNode(withName: "map/units") as? SKTileMapNode,
           let gameTileSet = SKTileSet(named: "GameTileSet") {
            let unitTiles = gameTileSet.tileGroups.first { $0.name == String(describing: type(of: unit)) }
            unitLayer.setTileGroup(unitTiles, forColumn: unit.column, row: unit.row)
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(focusTock), userInfo: nil, repeats: false)
        }
    }

    @objc func focusTock() {
        // hide the unit in focus, either by showing the terrain below or a city
        if let unit = focusUnit,
           let game = game,
           let unitLayer = childNode(withName: "map/units") as? SKTileMapNode,
           let gameTileSet = SKTileSet(named: "GameTileSet") {
            let city = game.units.filter({ $0 is City && $0.column == unit.column && $0.row == unit.row })
            if city.count > 0 {
                let cityTiles = gameTileSet.tileGroups.first { $0.name == "City" }
                unitLayer.setTileGroup(cityTiles, forColumn: unit.column, row: unit.row)
            } else {
                unitLayer.setTileGroup(nil, forColumn: unit.column, row: unit.row)
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
            location.x = (location.x - mapLayer.position.x) / mapLayer.xScale
            location.y = (location.y - mapLayer.position.y) / mapLayer.yScale
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
                pointerSprite.position = terrainLayer.centerOfTile(atColumn: column, row: row)
                pointerSprite.setScale(2.0)
                pointerSprite.run(SKAction.scale(to: 1.0, duration: 0.07))
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
            location.x = (location.x - mapLayer.position.x) / mapLayer.xScale.magnitude
            location.y = (location.y - mapLayer.position.y) / mapLayer.yScale.magnitude
            let rows = game.map.height
            let column = terrainLayer.tileColumnIndex(fromPosition: location)
            let row = rows - terrainLayer.tileRowIndex(fromPosition: location) - 1
            
            game.currentPlayer.visit(column: column, row: row)
            updateMap()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if let mapLayer = childNode(withName: "map"),
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode {
            let dragStartLocation = event.location(in: terrainLayer)
            let dragStartColumn = terrainLayer.tileColumnIndex(fromPosition: dragStartLocation)
            let dragStartRow = terrainLayer.tileRowIndex(fromPosition: dragStartLocation)
            if let focusUnit = focusUnit,
               focusUnit.column == dragStartColumn && focusUnit.row == dragStartRow {
                let shapeLayer = SKShapeNode()
                shapeLayer.name = "shape"
                shapeLayer.strokeColor = NSColor.yellow
                shapeLayer.lineWidth = 2
                mapLayer.addChild(shapeLayer)
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if let shapeLayer = childNode(withName: "map/shape") as? SKShapeNode,
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode,
           let focusUnit = focusUnit {
            let path = CGMutablePath()
            path.move(to: terrainLayer.centerOfTile(atColumn: focusUnit.column, row: focusUnit.row))
            path.addLine(to: event.location(in: shapeLayer))
            shapeLayer.path = path
        }
    }

    override func mouseUp(with event: NSEvent) {
        if let focusUnit = focusUnit,
           let terrainLayer = childNode(withName: "map/terrain") as? SKTileMapNode,
           let shapeLayer = childNode(withName: "map/shape") {
            shapeLayer.removeFromParent()
            
            let endLocation = event.location(in: terrainLayer)
            let endColumn = terrainLayer.tileColumnIndex(fromPosition: endLocation)
            let endRow = terrainLayer.tileRowIndex(fromPosition: endLocation)
            focusUnit.order = MoveOrder(column: endColumn, row: endRow)
            self.focusUnit = nil
            
            focusCallback?()
            focusCallback = nil
        }
    }
    
}
