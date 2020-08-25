//
//  WPRedPacketSendReceiveModel.m
//  BiChat
//
//  Created by 张迅 on 2018/5/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketSendReceiveModel.h"

@implementation WPRedPacketSendReceiveModel


+ (NSDictionary *)objectClassInArray {
    return @{@"list":@"WPRedPacketSendCoinModel",};
}
//+ (NSDictionary *)replacedKeyFromPropertyName {
//    return @{@"coin":@"WPRedPacketSendCoinModel",};
//}
@end
