#!/usr/bin/env python3
"""Send 1, 2 or 3 XYZ helices using the existing VOFA+ data protocols.

UDP needs only Python's standard library. Serial additionally needs pyserial.
Coordinates are quantized to finite IEEE-754 float32 for both protocols.
"""

import argparse
import math
import socket
import struct
import sys
import time


JUSTFLOAT_TAIL = b"\x00\x00\x80\x7f"


def float32_channels(values):
    """Reject invalid coordinates instead of transmitting NaN/Inf or overflow."""
    values = tuple(float(value) for value in values)
    if len(values) not in (3, 6, 9):
        raise ValueError("expected 3, 6 or 9 channels (one XYZ group per curve)")
    if not all(math.isfinite(value) for value in values):
        raise ValueError("XYZ must contain only finite numbers")
    try:
        packed = struct.pack("<" + "f" * len(values), *values)
    except (OverflowError, struct.error) as exc:
        raise ValueError("XYZ is outside the finite float32 range") from exc
    rounded = struct.unpack("<" + "f" * len(values), packed)
    if not all(math.isfinite(value) for value in rounded):
        raise ValueError("XYZ is outside the finite float32 range")
    return rounded


def float32_coordinates(x, y, z):
    """Compatibility helper for a single XYZ triple."""
    return float32_channels((x, y, z))


def encode_channels(protocol, values):
    """Encode all curves in one original-protocol frame, in XYZ group order."""
    values = float32_channels(values)
    if protocol == "justfloat":
        # No frame header, length, sequence number or checksum is added.
        return struct.pack("<" + "f" * len(values), *values) + JUSTFLOAT_TAIL
    if protocol == "firewater":
        return ("curve:" + ",".join("{:.9g}".format(value) for value in values) + "\n").encode("ascii")
    raise ValueError("unknown protocol: " + str(protocol))


def encode_frame(protocol, x, y, z):
    """Backward-compatible encoder for one trajectory."""
    return encode_channels(protocol, (x, y, z))


def helix(elapsed, radius, pitch, period):
    """pitch is the Z increment per complete turn; period is seconds per turn."""
    turns = elapsed / period
    angle = 2.0 * math.pi * (turns % 1.0)
    return radius * math.cos(angle), radius * math.sin(angle), pitch * turns


def helix_channels(elapsed, radius, pitch, period, curves):
    """One fixed frame: X1,Y1,Z1[,X2,Y2,Z2[,X3,Y3,Z3]].

    The first helix matches the original demo. Smaller radii, phase and Z
    offsets make the extra curves easy to distinguish in a shared view.
    """
    if curves not in (1, 2, 3):
        raise ValueError("curves must be 1, 2 or 3")
    values = list(helix(elapsed, radius, pitch, period))
    turns = elapsed / period
    angle = 2.0 * math.pi * (turns % 1.0)
    for index in range(1, curves):
        scale = 1.0 - 0.25 * index
        phase = angle + index * math.pi / 2.0
        z_offset = radius * (0.2 if index == 1 else -0.2)
        values.extend((radius * scale * math.cos(phase),
                       radius * scale * math.sin(phase),
                       pitch * turns + z_offset))
    return tuple(values)


def finite_number(text):
    value = float(text)
    if not math.isfinite(value):
        raise argparse.ArgumentTypeError("must be a finite number")
    return value


def parse_arguments(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--protocol", choices=("justfloat", "firewater"), default="justfloat")
    parser.add_argument("--curves", type=int, choices=(1, 2, 3), default=1,
                        help="number of XYZ groups sent together per frame")
    parser.add_argument("--host", default="127.0.0.1", help="VOFA+ IPv4 address (UDP only)")
    parser.add_argument("--port", type=int, default=1347, help="VOFA+ local UDP port")
    parser.add_argument("--rate", type=finite_number, default=20.0, help="frames per second, 0 < rate <= 1000")
    parser.add_argument("--duration", type=finite_number, default=0.0, help="seconds; 0 runs until Ctrl+C")
    parser.add_argument("--radius", type=finite_number, default=100.0, help="helix radius, >= 0")
    parser.add_argument("--pitch", type=finite_number, default=40.0, help="Z increment per complete turn")
    parser.add_argument("--period", type=finite_number, default=8.0, help="seconds per complete turn, > 0")
    parser.add_argument("--serial", dest="serial_port", help="serial port, e.g. COM3; overrides UDP")
    parser.add_argument("--baud", type=int, default=115200, help="serial baud rate")
    parser.add_argument("--dry-run", action="store_true", help="print three frames without opening any connection")
    args = parser.parse_args(argv)
    if not 0.0 < args.rate <= 1000.0:
        parser.error("--rate must be greater than 0 and no greater than 1000")
    if args.duration < 0.0:
        parser.error("--duration must be 0 or positive")
    if args.radius < 0.0:
        parser.error("--radius must be 0 or positive")
    if args.period <= 0.0:
        parser.error("--period must be positive")
    if not 1 <= args.port <= 65535:
        parser.error("--port must be between 1 and 65535")
    if args.baud <= 0:
        parser.error("--baud must be positive")
    try:
        float32_coordinates(args.radius, 0.0, args.pitch)
        if args.duration:
            float32_coordinates(0.0, 0.0, args.pitch * args.duration / args.period)
            # Include the added helices' Z offset in the finite-range check.
            if args.curves > 1:
                float32_coordinates(0.0, 0.0,
                                    abs(args.pitch * args.duration / args.period) + 0.2 * args.radius)
    except ValueError as exc:
        parser.error(str(exc))
    return args


def run(args):
    if args.dry_run:
        for index in range(3):
            elapsed = index / args.rate
            values = float32_channels(helix_channels(elapsed, args.radius, args.pitch, args.period, args.curves))
            frame = encode_channels(args.protocol, values)
            print("t={:.6f}s curves={} channels={} bytes={}".format(elapsed, args.curves, values, len(frame)))
            if args.protocol == "firewater":
                print("text=" + repr(frame.decode("ascii")))
            print("hex=" + frame.hex(" "))
        return 0

    transport = None
    try:
        if args.serial_port:
            try:
                import serial as pyserial
            except ImportError:
                print("Serial requires pyserial. Install it with: python -m pip install pyserial", file=sys.stderr)
                return 1
            transport = pyserial.Serial(args.serial_port, args.baud, write_timeout=1)

            def send(frame):
                if transport.write(frame) != len(frame):
                    raise OSError("serial write did not send a complete frame")

            destination = "{} @ {}".format(args.serial_port, args.baud)
        else:
            transport = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            address = (args.host, args.port)

            def send(frame):
                if transport.sendto(frame, address) != len(frame):
                    raise OSError("UDP send did not send a complete frame")

            destination = "udp://{}:{}".format(*address)

        print("Sending {} ({} curves / {} channels) at {} Hz to {}. Ctrl+C stops.".format(
            args.protocol, args.curves, args.curves * 3, args.rate, destination), flush=True)
        started = time.monotonic()
        next_tick = started
        interval = 1.0 / args.rate
        sent = 0
        while True:
            now = time.monotonic()
            elapsed = now - started
            if args.duration and elapsed >= args.duration:
                break
            if now < next_tick:
                # Keep the duration deadline even when duration < one interval.
                wait = next_tick - now
                if args.duration:
                    wait = min(wait, args.duration - elapsed)
                time.sleep(wait)
                continue
            send(encode_channels(args.protocol, helix_channels(
                elapsed, args.radius, args.pitch, args.period, args.curves)))
            sent += 1
            next_tick += interval
            # Skip overdue ticks; never send a burst to catch up after a stall.
            after_send = time.monotonic()
            if next_tick < after_send:
                next_tick = after_send + interval
        print("Sent {} frames.".format(sent))
        return 0
    finally:
        if transport is not None:
            transport.close()


def main(argv=None):
    args = parse_arguments(argv)
    try:
        return run(args)
    except KeyboardInterrupt:
        print("\nStopped.")
        return 0
    except (OSError, ValueError) as exc:
        print("Send failed: {}".format(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
