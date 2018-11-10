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
    
    var commandQueue: MTLCommandQueue?
    var defaultRenderPipelineState: MTLRenderPipelineState?
    var defaultVertexBuffer: MTLBuffer!
    var defaultUniformBuffer: MTLBuffer!
    var defaultIndexBuffer: MTLBuffer!
    var samplerState: MTLSamplerState!
    
    var testSprite: Character!
    var playerSprite: Character!
    
    var uimanager: UIManager?
    
    var applicationWasActive: Bool!
    var isCursorHidden: Bool!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        applicationWasActive = true
        isCursorHidden = false
        
        uimanager = UIManager(coder: coder)
        
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device?.makeCommandQueue()
        setupRenderPipeline()
        
        //end of required init(coder: NSCoder)
    }
    
    override var acceptsFirstResponder : Bool {
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if NSRunningApplication.current.isActive {
            update()
            render()
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
        let aspect: Float = Float(drawableSize.height) / Float(drawableSize.width)
        let aspectMatrix = matrix_float4x4(float4(   aspect, 0, 0, 0),
                                           float4(        0, 1, 0, 0),
                                           float4(        0, 0, 1, 0),
                                           float4(        0, 0, 0, 1))
        var uniforms = Uniforms(mat: aspectMatrix)
        let bufferPointer = defaultUniformBuffer.contents()
        memcpy(bufferPointer, &uniforms, MemoryLayout<Float>.size * 16)
        
        switch KeyState.down {
        case uimanager?.keyboard.keyStateA:
            playerSprite.boundingBox.translation.x -= 0.015
            //playerSprite.setTopTexture(id: 1)
            if playerSprite.animation?.name != "walkLeft" {
                playerSprite.clearAnimation()
                playerSprite.setAnimation(name: "walkLeft", frameIndex: [3,2], interval: 0.2)
            }
        case uimanager?.keyboard.keyStateD:
            playerSprite.boundingBox.translation.x += 0.015
            //playerSprite.setTopTexture(id: 0)
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
    
    func render() {
        if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor {
            rpd.colorAttachments[0].clearColor = MTLClearColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            let commandBuffer = commandQueue?.makeCommandBuffer()
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
            
            commandEncoder?.setRenderPipelineState(defaultRenderPipelineState!)
            commandEncoder?.setFrontFacing(.counterClockwise)
            commandEncoder?.setCullMode(.back)
            commandEncoder?.setTriangleFillMode(.fill)
            commandEncoder?.setVertexBuffer(defaultUniformBuffer, offset: 0, index: 1)
            commandEncoder?.setFragmentSamplerState(samplerState, index: 0)
            commandEncoder?.setFragmentTexture(testSprite.texture, index: 0)
            
            testSprite.render(commandEncoder: commandEncoder)
            playerSprite.render(commandEncoder: commandEncoder)
            
            commandEncoder?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
        
        //end of func render()
    }
    
    func setupRenderPipeline() {
        
        setupShaders()
        setupBuffers()
        
        //end of func setupRenderPipeline()
    }
    
    func setupShaders() {
        
        let shaderLibrary: MTLLibrary
        let vertex_func: MTLFunction
        let fragment_func: MTLFunction
        
        do {
            shaderLibrary = device!.makeDefaultLibrary()!
            
            vertex_func = shaderLibrary.makeFunction(name: "vertex_func")!
            fragment_func = shaderLibrary.makeFunction(name: "fragment_func")!
            
            let rpsd = MTLRenderPipelineDescriptor()
            rpsd.fragmentFunction = fragment_func
            rpsd.vertexFunction = vertex_func
            rpsd.colorAttachments[0].pixelFormat = .bgra8Unorm
            rpsd.colorAttachments[0].isBlendingEnabled = true
            rpsd.colorAttachments[0].rgbBlendOperation = .add
            rpsd.colorAttachments[0].alphaBlendOperation = .add
            rpsd.colorAttachments[0].sourceRGBBlendFactor = .one
            rpsd.colorAttachments[0].sourceAlphaBlendFactor = .one
            rpsd.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            rpsd.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            defaultRenderPipelineState = try device!.makeRenderPipelineState(descriptor: rpsd)
        } catch let e {
            print("oh no something has gone wrong: \(e)")
        }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.magFilter = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.minFilter = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.mipFilter = MTLSamplerMipFilter.nearest
        samplerDescriptor.maxAnisotropy = 1
        samplerDescriptor.rAddressMode = MTLSamplerAddressMode.clampToEdge
        samplerDescriptor.sAddressMode = MTLSamplerAddressMode.clampToEdge
        samplerDescriptor.tAddressMode = MTLSamplerAddressMode.clampToEdge
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.lodMinClamp = 0
        samplerDescriptor.lodMaxClamp = Float.greatestFiniteMagnitude
        
        samplerState = device?.makeSamplerState(descriptor: samplerDescriptor)
        //end of func setupShaders()
    }
    
    func setupBuffers() {
        
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
        
        defaultUniformBuffer = device!.makeBuffer(length: MemoryLayout<Float>.size * 16,
                                                  options: [])
        
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
        //end of func setupBuffers()
    }
    
}

