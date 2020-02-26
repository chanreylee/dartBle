//
//  IFMSportPlanPropertyKeys.h
//  P3KApp
//
//  Created by Guanghua Huo on 16/6/7.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#ifndef IFMSportPlanPropertyKeys_h
#define IFMSportPlanPropertyKeys_h

/*
 此结构的版本
 xU32
 */
extern NSString * const kIFMSportPlanPropertyKeys_Version;

/*
 运动计划名称
 NSString
 */
extern NSString * const kIFMSportPlanPropertyKeys_Name;

/*
 运动类型
 xU16
 */
extern NSString * const kIFMSportPlanPropertyKeys_Type;

/*
 目标bpm
 xU16
 */
extern NSString * const kIFMSportPlanPropertyKeys_BPM;

/*
 目标距离（单位：米）
 xU32
 */
extern NSString * const kIFMSportPlanPropertyKeys_Distance;

/*
 时间（单位：秒）
 xU32
 */
extern NSString * const kIFMSportPlanPropertyKeys_Time;

/*
 配速（单位：秒/公里）
 xU16
 */
extern NSString * const kIFMSportPlanPropertyKeys_Pace;

#endif /* IFMSportPlanPropertyKeys_h */
