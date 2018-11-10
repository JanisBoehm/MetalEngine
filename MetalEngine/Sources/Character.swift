//
//  Character.swift
//  Metal2DRasterTest
//
//  Created by Janis Böhm on 08.11.18.
//  Copyright © 2018 Company At The End Of The Universe. All rights reserved.
//

import Foundation
import MetalKit
import simd



class Character: Sprite {
    
    var textures: [MTLTexture?]
    var count: Int
    
    var animation: Animation?
    
    
    override init(device: MTLDevice?, vertexdata: [Vertex], vertexLength: Int, indexdata: [uint16], indexLength: Int, textureURL: URL, id: Int) {
        textures = [MTLTexture?]()
        count = 1
        self.animation = Animation()
        super.init(device: device, vertexdata: vertexdata, vertexLength: vertexLength, indexdata: indexdata, indexLength: indexLength, textureURL: textureURL, id: id)
        //end of override init()
    }
    
    init(device: MTLDevice?,
         vertexdata: [Vertex],
         vertexLength: Int,
         indexdata: [uint16],
         indexLength: Int,
         textureURLs: [URL],
         count: Int,
         id: Int) {
        textures = [MTLTexture?]()
        self.count = count
        self.animation = Animation()
        super.init(device: device, vertexdata: vertexdata, vertexLength: vertexLength, indexdata: indexdata, indexLength: indexLength, textureURL: textureURLs[0], id: 0)
        
        let textureLoader = MTKTextureLoader(device: device!)
        if textureURLs.count >= 1 {
            for i in 0..<count {
                do {
                    textures.append( try textureLoader.newTexture(URL: textureURLs[i], options: nil))
                } catch let e {
                    print("Failed to load texture: \(e)")
                }
            }
        }
        //end of init()
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
    
}
