//
//  WPRedPacketRobViewController.h
//  BiChat
//
//  Created by 张迅 on 2018/5/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"
#import "WPRedpacketRobRedPacketDetailModel.h"

@interface WPRedPacketRobViewController : WPBaseViewController

@property (nonatomic,strong)WPRedpacketRobRedPacketDetailModel *redModel;
@property (nonatomic,strong)NSString *rewardId;
@property (nonatomic,strong)NSString *shareUrl;

@end
