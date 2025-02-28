#include "cuda_utils.cuh"
#include<stdint.h>

#define CAST_OP(SRC_TYPENAME, DST_TYPENAME, FN_NAME) \
extern "C" __global__ void FN_NAME( \
    const size_t numel, \
    const size_t num_dims, \
    const size_t *info, \
    const SRC_TYPENAME *inp, \
    DST_TYPENAME *out \
) { \
    const size_t *dims = info; \
    const size_t *strides = info + num_dims; \
    if (is_contiguous(num_dims, dims, strides)) { \
        for (unsigned int i = blockIdx.x * blockDim.x + threadIdx.x; i < numel; i += blockDim.x * gridDim.x) { \
            out[i] = inp[i]; \
        } \
    } \
    else { \
        for (unsigned int i = blockIdx.x * blockDim.x + threadIdx.x; i < numel; i += blockDim.x * gridDim.x) { \
            unsigned strided_i = get_strided_index(i, num_dims, dims, strides); \
            out[i] = inp[strided_i]; \
        } \
    } \
} \

#define CAST_BF_OP(SRC_TYPENAME, DST_TYPENAME, FN_NAME) \
extern "C" __global__ void FN_NAME( \
    const size_t numel, \
    const size_t num_dims, \
    const size_t *info, \
    const SRC_TYPENAME *inp, \
    DST_TYPENAME *out \
) { \
    const size_t *dims = info; \
    const size_t *strides = info + num_dims; \
    if (is_contiguous(num_dims, dims, strides)) { \
        for (unsigned int i = blockIdx.x * blockDim.x + threadIdx.x; i < numel; i += blockDim.x * gridDim.x) { \
            out[i] = (DST_TYPENAME) (float) inp[i]; \
        } \
    } \
    else { \
        for (unsigned int i = blockIdx.x * blockDim.x + threadIdx.x; i < numel; i += blockDim.x * gridDim.x) { \
            unsigned strided_i = get_strided_index(i, num_dims, dims, strides); \
            out[i] = (DST_TYPENAME) (float) inp[strided_i]; \
        } \
    } \
} \

#if __CUDA_ARCH__ >= 800
CAST_OP(__nv_bfloat16, __nv_bfloat16, cast_bf16_bf16)

// CAST_OP(__nv_bfloat16, uint8_t, cast_bf16_u8)
CAST_OP(__nv_bfloat16, uint32_t, cast_bf16_u32)
CAST_OP(__nv_bfloat16, float,    cast_bf16_f32)
CAST_OP(__nv_bfloat16, double,   cast_bf16_f64)
CAST_OP(uint8_t, __nv_bfloat16, cast_u8_bf16)
CAST_OP(uint32_t, __nv_bfloat16, cast_u32_bf16)
CAST_OP(float,    __nv_bfloat16, cast_f32_bf16)
CAST_OP(double,   __nv_bfloat16, cast_f64_bf16)
CAST_BF_OP(__nv_bfloat16, __half,   cast_bf16_f16)
CAST_BF_OP(__half,   __nv_bfloat16, cast_f16_bf16)
#endif

#if __CUDA_ARCH__ >= 530
CAST_OP(__half, __half, cast_f16_f16)

// CAST_OP(__half, uint8_t,  cast_f16_u8 )
CAST_OP(__half, uint32_t, cast_f16_u32)
CAST_OP(__half, float,    cast_f16_f32)
CAST_OP(__half, double,   cast_f16_f64)
CAST_OP(uint8_t,  __half, cast_u8_f16 )
CAST_OP(uint32_t, __half, cast_u32_f16)
CAST_OP(float,    __half, cast_f32_f16)
CAST_OP(double,   __half, cast_f64_f16)
#endif

CAST_OP(uint32_t, uint32_t, cast_u32_u32)
CAST_OP(uint32_t, uint8_t,  cast_u32_u8 )
CAST_OP(uint32_t, int64_t,  cast_u32_i64 )
CAST_OP(uint32_t, float,    cast_u32_f32)
CAST_OP(uint32_t, double,   cast_u32_f64)

CAST_OP(uint8_t, uint32_t, cast_u8_u32)
CAST_OP(uint8_t, uint8_t,  cast_u8_u8 )
CAST_OP(uint8_t, int64_t,  cast_u8_i64 )
CAST_OP(uint8_t, float,    cast_u8_f32)
CAST_OP(uint8_t, double,   cast_u8_f64)

CAST_OP(int64_t, uint32_t, cast_i64_u32)
CAST_OP(int64_t, uint8_t,  cast_i64_u8 )
CAST_OP(int64_t, int64_t,  cast_i64_i64 )
CAST_OP(int64_t, float,    cast_i64_f32)
CAST_OP(int64_t, double,   cast_i64_f64)

CAST_OP(float, uint8_t,  cast_f32_u8 )
CAST_OP(float, uint32_t, cast_f32_u32)
CAST_OP(float, int64_t,  cast_f32_i64 )
CAST_OP(float, float,    cast_f32_f32)
CAST_OP(float, double,   cast_f32_f64)

CAST_OP(double, uint8_t,  cast_f64_u8 )
CAST_OP(double, uint32_t, cast_f64_u32)
CAST_OP(double, int64_t,  cast_f64_i64 )
CAST_OP(double, float,    cast_f64_f32)
CAST_OP(double, double,   cast_f64_f64)
