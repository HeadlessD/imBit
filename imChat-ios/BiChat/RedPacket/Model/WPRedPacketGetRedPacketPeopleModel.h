//
//  WPRedPacketGetRedPacketPeopleModel.h
//  BiChat
//
//  Created by 张迅 on 2018/5/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPRedPacketGetRedPacketPeopleModel : NSObject

//领取金额
@property (nonatomic,strong)NSString *amount;
@property (nonatomic,strong)NSString *createTime;
//用户名
@property (nonatomic,strong)NSString *nickName;
//领取状态
@property (nonatomic,strong)NSString *remark;
//头像
@property (nonatomic,strong)NSString *avatar;
//领取时间
@property (nonatomic,strong)NSString *timestamp;
//0未领取，1已领取,2已过期
@property (nonatomic,strong)NSString *status;
//用户来源0：imchat用户，1微信用户
@property (nonatomic,strong)NSString *platformType;

@end
