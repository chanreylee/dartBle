//
//  IFMCheckCMDReformer.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMCheckCMDReformer.h"

@implementation IFMCheckCMDReformer

- (id)bleManager:(IFMBLEManager*)manager reformData:(NSData*)data {
    P3K_Write_CMD_Response response;
    memset(&response, 0, sizeof(P3K_Write_CMD_Response));
    memcpy(&response, [data bytes], sizeof(P3K_Write_CMD_Response));
    
    return @(response.len);
}

@end


