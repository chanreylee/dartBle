/*
   此文件是 P3K pico 的 测试 结构
*/

import 'dart:ffi';
import 'dart:typed_data';

import 'package:dhsjakd/utls/NumsType.dart';

final String PAW_PROTO_VER = "01";

final int BLE_MAX_MTU_SIZE = 20; /* 最大传输的包长度 */
final int BLE_MAX_READ_INTERVAL = 0x100; /* 最多256个数据包 */
/* 
    Player 3000 BLE 说明
    Device name : IETPAWaa
    Device Service : 2
       uuid = {0xD4,0x49,0x7C,0x61,0xDA,0x72,0x3B,0xF0,0x96,0xFE,0x17,0xE4,0x04,0xD1,0x78,0x9F}
	   Attribute : 2
	       1. uuid : {0x57,0xDA,0xC9,0xB7,0x00,0xFB,0x3A,0xBC,0xAA,0x2B,0x83,0xDD,0xE7,0x46,0x58,0x55}
		      type : notify
			  MTU  : 20 Bytes
		   2. uuid : {0xCF,0x0D,0xD6,0x65,0xE9,0xFC,0x36,0x69,0x8E,0xA3,0xAC,0xB0,0x6A,0x2C,0xD4,0x62}
		      type : Write
			  MTU  : 20 Bytes
    Protocol : 
	    Host : Phone
		Device : Player 3000
		PI : Attribute notify
		PO : Attribute Write
	    1. Device不会主动发起命令
		2. PAW_CMD_STATES任何时候都可以调用，这表明Host可以在任何状态读取Device的state信息
		3. Host和Device应当对要发送/接收的数据按照BLE_MAX_MTU_SIZE进行分包,处于一个整体的包应当用pktno进行标识
		4. Host应当通过读取States来确定当前命令的完成状态
		5. 整体流程如下:
		    Host                    Device
			                        set dicoverable
			scan
			connect
			检查设备是否Player 3000(通过mac address / service uuid/ attribute uuid 进行检查),如果不是那么断开连接
			Read devstate(发送PAW_CMD_STATES,然后监听PI)
			....
		6. 举例(以Host端代码为例) : 
		    I. 以Phone写入系统设置的操作为例(OBJECTID_SETUP , PAW_CMD_WRITE),假设系统设置的数据长度为300 bytes: 
		        1. Host --> PO (PAW_CMD_WRITE)
				    PAW_Write_CMD.btype = PAW_CMD_WRITE
					PAW_Write_CMD.bno = 0
					PAW_Write_CMD.objID = DEVICE_OBJECTID_SETUP
					PAW_Write_CMD.len = 300
					PAW_Write_CMD.ex = DATA[0:7]
				2. PI --> Host (PAW_States)
				    if PAW_States.b.pkttype == PAW_CMD_STATE and 
					    PAW_States.objID == DEVICE_OBJECTID_SETUP and 
						PAW_States.o.pkttype == PAW_CMD_WRITE
					    goto 3
					 else
					    goto 1 or Error
				3. Host --> PO 
				    PAW_Data.b.pkttype = PAW_CMD_DATA
					PAW_Data.b.pktno = 0
					PAW_Data.data = DATA[8:BLE_MAX_MTU_SIZE - 2+8]
				4. Host --> PO 
				    PAW_Data.b.pkttype = PAW_CMD_WDATA
					PAW_Data.b.pktno = 1
					PAW_Data.data = DATA[BLE_MAX_MTU_SIZE - 2 + 8:(BLE_MAX_MTU_SIZE - 2)*2 + 8]
				5. Host --> PO 
				    PAW_Data.b.pkttype = PAW_CMD_WDATA
					PAW_Data.b.pktno = 2
					PAW_Data.data = DATA[(BLE_MAX_MTU_SIZE - 2)*2 + 8:(BLE_MAX_MTU_SIZE - 2)*3 + 8]
					.....
				20. PI --> Host (PAW_States , DEVICE_STATE_WRITING)
				21. PI --> Host (PAW_States , 0)
				22. operation complete
				在整个操作过程中Device会检查PAW_Data的pktno，如果不是上一个包的bno+1,那么将回送一个PAW_States,其中的bno等于上一个包的bno,而Host将从对应包重传
				总结一下，除了Host主动发起的PAW_CMD_STATES外，Device会在以下的情况下主动发送Device States
				1) 收到任意的合法PAW_CMD(包括BREAK,STATES命令)
					如果当前命令未结束就收到了新的CMD，那么不会进行任何回复
				2) 任意的状态变迁时
					例如:
					TRANSMITTING-->WRITTING
					WRITTING --> 0
					0 --> CHARGING
				3) 如果同时有多个状态变迁，那么只回复一次
				4) 如果收到合法CMD的同时发生了状态变迁，那么只回复一次
		    II. 以Phone读出系统设置文件为例
			    1. Host --> PO
				    PAW_Read_CMD.btype = PAW_CMD_READ
					PAW_Read_CMD.bno = 0
					PAW_Read_CMD.objID = DEVICE_OBJECTID_SETUP
				2. PI --> Host (PAW_Read_CMD_Response)
				    PAW_Read_CMD_Response.bype = PAW_CMD_READ
					PAW_Read_CMD_Response.bno = 0
					PAW_Read_CMD_Response.objID = DEVICE_OBJECTID_SETUP
					PAW_Read_CMD_Response.len = 300
					PAW_Read_CMD_Response.ex = DATA[0:7]
					if not equal 
					    goto 1 or Error
					else
					    goto 3
				3. PI --> Host 
				    PAW_Data.btype = PAW_CMD_RDATA
					PAW_Data.bno = 0
					PAW_Data.data = DATA[8:BLE_MAX_MTU_SIZE - 2+8]
				4. PI --> Host 
				    PAW_Data.btype = PAW_CMD_RDATA
					PAW_Data.bno = 1
					PAW_Data.data = DATA[BLE_MAX_MTU_SIZE - 2+8:(BLE_MAX_MTU_SIZE - 2)*2+8]
				5. PI --> Host 
				    PAW_Data.btype = PAW_CMD_RDATA
					PAW_Data.bno = 2
					PAW_Data.data = DATA[(BLE_MAX_MTU_SIZE - 2)*2+8:(BLE_MAX_MTU_SIZE - 2)*3+8]
					... ...
				20. PI --> Host (PAW_States)
				7. operation complete
				Error. goto 1 or exit
*/

final int PAW_CMD_NONE = 0x0; /* 无效 */
final int PAW_CMD_READ = 0x1; /* 读取对象的内容 */
final int PAW_CMD_WRITE = 0x2; /* 写入对象的内容 */
final int PAW_CMD_DATA = 0x3; /* 数据包 */
final int PAW_CMD_BREAK = 0x4; /* 退出当前操作 / reset */
final int PAW_CMD_STATES = 0x5; /* 获取当前状态 */
final int PAW_CMD_CHECK = 0x6; /* 查询对象信息 */
/* 任意时刻PAW_CMD_STATES都可以被发出来检测设备当前的状态,当然也包括上一个命令的执行状态(不包括PAW_CMD_STATES命令) */
/* 任意时刻PAW_CMD_BREAK都可以被发出来终止当前的任意操作 */

final int DEVICE_OBJECTID_SETUP = 0x1; /* 系统设置 */
final int SETUP_OFFSET_ALL = 0x00; //ALL		BleSetupItem_Ex
final int SETUP_OFFSET_BASE = 0x01; //base		BleSetupItem

final int DEVICE_OBJECTID_FIRMWARE =
    0x3; /* 固件 */ //续传 需要将offset往前对齐到 整的4K位置	//1K
//使用 PAW_FirmWare_CMD
//check、read 可以读取 PAW_FirmWare_Ctrl 结构。

final int DEVICE_OBJECTID_EPH = 0x4; /* 星历 */
final int DEVICE_OBJECTID_PLAYLIST =
    0x5; /* 播放列表 */ //PAW_PLaylist_Header	//指app编辑过后的list，比如“我喜欢的”	dbid = 0xF0000
//参数 dbid
// 最近播放的dbid = 0xF1001 播放列表

final int DEVICE_OBJECTID_BLEFW = 0x6; /* BLE固件 */
final int DEVICE_OBJECTID_CONTROL =
    0x7; /* 实时控制 */ //offset（bit7 = 1） 表示可读，否则只写     write 需要检测 DEVICE_STATE_RT_PROCESS
final int CONTROL_OFFSET_NULL = 0x00;
final int CONTROL_OFFSET_PLAYSTATE =
    0x81; /* play control */ // 参数 data =  0停止 1播放  2暂停
final	CONTROL_OFFSET_SINGLE_LOCK	=	0x82;			//单曲锁定
final int CONTROL_OFFSET_SEEK = 0x84; /* 跳转 */ //设置及获取	data = 当前播放时间 (秒数)

final int CONTROL_OFFSET_SELECTSONG =
    0x85; /* 选择指定的歌曲 */ //data = id(4) + dbpos(2) + index(2)		PAW_PLaylist_Item
//可以直接将参数放到data中     括号内是所占字节

final int CONTROL_OFFSET_SELECTPLIST =
    0x86; /* 选择当前播放列表 */ //文件夹dbid  or 列表dbid（0xF0000 “我喜欢的” 预留一些id给列表用）
//	PAW_PLaylist_Item
// index 表示播放第index个文件，

final int CONTROL_OFFSET_VOLNUM = 0x87; /* 音量设置 及获取 */
final int CONTROL_OFFSET_ATE_PMEQSET =
    0x88; /* ATE or EQ设置 */ //  mode(ATE = 1, EQ = 2)  	data = efx_mode(1) + c_efx_pos(1);
final int CONTROL_OFFSET_SPD =
    0x89; // 80% - 200%  stride = 1%    data = spd_val(2)
final int CONTROL_OFFSET_AB_PLAY =
    0x8a; // data = ab_a_time(4) + ab_b_time(4)     0xFFFFFFFF 表示到文件尾部
//	final int CONTROL_OFFSET_FMFREQ		0x8a /* FM频率设置 */
//	final int CONTROL_OFFSET_NAME			0x8b  /*设备名*/
//		final int REG_NAME_MAXLEN	0x6	/* 注意只能修改PAW1和XXX之间的6个字符,可以是字母/数字/符号(ascii必须<0x80) */

final int CONTROL_OFFSET_WORKMODE =
    0x8c; /*工作模式*/ //传参数 data = 0 （录音）,  1 （��放���

final int CONTROL_OFFSET_PLAYMODE =
    0x8d; /*播放模式*/ //传参数 data=  0顺序 1随机  2单曲循环3 全部循环

final int CONTROL_OFFSET_RT_INFO_ALL = 0x8e; /* 获取实时信息 */ //Ble_RT_Info

final int CONTROL_OFFSET_PLAYLIST_ADDITEM =
    0x90; /* add item */ //PAW_PLaylist_Item	pad[0] = index
final int CONTROL_OFFSET_PLAYLIST_SUBITEM =
    0x91; /* subtract item */ //PAW_PLaylist_Item	pad[0] = index

final int CONTROL_OFFSET_SET_RECORD_WORKFOLDER =
    0x92; // data = id(4) + dbpos(2) + index(2)

final int DEVICE_OBJECTID_DEBUG = 0x8; /* 调试 */
final int DEVICE_OBJECTID_AUTHORIZE = 0x9; /* 授权 */
final int AUTHORIZE_OFFSET_AUTH = 0x0; /* 授权 */
final int AUTHORIZE_OFFSET_BIND = 0x1; /* 绑定 */
final int AUTHORIZE_OFFSET_UNBIND = 0x2; /* 解绑 */

final int DEVICE_OBJECTID_TOTAL_FOLDER_LIST = 0xc; /*获取所有的目录ID+dbpos列表*/ //4+2
//PAW_PLaylist_Header

final int DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER =
    0xd; /*获取目录下所有meida的ID+dbpos列表   需要传入目录ID+dbpos*/
//PAW_PLaylist_Header		PAW_Check_Read_MediaList_CMD

final int DEVICE_OBJECTID_MODIFY_LIST =
    0xe; /*获取上次同步后被修改的播放列表*/ // folder + playlist
// PAW_PLaylist_Header,
// 1、目录ID+dbpos列表需要提前获取，有顺序问题(通过DEVICE_OBJECTID_TOTAL_FOLDER_LIST命令获取)
// 2、返回新增列表、有删除或新增子项的dbid，用于同步。

final int DEVICE_OBJECTID_MEIDA_INFO =
    0xF; /*获取media信息  需要传入ID+dbpos*/ //	PAW_Check_Read_MediaList_CMD
final int MEIDA_INFO_OFFSET_ALL = 0x00; /* 所有信息*/ //	Ble_MediaInfo
final int MEIDA_INFO_OFFSET_NAME = 0x01; /* 文件名*/
final int MEIDA_INFO_OFFSET_BASE_INFO = 0x02; /* 基础信息，*/ //_Media_Info_Base

final int DEVICE_OBJECTID_FIRMWARE_CHECK_AND_UPDATA =
    0x10; /* 当DEVICE_OBJECTID_FIRMWARE发完固件之后，通过check命令，获取返回值， 0：固件检测出错，非0：成功*/
//收到 Write 命令 就开始更新固件。
//由于可能需要 秒级Check  所以单独拧出一个object， 也需要一个命令 进行固件升级

final int DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY =
    0x12; //获取目录和文件对应的key，用于判断是否有修改。
//更新完之后需要将对应的key发送过来，  本地就开始记录修改

final int DEVICE_OBJECTID_PLAYLIST_NAMELIST =
    0x14; //  需要传入PAW_PLaylist_Name_Map，    check 只需传入ID+dbpos 用于校验，会返回上一次write的map对应的文件名长度。
//PAW_PLaylist_Name_List

final DEVICE_OBJECTID_UNSUPPORT_SONG_DBID	=	0x15;	 // 不支持的歌曲
														//PAW_ID_Modify_List	

final int DEVICE_OBJECTID_BACKGROUND_FIRMWARE = 0x16;

final int DEVICE_OBJECTID_DELETE = 0x17;
// 传入  PAW_PLaylist_Item 的数组    目录是否能删 需要确认，因为没有显示层级关系，可能导致将子目录删除的情况。
// 用check命令 可获取当前删除的百分比

final int DEVICE_OBJECTID_NULL = 0x1000; /* 空端口 */

//final int DEVICE_STATE_STATICS		0x1	 /* 当前 */
final int DEVICE_STATE_TRANSMITING = 0x2; /* 数据传输过程中 */
final int DEVICE_STATE_CHARGING = 0x4; /* 充电中 */
//final int DEVICE_STATE_RUNNING		= 0x8;	 /* 运动过程中 */
final int DEVICE_STATE_WRITTING = 0x10; /* 升级过程中 */
final int DEVICE_STATE_BIND = 0x20; /* 设备已经绑定 */
final int DEVICE_STATE_AUTHORIZED = 0x40; /* 设备已经通过授权 */
final int DEVICE_STATE_USB_CONNETING = 0x80; /* usb 通信 */
final int DEVICE_STATE_LOW_POWER = 0x100; /* 低电量 */
final int DEVICE_STATE_RT_PROCESS = 0x200; /* process 需要检测 正在处理实时消息*/

/* 
   OBJECTID_NULL是一个空的端口，数据长度固定为1MBytes,
   读出会得到一个不断累加的数字(4 Bytes)组成的缓冲区
   写入的数据会被直接丢弃，pktno也会被检测
*/
final int PAW_DEV_UNIQUE_ID_LENGT = 0x10;
final int PAW_KEY_LENGTH = 0x10;

//PAW_States中bno返回ret code，表示dev检测到的错误状态
const int RET_CODE_NORMAL = 0;
const int RET_CODE_DATA_OFFSET_ERR = 1; //读或写的frameoff有错误
const int RET_CODE_DATA_LEN_ERR = 2; //读或写的len有错误
const int RET_CODE_DATA_TRANS_OK =
    3; //cmdWrite时dev通过收到的数据长度判断已经传输完毕, cmdRead时dev发送完毕
const int RET_CODE_WDATA_ERR = 4; //Dev检查出收到的数据有错误
const int RET_CODE_WDATA_PKTNO_ERR = 5; //包编号错
const int RET_CODE_NO_AUTHORIZED = 6; //未验证时，收到验证命令以外的其它命令
const int RET_CODE_IS_WRITING = 7; //处在writing状态时收到新的COMW
const int RET_CODE_PARAM_ERR = 8; //收到的参数有错误
const int RET_CODE_DISK_ERR = 9; //磁盘出现错误，生成alp文件失败
//final int	RET_CODE_DEV_ERR				9		//收到的参数有错误
//final int	RET_CODE_FIREWARE_OFFSET_ERR	0xA		//固件比对 不匹配

final int PAWPICO_FIRMWARE_MAGIC = 0x575EBA7;

class PAW_States {
  XUint8 btype; /* 帧头命令 */
  XUint8 bno; /* 上一个命令的处理结果 */
  XUint8 otype; /* last cmd */
  XUint8 ono; /* last pkt no */
  XUint16 oobjID; /* last object id(if exists) */
  XUint16 devstate; /* 当前的设备状态 */
  XUint8 battery; /* 电池电量 */
  XUint8 oppercent; /* 当前操作的完成百分比 */
  XUint8 hwver; /* 硬件版本号 */
  XUint8 fwver; /* 固件版本号 */
  XUint8 gpsver; /* GPS版本号 */
  XUint8 blever; /* ble固件版本号 */
  Uint8List pad = Uint8List(BLE_MAX_MTU_SIZE - 14);
}

class PAW_Write_CMD {
  XUint8 btype; /* PAW_CMD_WRITE */
  XUint8 bno; /* 0 */
  XUint16 objID;
  XUint32 offset;
  XUint16 len; /* object length */
  Uint8List ex = Uint8List(BLE_MAX_MTU_SIZE - 12);
}

class PAW_CheckStatic_CMD {
  XUint8 btype; /* PAW_CMD_WRITE */
  XUint8 bno; /* 0 */
  XUint16 objID;
  XUint32 offset;
  XUint32 len; /* object length */
  XUint16 mode; //total or single
  XUint16 param; //如果是single，param为第几组数据(起始为0)
  Uint8List ex = Uint8List(BLE_MAX_MTU_SIZE - 16);
}

class PAW_ReadStatic_CMD {
  XUint8 btype; /* PAW_CMD_WRITE */
  XUint8 bno; /* 0 */
  XUint16 objID;
  XUint32 offset;
  XUint32 len; /* object length */
  XUint32 param; //第几组数据(起始为0)
  Uint8List ex = Uint8List(BLE_MAX_MTU_SIZE - 16);
}

class PAW_Data {
  XUint8 btype; /* PAW_CMD_WDATA/PAW_CMD_RDATA */
  XUint8 bno; /* 0 */
  Uint8List ex = Uint8List(BLE_MAX_MTU_SIZE - 2); /* object data */
}

class PAW_FirmWare_Ctrl {
  XUint32 offset; /*last transfer offset */
  XUint32 len; /* object length */
  XUint32 magic; //
  XUint32 version; //1.1.0.7 == 0x01010007
}

//FirmWare
class PAW_FirmWare_CMD {
  XUint8 btype; /* PAW_CMD_WRITE */
  XUint8 bno; /* 0 */
  XUint16 objID; /* CONTROL*/
  XUint32 offset; /*last transfer offset */
  XUint32 len; /* object length */
  XUint32 magic;
  XUint32 version;
}

class PAW_TagHeader {
  XUint16 datatag;
  XUint16 datasize;
}

class PAW_AutoVoice_BroadCast_Ctrl {
  XUint32 switch_flag; //目前作为开关用
  XUint32 group_flag; //组的数量不限，
  XUint32 group_value; //gruop的可选参数	//如果是距离就是放大过10倍的  时间就是分钟数
  XUint32 control_num;
  Uint32List control = Uint32List(1);
}

class PAW_BleSetupItem {
  XUint32 setupItemVer; //此结构体版本，做版本兼容时会用到
  XUint32 software; //软件版本
  XUint32 hardware; //硬件版本
  XUint32 loaderVersion; //loader版本
  XUint32 baseloader; //baseloader版本
  XUint32 gpsVer;
  XUint32 bleVer;
//	xU32		voiceContent;				//语音播报内容(按位或)
//	xU32		autoVoice;					//是否打开自动语音播报(每公里自动播报，以及运动计划提示)
  Uint8List hardware_id = Uint8List(8); //唯一ID
  XUint32 tfileno;
  XUint64 diskCapacity; //磁盘容量
  XUint64 remainCapacity; //剩余容量
  Uint8List devModel = Uint8List(16); //产品型号(字符串)
  Uint8List serialNo = Uint8List(32); //设备序列号(字符串)
}

class PAW_BleSetupItem_Ex {
  PAW_BleSetupItem base;
  XUint32 t_len; //base + tag
  PAW_TagHeader hd;
}

class Media_Info_Base {
  XInt32 samplerate;
  XUint32 totaltime;
  XUint16 bpm;
  XUint8 channel;
  XUint8 bit;
  XUint32 play_count;
  XInt32 bitrate;
}

//MEIDA_INFO
class PAW_Ble_MediaInfo {
  Media_Info_Base base;
  XUint32 t_len;
  PAW_TagHeader hd;
}

class PAW_Ble_Private_Info {
  XUint32 height; //cm
  XUint32 weight; //kg
  XUint16 age; //
  XUint8 sex; //	0  男性，  1  女性
  Uint8List pad = Uint8List(1); //预留
  XUint32 t_len; //Ble_Private_Info  total_size
  PAW_TagHeader hd; //用于扩展
}

class GPS_SamplePoint {
  XInt32 lon; //经度 * 10^-7
  XInt32 lat; //纬度 * 10^-7
  XInt16 hMSL; //海平面高度cm
  XUint16 step; //当前步数
}

class PAW_PLaylist_Item {
  XUint32 dbid;
  XUint16 dbpos;
  XUint16 pad; //reserved

}

class PAW_PLaylist_Header {
  XUint32 data_crc; //av_crc	AV_CRC_32_IEEE_LE
  XUint32 list_dbid;
  XUint32 item_num;
   // PAW_PLaylist_Item item;   PAW_PLaylist_Item
}

class PAW_ID_Modify_List {
//	xU32		data_crc;		//av_crc	AV_CRC_32_IEEE_LE
  XUint32 id_num;
  Uint32List id = Uint32List(1);
}

class PAW_PLaylist_NameItem {
  XUint32 dbid;
  XUint32 name_len;
  Uint16List name_buff = Uint16List(2);
}

class PAW_PLaylist_Name_List {
  XUint32 list_dbid;
  XUint16 list_dbpos;
  XUint16 item_num; //list中总项数
  PAW_PLaylist_NameItem item; //只存储需要获取文件名的项		会4字节对齐
}

class PAW_PLaylist_Name_Map {
  XUint32 list_dbid;
  XUint16 list_dbpos;
  XUint16 item_num; //list中总项数
  Uint32List item = Uint32List(1); //index下标，如果需要穿名字，就置1，，  一个4字节就有32个位，能表示32项
}

//final int DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER	0xd	 /*获取目录下所有meida的ID+dbpos列表   需要传入目录ID+dbpos*/
class PAW_Check_Read_MediaList_CMD {
  XUint8 btype; /* PAW_CMD_WRITE */
  XUint8 bno; /* 0 */
  XUint16 objID;
  XUint32 offset;
  XUint32 len; /* object length */
  XUint32 dbid;
  XUint16 dbpos;
  Uint8List ex = Uint8List(BLE_MAX_MTU_SIZE - 18);
}

// typedef struct PAW_PlayingList_Modify{
// 	xU32	list_id;
// 	xU32	item_id;
// 	xU8		fashion;	//0 = del,  1 = add   //暂时只加到最后一项。
// 	xU8		pad[3];		//reserved
// }PAW_PlayingList_Modify;

final PLAY_ERROR_STATE_NOMAL	=				0x0;	 	//NOMAL
final PLAY_ERROR_STATE_UNSUPPORT_SONG	=	0x1;		// 有不支持的歌曲


final PAW_PLAYMODE_SEQUENCE	=	0;
final PAW_PLAYMODE_RANDOM	=	1;
final PAW_PLAYMODE_SINGLE	=	2;
final PAW_PLAYMODE_ALL = 3;

final PAW_BPM_SWITCH_ON	=	0x8000;	//&0x8000 == 0  自动 == 1  手动  

final PAW_BLE_RT_INFO_SUM = (('S'.codeUnitAt(0) << 8) | ('U'.codeUnitAt(0) << 0));

//RT_Info
class Ble_RT_Info {
  XUint8 workmode; //工作模式  0 : hifi,  1 : sport
  XUint8 playmode; //0顺序 1随机
  XUint8 playstate; //0停止 1播放  2暂停
  XUint8 single_lock; //单曲锁定
  XInt16 hp_volnum;
  XUint16 bpm; //当前设置的bpm		//&0x8000 == 0  自动，  == 1  手动   0x7FFFF
  //	xU32	song_id;			//db id		//	PAW_PLaylist_Item	item;
  PAW_PLaylist_Item song_item;
  XUint32 playing_time; //当前秒数
  XUint32 total_time; //
  XUint32 playinglist_id; //文件夹dbid  or 列表dbid（0xF0000 “我喜欢的” 预留一些id给列表用）
  XUint16 play_error_state; //
  XUint16 t_len; //RT_info  total_size
  PAW_TagHeader hd; //用于扩展
}
