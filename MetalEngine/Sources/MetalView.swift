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
    
    var testSprite: Sprite!
    var playerSprite: Sprite!
    
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
        if uimanager.keyboard.keyStateD == .down {
            playerSprite.boundingBox.translation.x += 0.015
            playerSprite.setTopTexture(id: 0)
        }
        if uimanager.keyboard.keyStateA == .down {
            playerSprite.boundingBox.translation.x -= 0.015
            playerSprite.setTopTexture(id: 1)
        }
        if uimanager.keyboard.keyStateW == .down {
            playerSprite.boundingBox.translation.y += 0.015
            playerSprite.setTopTexture(id: 2)
        }
        if uimanager.keyboard.keyStateS == .down {
            playerSprite.boundingBox.translation.y -= 0.015
            playerSprite.setTopTexture(id: 3)
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
        let urlPlayer1 = Bundle.main.url(forResource: "starmanTopRight", withExtension: "png")!
        let urlPlayer2 = Bundle.main.url(forResource: "starmanTopLeft", withExtension: "png")!
        let urlPlayer3 = Bundle.main.url(forResource: "starmanTopUp", withExtension: "png")!
        let urlPlayer4 = Bundle.main.url(forResource: "starmanTopDown", withExtension: "png")!
        //let urlBlueBox = Bundle.main.url(forResource: "blue", withExtension: "png")!
        
        testSprite = Sprite(device: device,
                            vertexdata: vertex_data,
                            indexdata: index_data,
                            textureURLs: [url,urlMetal2],
                            id: 0)
        
        playerSprite = Sprite(device: device,
                              vertexdata: vertex_data,
                              indexdata: index_data,
                              textureURLs: [urlPlayer1,urlPlayer2,urlPlayer3,urlPlayer4],
                              id: 1)
        
        testSprite.boundingBox.scale = float3(0.5,0.5,1)
        testSprite.boundingBox.rotation.z = 2
        testSprite.boundingBox.translation.x = 0.4
        
        testSprite.setAnimation(name: "idle", frameIndex: [0,1], interval: 1)
        
        playerSprite.boundingBox.scale = float3(0.2,0.2,1)
        playerSprite.boundingBox.translation.y = -0.8
    }
}

