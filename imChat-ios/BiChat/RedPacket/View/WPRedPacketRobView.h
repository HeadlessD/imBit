//
//  WPRedPacketRobView.h
//  BiChat
//
//  Created by 张迅 on 2018/5/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPRedpacketRobRedPacketDetailModel.h"

@interface WPRedPacketRobView : UIView
//背景
@property (nonatomic,strong)UIImageView *backIV;
//分享用图
@property (nonatomic,strong)UIImageView *shareIV;
//分享label
@property (nonatomic,strong)UILabel *tapLabel;
//头像
@property (nonatomic,strong)UIImageView *headIV;
//人名
@property (nonatomic,strong)UILabel *nameLabel;
//提示
@property (nonatomic,strong)UILabel *tipLabel;
//红包名
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *titleAssistantLabel;
@property (nonatomic,strong)UILabel *titleAssistantLabel1;
//"开"按钮
@property (nonatomic,strong)UIButton *openButton;
//币图标
@property (nonatomic,strong)UIImageView *coinIV;
//显示领取详情按钮
@property (nonatomic,strong)UIButton *showDetailButton;
//关闭按钮
@property (nonatomic,strong)UIButton *closeButton;
//投诉按钮
@property (nonatomic,strong)UIButton *complainButton;
//邀请入群红包提示
@property (nonatomic,strong)UILabel *inviteTipLabel1;
@property (nonatomic,strong)UILabel *inviteTipLabel2;
@property (nonatomic,strong)UILabel *inviteTipLabel3;
//分享View
@property (nonatomic,strong)UIView *shareView;

@property (nonatomic,assign)BOOL doStop;
@property (nonatomic,strong)WPRedpacketRobRedPacketDetailModel *currentModel;

@property (nonatomic,copy)void (^CloseBlock)(void);
@property (nonatomic,copy)void (^ComplainBlock)(void);
@property (nonatomic,copy)void (^ShowDetailBlock)(WPRedpacketRobRedPacketDetailModel *model);
@property (nonatomic,copy)void (^RobBlock)(void);
@property (nonatomic,copy)void (^ChatBlock)(void);
@property (nonatomic,copy)void (^ShareBlock)(NSInteger tag);
//红包流抢红包后显示币个数
@property (nonatomic,strong)NSString *robbedCount;
//粉丝红包显示已经抢到后的提示
@property (nonatomic,strong)NSString *robbedTitle;

- (void)show;
//根据返回值重绘UI
- (void)fillModel:(WPRedpacketRobRedPacketDetailModel *)model;
//开始动画
- (void)startAnimation;
//停止动画
- (void)stopAnimation;

@end
