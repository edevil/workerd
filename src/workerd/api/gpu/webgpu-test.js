import { strictEqual, deepStrictEqual, ok } from "node:assert";

export const read_sync_stack = {
  async test(ctrl, env, ctx) {
    ok(navigator.gpu);

    const adapter = await navigator.gpu.requestAdapter();
    ok(adapter);

    const requiredFeatures = [];
    requiredFeatures.push("texture-compression-astc");
    requiredFeatures.push("depth-clip-control");
    const device = await adapter.requestDevice({
      requiredFeatures,
    });
    ok(device);

    const firstMatrix = new Float32Array([
      2 /* rows */, 4 /* columns */, 1, 2, 3, 4, 5, 6, 7, 8,
    ]);

    const gpuBufferFirstMatrix = device.createBuffer({
      mappedAtCreation: true,
      size: firstMatrix.byteLength,
      usage: GPUBufferUsage.STORAGE,
    });
    ok(gpuBufferFirstMatrix);

    const arrayBufferFirstMatrix = gpuBufferFirstMatrix.getMappedRange();
    ok(arrayBufferFirstMatrix);

    new Float32Array(arrayBufferFirstMatrix).set(firstMatrix);
    gpuBufferFirstMatrix.unmap();

    // Second Matrix
    const secondMatrix = new Float32Array([
      4 /* rows */, 2 /* columns */, 1, 2, 3, 4, 5, 6, 7, 8,
    ]);

    const gpuBufferSecondMatrix = device.createBuffer({
      mappedAtCreation: true,
      size: secondMatrix.byteLength,
      usage: GPUBufferUsage.STORAGE,
    });
    ok(gpuBufferSecondMatrix);

    const arrayBufferSecondMatrix = gpuBufferSecondMatrix.getMappedRange();
    ok(arrayBufferSecondMatrix);

    new Float32Array(arrayBufferSecondMatrix).set(secondMatrix);
    gpuBufferSecondMatrix.unmap();

    // Result Matrix
    const resultMatrixBufferSize =
      Float32Array.BYTES_PER_ELEMENT * (2 + firstMatrix[0] * secondMatrix[1]);
    const resultMatrixBuffer = device.createBuffer({
      size: resultMatrixBufferSize,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC,
    });
    ok(resultMatrixBuffer);

    // Bind group layout and bind group
    const bindGroupLayout = device.createBindGroupLayout({
      entries: [
        {
          binding: 0,
          visibility: GPUShaderStage.COMPUTE,
          buffer: {
            type: "read-only-storage",
          },
        },
        {
          binding: 1,
          visibility: GPUShaderStage.COMPUTE,
          buffer: {
            type: "read-only-storage",
          },
        },
        {
          binding: 2,
          visibility: GPUShaderStage.COMPUTE,
          buffer: {
            type: "storage",
          },
        },
      ],
    });
    ok(bindGroupLayout);

    const bindGroup = device.createBindGroup({
      layout: bindGroupLayout,
      entries: [
        {
          binding: 0,
          resource: {
            buffer: gpuBufferFirstMatrix,
          },
        },
        {
          binding: 1,
          resource: {
            buffer: gpuBufferSecondMatrix,
          },
        },
        {
          binding: 2,
          resource: {
            buffer: resultMatrixBuffer,
          },
        },
      ],
    });
    ok(bindGroup);
  },
};
