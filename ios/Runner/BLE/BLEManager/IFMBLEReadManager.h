//
//  IFMBLEReadManager.h
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEManager.h"

@interface IFMBLEReadManager : IFMBLEManager <IFMBLEManager>
- (void)setupParam:(xU16)param;
- (void)setupDbId:(xU32)dbId Dbpos:(xU16)dbpos;
- (void)setupLat:(xU32)lat lon:(xU32)lon;
@end
