// Copyright (c) 2017-2022 Cloudflare, Inc.
// Licensed under the Apache 2.0 license found in the LICENSE file or at:
//     https://opensource.org/licenses/Apache-2.0

#pragma once

#include "gpu-adapter.h"
#include "gpu-device.h"
#include "gpu-utils.h"
#include <dawn/native/DawnNative.h>
#include <webgpu/webgpu_cpp.h>
#include <workerd/jsg/jsg.h>

// Very experimental initial webgpu support based on the Dawn library.
namespace workerd::api::gpu {
void initialize();

class GPU : public jsg::Object {
  jsg::Promise<kj::Maybe<jsg::Ref<GPUAdapter>>> requestAdapter(jsg::Lock &);
  dawn::native::Instance instance_;

public:
  explicit GPU();
  JSG_RESOURCE_TYPE(GPU) { JSG_METHOD(requestAdapter); }
};

#define EW_WEBGPU_ISOLATE_TYPES                                                \
  api::gpu::GPU, api::gpu::GPUAdapter, api::gpu::GPUDevice,                    \
      api::gpu::GPUDeviceDescriptor, api::gpu::GPUBufferDescriptor,            \
      api::gpu::GPUQueueDescriptor, api::gpu::GPUBufferUsage,                  \
      api::gpu::GPUBuffer, api::gpu::GPUShaderStage,                           \
      api::gpu::GPUBindGroupLayoutDescriptor,                                  \
      api::gpu::GPUBindGroupLayoutEntry,                                       \
      api::gpu::GPUStorageTextureBindingLayout,                                \
      api::gpu::GPUTextureBindingLayout, api::gpu::GPUSamplerBindingLayout,    \
      api::gpu::GPUBufferBindingLayout, api::gpu::GPUBindGroupLayout

}; // namespace workerd::api::gpu
