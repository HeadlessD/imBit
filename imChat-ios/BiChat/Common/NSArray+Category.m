//
//  NSArray+Category.m
//  BiChat
//
//  Created by Admin on 2018/6/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "NSArray+Category.h"

@implementation NSArray(Category)

- (BOOL)containsString:(NSString *)str
{
    for (id item in self)
    {
        if ([item isKindOfClass:[NSString class]] &&
            [item isEqualToString:str])
            return YES;
    }
    return NO;
}

@end
