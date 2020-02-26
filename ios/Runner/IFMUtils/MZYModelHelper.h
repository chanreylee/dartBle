//
//  MZYModelHelper.h
//  News
//
//  Created by wuxl on 2018/3/28.
//  Copyright © 2018年 com.ifm. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Block

@interface MZYModelHelper : NSObject

//字典返回json字符串
+ (NSString *)getJsonStringWith:(NSDictionary *)dict;

//通过对象返回一个NSDictionary，键是属性名称，值是属性值。
+ (NSDictionary*)getObjectData:(id)obj;

//将getObjectData方法返回的NSDictionary转化成JSON
+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;

//直接通过NSLog输出getObjectData方法返回的NSDictionary
+ (void)print:(id)obj;
@end
