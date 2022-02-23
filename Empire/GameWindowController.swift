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
    var horizontalScroller: NSScroller!
    @IBOutlet var productionPanel: NSPanel!
    var productionUnit: Unit?
    
    override var windowNibName: String! {
        return "GameWindow"
    }
    
    convenience init(_ game: Game) {
        self.init()
        self.loadWindow()
        window?.delegate = self
        spriteView.delegate = self
        
        self.game = game
        
        // create the scene
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            scene.game = game
            scene.scaleMode = .resizeFill
            spriteView.presentScene(scene)
        }
        spriteView.ignoresSiblingOrder = true
        spriteView.showsFPS = true
        spriteView.showsNodeCount = true
        
        verticalScroller.isEnabled = true
    
        // for some reason a NSScroller instantiated from nib refuses to go
        // horizontal, so we have to create this manually
        let scrollerWidth = NSScroller.scrollerWidth(for: .regular, scrollerStyle: .legacy)
        horizontalScroller = NSScroller.init(frame: CGRect(x: 0, y: 0, width: spriteView.frame.width, height: scrollerWidth))
        horizontalScroller.isEnabled = true
        horizontalScroller.autoresizingMask = [ .width ]
        window?.contentView?.addSubview(horizontalScroller)
        
        updateScrollers()
        
        // start the game
        gameNextAction()
    }
    
    func windowDidResize(_ notification: Notification) {
        updateScrollers()
    }
    
    func updateScrollers() {
        // size the scroller knobs to reflect the ratio between the viewport
        // and the full map
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
        // scroll the map to match the scroller motion
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
        // scroll the map to match the scroller motion
        if scroller.hitPart == .knob,
           let scene = spriteView.scene,
           let map = scene.childNode(withName: "map") as? SKSpriteNode,
           let terrainLayer = scene.childNode(withName: "map/terrain") as? SKTileMapNode {
            let mapWidth = terrainLayer.mapSize.width * terrainLayer.xScale
            let spriteViewWidth = spriteView.frame.width
            map.position.x = -scroller.doubleValue * (mapWidth - spriteViewWidth)
        }
    }
    
    func scrollToCenter(x: Int, y: Int) {
        // scroll so that x, y would be centered in the window
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
        // handle two-finger scrolling
        if let scene = spriteView.scene,
           let map = scene.childNode(withName: "map") as? SKSpriteNode,
           let terrainLayer = scene.childNode(withName: "map/terrain") as? SKTileMapNode {
            horizontalScroller.doubleValue -= event.deltaX / 20
            verticalScroller.doubleValue -= event.deltaY / 20
            
            let mapWidth = terrainLayer.mapSize.width * terrainLayer.xScale
            let mapHeight = terrainLayer.mapSize.height * terrainLayer.yScale
            let spriteViewWidth = spriteView.frame.width
            let spriteViewHeight = spriteView.frame.height
            map.position.x = -horizontalScroller.doubleValue * (mapWidth - spriteViewWidth)
            map.position.y = -(1.0 - verticalScroller.doubleValue) * (mapHeight - spriteViewHeight)
        }
    }
    
    func gameNextAction() {
        let player = game.currentPlayer
        
        // see if any units need orders
        for unit in game.units.filter({ $0.owner === player }) {
            if unit.order == nil {
                scrollToCenter(x: unit.x, y: unit.y)
                if type(of: unit).canProduce() {
                    productionPanel.title = unit.name
                    productionPanel.orderFront(self)
                    productionUnit = unit
                    return
                }
            }
        }
        

    }

    @IBAction func setProduction(_ sender: NSButton) {
        let unitTypes: [Unit.Type] = [ Army.self, Fighter.self,
                                       AirTransport.self, Bomber.self,
                                       Destroyer.self, SeaTransport.self,
                                       Cruiser.self, Submarine.self,
                                       AircraftCarrier.self ]
        
        if let productionUnit = self.productionUnit {
            productionUnit.order = ProduceUnit(unitTypes[sender.tag - 1])
        }
    }
    
    @IBAction func finishSetProduction(_ sender: Any) {
        productionPanel.orderOut(sender)
        gameNextAction()
    }
    
}

public class SharpImageView: NSImageView {

    public override func draw(_ dirtyRect: NSRect) {
        // disable interpolation for sharp "pixellated" look
        if let image = self.image,
           image.size.width <= dirtyRect.size.width && image.size.height <= dirtyRect.size.height {
            NSGraphicsContext.current?.cgContext.interpolationQuality = .none
        }
        super.draw(dirtyRect)
        NSGraphicsContext.current?.cgContext.interpolationQuality = .default
    }

}
