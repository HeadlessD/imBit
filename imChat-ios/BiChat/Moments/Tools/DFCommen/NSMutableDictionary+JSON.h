//
//  NSMutableDictionary+JSON.h
//  DFCommon
//
//  Created by 豆凯强 on 17/4/12.
//  Copyright (c) 2017年 Datafans Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (JSON)

-(NSString*) dic2jsonString:(id)object;
-(NSData *) dic2jsonData:(id)object;

@end
