备注：
1、Read时的数据已经改正了
2、Read时如果发现丢包，不用发break，可以直接发新的cmdread
3、下面各项结构体中的数据可以先用来测试，下周我再继续补充
4、write方式，dev通过IFM_CMD_DATA接收数据成功后，如果retcode为TRANS_OK，则快闪2下，闪3次，**  **  **
												 如果retcode有错误，则快闪3下，闪3次， ***  ***  ***

需要测试的部分：
1、1M数据,Read中途，假设丢包，发cmdread从丢包处继续传输


数据结构：
DEVICE_OBJECTID_SETUP
typedef	struct	BleSetupItem{
	xU32		software;					//0x11111111
	xU32		hardware;					//0x22222222
	xU32		loaderVersion;				//0x55555555
	xU32		baseloader;					//0xaaaaaaaa
}BleSetupItem;

DEVICE_OBJECTID_PLAN
typedef	struct	BlePlanItem{
	xU32		timeTarget;					//0x33333333
	xU32		distanceTarget;				//0x99999999
	xU8			data[0x20];					//全0
}BlePlanItem;

DEVICE_OBJECTID_PLAYLIST
typedef	struct	BleListItem{
	xU32		fileNum;					//0x12345
	xU8			data[0x20];					//每个字节都为1 (0x01,0x01,0x01,0x01,0x01,0x01......)
}BleListItem;

DEVICE_OBJECTID_FIRMWARE
DEVICE_OBJECTID_EPH
DEVICE_OBJECTID_BLEFW
传输指定长度的数据，没有数据结构，类似1m测试



当前已经实现的部分
Host --> Dev
DEVICE_OBJECTID_SETUP
DEVICE_OBJECTID_PLAYLIST
DEVICE_OBJECTID_FIRMWARE
DEVICE_OBJECTID_EPH
DEVICE_OBJECTID_BLEFW
DEVICE_OBJECTID_CONTROL
DEVICE_OBJECTID_PLAN

Dev  --> Host
DEVICE_OBJECTID_SETUP
DEVICE_OBJECTID_PLAYLIST
DEVICE_OBJECTID_STATICS



#define DEVICE_OBJECTID_SETUP 0x1	 /* 系统设置 */
#define DEVICE_OBJECTID_STATICS 0x2	 /* 运动信息 */
#define DEVICE_OBJECTID_FIRMWARE 0x3 /* 固件 */
#define DEVICE_OBJECTID_EPH 0x4		 /* 星历 */
#define DEVICE_OBJECTID_PLAYLIST 0x5 /* 播放列表 */
#define DEVICE_OBJECTID_BLEFW 0x6	 /* BLE固件 */
#define DEVICE_OBJECTID_CONTROL 0x7	  /* 实时控制 */
#define DEVICE_OBJECTID_DEBUG 0x8	  /* 调试 */
#define DEVICE_OBJECTID_AUTHORIZE 0x9 /* 授权 */
#define	DEVICE_OBJECTID_PLAN 0xa	 /*运动计划*/
#define DEVICE_OBJECTID_NULL 0x1000	 /* 空端口 */


E21BF5CD-2E97-6A68-1C3E-66DEF71AC5F8

