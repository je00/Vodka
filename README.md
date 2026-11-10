<br/>
<br/>
<div align=center>
<img src="images/vofa+.png" width=260x/>
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
* VOFA+是一款通过直观简洁的协议将字节流翻译成多通道数据的软件，支持十六进制浮点数据，也支持CSV格式字符串流，具体协议请阅读[协议引擎介绍](https://www.vofa.plus/docs/learning/dataengines/introduce)。
* VOFA+通过拖动的操作逻辑动态添加控件，并将数据绑定到控件上，以实现传感器数据的可视化，具体协议请查看[控件介绍](https://www.vofa.plus/docs/learning/widgets/introduce)。 

## 更多链接

* **[前往官网](https://www.vofa.plus)**  
* **[下载VOFA+](https://www.vofa.plus/downloads/)**  
* **[阅读使用教程](https://www.vofa.plus/docs/learning)**  

## Curve3D 三维轨迹控件

[Curve3D](widgets/curve3d/README.md) 可在同一坐标系中显示 1、2 或 3 条三维轨迹，每条独立绑定 X、Y、Z 通道，支持旋转、缩放、平移和配置恢复。通信继续使用 VOFA+ 原有协议与接口，包含 JustFloat / FireWater 数据发送示例及测试。控件读取每次宿主刷新后的最新坐标，适合实时轨迹预览。
