import numpy as np

# =========================================================
# INT8 Quantization Utilities (Power-of-Two Scaling)
# =========================================================

def quantize_int8(weights, scale):
    """
    INT32 -> INT8 quantization with rounding and saturation
    """
    q = np.round(weights / scale)
    q = np.clip(q, -128, 127)
    return q.astype(np.int8)


def dequantize_int32(weights_q, scale):
    """
    INT8 -> INT32 fixed-point expansion
    """
    return (weights_q.astype(np.int32) * scale).astype(np.int32)


# =========================================================
# Golden Systolic Matrix Multiplication Model
# (Matches RTL datapath)
# =========================================================

def golden_systolic_model(A, B, scale):
    """
    A : INT32 activation matrix (NxN)
    B : INT32 weight matrix (NxN)
    scale : layer scale (1, 2, 4, 8, 16)

    Returns:
      C_ref   : Full-precision reference (INT64)
      C_quant : Quantized systolic result (INT64)
      error   : Difference (INT64)
    """

    # Reference full-precision computation
    C_ref = A.astype(np.int64) @ B.astype(np.int64)

    # Quantized path (matches hardware)
    B_q   = quantize_int8(B, scale)        # INT8 storage
    B_dq  = dequantize_int32(B_q, scale)   # INT32 compute

    C_quant = np.zeros_like(C_ref, dtype=np.int64)

    for i in range(A.shape[0]):
        for j in range(B.shape[1]):
            acc = np.int64(0)
            for k in range(A.shape[1]):
                acc += np.int64(A[i, k]) * np.int64(B_dq[k, j])
            C_quant[i, j] = acc

    error = C_ref - C_quant
    return C_ref, C_quant, error


# =========================================================
# Functional Test (4×4 Example Used in RTL)
# =========================================================

A = np.array([
    [ 1,  2,  3,  4],
    [ 5,  6,  7,  8],
    [ 9, 10, 11, 12],
    [13, 14, 15, 16]
], dtype=np.int32)

B = np.array([
    [ 1,  2,  3,  4],
    [ 5,  6,  7,  8],
    [ 9, 10, 11, 12],
    [13, 14, 15, 16]
], dtype=np.int32)


# =========================================================
# Run Tests for Multiple Layer Scales
# =========================================================

scales = [1, 2, 4, 8, 16]

for scale in scales:
    C_ref, C_quant, error = golden_systolic_model(A, B, scale)

    print("\n==============================================")
    print(f"Layer Scale = {scale}")
    print("Reference Output (INT64):")
    print(C_ref)
    print("\nQuantized Systolic Output:")
    print(C_quant)
    print("\nError (Reference - Quantized):")
    print(error)
    print("Max Absolute Error:", np.max(np.abs(error)))
