//
//  WPDiscoverModel.m
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPDiscoverModel.h"

@implementation WPDiscoverModel

+ (NSDictionary *)objectClassInArray {
    return @{};
}

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"newsid":@"id",
             @"pubnickname":@"groupName"
             };
}

@end
