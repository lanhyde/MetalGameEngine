#ifndef Common_h
#define Common_h

#import <simd/simd.h>
#import "stdbool.h"

typedef struct {
  matrix_float4x4 modelMatrix;
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
  matrix_float3x3 normalMatrix;
  matrix_float4x4 shadowProjectionMatrix;
  matrix_float4x4 shadowMatrixMatrix;
  vector_float4 clipPlane;
} Uniforms;

typedef struct {
  uint width;
  uint height;
  uint tiling;
  uint lightCount;
  vector_float3 cameraPosition;
  bool alphaBlending;
  bool transparency;
} Params;

#endif /* Common_h */
