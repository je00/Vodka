<br/>
<br/>
<div align=center>
<img src="images/vofa.png" width=200x/>
</div>
<br/>

# 关于此仓库
* 伏特加上位机自2020年3月27将改名为VOFA+，协议和控件仓库名称不变。
* Vodka是VOFA+上位机的插件库，当前包含[3个协议](#protocal)、[5个控件](#widget)。
* **VOFA+主体尚不开源，此仓库的代码仅仅是插件代码**。
* 此仓库也存放VOFA+软件的使用issues，和使用说明书等资料。
* VOFA+上位机主体新版本也会发布在此处。

##  VOFA+是什么
* Volt（伏特）、Ohm（欧姆）、Fala（法拉)、Ampere(安培)，是4个传感器信号的常用单位，同时也是4位电子物理学的伟大前驱。
* VOFA+是一款通过直观简洁的协议将字节流翻译成多通道数据的软件，支持十六进制浮点数据，也支持CSV格式字符串流，具体协议请查看[协议介绍](#protocal)。
* VOFA+通过拖动的操作逻辑动态添加控件，并将数据绑定到控件上，以实现传感器数据的可视化，具体协议请查看[控件介绍](#widget)。                   

## <span id="protocal">协议介绍</span>

### 1. RawData
接收什么数据，就在文本区显示什么。**如果你仅仅把VOFA+当成串口助手来使用，发送的数据杂乱无章，那么必须使用RawData协议**，其他协议会因为一直穷举数据帧标志，导致过度使用CPU资源。
### 2. FireWater（烈酒协议）
本协议是CSV风格的字符串流，直观简洁，编程简单。但由于字符串解析消耗更多的运算资源（无论在上位机还是下位机），**建议仅在通道数量不多、发送频率不高的时候使用**。
1|2
:-:|:-:
特点|纯字符串，像printf一样简单
数据格式| "any:float0,float1,float2,...,floatN\n"
发送4个曲线的例子|"d0:1.386578,0.977929,-0.628913,-0.942729\n"
#### 示例代码
```
void setup() {
 Serial.begin(115200);
}
float t = 0;
void loop() {
 t += 0.1;
 Serial.print("d:%f, %f\n", sin(t), sin(2*t));
 delay(100);
}
```
### 3. JustFloat
**此协议非常适合用在通道数量多、发送频率高的时候。**
1|2
:-:|:-:
特点|小端浮点数据，纯十六进制浮点传输，节省带宽
数据格式| float f[N +1]; f[0]=data0; f[1]=data1; ... ; f[N-1]=dataN; \*((int\*)&f[N])=0x7F800000;
发送4个曲线的例子|bf 10 59 3f b1 02 95 3e 57 a6 16 be 7b 4d 7f bf 00 00 80 7f
#### 示例代码
```
float data[6];
char[4] tail = {0x00, 0x00, 0x80, 0x7f};
data[0] = DATA0;
data[1] = DATA1;
data[2] = DATA2;
data[3] = DATA3;
data[4] = DATA4;
data[5] = DATA5;
Serial.write((char *)data, 24);
Serial.write(tail, 4);
```

## ## <span id="widget">控件介绍</span>

  1. 多功能波形图（未开源）
  可切换柱状图，直方统计图、FFT，运算在上位机完成。

  2. 回弹按钮

  3. 可替换模型的3D立方

  4. 图片

  5. 状态灯  

  6. 滑动条