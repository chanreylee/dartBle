//
//  CBPeripheral+IFMProperties.h
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (IFMProperties)
- (void)ifm_setNick:(NSString*)nick;
- (NSString*)ifm_nick;
- (void)ifm_setIsBind:(BOOL)isBind;
- (BOOL)ifm_isBind;
- (void)ifm_setIsSelected:(BOOL)isSelected;
- (BOOL)ifm_isSelected;

- (BOOL)ifm_isConnected;
@end
