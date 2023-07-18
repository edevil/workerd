// Copyright (c) 2017-2022 Cloudflare, Inc.
// Licensed under the Apache 2.0 license found in the LICENSE file or at:
//     https://opensource.org/licenses/Apache-2.0

#include "gpu.h"
#include <dawn/dawn_proc.h>

namespace workerd::api::gpu {

void initialize() {
  // Dawn native initialization. Dawn proc allows us to point the webgpu methods
  // to different implementations such as native, wire, or our custom
  // implementation. For now we will use the native version but in the future we
  // can make use of the wire version if we separate the GPU process or a custom
  // version as a stub in tests.
  dawnProcSetProcs(&dawn::native::GetProcs());
}

GPU::GPU() { instance_.DiscoverDefaultAdapters(); }

// TODO(soon): support options parameter
jsg::Promise<kj::Maybe<jsg::Ref<GPUAdapter>>>
GPU::requestAdapter(jsg::Lock &js) {

#if defined(_WIN32)
  constexpr auto defaultBackendType = wgpu::BackendType::D3D12;
#elif defined(__linux__)
  constexpr auto defaultBackendType = wgpu::BackendType::Vulkan;
#elif defined(__APPLE__)
  constexpr auto defaultBackendType = wgpu::BackendType::Metal;
#else
  KJ_FAIL_REQUIRE("Unsupported platform");
#endif

  auto adapters = instance_.GetAdapters();
  if (adapters.empty()) {
    return NULL;
  }

  kj::Maybe<dawn::native::Adapter> adapter = nullptr;
  for (auto &a : adapters) {
    wgpu::AdapterProperties props;
    a.GetProperties(&props);
    if (props.backendType != defaultBackendType) {
      continue;
    }

    adapter = a;
    break;
  }

  KJ_IF_MAYBE (a, adapter) {
    kj::Maybe<jsg::Ref<GPUAdapter>> gpuAdapter = jsg::alloc<GPUAdapter>(*a);
    return js.resolvedPromise(kj::mv(gpuAdapter));
  }

  // We did not find an adapter that matched what we wanted
  return NULL;
}

} // namespace workerd::api::gpu
