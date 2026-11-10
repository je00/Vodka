#include "curve_sender.h"

#include <float.h>
#include <limits.h>
#include <math.h>
#include <string.h>

#if CHAR_BIT != 8 || FLT_RADIX != 2 || FLT_MANT_DIG != 24 || FLT_MAX_EXP != 128
#error "curve_sender requires 8-bit bytes and IEEE-754 binary32 float"
#endif

/* C99 compile-time checks; no dependency on C11 _Static_assert. */
typedef char curve_float_must_be_4_bytes[(sizeof(float) == 4) ? 1 : -1];
typedef char curve_uint_must_be_4_bytes[(sizeof(uint32_t) == 4) ? 1 : -1];

static void write_float_le(uint8_t *output, float value)
{
    uint32_t bits;
    /* memcpy avoids pointer aliasing and alignment violations. */
    memcpy(&bits, &value, sizeof(bits));
    output[0] = (uint8_t)(bits & 0xffu);
    output[1] = (uint8_t)((bits >> 8) & 0xffu);
    output[2] = (uint8_t)((bits >> 16) & 0xffu);
    output[3] = (uint8_t)((bits >> 24) & 0xffu);
}

size_t curve_encode_justfloat_channels(uint8_t *output, size_t capacity,
                                      const float *values, size_t channel_count)
{
    size_t index;
    size_t payload_size;
    if (output == NULL || values == NULL ||
        (channel_count != 3u && channel_count != 6u && channel_count != 9u)) {
        return 0;
    }
    payload_size = channel_count * 4u;
    if (capacity < payload_size + 4u) {
        return 0;
    }
    for (index = 0; index < channel_count; ++index) {
        if (!isfinite(values[index])) {
            return 0;
        }
    }
    for (index = 0; index < channel_count; ++index) {
        write_float_le(output + index * 4u, values[index]);
    }
    output[payload_size] = 0x00u;
    output[payload_size + 1u] = 0x00u;
    output[payload_size + 2u] = 0x80u;
    output[payload_size + 3u] = 0x7fu;
    return payload_size + 4u;
}

size_t curve_encode_justfloat(uint8_t *output, size_t capacity,
                             float x, float y, float z)
{
    const float values[3] = {x, y, z};
    return curve_encode_justfloat_channels(output, capacity, values, 3u);
}

int curve_send_justfloat_channels(const float *values, size_t channel_count,
                                 curve_send_callback send, void *user)
{
    uint8_t frame[CURVE_JUSTFLOAT_MAX_FRAME_SIZE];
    size_t length;
    if (send == NULL) {
        return 0;
    }
    length = curve_encode_justfloat_channels(frame, sizeof(frame), values, channel_count);
    if (length == 0) {
        return 0;
    }
    return send(frame, length, user) ? 1 : 0;
}

int curve_send_justfloat(float x, float y, float z,
                        curve_send_callback send, void *user)
{
    const float values[3] = {x, y, z};
    return curve_send_justfloat_channels(values, 3u, send, user);
}
