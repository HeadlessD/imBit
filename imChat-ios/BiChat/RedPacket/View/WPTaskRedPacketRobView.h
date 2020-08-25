//
//  WPTaskRedPacketRobView.h
//  BiChat
//
//  Created by iMac on 2018/12/7.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPTaskRedPacketRobView : UIView

@property (nonatomic,strong)NSDictionary *dict;
//背景
@property (nonatomic,strong)UIImageView *backIV;
//分享用图
@property (nonatomic,strong)UIImageView *shareIV;
//头像
@property (nonatomic,strong)UIImageView *headIV;
//人名
@property (nonatomic,strong)UILabel *nameLabel;
//提示
@property (nonatomic,strong)UILabel *tipLabel;
//底部提示label
@property (nonatomic,strong)UILabel *bottomLabel;
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
//分享View
@property (nonatomic,strong)UIView *shareView;

@property (nonatomic,assign)BOOL doStop;

@property (nonatomic,copy)void (^CloseBlock)(void);
@property (nonatomic,copy)void (^RobBlock)(void);
@property (nonatomic,copy)void (^ShowDetailBlock)(void);
@property (nonatomic,copy)void (^ShareBlock)(NSInteger tag);
//红包流抢红包后显示币个数
@property (nonatomic,strong)NSString *robbedCount;
//开始动画
- (void)startAnimation;
//停止动画
- (void)stopAnimation;

- (void)fillData:(NSDictionary *)data;

- (void)show;

- (void)setFinish;

@end

NS_ASSUME_NONNULL_END
