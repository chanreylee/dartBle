#ifndef _BLE_ATTRIBUTE_SETUP_H_
#define _BLE_ATTRIBUTE_SETUP_H_

#include "xtypes.h"

#ifndef	DOUBLE
#define	DOUBLE	long double
#endif

#ifndef	MAX_EQ_FILTER_BAND
#define MAX_EQ_FILTER_BAND		8
#endif

// level-> {"OFF","-10DBFS","-20DBFS","-30DBFS"}
// mode->{"PAUSE","SPLIT"}
// delaySec->{"5s","10s","30s","1M","2M","3M"}
typedef struct VOR_Data_Ble{
	xU8	level;	//等级
	xU8	mode;	//模式
	xU8	delaySec;	//时间
	xU8	pad[1];
}VOR_Data_Ble;

//mode->0,1,2   内容待定
//enable->0,1  {"OFF","ON"}
//samplerate->是否可调还是主动降噪开启后只能固定频率待确定
typedef	struct	Webrtc_Data_Ble{	//主动降噪
	xS32	samplerate;	//采样率
	xS16	mode;	//模式
	xS16	enable;	//主动降噪是否使能
}Webrtc_Data_Ble;

//6、限辐器：具体使用前端还是后端还是两个都可以调节不确定，所以两个都放上来了（如何显示，显示哪些项，范围待确定）	
typedef struct Compress_Type_Ble{		//限幅器
	DOUBLE avems;
	DOUBLE attackms;
	DOUBLE releasems;
	DOUBLE ratio;
	DOUBLE threshdB;
	DOUBLE gaindb;
	xS16 rmsen;
	xS16 isenable;
}Compress_Type_Ble;

//7、Noise_Type结构是否开放使用不确定，手表手环里都没有设置先放上；
typedef	struct Noise_Type_Ble {
	DOUBLE avems;
	DOUBLE attackms;
	DOUBLE releasems;
	DOUBLE threshdB;
	DOUBLE gaindb;
	xS16 rmsen;
	xS16 isenable;
}Noise_Type_Ble;

// type-> {"lpf2","hpf2","lpf1","hpf1","lowshelf","highshelf","nortch","peak"}	
// gain,fc,q具体调节范围待确定；
// bands根据选择的多少段才固定需要传入
typedef struct _sEQ_BandParam_Ble{
	xS32	type;	//滤波器类型
	DOUBLE	gain;	//gain[(5)]
	DOUBLE	fc;		//中心频率
	DOUBLE	q;		//q值
}_sEQ_BandParam_Ble;

typedef	struct	sEQ_Param_Ble{
	xU8	bands;
	xU8	pad[3];
	_sEQ_BandParam_Ble	bp[MAX_EQ_FILTER_BAND];
}sEQ_Param_Ble;


// format->	{"wav_pcm_16bit","wav_pcm_24bit","mp3"}
// samplerate->	{"44K","48K","96K"},(如果formatID选择mp3的话无法设置采样率为96K)
// channelId-> {"ST","MO"}
// bitrateSt与bitrateMo根据采样率，声道，格式来定：如果foramtID不是mp3格式文件则bitrateSt = 位宽*声道（ST）*采样率，bitrateMo=位宽*声道（MO）*采样率
//	formatID是MP3格式文件：则bitrateSt分三挡128k,256k,320k；bitrateMo为32K,64K,128K,三档位可选	

// format 选择 "wav_pcm_16bit" 、"wav_pcm_24bit" 时
// samplerate 可选 {"44K","48K","96K"}
// channelId-> 可选 {"ST","MO"}
// bitrate 不可选 = 位宽*声道*采样率 = format * channelId * samplerate / 1000   单位是 KBPS (16 * 2 * 44100 / 1000)

// format 选择 "mp3" 时
// samplerate 可选 {"44K","48K"}
// channelId-> 可选 {"ST","MO"}
// bitrate 可选 = channelId = "ST" : {"128k","256k","320k"}
//				  channelId = "MO": {"32K","64K","128K"}
typedef	struct	RecTemplate_Ble	{
	xU8		formatpos;
	xU8		sampleratepos;
	xU8		channnelpos;
	xU8		bitratepos;
}RecTemplate_Ble;

typedef	struct	PAW1_BLERecoderItem{
	VOR_Data_Ble	vor;	//声控开关
	xU8		agcon;	//AGC功能开关（打开/关闭）
	xU8		micpower;	//麦克供电（打开/关闭）
	xU8		lowCut;		//低切降噪（关闭/档位or打开）
	xU8		recLevel;	//录音增益
	Webrtc_Data_Ble	webrtcdata;	//主动降噪
	Compress_Type_Ble	preCompress;	//限辐器（前端）
	Compress_Type_Ble	postCompress;	//限辐器（后端）
	Noise_Type_Ble	preNoisegate;	
	Noise_Type_Ble	postNoisegate;
	sEQ_Param_Ble	preEq;				//录音EQ
	sEQ_Param_Ble	postEq;				//录音EQ
	RecTemplate_Ble	rectemp;			//录音模式
	xS32		preGaindbx10;		//录音前端增益（放大10倍）
	xS32		postGaindbx10;		//录音后端增益（放大10倍）
	xS32	micIn_sensitivity;		//内置MIC灵敏度
}PAW1_BLERecoderItem;

// 1、recLevel具体怎么设置不清楚：是分档位（HIGH-LOW）还是可以调节录音的inputLevel形式，(但这个不是录音软件上前端增益和后端增益，跟徐航确认过)
// 2、限辐器：具体使用前端还是后端还是两个都可以调节不确定，所以两个都放上来了（如何显示，显示哪些项，范围待确定）
// 3、Noise_Type结构是否开放使用不确定，手表手环里都没有设置先放上；
// 4、preGaindbx10，postGaindbx10为录音部分前端、后端增益，原来为double类型，放大10倍传入，
// 具体有些细节都没有定，所以目前将我能考虑到的最全的放在上面
/*
1、VOR_Data_Ble结构范围：level->四挡：OFF,-10DBFS,-20DBFS,-30DBFS
						mode->PAUSE,SPLIT
						delaySec->5s,10s,30s,1M,2M,3M
2、agcon范围：打开/关闭						
3、micpower范围：打开/关闭
4、lowCut范围：一种打开/关闭；一种：关闭+档位待确定；

5、Webrtc_Data_Ble结构范围：mode->0,1,2
						enable->0,1
						samplerate->是否可调还是主动降噪开启后只能固定频率待确定
					 											
6、限辐器：具体使用前端还是后端还是两个都可以调节不确定，所以两个都放上来了（如何显示，显示哪些项，范围待确定）	
7、Noise_Type结构是否开放使用不确定，手表手环里都没有设置先放上；
8、录音EQ：_sEQ_BandParam_Ble范围：type->lpf2,hpf2,lpf1,hpf1,lowshelf,highshelf,nortch,peak	
		gain,fc,q具体调节范围待确定；采样率，声道在RecTemplate_Ble确定后都已经固定了可以不用再传入一次但是bands根据选择的多少段才固定需要传入
9、RecTemplate_Ble结构范围：formatID->	wav_pcm_16bit,wav_pcm_24bit,mp3三挡
						 samplerateId->44K,48K,96K,(如果formatID选择mp3的话无法设置采样率为96K)
						 channelId->ST,MO
						 bitrateSt与bitrateMo根据采样率，声道，格式来定：如果foramtID不是mp3格式文件则bitrateSt = 位宽*声道（ST）*采样率，bitrateMo=位宽*声道（MO）*采样率
						 												如果formatID是MP3格式文件：则bitrateSt分三挡128k,256k,320k；bitrateMo为32K,64K,128K,三档位可选	
10、preGaindbx10，postGaindbx10为录音部分前端、后端增益，原来为double类型，放大10倍传入是否需要待确定，	
11、内置MIC灵敏度：灵敏度是直接可以调节还是按照档位分布不确定，方式、调节范围待确定					 																 				
*/
#endif //_BLE_ATTRIBUTE_SETUP_H_

