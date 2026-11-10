#ifndef VODKA_CURVE_SENDER_H
#define VODKA_CURVE_SENDER_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define CURVE_JUSTFLOAT_FRAME_SIZE 16u
#define CURVE_MAX_CHANNELS 9u
#define CURVE_JUSTFLOAT_MAX_FRAME_SIZE 40u

/* Encode 3, 6 or 9 channels in ONE existing JustFloat frame.
 * Channel order: X1,Y1,Z1,X2,Y2,Z2,X3,Y3,Z3 (omit unused groups).
 * Returns 16, 28 or 40 bytes, or 0 for invalid input/insufficient capacity.
 * No header, sequence number, channel count or CRC is inserted.
 */
size_t curve_encode_justfloat_channels(uint8_t *output, size_t capacity,
                                      const float *values, size_t channel_count);

/* Return 16 on success, 0 on invalid data, NULL output or insufficient space.
 * The output is XYZ as little-endian IEEE-754 float32, then 00 00 80 7F.
 * Requires a platform with IEEE-754 binary32 float and 32-bit uint32_t.
 */
size_t curve_encode_justfloat(uint8_t *output, size_t capacity,
                             float x, float y, float z);

/* Return nonzero only when all length bytes were consumed or copied.
 * The pointer is valid only for the duration of this call. DMA/asynchronous
 * drivers must copy it into their own persistent transmit buffer first.
 */
typedef int (*curve_send_callback)(const uint8_t *data, size_t length, void *user);

/* Same callback lifetime requirements as the single-curve helper below. */
int curve_send_justfloat_channels(const float *values, size_t channel_count,
                                 curve_send_callback send, void *user);

/* Return 1 when the callback accepts a complete frame, otherwise 0. */
int curve_send_justfloat(float x, float y, float z,
                        curve_send_callback send, void *user);

#ifdef __cplusplus
}
#endif

#endif
