#include <metal_stdlib>
using namespace metal;
#import "Common.h"
#import "Lighting.h"
#import "Vertex.h"

vertex VertexOut vertex_main(const VertexIn in [[stage_in]], constant Uniforms& uniforms [[buffer(UniformsBuffer)]]) {
  float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
  VertexOut out {
    .position = position,
    .uv = in.uv,
    .color = in.color,
    .worldPosition = (uniforms.modelMatrix * in.position).xyz,
    .worldNormal = uniforms.normalMatrix * in.normal,
    .worldTangent = uniforms.normalMatrix * in.tangent,
    .worldBitangent = uniforms.normalMatrix * in.bitangent,
    .shadowPosition = uniforms.shadowProjectionMatrix * uniforms.shadowViewMatrix * uniforms.modelMatrix * in.position
  };
  
  out.clip_distance[0] = dot(uniforms.modelMatrix * in.position, uniforms.clipPlane);
  return out;
}
