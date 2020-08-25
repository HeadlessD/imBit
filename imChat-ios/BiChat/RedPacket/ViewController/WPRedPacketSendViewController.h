//
//  WPRedPacketSendViewController.h
//  BiChat
//
//  Created by 张迅 on 2018/5/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"

@protocol RedPacketCreateDelegate <NSObject>
@optional
- (void)redPacketCreated:(NSString *)url
             redPacketId:(NSString *)redPacketId
            coinImageUrl:(NSString *)coinImageUrl
       shareCoinImageUrl:(NSString *)shareCoinImageUrl
              coinSymbol:(NSString *)coinSymbol
                greeting:(NSString *)greeting
                 groupId:(NSString *)groupId
               groupName:(NSString *)groupName
              rewardType:(NSString *)rewardType
                 subType:(NSString *)subType
                isInvite:(BOOL)isInvite
                 expired:(NSString *)expired
                      at:(NSString *)at
                  atName:(NSString *)atName;
@end

@interface WPRedPacketSendViewController : WPBaseViewController
//是否群
@property (nonatomic, assign) BOOL isGroup;
//是否拉人入群红包
@property (nonatomic, assign) BOOL isInvite;

@property (nonatomic, strong) NSString *peerId;
@property (nonatomic, strong) UIViewController *chatVC;
@property (nonatomic, weak) id<RedPacketCreateDelegate> delegate;
//是否私密群
@property (nonatomic,assign)BOOL isPrivate;
//群名
@property (nonatomic, strong)NSString *groupName;
//人名
@property (nonatomic, strong)NSString *peopleName;
//是否可返回上层
@property (nonatomic, assign) BOOL canPop;

@end

