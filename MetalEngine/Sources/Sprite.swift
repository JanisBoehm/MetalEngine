//
//  Sprite.swift
//  Metal2DRasterTest
//
//  Created by Janis Böhm on 08.11.18.
//  Copyright © 2018 Company At The End Of The Universe. All rights reserved.
//

import Foundation
import MetalKit
import simd



class Sprite {
    var vertexBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var texture: MTLTexture!
    var device: MTLDevice!
    var textures: [MTLTexture?]
    
    var count: Int
    var spriteID: Int

    var boundingBox: BoundingBox2D!
    var animation: Animation!
    
    init(device: MTLDevice?,vertexdata: [Vertex], vertexLength: Int, indexdata: [uint16], indexLength: Int, textureURL: URL, id: Int) {
        spriteID = id
        self.device = device
        self.count = 1
        self.textures = [MTLTexture?]()
        
        let rect = Rect(a: vertexdata[0].position, b: vertexdata[1].position, c: vertexdata[2].position, d: vertexdata[3].position)
        boundingBox = BoundingBox2D(origin: vector_float4(0,0,0,0), bounds: rect)

        vertexBuffer = device?.makeBuffer(bytes: vertexdata, length: vertexLength, options: [])
        uniformBuffer = device?.makeBuffer(length: MemoryLayout<Float>.size*16, options: [])
        indexBuffer = device?.makeBuffer(bytes: indexdata, length: indexLength, options: [])
        
        addTexture(with: textureURL)
        texture = textures[0]
    }
    
    init(device: MTLDevice?, vertexdata: [Vertex], indexdata: [uint16], textureURLs: [URL], id: Int) {
        spriteID = id
        self.device = device
        self.count = textureURLs.count
        self.textures = [MTLTexture?]()
        
        let rect = Rect(a: vertexdata[0].position, b: vertexdata[1].position, c: vertexdata[2].position, d: vertexdata[3].position)
        boundingBox = BoundingBox2D(origin: float4(0,0,0,1), bounds: rect)
        
        vertexBuffer = self.device.makeBuffer(bytes: vertexdata, length: vertexdata.count * MemoryLayout<Vertex>.size, options: [])
        uniformBuffer = self.device.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
        indexBuffer = self.device.makeBuffer(bytes: indexdata, length: indexdata.count * MemoryLayout<Vertex>.size, options: [])
        
        for i in 0..<self.count {
            addTexture(with: textureURLs[i])
        }
        texture = textures[0]
    }
    
    func addTexture(with url: URL) {
        let textureLoader = MTKTextureLoader(device: device)
        do {
            textures.append(try textureLoader.newTexture(URL: url, options: nil))
            count += 1
        } catch let e {
            print("Failed to load texture: \(e)")
        }
        
    }
    
    public func clearAnimation() {
        if (animation != nil) {
            animation?.timer?.invalidate()
            animation = nil
        }
    }
    
    public func setAnimation(name: String, frameIndex: [Int], interval: TimeInterval, repeating: Bool = true) {
        clearAnimation()
        animation = Animation(animationName: name, frameIndex: frameIndex, topTexture: &texture, textures: textures, interval: interval, repeating: repeating)
    }
    
    public func setTopTexture(id: Int) {
        if textures[id] != nil {
            texture = textures[id]
        }
    }
    
    func loadTexture(from url: URL) {
        let textureLoader = MTKTextureLoader(device: device!)
        do {
            texture = try textureLoader.newTexture(URL: url, options: nil)
        } catch let e {
            print("Failed to load texture: \(e)")
        }
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder?) {
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indexBuffer.length / MemoryLayout<uint16>.size, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
    }
    
    func update() {
        let rotationX = rotationMatrix(angle: boundingBox.rotation.x, axis: vector_float3(1,0,0))
        let rotationY = rotationMatrix(angle: boundingBox.rotation.y, axis: vector_float3(0,1,0))
        let rotationZ = rotationMatrix(angle: boundingBox.rotation.z, axis: vector_float3(0,0,1))
        let scaleMatrix = scalingMatrix(scale: boundingBox.scale)
        let translate = translationMatrix(position: boundingBox.translation)
        boundingBox.matrix = matrix_multiply(translate,
                                      matrix_multiply(rotationZ,
                                      matrix_multiply(rotationX,
                                      matrix_multiply(rotationY,scaleMatrix))))
        let uniformPointer = uniformBuffer.contents()
        var uniforms = Uniforms(mat: boundingBox.matrix)
        memcpy(uniformPointer, &uniforms, MemoryLayout<Float>.size*16)
    }
    
}
