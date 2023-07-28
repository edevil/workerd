// Copyright (c) 2017-2022 Cloudflare, Inc.
// Licensed under the Apache 2.0 license found in the LICENSE file or at:
//     https://opensource.org/licenses/Apache-2.0

#pragma once

#include "gpu-compute-pipeline.h"
#include "gpu-query-set.h"
#include "gpu-utils.h"
#include <webgpu/webgpu_cpp.h>
#include <workerd/jsg/jsg.h>

namespace workerd::api::gpu {

class GPUComputePassEncoder : public jsg::Object {
public:
  explicit GPUComputePassEncoder(wgpu::ComputePassEncoder e)
      : encoder_(kj::mv(e)){};
  JSG_RESOURCE_TYPE(GPUComputePassEncoder) { JSG_METHOD(setPipeline); }

private:
  wgpu::ComputePassEncoder encoder_;
  void setPipeline(jsg::Ref<GPUComputePipeline> pipeline);
};

struct GPUComputePassTimestampWrite {
  jsg::Ref<GPUQuerySet> querySet;
  GPUSize32 queryIndex;
  kj::String location;

  JSG_STRUCT(querySet, queryIndex, location);
};

struct GPUComputePassDescriptor {
  jsg::Optional<kj::String> label;

  kj::Array<GPUComputePassTimestampWrite> timestampWrites;

  JSG_STRUCT(label, timestampWrites);
};

wgpu::ComputePassTimestampLocation
parseComputePassTimestampLocation(kj::StringPtr location);

} // namespace workerd::api::gpu
