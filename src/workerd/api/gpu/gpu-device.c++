// Copyright (c) 2017-2022 Cloudflare, Inc.
// Licensed under the Apache 2.0 license found in the LICENSE file or at:
//     https://opensource.org/licenses/Apache-2.0

#include "gpu-device.h"
#include "gpu-bindgroup-layout.h"
#include "gpu-buffer.h"
#include "gpu-utils.h"

namespace workerd::api::gpu {

jsg::Ref<GPUBuffer> GPUDevice::createBuffer(jsg::Lock &,
                                            GPUBufferDescriptor descriptor) {
  wgpu::BufferDescriptor desc{};
  desc.label = descriptor.label.cStr();
  desc.mappedAtCreation = descriptor.mappedAtCreation;
  desc.size = descriptor.size;
  desc.usage = static_cast<wgpu::BufferUsage>(descriptor.usage);
  auto buffer = device_.CreateBuffer(&desc);
  return jsg::alloc<GPUBuffer>(kj::mv(buffer), kj::mv(desc));
}

jsg::Ref<GPUBindGroupLayout>
GPUDevice::createBindGroupLayout(GPUBindGroupLayoutDescriptor descriptor) {
  wgpu::BindGroupLayoutDescriptor desc{};

  KJ_IF_MAYBE (label, descriptor.label) {
    desc.label = label->cStr();
  }

  kj::Vector<wgpu::BindGroupLayoutEntry> layoutEntries;
  for (auto& e : descriptor.entries) {
    layoutEntries.add(parseBindGroupLayoutEntry(e));
  }
  desc.entries = layoutEntries.begin();
  desc.entryCount = layoutEntries.size();

  auto bindGroupLayout = device_.CreateBindGroupLayout(&desc);
  return jsg::alloc<GPUBindGroupLayout>(kj::mv(bindGroupLayout));
}

} // namespace workerd::api::gpu
