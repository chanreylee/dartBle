#ifndef _BLE_ATTRIBUTE_H
#define _BLE_ATTRIBUTE_H

#include "xtypes.h"

#define	P3K_PROTO_VER	"01"

#define BLE_MAX_MTU_SIZE 20 /* 最大传输的包长度 */
#define BLE_MAX_READ_INTERVAL 0x100 /* 最多256个数据包 */
/* 
    Player 3000 BLE 说明
    Device name : IETP3Kaa
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
		2. P3K_CMD_STATES任何时候都可以调用，这表明Host可以在任何状态读取Device的state信息
		3. Host和Device应当对要发送/接收的数据按照BLE_MAX_MTU_SIZE进行分包,处于一个整体的包应当用pktno进行标识
		4. Host应当通过读取States来确定当前命令的完成状态
		5. 整体流程如下:
		    Host                    Device
			                        set dicoverable
			scan
			connect
			检查设备是否Player 3000(通过mac address / service uuid/ attribute uuid 进行检查),如果不是那么断开连接
			Read devstate(发送P3K_CMD_STATES,然后监听PI)
			....
		6. 举例(以Host端代码为例) : 
		    I. 以Phone写入系统设置的操作为例(OBJECTID_SETUP , P3K_CMD_WRITE),假设系统设置的数据长度为300 bytes: 
		        1. Host --> PO (P3K_CMD_WRITE)
				    P3K_Write_CMD.btype = P3K_CMD_WRITE
					P3K_Write_CMD.bno = 0
					P3K_Write_CMD.objID = DEVICE_OBJECTID_SETUP
					P3K_Write_CMD.len = 300
					P3K_Write_CMD.ex = DATA[0:7]
				2. PI --> Host (P3K_States)
				    if P3K_States.b.pkttype == P3K_CMD_STATE and 
					    P3K_States.objID == DEVICE_OBJECTID_SETUP and 
						P3K_States.o.pkttype == P3K_CMD_WRITE
					    goto 3
					 else
					    goto 1 or Error
				3. Host --> PO 
				    P3K_Data.b.pkttype = P3K_CMD_DATA
					P3K_Data.b.pktno = 0
					P3K_Data.data = DATA[8:BLE_MAX_MTU_SIZE - 2+8]
				4. Host --> PO 
				    P3K_Data.b.pkttype = P3K_CMD_WDATA
					P3K_Data.b.pktno = 1
					P3K_Data.data = DATA[BLE_MAX_MTU_SIZE - 2 + 8:(BLE_MAX_MTU_SIZE - 2)*2 + 8]
				5. Host --> PO 
				    P3K_Data.b.pkttype = P3K_CMD_WDATA
					P3K_Data.b.pktno = 2
					P3K_Data.data = DATA[(BLE_MAX_MTU_SIZE - 2)*2 + 8:(BLE_MAX_MTU_SIZE - 2)*3 + 8]
					.....
				20. PI --> Host (P3K_States , DEVICE_STATE_WRITING)
				21. PI --> Host (P3K_States , 0)
				22. operation complete
				在整个操作过程中Device会检查P3K_Data的pktno，如果不是上一个包的bno+1,那么将回送一个P3K_States,其中的bno等于上一个包的bno,而Host将从对应包重传
				总结一下，除了Host主动发起的P3K_CMD_STATES外，Device会在以下的情况下主动发送Device States
				1) 收到任意的合法P3K_CMD(包括BREAK,STATES命令)
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
				    P3K_Read_CMD.btype = P3K_CMD_READ
					P3K_Read_CMD.bno = 0
					P3K_Read_CMD.objID = DEVICE_OBJECTID_SETUP
				2. PI --> Host (P3K_Read_CMD_Response)
				    P3K_Read_CMD_Response.bype = P3K_CMD_READ
					P3K_Read_CMD_Response.bno = 0
					P3K_Read_CMD_Response.objID = DEVICE_OBJECTID_SETUP
					P3K_Read_CMD_Response.len = 300
					P3K_Read_CMD_Response.ex = DATA[0:7]
					if not equal 
					    goto 1 or Error
					else
					    goto 3
				3. PI --> Host 
				    P3K_Data.btype = P3K_CMD_RDATA
					P3K_Data.bno = 0
					P3K_Data.data = DATA[8:BLE_MAX_MTU_SIZE - 2+8]
				4. PI --> Host 
				    P3K_Data.btype = P3K_CMD_RDATA
					P3K_Data.bno = 1
					P3K_Data.data = DATA[BLE_MAX_MTU_SIZE - 2+8:(BLE_MAX_MTU_SIZE - 2)*2+8]
				5. PI --> Host 
				    P3K_Data.btype = P3K_CMD_RDATA
					P3K_Data.bno = 2
					P3K_Data.data = DATA[(BLE_MAX_MTU_SIZE - 2)*2+8:(BLE_MAX_MTU_SIZE - 2)*3+8]
					... ...
				20. PI --> Host (P3K_States)
				7. operation complete
				Error. goto 1 or exit
*/

#define P3K_CMD_NONE 0x0		/* 无效 */
#define P3K_CMD_READ 0x1		/* 读取对象的内容 */
#define P3K_CMD_WRITE 0x2		/* 写入对象的内容 */
#define P3K_CMD_DATA 0x3		/* 数据包 */
#define P3K_CMD_BREAK 0x4		/* 退出当前操作 / reset */
#define P3K_CMD_STATES 0x5		/* 获取当前状态 */
#define P3K_CMD_CHECK 0x6		/* 查询对象信息 */
/* 任意时刻P3K_CMD_STATES都可以被发出来检测设备当前的状态,当然也包括上一个命令的执行状态(不包括P3K_CMD_STATES命令) */
/* 任意时刻P3K_CMD_BREAK都可以被发出来终止当前的任意操作 */

#define DEVICE_OBJECTID_SETUP		0x1		/* 系统设置 */
	#define	SETUP_OFFSET_ALL						0x00		//ALL		BleSetupItem_Ex
	#define	SETUP_OFFSET_BASE						0x01		//base		BleSetupItem
	#define	SETUP_OFFSET_MODE_USED_DURATION		0x80		//Hifi模式 及 运动模式 使用时长（分钟） 2个4字节记录
	#define	SETUP_OFFSET_MAX_VOLNUM				0x81		//最大音量
	#define	SETUP_OFFSET_FN_HIFI_BROADCAST		0x82		//P3K_Fn_AutoVoice_BroadCast_Ctrl
	#define	SETUP_OFFSET_FN_SPORT_BROADCAST		0x83		//P3K_Fn_AutoVoice_BroadCast_Ctrl
	#define	SETUP_OFFSET_AUTOVOICE_BROADCAST		0x84		//P3K_Fn_AutoVoice_BroadCast_Ctrl
	

#define DEVICE_OBJECTID_STATICS		0x2		 /* 运动信息 */		//需要在非运动模式下
											//同步完成之后， app 需要给pico发一个write命令 不需要内容，pico清除对应标记

#define DEVICE_OBJECTID_FIRMWARE	0x3		/* 固件 */		//续传 需要将offset往前对齐到 整的4K位置	//1K
															//使用 P3K_FirmWare_CMD

															//check、read 可以读取 P3K_FirmWare_Ctrl结构。

#define DEVICE_OBJECTID_EPH			0x4		 /* 星历 */
#define DEVICE_OBJECTID_PLAYLIST	0x5		/* 播放列表 */	//P3k_PLaylist_Header	//指app编辑过后的list，比如“我喜欢的”	dbid = 0xF0000
											//参数 dbid

#define DEVICE_OBJECTID_BLEFW		0x6	 /* BLE固件 */
#define DEVICE_OBJECTID_CONTROL		0x7	  /* 实时控制 */   //offset（bit7 = 1） 表示可读，否则只写     write 需要检测 DEVICE_STATE_RT_PROCESS
	#define	CONTROL_OFFSET_NULL			0x00
	#define	CONTROL_OFFSET_PLAYSTATE	0x81 /* play control */	// 参数 data =  0停止 1播放  2暂停
	//#define	CONTROL_OFFSET_BATTERY_PERCENT		0x82			//当前电量
	#define	CONTROL_OFFSET_SINGLE_LOCK		0x82			//单曲锁定

//	#define	CONTROL_OFFSET_LIST_MODIFY_ITEM		0x02		// 只能操作playinglist（其他list修改只能全部传入 因为不影响播放）  
//															// P3k_PlayingList_Modify

	#define	CONTROL_OFFSET_SEEK			0x84 /* 跳转 */ //设置及获取	data = 当前播放时间 (秒数)	

	#define	CONTROL_OFFSET_SELECTSONG	0x85 /* 选择指定的歌曲 */		//data = id(4) + dbpos(2) + index(2)		P3k_PLaylist_Item
                                                                        //可以直接将参数放到data中     括号内是所占字节

	#define	CONTROL_OFFSET_SELECTPLIST	0x86 /* 选择当前播放列表 */		//文件夹dbid  or 列表dbid（0xF0000 “我喜欢的” 预留一些id给列表用）
																		//	P3k_PLaylist_Item
																		// index 表示播放第index个文件，

	#define	CONTROL_OFFSET_VOLNUM		0x87 /* 音量设置 及获取 */		
	#define	CONTROL_OFFSET_EQSET		0x88 /* EQ设置 */
	#define	CONTROL_OFFSET_BPMSET		0x89 /* BPM设置 */
	#define CONTROL_OFFSET_FMFREQ		0x8a /* FM频率设置 */
	#define CONTROL_OFFSET_NAME			0x8b  /*设备名*/
		#define REG_NAME_MAXLEN	0x6	/* 注意只能修改IETP3K和XXX之间的6个字符,可以是字母/数字/符号(ascii必须<0x80) */

	#define CONTROL_OFFSET_WORKMODE		0x8c  /*工作模式*/	//传参数 data = 0 （hifi）,  1 （sport）

	#define CONTROL_OFFSET_PLAYMODE		0x8d  /*播放模式*/	//传参数 data=  0顺序 1随机  2单曲循环 3全部播放

	#define CONTROL_OFFSET_RT_INFO_ALL	0x8e	/* 获取实时信息 */	//Ble_RT_Info
	
//	#define CONTROL_OFFSET_RT_EASE_INFO	0x8f	/* 获取简易的实时信息 */	//Ble_RT_Info_Ease

	#define CONTROL_OFFSET_PLAYLIST_ADDITEM	0x90	/* add item */			//P3k_PLaylist_Item	pad[0] = index
	#define CONTROL_OFFSET_PLAYLIST_SUBITEM	0x91	/* subtract item */		//P3k_PLaylist_Item	pad[0] = index
		
#define DEVICE_OBJECTID_DEBUG					0x8	  /* 调试 */
#define DEVICE_OBJECTID_AUTHORIZE				0x9	  /* 授权 */
	#define AUTHORIZE_OFFSET_AUTH		0x0 /* 授权 */
	#define AUTHORIZE_OFFSET_BIND		0x1 /* 绑定 */
	#define AUTHORIZE_OFFSET_UNBIND		0x2 /* 解绑 */
#define	DEVICE_OBJECTID_PLAN					0xa	 /*运动计划*/
#define DEVICE_OBJECTID_PRIVATE_INFO			0xb	 /*个人信息 身高/体重/年龄等等*/	//	Ble_Private_Info

#define DEVICE_OBJECTID_TOTAL_FOLDER_LIST		0xc	 /*获取所有的目录ID+dbpos列表*/	//4+2
													//P3k_PLaylist_Header

#define DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER	0xd	 /*获取目录下所有meida的ID+dbpos列表   需要传入目录ID+dbpos*/
													//P3k_PLaylist_Header		P3K_Check_Read_MediaList_CMD

#define DEVICE_OBJECTID_MODIFY_MEIDA_LIST		0xe	 /*获取上次同步后被修改的媒体文件ID 列表*/
													//P3k_ID_Modify_List        return len = -1 则需要同步所有。
													//同步完成之后， app 需要给pico发一个write命令 不需要内容，pico清除对应标记

#define DEVICE_OBJECTID_MEIDA_INFO				0xF	 /*获取media信息  需要传入ID+dbpos*/	//	P3K_Check_Read_MediaList_CMD
	#define MEIDA_INFO_OFFSET_ALL		0x00	/* 所有信息*/	//	Ble_MediaInfo
	#define MEIDA_INFO_OFFSET_NAME		0x01	/* 文件名*/	
	#define MEIDA_INFO_OFFSET_BASE_INFO	0x02	/* 基础信息，*/		//_Media_Info_Base
	
#define DEVICE_OBJECTID_FIRMWARE_CHECK_AND_UPDATA 	0x10	 /* 当DEVICE_OBJECTID_FIRMWARE发完固件之后，通过check命令，获取返回值， 0：固件检测出错，非0：成功*/	
															//收到 Write 命令 就开始更新固件。
															//由于可能需要 秒级Check  所以单独拧出一个object， 也需要一个命令 进行固件升级

#define DEVICE_OBJECTID_STATICS_SPORTING 			0x11	 //获取  正在运动的记录， 当然如果不在运动，则返回 0

#define DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY		0x12	 //获取目录和文件对应的key，用于判断是否有修改。
														//更新完所有的modify  ID 之后需要 将对应的key发送过来，
	

#define DEVICE_OBJECTID_NEWLY_PLAYED_MEDIA_ID		0x13	 //最近播放的歌曲id 最多50首	
														//P3k_ID_Modify_List					


#define DEVICE_OBJECTID_PLAYLIST_NAMELIST			0x14	 //  需要传入P3k_PLaylist_Name_Map，    check 只需传入ID+dbpos 用于校验，会返回上一次write的map对应的文件名长度。
														//P3k_PLaylist_Name_List

#define DEVICE_OBJECTID_UNSUPPORT_SONG_DBID		0x15	 // 不支持的歌曲
														//P3k_ID_Modify_List	

#define DEVICE_OBJECTID_BACKGROUND_FIRMWARE		0x16

														
#define DEVICE_OBJECTID_NULL 0x1000	 /* 空端口 */

#define DEVICE_STATE_STATICS		0x1	 /* 当前有存储在机器内部的运动数据 */
#define DEVICE_STATE_TRANSMITING	0x2 /* 数据传输过程中 */
#define DEVICE_STATE_CHARGING		0x4	 /* 充电中 */
#define DEVICE_STATE_RUNNING		0x8	 /* 运动过程中 */
#define DEVICE_STATE_WRITTING		0x10	 /* 升级过程中 */
#define DEVICE_STATE_BIND			0x20		 /* 设备已经绑定 */
#define DEVICE_STATE_AUTHORIZED		0x40 /* 设备已经通过授权 */
#define DEVICE_STATE_USB_CONNETING	0x80		/* usb 通信 */
#define DEVICE_STATE_LOW_POWER		0x100		/* 低电量 */
#define DEVICE_STATE_RT_PROCESS		0x200		/* process 需要检测 正在处理实时消息*/


/* 
   OBJECTID_NULL是一个空的端口，数据长度固定为1MBytes,
   读出会得到一个不断累加的数字(4 Bytes)组成的缓冲区
   写入的数据会被直接丢弃，pktno也会被检测
*/
#define P3K_DEV_UNIQUE_ID_LENGT 0x10
#define P3K_KEY_LENGTH 0x10

//P3K_States中bno返回ret code，表示dev检测到的错误状态
#define	RET_CODE_NORMAL					0
#define	RET_CODE_DATA_OFFSET_ERR		1		//读或写的frameoff有错误
#define	RET_CODE_DATA_LEN_ERR			2		//读或写的len有错误
#define	RET_CODE_DATA_TRANS_OK			3		//cmdWrite时dev通过收到的数据长度判断已经传输完毕, cmdRead时dev发送完毕
#define	RET_CODE_WDATA_ERR				4		//Dev检查出收到的数据有错误
#define	RET_CODE_WDATA_PKTNO_ERR		5		//包编号错
#define	RET_CODE_NO_AUTHORIZED			6		//未验证时，收到验证命令以外的其它命令
#define	RET_CODE_IS_WRITING				7		//处在writing状态时收到新的COMW
#define	RET_CODE_PARAM_ERR				8		//收到的参数有错误
#define	RET_CODE_DISK_ERR				9		//磁盘出现错误，生成alp文件失败
//#define	RET_CODE_DEV_ERR				9		//收到的参数有错误
//#define	RET_CODE_FIREWARE_OFFSET_ERR	0xA		//固件比对 不匹配

typedef struct P3K_States{
	xU8 btype;				/* 帧头命令 */
	xU8 bno;				/* 上一个命令的处理结果 */
	xU8 otype;				/* last cmd */
	xU8 ono;				/* last pkt no */
	xU16 oobjID;			/* last object id(if exists) */
	xU16 devstate;			/* 当前的设备状态 */
	xU8 battery;			/* 电池电量 */
	xU8 oppercent;			/* 当前操作的完成百分比 */
	xU8 hwver;				/* 硬件版本号 */
	xU8 fwver;				/* 固件版本号 */
	xU8 gpsver;				/* GPS版本号 */
	xU8 blever;				/* ble固件版本号 */
	xU8 pad[BLE_MAX_MTU_SIZE - 14];
}P3K_States;

#define	P3K_CMD_EXPARAM_SIZE		(BLE_MAX_MTU_SIZE-12)
typedef struct P3K_Write_CMD{
	xU8 btype;	/* P3K_CMD_WRITE */
	xU8 bno;	/* 0 */
	xU16 objID;
	xU32 offset;
	xU32 len;					/* object length */
	xU8 ex[P3K_CMD_EXPARAM_SIZE];
}P3K_Write_CMD;

#define P3K_Write_CMD_Response P3K_Write_CMD
#define P3K_Read_CMD_Response P3K_Write_CMD
#define P3K_Read_CMD	P3K_Write_CMD /* 如果 len=0,那么设备将只返回object信息(参数offset无效)，但是不传输数据(因为len=0),相当于以前的命令CMD_CHECK */
#define P3K_Check_CMD 	P3K_Write_CMD
#define P3K_Check_CMD_Response 	P3K_Write_CMD

//check 运动历史数据
#define	P3K_STATICS_MODE_TOTAL		1
#define	P3K_STATICS_MODE_SINGLE		2
typedef struct P3K_CheckStatic_CMD{
	xU8 btype;	/* P3K_CMD_WRITE */
	xU8 bno;	/* 0 */
	xU16 objID;
	xU32 offset;
	xU32 len;					/* object length */
	xU16 mode;	//total or single
	xU16 param;	//如果是single，param为第几组数据(起始为0)
	xU8 ex[BLE_MAX_MTU_SIZE-16];
}P3K_CheckStatic_CMD;

//读运动历史数据
typedef struct P3K_ReadStatic_CMD{
	xU8 btype;	/* P3K_CMD_WRITE */
	xU8 bno;	/* 0 */
	xU16 objID;
	xU32 offset;
	xU32 len;					/* object length */
	xU32 param;		//第几组数据(起始为0)
	xU8 ex[BLE_MAX_MTU_SIZE-16];
}P3K_ReadStatic_CMD;

#define	BLE_MAX_DATA_SIZE		(BLE_MAX_MTU_SIZE-2)
typedef struct P3K_Data{
	xU8 btype;	/* P3K_CMD_WDATA/P3K_CMD_RDATA */
	xU8 bno;	/* 0 */
	xU8 data[BLE_MAX_MTU_SIZE-2];				/* object data */
}P3K_Data;

/*
发送完Break后，会notify返回一个state，retcode如果为RET_CODE_DATA_TRANS_OK则成功，
或者为RET_CODE_IS_WRITING，说明dev正在些数据，这时不能break
*/

/* phone应当根据Phone的ID生成唯一授权码，交由P3K进行验证，如果通过则可以进行其他操作，否则  
   P3K将拒绝其他的操作
   当设备未经绑定时，授权码为0
   操作成功与否通过检查P3K_States的DEVICE_STATE_AUTHORIZED确定
*/
/*
xVOID P3K_WriteObject(xU16 objid,xU32 offset,xPU8 pdata,xU32 len);
xVOID P3K_ReadObject(xU16 objid,xU32 offset,xPU8 pdata,xU32 len);
xU32 P3K_GetObjectLength(xU16 objid);
#define P3K_ReadObject0(objid,pex) P3K_ReadObject(objid,0,pex,BLE_MAX_MTU_SIZE-12)
*/
/********************************************************************************
DEVICE_OBJECTID_CONTROL  参数部分通过cmd.ex传输

参数：devName 6字节
	#define CONTROL_OFFSET_NAME	0xE  
	
无参数
	#define	CONTROL_OFFSET_PLAY	0x01 
	#define	CONTROL_OFFSET_PAUSE	0x02 
	#define	CONTROL_OFFSET_NEXT	0x03 
	#define	CONTROL_OFFSET_PREV	0x04 
	#define	CONTROL_OFFSET_STOP	0x05 
	#define	CONTROL_OFFSET_VOLA		0x09
	#define	CONTROL_OFFSET_VOLS		0x0A 
（可以先实现以上部分）
参数：1个int	
	#define	CONTROL_OFFSET_SEEK	0x06 
	
暂时不会用到，暂时无参数，后面根据实际情况添加
	#define	CONTROL_OFFSET_SELECTSONG	0x07 
	#define	CONTROL_OFFSET_SELECTPLIST	0x08 
	#define	CONTROL_OFFSET_EQSET	0x0B 
	#define	CONTROL_OFFSET_TEMPOSET	0x0C 
	#define CONTROL_OFFSET_FMFREQ	0x0D 
********************************************************************************/

#define	PAWPICO_FIRMWARE_MAGIC	0x575EBA7

typedef struct P3K_FirmWare_Ctrl{
	xU32 offset;				/*last transfer offset */
	xU32 len;					/* object length */
	xU32 magic;					//
	xU32 version;				//1.1.0.7 == 0x01010007	
}P3K_FirmWare_Ctrl;

//FirmWare
typedef struct P3K_FirmWare_CMD{
	xU8 btype;	/* P3K_CMD_WRITE */
	xU8 bno;	/* 0 */
	xU16 objID; /* CONTROL*/
	xU32 offset;	/*last transfer offset */
	xU32 len;					/* object length */
	xU32 magic;	
	xU32 version;	
}P3K_FirmWare_CMD;

//DEVICE_OBJECTID_SETUP
#define		VOICE_CONTENT_TIME			0x1
#define		VOICE_CONTENT_DISTANCE		0x2
#define		VOICE_CONTENT_PACE			0x4
#define		VOICE_CONTENT_FREQUENCY		0x8


typedef	struct	P3K_TagHeader{
	xU16	datatag;
	xU16	datasize;
}P3K_TagHeader;


//Switch 
#define		P3K_SWITCH_STATE_NOMAL		0
#define		P3K_SWITCH_STATE_ON			0
#define		P3K_SWITCH_STATE_OFF			1

//FN 设置项 HIFI
#define	FN_BROADCAST_HIFI_GROUP_NOMAL				(0x1 << 0)
	#define	HIFI_GROUP_NOMAL_DUMP_ENERGY							(0x1 << 0)	
	//...
#define	FN_BROADCAST_HIFI_GROUP_SETUP				(FN_BROADCAST_HIFI_GROUP_NOMAL + 1)
	#define	HIFI_GROUP_SETUP_SINGLE_LOCK							(0x1 << 0)	
	//...
	
//FN 设置项 Sport
#define	FN_BROADCAST_SPORT_GROUP_NOMAL				(0x1 << 0)
	#define	SPORT_GROUP_NOMAL_DUMP_ENERGY						(0x1 << 0)	
	//...
#define	FN_BROADCAST_SPORT_GROUP_STANDARD_CONTENT	(FN_BROADCAST_SPORT_GROUP_NOMAL + 1)
	#define	SPORT_GROUP_STANDARD_CONTENT_TIME					(0x1 << 0)
	#define	SPORT_GROUP_STANDARD_CONTENT_DISTANCE				(0x1 << 1)	
	#define	SPORT_GROUP_STANDARD_CONTENT_STEP_NUMBER			(0x1 << 2)
	#define	SPORT_GROUP_STANDARD_CONTENT_STEP_FREQUENCY		(0x1 << 3)	
	#define	SPORT_GROUP_STANDARD_CONTENT_CALORIE				(0x1 << 4)	//卡路里   千卡
	//...

//AutoVoice 
#define	AUTOVOICE_BROADCAST_GROUP_DISTANCE			(0x1 << 0)
	#define	AUTOVOICE_GROUP_DISTANCE_TIME						(0x1 << 0)
	#define	AUTOVOICE_GROUP_DISTANCE_DISTANCE					(0x1 << 1)	
	#define	AUTOVOICE_GROUP_DISTANCE_STEP_NUMBER				(0x1 << 2)
	#define	AUTOVOICE_GROUP_DISTANCE_STEP_FREQUENCY				(0x1 << 3)	
	#define	AUTOVOICE_GROUP_DISTANCE_CALORIE						(0x1 << 4)	//卡路里   千卡
	//...
#define	AUTOVOICE_BROADCAST_GROUP_TIME				(AUTOVOICE_BROADCAST_GROUP_DISTANCE + 1)	
//因为目前 DISTANCE or TIME 播报内容相同，所以暂时屏蔽用统一的
//	#define	AUTOVOICE_GROUP_TIME_DISTANCE						(0x1 << 0)
//	#define	AUTOVOICE_GROUP_TIME_STEP_FREQUENCY					(0x1 << 1)	
//	#define	AUTOVOICE_GROUP_TIME_STEP_NUMBER						(0x1 << 2)	
//	#define	AUTOVOICE_GROUP_TIME_CALORIE							(0x1 << 3)	//卡路里   千卡
	//...

typedef struct P3K_Fn_AutoVoice_BroadCast_Ctrl{
	xU32	switch_flag;				//目前作为开关用
	xU32	group_flag;			//组的数量不限，
	xU32	group_value;		//gruop的可选参数	//如果是距离就是放大过10倍的  时间就是分钟数
	xU32	control_num;
	xU32	control[1];		
}P3K_Fn_AutoVoice_BroadCast_Ctrl;

#define		BLE_SETUP_VER		0x00000001
typedef	struct	BleSetupItem{
	xU32		setupItemVer;				//此结构体版本，做版本兼容时会用到
	xU32		software;					//软件版本
	xU32		hardware;					//硬件版本
	xU32		loaderVersion;				//loader版本
	xU32		baseloader;					//baseloader版本
	xU32		gpsVer;
	xU32		bleVer;
//	xU32		voiceContent;				//语音播报内容(按位或)
//	xU32		autoVoice;					//是否打开自动语音播报(每公里自动播报，以及运动计划提示)
	xU8 			hardware_id[8];			//唯一ID
	xU32		tfileno;
	xU64		diskCapacity;				//磁盘容量
	xU64		remainCapacity;				//剩余容量
	xU8			devModel[16];				//产品型号(字符串)
	xU8			serialNo[32];				//设备序列号(字符串)
}BleSetupItem;


#define	TAG_MODE_USED_DURATION			0x1		//Hifi模式 及 运动模式 使用时长（分钟） 2个4字节记录
#define	TAG_MODE_MAX_VOLNUM				0x2		//最大音量
#define	TAG_MODE_FN_HIFI_BROADCAST		0x3		//
#define	TAG_MODE_FN_SPORT_BROADCAST		0x4		//
#define	TAG_MODE_AUTOVOICE_BROADCAST	0x5		//

typedef struct BleSetupItem_Ex{
	BleSetupItem base;
	xU32	t_len;			//base + tag  
	P3K_TagHeader hd[1];
}BleSetupItem_Ex;


#define	TAG_MEDIAINFO_IDSTART		0x10
#define	TAG_MEDIAINFO_FILE_NAME		(TAG_MEDIAINFO_IDSTART + 1)		//file name
#define	TAG_MEDIAINFO_TITLE			(TAG_MEDIAINFO_IDSTART + 2)		//曲名
#define	TAG_MEDIAINFO_ARTIST		(TAG_MEDIAINFO_IDSTART + 3)		//表演者
#define	TAG_MEDIAINFO_SONGWRITER	(TAG_MEDIAINFO_IDSTART + 4)		//词作者
#define	TAG_MEDIAINFO_COMPOSER		(TAG_MEDIAINFO_IDSTART + 5)		//作曲者
#define	TAG_MEDIAINFO_ALBUM			(TAG_MEDIAINFO_IDSTART + 6)		//专辑
#define	TAG_MEDIAINFO_YEAR			(TAG_MEDIAINFO_IDSTART + 7)		//发布年份
#define	TAG_MEDIAINFO_COPYRIGHT		(TAG_MEDIAINFO_IDSTART + 8)		//版权信息
#define	TAG_MEDIAINFO_LINK			(TAG_MEDIAINFO_IDSTART + 9)		//网址信息
#define	TAG_MEDIAINFO_PUBLISHER		(TAG_MEDIAINFO_IDSTART + 10)	//发行商

// typedef struct DB_Media_Info{
// 	xS32	samplerate;
// 	xU32	totaltime;
// 	xU16	bpm;
// 	xU8		channel;
// 	xU8		bit;
// 	xU32	play_count;
// 	xS32	bitrate;
// }DB_Media_Info;

typedef struct _Media_Info_Base{
	xS32	samplerate;
	xU32	totaltime;
	xU16	bpm;
	xU8		channel;
	xU8		bit;
	xU32	play_count;
	xS32	bitrate;
}_Media_Info_Base;

//MEIDA_INFO
typedef struct Ble_MediaInfo{	
	_Media_Info_Base base;
	xU32	t_len;			
	P3K_TagHeader	hd[1];
}Ble_MediaInfo;


typedef struct Ble_Private_Info{
	xU32	height;		//cm
	xU32	weight;		//kg
	xU16	age;			//
	xU8		sex;			//	0  男性，  1  女性
	xU8		pad[1];		//预留
	xU32	t_len;				//Ble_Private_Info  total_size
	P3K_TagHeader	hd[1];		//用于扩展
}Ble_Private_Info;

/////////////////////////////////////////////////////////////
//DEVICE_OBJECTID_PLAN
/////////////////////////////////////////////////////////////
#define		OBJPLAN_TYPE_FREERUN		0	//无运动计划
#define		OBJPLAN_TYPE_MARATHON		1	//马拉松
#define		OBJPLAN_TYPE_JOGGING		2	//慢跑
#define		OBJPLAN_TYPE_RIDING			3	//骑行
#define		OBJPLAN_TYPE_WALKING		4	//散步

#define		BLE_PLAN_VER		0x00000001
typedef	struct	BlePlanItem{
	xU32		planVer;			//版本，0x00000001
	xU8			planName[60];			//计划名称
	xU16		type;				//运动类型
	xU16		bpm;				//目标bpm
	xU32		distance;			//目标距离（单位：米）
	xU32		time;				//时间（单位：秒）
	xU16		pace;				//配速（单位：秒/公里）
	//运动文件信息
	xU16		fileNo;				//选定的文件数量

//........第一个文件信息.............
//	xU32	fileIdx;	//此文件索引
//	xU32	namelen;	//此文件名长度
//	xU16	fileName[namelen];	//要8字节对齐，namelen之后补0
//......
//......
//......
//........第N个文件信息.............
//	xU32	fileIdx;	//此文件索引
//	xU16	namelen;	//此文件名长度
//	xU16	fileName[namelen];	//能否加上前一个变量namelen，保证8字节对齐，对齐的字节补0
}BlePlanItem;
//第一版运动计划，界面上先不加歌曲选择


/////////////////////////////////////////////////////////////
//DEVICE_OBJECTID_PLAYLIST
/////////////////////////////////////////////////////////////


/*///////////////////////////////////////////////////////////
DEVICE_OBJECTID_STATICS
///////////////////////////////////////////////////////////
数据结构
------------------------------------
Header（P3k_MotionDataHeader）
SamplePoint 1（GPS_SamplePoint）
...
SamplePoint n
------------------------------------
说明：
1、开始运动后不一定能马上定位，firstTime为第一次成功定位的日期时间，
	startSecond为开始运动与第一次成功定位之间的秒数
2、GPS_SamplePoint为每个采样点的数据，每隔2秒1次，通过运动起始时间+采样点个数，可以算出每个点的具体时间
3、如果lon/lat/hMSL都为0，则认为没有定位，或者定位丢失，
4、如果step为0xFFFF，则认为当前是运动暂停状态
5、当step大于GPS_STEP_MAX时会发生反转，step要继续累加

操作：
1、通过check获取当前有多少组历史数据(P3K_CheckStatic_CMD, mode:P3K_STATICS_MODE_TOTAL)，
	返回的P3K_Check_CMD_Response中len为总共多少组
2、通过check获取每组数据的长度(P3K_CheckStatic_CMD, mode:P3K_STATICS_MODE_SINGLE, param:哪组)，
	返回的P3K_Check_CMD_Response中len为该组数据长度
*////////////////////////////////////////////////////////////
//每隔2秒有一次采样
/*
#define	GPS_HMSL_MIN			0
#define	GPS_HMSL_MAX			0x1FFF	//占13位，最大0x1FFF
#define	GPS_STEP_MIN			0
#define	GPS_STEP_MAX			(0x7FFFF - 5)	//占16位，满16位最大值有特殊意义，所以减5
typedef struct GPS_SP_Sub{
	xU32	hMSL:13;		//海平面高度
	xU32	step:19;		//当前步数
}GPS_SP_Sub;
*/
#define	GPS_STEP_MIN			0
#define	GPS_STEP_MAX			(0xFFFF - 5)	//最大值有特殊意义，所以减5
#define	GPS_STEP_PAUSE			0xFFFF
typedef struct GPS_SamplePoint{
	xS32		lon;		//经度 * 10^-7
	xS32		lat;		//纬度 * 10^-7
	xS16		hMSL;		//海平面高度cm
	xU16		step;		//当前步数
}GPS_SamplePoint;


//目前运动记录后最大可能多出200字节的步频列表
#define MOTIONDATA_ADD_LENGTH		(200)

typedef struct P3k_MotionDataHeader{
	xU32	version;		//运动数据版本
	BlePlanItem		plan;	//当前运动计划
	xU32	sport_distance;	//运动距离
	xU32	first_time;		//第一次定位成功的格林威治时间(定位成功后才能获取到时间)(此值为打过包的日期与时间，解包函数我单独给你)
	xU32	first_second;	//开始运动与第一次定位成功之间的秒数
	xU32	data_len;		//不算header,后面GPS_SamplePoint的总长度
	xU32	crc;			//header的crc校验
}P3k_MotionDataHeader;

#define SPORT_SONG_TOTALSTEP_TIME_MAGIC		0x73707469	//spti
#define SPORT_SONG_BPMCOUNT_MAGIC		0x636d7062	//bpmc
//#define SPORT_SONG_BPMCOUNT_MAX_SONGNUM		(20) //(200 /sizeof(_Sport_Song_Base_Info)  - 1)	//运动的bpm排名前20的歌曲，可能会重
#define SPORT_SONG_BPMCOUNT_MAX_SONGNUM		(1024 - 1)

#define SPORT_SONG_SINGLE_PLAYING_MIN_TIME		10	//s
typedef struct _Sport_Song_Base_Info{
	xU32	dbid;		//song  id
	xU16	song_bpm;		//song bpm
	xU16	sport_bpm;	//人在当前歌曲播放过程的平均bpm
	xU32	playing_time_count;	//s	
}_Sport_Song_Base_Info;

typedef struct Sport_Tag_Ctrl{
	xU32 magic;
	xU32 datalen;		//数据的大小				datalen/sizeof(_Sport_Song_Base_Info) 就是项数。
}Sport_Tag_Ctrl;


typedef struct Sport_Song_BpmCount{
//	xU32 magic;
//	xU32 datalen;		//数据的大小				datalen/sizeof(_Sport_Song_Base_Info) 就是项数。
	Sport_Tag_Ctrl head_tag;
	_Sport_Song_Base_Info	item[1];
}Sport_Song_BpmCount;
typedef struct Sport_Total_Step_Time{
//	xU32 magic;
//	xU32 datalen;	
	Sport_Tag_Ctrl head_tag;
	xU32 step;
	xU32 total_pause_time;
}Sport_Total_Step_Time;



#define P3K_PLAYLIST_DBID_START			0xF0000		// 0xF0000 ~ 0xF0005		预留的播放列表ID
#define P3K_PLAYLIST_NUM				6
#define P3K_PLAYLIST_ITEM_NUM			(1000)		//暂定	
#define P3K_PLAYLIST_DBID_RESERVED		(0xF0000 - 1)	// 隐藏区的列表ID
#define P3K_RESERVED_DBID_MIN			((0x2 << 8)|(0x1))		//PACK_SONG_DATA_ID
#define P3K_RESERVED_DBID_MAX			((0x2 << 8)|(0xFF))	//PACK_SONG_DATA_ID_MAX

#define P3K_PLAYLIST_DBID_ALLMEDIA      0xF1000

typedef struct P3k_PLaylist_Item{
	xU32	dbid;
	xU16	dbpos;
	xU16	pad[1];		//reserved
}P3k_PLaylist_Item;

typedef struct P3k_PLaylist_Header{
	xU32				data_crc;		//av_crc	AV_CRC_32_IEEE_LE	
	xU32				list_dbid;
	xU32				item_num;
	P3k_PLaylist_Item	item[1];
}P3k_PLaylist_Header;

typedef struct P3k_ID_Modify_List{
//	xU32		data_crc;		//av_crc	AV_CRC_32_IEEE_LE	
	xU32		id_num;
	xU32		id[1];
}P3k_ID_Modify_List;



typedef struct P3k_PLaylist_NameItem{
	xU32	dbid;
	xU32	name_len;
	xU16	name_buff[2];
}P3k_PLaylist_NameItem;

typedef struct P3k_PLaylist_Name_List{
	xU32	list_dbid;
	xU16	list_dbpos;
	xU16	item_num;		//list中总项数
	P3k_PLaylist_NameItem	item[1];				//只存储需要获取文件名的项		会4字节对齐	
}P3k_PLaylist_Name_List;


typedef struct P3k_PLaylist_Name_Map{
	xU32	list_dbid;
	xU16	list_dbpos;
	xU16	item_num;		//list中总项数
	xU32	item[1];			//index下标，如果需要穿名字，就置1，，  一个4字节就有32个位，能表示32项
}P3k_PLaylist_Name_Map;




//#define DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER	0xd	 /*获取目录下所有meida的ID+dbpos列表   需要传入目录ID+dbpos*/
typedef struct P3K_Check_Read_MediaList_CMD{
	xU8 btype;	/* P3K_CMD_WRITE */
	xU8 bno;	/* 0 */
	xU16 objID;
	xU32 offset;
	xU32 len;					/* object length */
	xU32 dbid;	
	xU16 dbpos;	
	xU8 ex[BLE_MAX_MTU_SIZE-18];
}P3K_Check_Read_MediaList_CMD;


// typedef struct P3k_PlayingList_Modify{
// 	xU32	list_id;
// 	xU32	item_id;
// 	xU8		fashion;	//0 = del,  1 = add   //暂时只加到最后一项。			
// 	xU8		pad[3];		//reserved
// }P3k_PlayingList_Modify;

//play_error_state
#define PLAY_ERROR_STATE_NOMAL					0x0	 	//NOMAL
#define PLAY_ERROR_STATE_UNSUPPORT_SONG		0x1		// 有不支持的歌曲


#define P3K_PLAYMODE_SEQUENCE		0
#define P3K_PLAYMODE_RANDOM		1
#define P3K_PLAYMODE_SINGLE			2
#define P3K_PLAYMODE_ALL			3

#define P3K_BPM_SWITCH_ON			0x8000	//&0x8000 == 0  自动 == 1  手动  


#define P3K_BLE_RT_INFO_SUM			(('S' << 8) | ('U' << 0))


//RT_Info
typedef struct Ble_RT_Info{
	xU8		workmode;			//工作模式  0 : hifi,  1 : sport
	xU8		playmode;			//0顺序 1随机
	xU8		playstate;			//0停止 1播放  2暂停
	xU8		single_lock;			//单曲锁定
	xS16	hp_volnum;			
	xU16	bpm;				//当前设置的bpm		//&0x8000 == 0  自动，  == 1  手动   0x7FFFF
	//	xU32	song_id;			//db id		//	P3k_PLaylist_Item	item;	
	P3k_PLaylist_Item song_item;
	xU32	playing_time;		//当前秒数
	xU32	total_time;			//
	xU32	playinglist_id;		//文件夹dbid  or 列表dbid（0xF0000 “我喜欢的” 预留一些id给列表用）
	xU16	play_error_state;		//
	xU16	t_len;				//RT_info  total_size
	P3K_TagHeader	hd[1];		//用于扩展
}Ble_RT_Info;

//RT_Info
//typedef struct Ble_RT_Info_Ease{
//	xU8		workmode;			//工作模式  0 : hifi,  1 : sport
//	xU8		playmode;			//0顺序 1随机  2单曲循环
//	xU8		playstate;			//0停止 1播放  2暂停
//	xU8 	hp_volnum;			
//	xU16	bpm;				//当前设置的bpm	
//	xU16	playing_time;		//当前秒数
//	xU32	dbid;
//	xU32	playinglist_id;		//文件夹dbid  or 列表dbid（0xF0000 “我喜欢的” 预留一些id给列表用）	
//}Ble_RT_Info_Ease;

#endif


