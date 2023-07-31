// Copyright (c) 2017-2022 Cloudflare, Inc.
// Licensed under the Apache 2.0 license found in the LICENSE file or at:
//     https://opensource.org/licenses/Apache-2.0

#include "gpu-queue.h"

namespace workerd::api::gpu {

void GPUQueue::submit(kj::Array<jsg::Ref<GPUCommandBuffer>> commandBuffers) {
  kj::Vector<wgpu::CommandBuffer> bufs(commandBuffers.size());
  for (auto &cb : commandBuffers) {
    bufs.add(*cb);
  }

  queue_.Submit(bufs.size(), bufs.begin());
}

} // namespace workerd::api::gpu
