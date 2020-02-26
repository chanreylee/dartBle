//
//  CBPeripheral+IFMProperties.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "CBPeripheral+IFMProperties.h"
#import <objc/runtime.h>

static void *IFMProperties_Peripheral_Nick;
static void *IFMProperties_Peripheral_IsBind;
static void *IFMProperties_Peripheral_IsSelected;

@implementation CBPeripheral (IFMProperties)
- (void)ifm_setNick:(NSString*)nick {
    objc_setAssociatedObject(self, &IFMProperties_Peripheral_Nick, nick, OBJC_ASSOCIATION_COPY);
}

- (NSString*)ifm_nick {
    return objc_getAssociatedObject(self, &IFMProperties_Peripheral_Nick);
}

- (void)ifm_setIsBind:(BOOL)isBind {
    objc_setAssociatedObject(self, &IFMProperties_Peripheral_IsBind, @(isBind), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)ifm_isBind {
    return [objc_getAssociatedObject(self, &IFMProperties_Peripheral_IsBind) boolValue];
}

- (void)ifm_setIsSelected:(BOOL)isSelected {
    objc_setAssociatedObject(self, &IFMProperties_Peripheral_IsSelected, @(isSelected), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)ifm_isSelected {
    return [objc_getAssociatedObject(self, &IFMProperties_Peripheral_IsSelected) boolValue];
}

- (BOOL)ifm_isConnected {
    return self.state == CBPeripheralStateConnected;
}

@end
