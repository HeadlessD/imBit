//
//  NSMutableDictionary+JSON.h
//  DFCommon
//
//  Created by 豆凯强 on 17/4/12.
//  Copyright (c) 2017年 Datafans Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

+(NSString*) dic2jsonString:(NSDictionary *) dic;
+(NSData *) dic2jsonData:(NSDictionary *) dic;
+(NSDictionary*) jsonString2Dic:(NSString *) str;
+(NSDictionary*) jsonData2Dic:(NSData *) data;

@end
