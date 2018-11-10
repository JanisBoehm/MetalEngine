//
//  MathUtils.swift
//  Metal2DRasterTest
//
//  Created by Janis Böhm on 08.11.18.
//  Copyright © 2018 Company At The End Of The Universe. All rights reserved.
//

import Foundation
import simd



enum Facing {
    case right, left, topRight, topLeft, topUp, topDown
}

enum Result {
    case success, failure
}

enum KeyState {
    case up, down
}

struct KeyboardState {
    var keyStateA : KeyState = .up
    var keyStateB : KeyState = .up
    var keyStateC : KeyState = .up
    var keyStateD : KeyState = .up
    var keyStateE : KeyState = .up
    var keyStateF : KeyState = .up
    var keyStateG : KeyState = .up
    var keyStateH : KeyState = .up
    var keyStateI : KeyState = .up
    var keyStateJ : KeyState = .up
    var keyStateK : KeyState = .up
    var keyStateL : KeyState = .up
    var keyStateM : KeyState = .up
    var keyStateN : KeyState = .up
    var keyStateO : KeyState = .up
    var keyStateP : KeyState = .up
    var keyStateQ : KeyState = .up
    var keyStateR : KeyState = .up
    var keyStateS : KeyState = .up
    var keyStateT : KeyState = .up
    var keyStateU : KeyState = .up
    var keyStateV : KeyState = .up
    var keyStateW : KeyState = .up
    var keyStateX : KeyState = .up
    var keyStateY : KeyState = .up
    var keyStateZ : KeyState = .up
    
    var keyState0 : KeyState = .up
    var keyState1 : KeyState = .up
    var keyState2 : KeyState = .up
    var keyState3 : KeyState = .up
    var keyState4 : KeyState = .up
    var keyState5 : KeyState = .up
    var keyState6 : KeyState = .up
    var keyState7 : KeyState = .up
    var keyState8 : KeyState = .up
    var keyState9 : KeyState = .up
    
    var keyStateESC : KeyState = .up
    var keyStateSPACE : KeyState = .up
    var keyStateShift : KeyState = .up
    
}

struct Constant {
    static let defaultMatrix: matrix_float4x4 = matrix_float4x4(float4([1,0,0,0]),
                                                         float4([0,1,0,0]),
                                                         float4([0,0,1,0]),
                                                         float4([0,0,0,1]))
}

struct Rect {
    var a: vector_float4
    var b: vector_float4
    var c: vector_float4
    var d: vector_float4
    
    init(a: vector_float4, b: vector_float4, c: vector_float4, d: vector_float4) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
}

struct ConvexPolygon {
    var vertices: [vector_float4]
    
    init() {
        vertices = [vector_float4]()
    }
    
    init(a: vector_float4, b: vector_float4, c: vector_float4) {
        self.init()
        vertices.append(contentsOf: [a,b,c])
    }
    
    init(a: vector_float4, b: vector_float4, c: vector_float4, d: vector_float4) {
        self.init()
        vertices.append(contentsOf: [a,b,c,d])
    }
}

struct Vertex {
    var position: vector_float4
    var color: vector_float4
    var textureCoords: vector_float2
    
    init(pos: vector_float4, col: vector_float4, tex: vector_float2) {
        position = pos
        color = col
        textureCoords = tex
    }
}

struct Uniforms {
    var matrix: matrix_float4x4
    
    init(mat: matrix_float4x4) {
        matrix = mat
    }
}

func magnitude(vector: vector_float4) -> Float {
    return sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z + vector.w*vector.w)
    //end of func magnitude()
}

func dotProduct(a: vector_float4, b: vector_float4) -> Float {
    return Float(a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w)
    //end of func dotProduct()
}

func translationMatrix(position: float3) -> matrix_float4x4 {
    let X = vector_float4(1, 0, 0, 0)
    let Y = vector_float4(0, 1, 0, 0)
    let Z = vector_float4(0, 0, 1, 0)
    let W = vector_float4(position.x, position.y, position.z, 1)
    return matrix_float4x4(columns:(X, Y, Z, W))
    // end of func translationMatrix(position: float3) -> matrix_float4x4
}

func translationMatrix(position: float4) -> matrix_float4x4 {
    let X = vector_float4(1, 0, 0, 0)
    let Y = vector_float4(0, 1, 0, 0)
    let Z = vector_float4(0, 0, 1, 0)
    let W = vector_float4(position.x, position.y, position.z, position.w)
    return matrix_float4x4(columns:(X, Y, Z, W))
    // end of func translationMatrix(position: float3) -> matrix_float4x4
}

func scalingMatrix(scale: Float) -> matrix_float4x4 {
    let X = vector_float4(scale, 0, 0, 0)
    let Y = vector_float4(0, scale, 0, 0)
    let Z = vector_float4(0, 0, scale, 0)
    let W = vector_float4(0, 0, 0, 1)
    return matrix_float4x4(columns:(X, Y, Z, W))
    // end of func scalingMatrix(scale: Float) -> matrix_float4x4
}

func rotationMatrix(angle: Float, axis: vector_float3) -> matrix_float4x4 {
    var X = vector_float4(0, 0, 0, 0)
    X.x = axis.x * axis.x + (1 - axis.x * axis.x) * cos(angle)
    X.y = axis.x * axis.y * (1 - cos(angle)) - axis.z * sin(angle)
    X.z = axis.x * axis.z * (1 - cos(angle)) + axis.y * sin(angle)
    X.w = 0.0
    var Y = vector_float4(0, 0, 0, 0)
    Y.x = axis.x * axis.y * (1 - cos(angle)) + axis.z * sin(angle)
    Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * cos(angle)
    Y.z = axis.y * axis.z * (1 - cos(angle)) - axis.x * sin(angle)
    Y.w = 0.0
    var Z = vector_float4(0, 0, 0, 0)
    Z.x = axis.x * axis.z * (1 - cos(angle)) - axis.y * sin(angle)
    Z.y = axis.y * axis.z * (1 - cos(angle)) + axis.x * sin(angle)
    Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * cos(angle)
    Z.w = 0.0
    let W = vector_float4(0, 0, 0, 1)
    return matrix_float4x4(columns:(X, Y, Z, W))
    // end of func rotationMatrix(angle: Float, axis: vector_float3) -> matrix_float4x4
}
