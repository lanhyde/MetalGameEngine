#include <metal_stdlib>
using namespace metal;

#import "Vertex.h"
#import "Lighting.h"

fragment float4 fragment_terrain(FragmentIn in [[stage_in]], constant Params& params [[buffer(ParamsBuffer)]],
                                 constant Light* lights [[buffer(LightBuffer)]],
                                 depth2d<float> shadowTexture [[texture(ShadowTexture)]],
                                 texture2d<float> baseColor [[texture(BaseColor)]]) {
  const sampler default_sampler(filter::linear, address::repeat);
  float4 color;
  float4 grass = baseColor.sample(default_sampler, in.uv * params.tiling);
  color = grass;
  
  
  float3 normal = normalize(in.worldNormal);
  Light light = lights[0];
  float3 lightDirection = normalize(light.position);
  float diffuseIntensity = saturate(dot(lightDirection, normal));
  float maxIntensity = 1;
  float minInstensity = 0.2;
  diffuseIntensity = diffuseIntensity * (maxIntensity - minInstensity) + minInstensity;
  color *= diffuseIntensity;
  color *= calculateShadow(in.shadowPosition, shadowTexture);
  
  return color;
}

