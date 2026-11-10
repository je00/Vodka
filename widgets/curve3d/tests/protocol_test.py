"""Original-protocol tests for 1/2/3 curves, including short UDP loopbacks."""
import contextlib
import importlib.util
import io
import math
from pathlib import Path
import socket
import struct
import subprocess
import sys
import time

sys.dont_write_bytecode = True
example = Path(__file__).resolve().parents[1] / 'examples' / 'demo_sender.py'
spec = importlib.util.spec_from_file_location('curve_demo', example)
demo = importlib.util.module_from_spec(spec)
spec.loader.exec_module(demo)

# Preserve the old one-curve API and exact wire representation.
assert demo.encode_frame('justfloat',1,-2,3.5) == bytes.fromhex('0000803f000000c0000060400000807f')
assert demo.encode_frame('firewater',1,-2,3.5) == b'curve:1,-2,3.5\n'

for protocol in ('justfloat', 'firewater'):
    for curves in (1, 2, 3):
        count = curves * 3
        values = tuple(range(1, count + 1))
        frame = demo.encode_channels(protocol, values)
        if protocol == 'justfloat':
            assert frame == struct.pack('<' + 'f' * count, *values) + demo.JUSTFLOAT_TAIL
            assert len(frame) == {1:16, 2:28, 3:40}[curves]
        else:
            assert frame == ('curve:' + ','.join(str(v) for v in values) + '\n').encode('ascii')
        # Invalid values in any of the 9 positions must be rejected.
        for index in range(count):
            for bad in (float('nan'),float('inf'),-float('inf'),1e100):
                invalid = list(values)
                invalid[index] = bad
                try:
                    demo.encode_channels(protocol, invalid)
                except ValueError:
                    pass
                else:
                    raise AssertionError((protocol, index, bad))
        for elapsed in (0, 0.5, 100):
            generated = demo.helix_channels(elapsed, 100, 40, 8, curves)
            assert len(generated) == count
            assert generated[:3] == demo.helix(elapsed, 100, 40, 8)
        if curves > 1:
            assert generated[:3] != generated[3:6]
        dry = subprocess.run([sys.executable,str(example),'--protocol',protocol,
                              '--curves',str(curves),'--dry-run','--serial','COM_DOES_NOT_EXIST'],
                             capture_output=True,text=True)
        assert dry.returncode == 0, dry.stderr
        assert dry.stdout.count('hex=') == 3
        if protocol == 'justfloat':
            assert dry.stdout.count('bytes=' + str(count * 4 + 4)) == 3

    for invalid_count in (0,1,2,4,5,7,8,10):
        try:
            demo.encode_channels(protocol, [0] * invalid_count)
        except ValueError:
            pass
        else:
            raise AssertionError((protocol, invalid_count))

for args in [('--rate','0'),('--radius','-1'),('--duration','-1'),('--period','0'),
             ('--port','65536'),('--baud','0'),('--pitch','nan'),('--curves','0'),('--curves','4')]:
    with contextlib.redirect_stderr(io.StringIO()):
        try:
            demo.parse_arguments(list(args))
        except SystemExit as exc:
            assert exc.code == 2
        else:
            raise AssertionError(args)

def decode_frame(protocol, frame, count):
    if protocol == 'justfloat':
        assert len(frame) == count * 4 + 4
        assert frame[-4:] == demo.JUSTFLOAT_TAIL
        return struct.unpack('<' + 'f' * count, frame[:-4])
    assert frame.startswith(b'curve:') and frame.endswith(b'\n')
    values = tuple(float(v) for v in frame[6:-1].split(b','))
    assert len(values) == count
    return values

results = []
for protocol in ('justfloat', 'firewater'):
    for curves in (1, 2, 3):
        with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as receiver:
            receiver.bind(('127.0.0.1',0))
            receiver.settimeout(0.1)
            child = subprocess.Popen([sys.executable,str(example),'--port',str(receiver.getsockname()[1]),
                                      '--duration','0.25','--rate','20','--protocol',protocol,
                                      '--curves',str(curves)],
                                     stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
            received = []
            deadline = time.monotonic() + 5
            try:
                while time.monotonic() < deadline:
                    try:
                        frame,_ = receiver.recvfrom(1024)
                        values = decode_frame(protocol, frame, curves * 3)
                        assert all(math.isfinite(v) for v in values)
                        received.append(values)
                    except socket.timeout:
                        if child.poll() is not None:
                            break
                stdout,stderr = child.communicate(timeout=1)
                assert child.returncode == 0, stderr
            finally:
                if child.poll() is None:
                    child.kill()
                    child.communicate()
            assert 3 <= len(received) <= 6, received
            for group in range(curves):
                z = group * 3 + 2
                assert all(received[i][z] < received[i+1][z] for i in range(len(received)-1))
            results.append('{} / {} curves: {} frames'.format(protocol,curves,len(received)))
print('Protocol vectors, all-channel validation, CLI/dry runs and UDP loopbacks passed.')
print('\n'.join(results))
