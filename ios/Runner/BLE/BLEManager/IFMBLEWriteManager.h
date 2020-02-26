//
//  IFMBLEWriteManager.h
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEManager.h"

@interface IFMBLEWriteManager : IFMBLEManager <IFMBLEManager>
- (void)setupOffset:(xU32)offset;
@end
