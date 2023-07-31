// Copyright (c) 2017-2022 Cloudflare, Inc.
// Licensed under the Apache 2.0 license found in the LICENSE file or at:
//     https://opensource.org/licenses/Apache-2.0

#pragma once

#include "workerd/api/gpu/gpu-command-buffer.h"
#include <webgpu/webgpu_cpp.h>
#include <workerd/jsg/jsg.h>

namespace workerd::api::gpu {

class GPUQueue : public jsg::Object {
public:
  // Implicit cast operator to Dawn GPU object
  inline operator const wgpu::Queue &() const { return queue_; }
  explicit GPUQueue(wgpu::Queue q) : queue_(kj::mv(q)){};
  JSG_RESOURCE_TYPE(GPUQueue) { JSG_METHOD(submit); }

private:
  wgpu::Queue queue_;
  void submit(kj::Array<jsg::Ref<GPUCommandBuffer>> commandBuffers);
};

} // namespace workerd::api::gpu
