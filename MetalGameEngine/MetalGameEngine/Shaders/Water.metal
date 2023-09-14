#include <metal_stdlib>
using namespace metal;

#import "Common.h"

struct VertexIn {
  float4 position [[attribute(Position)]];
  float2 uv [[attribute(UV)]];
};

struct VertexOut {
  float4 position [[position]];
  float4 worldPosition;
  float2 uv;
};

vertex VertexOut vertex_water(const VertexIn in [[stage_in]], constant Uniforms& uniforms [[buffer(UniformsBuffer)]]) {
  float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.viewMatrix;
  VertexOut out {
    .position = mvp * in.position,
    .worldPosition = uniforms.modelMatrix * in.position,
    .uv = in.uv
  };
  return out;
}

fragment float4 fragment_water(VertexOut in [[stage_in]], constant Params& params [[buffer(ParamsBuffer)]]) {
  float3 color = 0.5;
  return float4(color, 1.0);
}

