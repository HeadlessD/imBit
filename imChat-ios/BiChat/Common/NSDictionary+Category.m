//
//  NSDictionary+Category.m
//  Vegetable365
//
//  Created by 张迅 on 15/11/24.
//  Copyright © 2015年 zhangxun. All rights reserved.
//

#import "NSDictionary+Category.h"

@implementation NSDictionary (Category)

- (NSString *)stringObjectForkey:(NSString *)key {
    if ([self isKindOfClass:[NSNull class]] || !self) {
        return @"";
    }
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]]) {
        if ([obj isEqualToString:@"<null>"]) {
            return @"";
        }
        return obj;
    } else if([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@",obj];
    }else {
        if ([obj isKindOfClass:[NSNull class]] || obj == nil) {
            return @"";
        }
        return [NSString stringWithFormat:@"%@",obj];
    }
}

- (NSString *)floatValueForKey:(NSString *)key {
    if ([self isKindOfClass:[NSNull class]] || !self) {
        return @"";
    }
    float value = [self[key] floatValue];
    return [NSString stringWithFormat:@"%f",value];
}

- (NSArray *)arrayObjectForKey:(NSString *)key {
    if ([self isKindOfClass:[NSNull class]] || !self) {
        return [NSArray array];
    }
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    } else {
        return [NSArray array];
    }
}

- (NSDictionary *)dictionaryObjectForkey:(NSString *)key {
    if ([self isKindOfClass:[NSNull class]] || !self) {
        return [NSDictionary dictionary];
    }
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    } else {
        if ([obj isKindOfClass:[NSNull class]] || obj == nil) {
            return [NSDictionary dictionary];
        }
        return obj;
    }
}

@end
