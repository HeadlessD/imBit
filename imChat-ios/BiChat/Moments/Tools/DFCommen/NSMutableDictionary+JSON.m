//
//  NSMutableDictionary+JSON.m
//  DFCommon
//
//  Created by 豆凯强 on 17/4/12.
//  Copyright (c) 2017年 Datafans Inc. All rights reserved.
//

#import "NSMutableDictionary+JSON.h"


@implementation NSMutableDictionary (JSON)

-(NSString*) dic2jsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


-(NSData *) string2nsdata:(NSString *) string
{
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *) dic2jsonData:(id)object
{
    return [self string2nsdata:[self dic2jsonString:object]];
}




@end
