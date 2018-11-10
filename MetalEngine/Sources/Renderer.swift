//
//  Renderer.swift
//  MetalEngine
//
//  Created by Janis Böhm on 10.11.18.
//  Copyright © 2018 Company At The End Of The Universe. All rights reserved.
//

import Foundation
import simd
import Cocoa
import Metal



class Renderer {
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var commandBuffer: MTLCommandBuffer!
    var commandEncoder: MTLRenderCommandEncoder!
    
    var defaultRenderPipelineState: MTLRenderPipelineState!
    var defaultUniformBuffer: MTLBuffer!
    var defaultSamplerState: MTLSamplerState!
    
    
    
    init() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        initRenderPipeline()
    }
    
    func startRender(renderPassDescriptor: MTLRenderPassDescriptor) {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.9, 0.9, 0.9, 1)
        commandBuffer = commandQueue.makeCommandBuffer()
        commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        commandEncoder?.setRenderPipelineState(defaultRenderPipelineState!)
        commandEncoder?.setFrontFacing(.counterClockwise)
        commandEncoder?.setCullMode(.back)
        commandEncoder?.setTriangleFillMode(.fill)
        commandEncoder?.setVertexBuffer(defaultUniformBuffer, offset: 0, index: 1)
        commandEncoder?.setFragmentSamplerState(defaultSamplerState, index: 0)
    }
    
    func finishRender(drawable: MTLDrawable) {
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func initRenderPipeline() {
        initUniformsBuffer()
        initRenderPipelineState()
        initSamplerState()
    }
    
    func initUniformsBuffer() {
        defaultUniformBuffer = device!.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
    }
    
    func initRenderPipelineState() {
        let shaderLibrary: MTLLibrary
        let vertex_function: MTLFunction
        let fragment_function: MTLFunction
        
        do {
            shaderLibrary = device.makeDefaultLibrary()!
            vertex_function = shaderLibrary.makeFunction(name: "vertex_func")!
            fragment_function = shaderLibrary.makeFunction(name: "fragment_func")!
            
            let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
            renderPipelineDescriptor.vertexFunction = vertex_function
            renderPipelineDescriptor.fragmentFunction = fragment_function
            renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
            renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
            renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
            renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            defaultRenderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let e {
            print("\(e)")
        }
    }
    
    func initSamplerState() {
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
        
        defaultSamplerState = device.makeSamplerState(descriptor: samplerDescriptor)
    }
    
    func updateUniforms(drawableSize: CGSize) {
        let aspect: Float = Float(drawableSize.height) / Float(drawableSize.width)
        let aspectMatrix = matrix_float4x4(float4(   aspect, 0, 0, 0),
                                           float4(        0, 1, 0, 0),
                                           float4(        0, 0, 1, 0),
                                           float4(        0, 0, 0, 1))
        var uniforms = Uniforms(mat: aspectMatrix)
        let bufferPointer = defaultUniformBuffer.contents()
        memcpy(bufferPointer, &uniforms, MemoryLayout<Float>.size * 16)
    }
}
