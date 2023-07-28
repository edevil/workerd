// Copyright (c) 2017-2022 Cloudflare, Inc.
// Licensed under the Apache 2.0 license found in the LICENSE file or at:
//     https://opensource.org/licenses/Apache-2.0

#include "gpu-compute-pass-encoder.h"

namespace workerd::api::gpu {

void GPUComputePassEncoder::setPipeline(jsg::Ref<GPUComputePipeline> pipeline) {
  encoder_.SetPipeline(*pipeline);
}

wgpu::ComputePassTimestampLocation
parseComputePassTimestampLocation(kj::StringPtr location) {
  if (location == "beginning") {
    return wgpu::ComputePassTimestampLocation::Beginning;
  }

  if (location == "end") {
    return wgpu::ComputePassTimestampLocation::End;
  }

  KJ_FAIL_REQUIRE("unknown compute pass timestamp location", location);
}

} // namespace workerd::api::gpu
