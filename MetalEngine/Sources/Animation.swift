//
//  Animation.swift
//  Metal2DRasterTest
//
//  Created by Janis Böhm on 08.11.18.
//  Copyright © 2018 Company At The End Of The Universe. All rights reserved.
//

import Foundation
import MetalKit
import simd


/*
 
 
 class {
    var nextFrame: Int
    var frameIndex: [Int]
    var topTexture -> &
    var textures -> &[]
    var repeating: Bool
 
 
 //swaps textures every .25s, sets topTexture to texture[frameIndex[nextFrame]] nextFrame++
 //maybe via Foundation:Timer https://stackoverflow.com/questions/38695802/timer-scheduledtimer-swift-3-pre-ios-10-compatibility
 
 }
 
 
 */

class Animation {
    var nextFrame: Int
    var frameIndex: [Int]
    var name: String?
    
    var topTexture: UnsafeMutablePointer<MTLTexture>?
    var textures: [MTLTexture?]?
    
    var repeating: Bool
    
    var timer: Timer?
    
    init() {
        self.nextFrame = 0
        self.frameIndex = [Int]()
        repeating = false
    }
    
    init(animationName: String,
         frameIndex: [Int],
         topTexture: UnsafeMutablePointer<MTLTexture>,
         textures: [MTLTexture?],
         interval: TimeInterval,
         repeating: Bool = true) {
        
        self.name = animationName
        self.nextFrame = 0
        self.frameIndex = frameIndex
        self.topTexture = topTexture
        self.textures = textures
        self.repeating = repeating
        
        loop()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.loop), userInfo: nil, repeats: self.repeating)
        timer?.tolerance = interval*0.2
        
    }
    
    @objc func loop() {
        
        if ((textures![frameIndex[nextFrame]]) != nil) {
            topTexture?.pointee = textures![frameIndex[nextFrame]]!
        }
        
        nextFrame += 1
        if nextFrame >= frameIndex.count {
            nextFrame = 0
        }
    }
 
    func deactivateAnimation() {
        timer?.invalidate()
    }
    
    deinit {
        deactivateAnimation()
    }
    
}
