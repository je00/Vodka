# 数据发送示例

先在 VOFA+ 选择相同的协议，配置通信接口并打开连接。默认发送 1 条轨迹；`--curves 2` 或 `--curves 3` 会在同一帧中发送两组或三组 XYZ，然后在插件中选择相应显示条数，逐条绑定通道。这里发送的是坐标，三个轴应使用相同单位。第一条螺旋线半径为 100，每圈沿 Z 增加 40，每圈用时 8 秒；第二、第三条的半径、相位和 Z 偏置不同，便于区分。

## Python UDP 演示

在此目录打开终端。UDP 只需要 Python 3，不需要安装第三方库。

```powershell
# 仅查看帧，不打开 UDP 或串口。
python demo_sender.py --dry-run

# VOFA+ 配置 UDP 本地端口 1347，并选 JustFloat。持续发送，Ctrl+C 停止。
python demo_sender.py

# 两条轨迹，每帧 6 个通道。
python demo_sender.py --curves 2

# 三条轨迹，每帧 9 个通道。插件中选择显示 3 条并分别绑定 XYZ。
python demo_sender.py --curves 3

# FireWater 协议，持续 30 秒，20 帧/秒。
python demo_sender.py --protocol firewater --duration 30

# FireWater 同样支持三条轨迹。
python demo_sender.py --protocol firewater --curves 3 --duration 30

# 发送到另一台电脑；上位机要监听相应网卡和端口。
python demo_sender.py --host 192.168.1.10 --port 1347 --duration 30

# 改变螺旋线尺寸与速度。
python demo_sender.py --radius 50 --pitch 20 --period 10 --rate 20
```

`--duration 0` 表示持续运行。`--pitch` 为每圈沿 Z 增加的量，可为负数；`--period` 为每圈秒数。演示建议保持 20 Hz，控件显示的是宿主每次刷新后的最新坐标，不保证高速发送的每一帧都会显示。所有参数说明见 `python demo_sender.py --help`。

通道顺序固定为 `X1,Y1,Z1,X2,Y2,Z2,X3,Y3,Z3`，仅省略未启用的末尾轨迹：

| 轨迹 | X | Y | Z |
| --- | --- | --- | --- |
| 1 | 第 1 通道（通常 CH0） | 第 2 通道（CH1） | 第 3 通道（CH2） |
| 2 | 第 4 通道（CH3） | 第 5 通道（CH4） | 第 6 通道（CH5） |
| 3 | 第 7 通道（CH6） | 第 8 通道（CH7） | 第 9 通道（CH8） |

主程序的通道名称以实际版本为准。请在一帧里发送所有启用轨迹的坐标，**不要交替发送三个只有 XYZ 的三通道帧**，否则它们会反复更新同一组通道，无法区分为三条轨迹。同一次运行中保持通道数量与顺序不变；从 2 条切换为 3 条演示时先停止发送，再调整命令和插件绑定。

## Python 串口演示

电脑的 COM 端口通常不能被本脚本和 VOFA+ 同时打开。可用虚拟串口对：VOFA+ 打开一端，脚本打开另一端；或使用两路交叉连接的 USB 串口（TX 接 RX，共地）。波特率应一致。

```powershell
python -m pip install pyserial
python demo_sender.py --serial COM3 --baud 115200 --protocol justfloat --duration 30
# 三条轨迹串口示例。
python demo_sender.py --serial COM3 --baud 115200 --curves 3 --duration 30
```

`--serial` 启用后不使用 UDP。`--dry-run` 无论是否指定串口都不会建立连接。

## MCU / C99

把 `curve_sender.c` 与 `curve_sender.h` 加入固件工程。`float` 必须为 32 位 IEEE-754 类型。此示例只封装 JustFloat，通信发送由你的 UART/USB/网络驱动完成。

```c
#include "curve_sender.h"

/* 这里假设 board_uart_write 阻塞发送全部数据，成功返回非零。 */
static int send_bytes(const uint8_t *data, size_t length, void *user)
{
    (void)user;
    return board_uart_write(data, length);
}

void report_xyz(float x, float y, float z)
{
    if (!curve_send_justfloat(x, y, z, send_bytes, 0)) {
        /* 处理发送失败或非法坐标。 */
    }
}

/* 三条轨迹共 9 个通道，作为一帧发送；两条时改用 6 个元素。 */
void report_three_curves(float x1, float y1, float z1,
                         float x2, float y2, float z2,
                         float x3, float y3, float z3)
{
    const float channels[9] = {x1,y1,z1, x2,y2,z2, x3,y3,z3};
    if (!curve_send_justfloat_channels(channels, 9u, send_bytes, 0)) {
        /* 处理发送失败或非法坐标。 */
    }
}
```

`board_uart_write` 是需替换的驱动占位函数。若采用 DMA、异步或非阻塞发送，请先用 `curve_encode_justfloat_channels` 编码到你自己的持久缓冲区（三条轨迹最多 40 字节），并在发送完成前保持缓冲区有效；`curve_send_justfloat` 和 `curve_send_justfloat_channels` 的回调收到的是临时栈缓冲区，不能直接保存其地址用于 DMA。原来的单条 `curve_encode_justfloat` / `curve_send_justfloat` 接口仍可使用。

JustFloat 每个通道 4 字节小端 float32，所有数据后只接一个 `00 00 80 7F` 帧尾。1、2、3 条轨迹的帧长分别是 **16、28、40 字节**，没有新增帧头、长度、序号或校验。示例的 FireWater 文本相应为 `curve:x1,y1,z1\n`、`curve:x1,y1,z1,x2,y2,z2\n` 或 `curve:x1,y1,z1,x2,y2,z2,x3,y3,z3\n`，行末是实际的换行字节 `0A`；前缀 `curve` 仅是原协议允许的普通字符串。

例如坐标 `(1, -2, 3.5)` 的 JustFloat 帧：

```text
00 00 80 3F  00 00 00 C0  00 00 60 40  00 00 80 7F
```
