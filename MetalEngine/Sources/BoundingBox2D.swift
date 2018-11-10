//
//  2DBoundingBox.swift
//  Metal2DRasterTest
//
//  Created by Janis Böhm on 09.11.18.
//  Copyright © 2018 Company At The End Of The Universe. All rights reserved.
//

import Foundation
import simd
import MetalKit



class BoundingBox2D {
    
    var origin: vector_float4
    var bounds: Rect
    
    var rotation: vector_float3
    var scale: Float
    var translation: vector_float4
    
    var matrix: matrix_float4x4
    
    func getOrigin() -> vector_float4 {
        return matrix * origin
    }
    
    func getBounds() -> Rect {
        let rect = Rect(a: matrix * bounds.a, b: matrix * bounds.b, c: matrix * bounds.c, d: matrix * bounds.d)
        return rect
    }
    
    init(origin: vector_float4, bounds: Rect) {
        self.bounds = bounds
        
        rotation = vector_float3(0,0,0)
        scale = 1.0
        translation = vector_float4(0,0,0,1)
        
        matrix = matrix_multiply(translationMatrix(position: translation),
                      matrix_multiply(rotationMatrix(angle: rotation.x, axis: vector_float3(1,0,0)),
                      matrix_multiply(rotationMatrix(angle: rotation.y, axis: vector_float3(0,1,0)),
                      matrix_multiply(rotationMatrix(angle: rotation.z, axis: vector_float3(0,0,1)),
                      scalingMatrix(scale: scale)))))
        
        self.origin = matrix * origin
    }
    
    func checkPointCollision(with rect: Rect, point: vector_float4) -> Int {
        let _1: Double = Double(dotProduct(a: rect.a-point, b: rect.b-point) /
            (magnitude(vector: rect.a-point)*magnitude(vector: rect.b-point)))
        let _2: Double = Double(dotProduct(a: rect.b-point, b: rect.c-point) /
            (magnitude(vector: rect.b-point)*magnitude(vector: rect.c-point)))
        let _3: Double = Double(dotProduct(a: rect.c-point, b: rect.d-point) /
            (magnitude(vector: rect.c-point)*magnitude(vector: rect.d-point)))
        let _4: Double = Double(dotProduct(a: rect.d-point, b: rect.a-point) /
            (magnitude(vector: rect.d-point)*magnitude(vector: rect.a-point)))
        
        let _0 = acos(_1) + acos(_2) + acos(_3) + acos(_4)
        
        if fabs(Double.pi*2 - _0) <= 0.001*fabs(Double.pi*2) {
            return 1
        }
        
        return 0 //returns 1 if collision detected
    }
    
    public func checkCollision(with rect2: Rect) -> Int {
        let _00 = Rect(a: matrix * bounds.a, b: matrix * bounds.b, c: matrix * bounds.c, d: matrix * bounds.d)
        
        let _01 = vector_float4((_00.c.x-_00.a.x)/2,
                                (_00.c.y-_00.a.y)/2,
                                (_00.c.z-_00.a.z)/2,
                                (_00.c.w-_00.a.w)/2)
        let _02 = vector_float4((rect2.c.x-rect2.a.x)/2,
                                (rect2.c.y-rect2.a.y)/2,
                                (rect2.c.z-rect2.a.z)/2,
                                (rect2.c.w-rect2.a.w)/2)
        let _03 = (_00.a + _01) - (rect2.a + _02)
        let _04 = magnitude(vector: _01) + magnitude(vector: _02)
        
        if magnitude(vector: _03) > _04 {
            return 0
        }
        
        let _11 = checkPointCollision(with: rect2, point: _00.a)
        let _12 = checkPointCollision(with: rect2, point: _00.b)
        let _13 = checkPointCollision(with: rect2, point: _00.c)
        let _14 = checkPointCollision(with: rect2, point: _00.d)
        
        let _21 = checkPointCollision(with: _00, point: rect2.a)
        let _22 = checkPointCollision(with: _00, point: rect2.b)
        let _23 = checkPointCollision(with: _00, point: rect2.c)
        let _24 = checkPointCollision(with: _00, point: rect2.d)
        
        return _11 + _12 + _13 + _14 + _21 + _22 + _23 + _24
    }
}
