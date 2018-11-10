//
//  Shaders.metal
//  Metal2DRasterTest
//
//  Created by Janis Böhm on 08.11.18.
//  Copyright © 2018 Company At The End Of The Universe. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
    float2 textureCoords;
};

struct Uniforms {
    float4x4 matrix_t;
};

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(1)]],
                          constant Uniforms &spaceUniforms [[buffer(2)]],
                          uint vid [[vertex_id]]) {
    Vertex in = vertices[vid];
    Vertex out;
    float4x4 mat = uniforms.matrix_t * spaceUniforms.matrix_t;
    out.position = mat * float4(in.position);
    out.color = in.color;
    out.textureCoords = in.textureCoords;
    return out;
}

fragment float4 fragment_func(Vertex vert [[stage_in]],
                              texture2d<float> tex2d [[texture(0)]],
                              sampler sampler2d [[sampler(0)]]) {
    float4 out = tex2d.sample(sampler2d, vert.textureCoords);
    return out;
}
