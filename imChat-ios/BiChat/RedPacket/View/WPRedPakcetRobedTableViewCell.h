//
//  WPRedPakcetRobedTableViewCell.h
//  BiChat
//
//  Created by 张迅 on 2018/5/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPRedPacketModel.h"
#import "FBShimmeringView.h"

@interface WPRedPakcetRobedTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UIView *backView;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UITextView *contentTV;
@property (nonatomic,strong)UILabel *coinLabel;
@property (nonatomic,strong)UILabel *timeLabel;
//倒计时label
@property (nonatomic,strong)UILabel *overTimeLabel;
@property (nonatomic,strong)UIImageView *coinIV;
@property (nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic,strong)UIImageView *sharedIV;
@property (nonatomic,strong)CAGradientLayer *gradientLayer;
@property (nonatomic,strong)FBShimmeringView *shimmeringView;
@property (nonatomic,strong)UILabel *coinTypeLabel;

//点击block
@property (nonatomic,copy)void (^SelectBlock)(NSIndexPath *indexPath);
@property (nonatomic,copy)void (^RefreshBlock)(void);

- (void)fillData:(WPRedPacketModel *)model isPersonal:(BOOL)personal isPush:(BOOL)push isShare:(BOOL)share;

@end
