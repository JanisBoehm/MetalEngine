//
//  ViewController.swift
//  Metal2DRasterTest
//
//  Created by Janis Böhm on 08.11.18.
//  Copyright © 2018 Company At The End Of The Universe. All rights reserved.
//

import Cocoa
import Carbon
import Foundation
import MetalKit


class MetalView: MTKView {
    
    var testSprite: Character!
    var playerSprite: Character!
    
    var uimanager: UIManager!
    var renderer: Renderer!
    
    var applicationWasActive: Bool!
    var isCursorHidden: Bool!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        device = MTLCreateSystemDefaultDevice()!
        
        applicationWasActive = true
        isCursorHidden = false
        
        uimanager = UIManager()
        renderer = Renderer()
        
        initCharacters()
        //end of required init(coder: NSCoder)
    }
    
    override var acceptsFirstResponder : Bool {
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if NSRunningApplication.current.isActive {
            autoreleasepool {
                update()
                renderer.updateUniforms(drawableSize: drawableSize)
                renderer.startRender(renderPassDescriptor: currentRenderPassDescriptor!)
                testSprite.render(commandEncoder: renderer.commandEncoder)
                playerSprite.render(commandEncoder: renderer.commandEncoder)
                renderer.finishRender(drawable: currentDrawable!)
            }
            applicationWasActive = true
        }
        
        if NSRunningApplication.current.isHidden {
            if applicationWasActive && isCursorHidden {
                if CGDisplayShowCursor(kCGNullDirectDisplay) == CGError.success {
                    isCursorHidden = false
                }
            }
            applicationWasActive = false
        }
        //end of override func draw(_ dirtyRect: NSRect)
    }
    
    func update() {
        switch KeyState.down {
        case uimanager?.keyboard.keyStateA:
            playerSprite.boundingBox.translation.x -= 0.015
            if playerSprite.animation?.name != "walkLeft" {
                playerSprite.clearAnimation()
                playerSprite.setAnimation(name: "walkLeft", frameIndex: [3,2], interval: 0.2)
            }
        case uimanager?.keyboard.keyStateD:
            playerSprite.boundingBox.translation.x += 0.015
            if playerSprite.animation?.name != "walkRight" {
                playerSprite.clearAnimation()
                playerSprite.setAnimation(name: "walkRight", frameIndex: [1,0], interval: 0.2)
            }
        default:
            _ = 0
        }
        
        if uimanager?.keyboard.keyStateA == .up {
            if playerSprite.animation?.name == "walkLeft" {
                playerSprite.clearAnimation()
                playerSprite.setTopTexture(id: 2)
            }
        }
        if uimanager?.keyboard.keyStateD == .up {
            if playerSprite.animation?.name == "walkRight" {
                playerSprite.clearAnimation()
                playerSprite.setTopTexture(id: 0)
            }
        }
        
        
        testSprite.boundingBox.rotation.z += 0.01
        if testSprite.boundingBox.rotation.z >= 2*Float.pi {
            testSprite.boundingBox.rotation.z -= 2*Float.pi
        }
        
        testSprite.update()
        playerSprite.update()
        
        //end of func update()
    }
    
    func initCharacters() {
        let vertex_data: [Vertex] = [Vertex(pos: [-1.0,-1.0, 0.0, 1.0], col: [ 1.0, 0.0, 0.0, 1.0], tex: [0.0, 1.0]),
                                     Vertex(pos: [ 1.0,-1.0, 0.0, 1.0], col: [ 0.0, 1.0, 0.0, 1.0], tex: [1.0, 1.0]),
                                     Vertex(pos: [ 1.0, 1.0, 0.0, 1.0], col: [ 0.0, 0.0, 1.0, 1.0], tex: [1.0, 0.0]),
                                     Vertex(pos: [-1.0, 1.0, 0.0, 1.0], col: [ 1.0, 1.0, 0.0, 1.0], tex: [0.0, 0.0]),
                                     Vertex(pos: [ 0.0, 0.0, 0.0, 1.0], col: [ 0.0, 0.0, 0.0, 1.0], tex: [0.0, 0.0]),]
        
        let vertex_data2: [Vertex] = [Vertex(pos: [-0.625,-1.0, 0.0, 1.0], col: [ 1.0, 0.0, 0.0, 1.0], tex: [0.0, 1.0]),
                                      Vertex(pos: [ 0.625,-1.0, 0.0, 1.0], col: [ 0.0, 1.0, 0.0, 1.0], tex: [1.0, 1.0]),
                                      Vertex(pos: [ 0.625, 1.0, 0.0, 1.0], col: [ 0.0, 0.0, 1.0, 1.0], tex: [1.0, 0.0]),
                                      Vertex(pos: [-0.625, 1.0, 0.0, 1.0], col: [ 1.0, 1.0, 0.0, 1.0], tex: [0.0, 0.0]),
                                      Vertex(pos: [ 0.000, 0.0, 0.0, 1.0], col: [ 0.0, 0.0, 0.0, 1.0], tex: [0.0, 0.0]),]
        
        let index_data: [uint16] = [0, 1, 2, 2, 3, 0]
        
        let url = Bundle.main.url(forResource: "metal", withExtension: "png")!
        let urlMetal2 = Bundle.main.url(forResource: "swift", withExtension: "png")!
        let urlPlayer1 = Bundle.main.url(forResource: "starmanRight1", withExtension: "png")!
        let urlPlayer2 = Bundle.main.url(forResource: "starmanRight2", withExtension: "png")!
        let urlPlayer3 = Bundle.main.url(forResource: "starmanLeft1", withExtension: "png")!
        let urlPlayer4 = Bundle.main.url(forResource: "starmanLeft2", withExtension: "png")!
        //let urlBlueBox = Bundle.main.url(forResource: "blue", withExtension: "png")!
        
        testSprite = Character(device: device,
                               vertexdata: vertex_data,
                               vertexLength: MemoryLayout<Vertex>.size * vertex_data.count,
                               indexdata: index_data,
                               indexLength: MemoryLayout<uint16>.size * index_data.count,
                               textureURLs: [url, urlMetal2],
                               count: 2,
                               id: 0)
        
        playerSprite = Character(device: device,
                                 vertexdata: vertex_data2,
                                 vertexLength: MemoryLayout<Vertex>.size * vertex_data2.count,
                                 indexdata: index_data,
                                 indexLength: MemoryLayout<uint16>.size * index_data.count,
                                 textureURLs: [urlPlayer1,urlPlayer2,urlPlayer3,urlPlayer4],
                                 count: 4,
                                 id: 1)
        
        testSprite.boundingBox.scale = 0.5
        testSprite.boundingBox.rotation.z = 2
        testSprite.boundingBox.translation.x = 0.4
        
        testSprite.setAnimation(name: "idle", frameIndex: [0,1], interval: 1)
        
        playerSprite.boundingBox.scale = 0.2
        playerSprite.boundingBox.translation.y = -0.8
    }
}

