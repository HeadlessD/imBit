//
//  WPRedPacketSendReceiveModel.h
//  BiChat
//
//  Created by 张迅 on 2018/5/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPRedPacketSendCoinModel.h"
@interface WPRedPacketSendReceiveModel : NSObject
//两个接口合用model，上面用发红包前请求的数据，下面用创建红包成功后的数据
@property (nonatomic,strong)NSString *total;
@property (nonatomic,strong)NSString *code;
@property (nonatomic,strong)NSString *isBtType;
@property (nonatomic,strong)NSString *rewardType;
@property (nonatomic,strong)NSString *mess;
@property (nonatomic,strong)NSArray *list;

@property (nonatomic,strong)NSString *coinImgUrl;
@property (nonatomic,strong)NSString *rewardId;
@property (nonatomic,strong)NSString *groupId;
@property (nonatomic,strong)NSString *greetings;
@property (nonatomic,strong)NSString *groupName;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)WPRedPacketSendCoinModel *coin;




@end
