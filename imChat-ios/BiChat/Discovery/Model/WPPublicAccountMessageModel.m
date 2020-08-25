//
//  WPPublicAccountMessageModel.m
//  BiChat
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPPublicAccountMessageModel.h"

@implementation WPPublicAccountMessageModel
+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"newsId":@"id"
             };
}
@end
