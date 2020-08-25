//
//  WPRedPacketModel.h
//  BiChat
//
//  Created by 张迅 on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPRedPacketModel : NSObject

@property (nonatomic,strong)NSString *coinType;
//红包个数
@property (nonatomic,strong)NSString *count;
@property (nonatomic,strong)NSString *createdTime;
@property (nonatomic,assign)NSInteger expiredTime;
@property (nonatomic,strong)NSString *sendTime;
@property (nonatomic,strong)NSString *holdExpired;
//发红包者的名字
@property (nonatomic,strong)NSString *nickName;
//发红包者的id
@property (nonatomic,strong)NSString *ownerUid;
//发红包者的电话
@property (nonatomic,strong)NSString *phone;
//红包id
@property (nonatomic,strong)NSString *uuid;
//红包总额
@property (nonatomic,strong)NSString *value;
//剩余可抢红包
@property (nonatomic,strong)NSString *leftValue;
@property (nonatomic,strong)NSString *amount;
//红包标题
@property (nonatomic,strong)NSString *rewardName;
//红包类型（用于接受的推送红包）
@property (nonatomic,assign)NSInteger rewardType;
//红包子类型（用于接受的推送红包）
@property (nonatomic,assign)NSInteger subType;
//币类型（用于接受的推送红包）
@property (nonatomic,strong)NSString *coinSymbol;
//是否推送来的红包
@property (nonatomic,assign)BOOL isPush;
//群id
@property (nonatomic,strong)NSString *groupId;
//虚拟群id
@property (nonatomic,strong)NSString *virtualGroupId;
//公众号id(实际是公众号所有者id)，关注公众号用此id
@property (nonatomic,strong)NSString *publicAccountOwnerUid;
//群名
@property (nonatomic,strong)NSString *groupName;
@property (nonatomic,strong)NSString *imgColor;
@property (nonatomic,strong)NSString *imgWhite;
//是否已领抢，自己获取，不在接口提供
@property (nonatomic,assign)BOOL hasReceived;
//是否已过期，自己获取，不在接口提供
@property (nonatomic,assign)BOOL hasExpired;
//是否已被抢完，自己获取，不在接口提供
@property (nonatomic,assign)BOOL hasFinished;
//是否已抢，自己获取，不在接口提供
@property (nonatomic,assign)BOOL hasOccupied;
//是否已分享，自己获取，不在接口提供
@property (nonatomic,assign)BOOL hasShared;
//红包个人状体
@property (nonatomic,strong)NSString *status;
//红包状态
@property (nonatomic,strong)NSString *rewardStatus;
//显示不可用
@property (nonatomic,assign)BOOL showDisable;
//头像
@property (nonatomic,strong)NSString *avatar;
//群头像
@property (nonatomic,strong)NSString *groupAvatar;
//是否公号
@property (nonatomic,assign)BOOL isPublic;

//分享用url
@property (nonatomic,strong)NSString *url;
//邀请码
@property (nonatomic,strong)NSString *inviteCode;
//仅用于“我的”，切换tab移除掉YES的数据
@property (nonatomic,assign)BOOL beGray;
@property (nonatomic,assign)BOOL isWeiXin;

@end
