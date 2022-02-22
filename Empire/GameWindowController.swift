//
//  GameWindowController.swift
//  Empire
//
//  Created by Steven Huang on 2/21/22.
//

import Cocoa
import SpriteKit

class GameWindowController: NSWindowController, NSWindowDelegate, SKViewDelegate {
    
    var game: Game!
    @IBOutlet var spriteView: SKView!
    @IBOutlet var verticalScroller: NSScroller!
    @IBOutlet var horizontalScroller: NSScroller!
    
    override var windowNibName: String! {
        return "GameWindow"
    }
    
    convenience init(_ game: Game) {
        self.init()
        self.loadWindow()
        
        window?.delegate = self
        
        self.game = game
        
        spriteView.delegate = self
        
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            scene.game = game
            scene.scaleMode = .resizeFill
            spriteView.presentScene(scene)
        }
        spriteView.ignoresSiblingOrder = true
        spriteView.showsFPS = true
        spriteView.showsNodeCount = true
        
        verticalScroller.doubleValue = 1
        verticalScroller.isEnabled = true
    
        // for some reason a NSScroller instantiated from nib refuses to go
        // horizontal, so we have to create this manually
        let scrollerWidth = NSScroller.scrollerWidth(for: .regular, scrollerStyle: .legacy)
        horizontalScroller = NSScroller.init(frame: CGRect(x: 0, y: 0, width: spriteView.frame.width, height: scrollerWidth))
        window?.contentView?.addSubview(horizontalScroller)
        
        horizontalScroller.doubleValue = 0
        horizontalScroller.isEnabled = true
        horizontalScroller.autoresizingMask = [ .width ]
        
        configureScrollers()
        
        let city = game.cities[0]
        scrollToCenter(x: city.x, y: city.y)
    }
    
    func windowDidResize(_ notification: Notification) {
        configureScrollers()
    }
    
    func configureScrollers() {
        if let scene = spriteView.scene,
           let terrainLayer = scene.childNode(withName: "map/terrain") as? SKTileMapNode {
            let mapWidth = terrainLayer.mapSize.width * terrainLayer.xScale
            let mapHeight = terrainLayer.mapSize.height * terrainLayer.yScale
            let spriteViewWidth = spriteView.frame.width
            let spriteViewHeight = spriteView.frame.height

            verticalScroller.knobProportion = spriteViewHeight / mapHeight
            
            horizontalScroller.knobProportion = spriteViewWidth / mapWidth
            horizontalScroller.target = self
            horizontalScroller.action = #selector(didScrollHorizontally(_:))
        }
    }
    
    @IBAction func didScrollVertically(_ scroller: NSScroller) {
        if scroller.hitPart == .knob,
           let scene = spriteView.scene,
           let map = scene.childNode(withName: "map") as? SKSpriteNode,
           let terrainLayer = scene.childNode(withName: "map/terrain") as? SKTileMapNode {
            let mapHeight = terrainLayer.mapSize.height * terrainLayer.yScale
            let spriteViewHeight = spriteView.frame.height
            map.position.y = -(1.0 - scroller.doubleValue) * (mapHeight - spriteViewHeight)
        }
    }
    
    @objc func didScrollHorizontally(_ scroller: NSScroller) {
        if scroller.hitPart == .knob,
           let scene = spriteView.scene,
           let map = scene.childNode(withName: "map") as? SKSpriteNode,
           let terrainLayer = scene.childNode(withName: "map/terrain") as? SKTileMapNode {
            let mapWidth = terrainLayer.mapSize.width * terrainLayer.xScale
            let spriteViewWidth = spriteView.frame.width
            map.position.x = -scroller.doubleValue * (mapWidth - spriteViewWidth)
        }
    }
    
    func viewDidScroll(_ view: NSView, deltaX: Double, deltaY: Double) {
        if let scene = spriteView.scene,
           let map = scene.childNode(withName: "map") as? SKSpriteNode,
           let terrainLayer = scene.childNode(withName: "map/terrain") as? SKTileMapNode {
            horizontalScroller.doubleValue -= deltaX / 20
            verticalScroller.doubleValue -= deltaY / 20
            
            let mapWidth = terrainLayer.mapSize.width * terrainLayer.xScale
            let mapHeight = terrainLayer.mapSize.height * terrainLayer.yScale
            let spriteViewWidth = spriteView.frame.width
            let spriteViewHeight = spriteView.frame.height
            map.position.x = -horizontalScroller.doubleValue * (mapWidth - spriteViewWidth)
            map.position.y = -(1.0 - verticalScroller.doubleValue) * (mapHeight - spriteViewHeight)
        }
    }
    
    func scrollToCenter(x: Int, y: Int) {
        let visibleWidth = horizontalScroller.knobProportion * Double(game.map.width)
        var desiredX = (Double(x) - visibleWidth / 2.0) / (Double(game.map.width) - visibleWidth)
        if desiredX < 0.0 {
            desiredX = 0.0
        } else if desiredX > 1.0 {
            desiredX = 1.0
        }
        
        let visibleHeight = verticalScroller.knobProportion * Double(game.map.height)
        var desiredY = (Double(y) - visibleHeight / 2.0) / (Double(game.map.height) - visibleHeight)
        if desiredY < 0.0 {
            desiredY = 0.0
        } else if desiredY > 1.0 {
            desiredY = 1.0
        }
        
        if let scene = spriteView.scene,
           let map = scene.childNode(withName: "map") as? SKSpriteNode,
           let terrainLayer = scene.childNode(withName: "map/terrain") as? SKTileMapNode {
            horizontalScroller.doubleValue = desiredX
            verticalScroller.doubleValue = desiredY
            
            let mapWidth = terrainLayer.mapSize.width * terrainLayer.xScale
            let mapHeight = terrainLayer.mapSize.height * terrainLayer.yScale
            let spriteViewWidth = spriteView.frame.width
            let spriteViewHeight = spriteView.frame.height
            map.position.x = -horizontalScroller.doubleValue * (mapWidth - spriteViewWidth)
            map.position.y = -(1.0 - verticalScroller.doubleValue) * (mapHeight - spriteViewHeight)
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        if let view = window?.contentView {
            viewDidScroll(view, deltaX: event.deltaX, deltaY: event.deltaY)
        }
    }
    
}

extension ClosedRange {
    
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
    
}
