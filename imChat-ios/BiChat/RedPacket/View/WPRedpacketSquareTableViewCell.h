//
//  WPRedpacketSquareTableViewCell.h
//  BiChat
//
//  Created by iMac on 2018/8/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPRedPacketModel.h"

@interface WPRedpacketSquareTableViewCell : WPBaseTableViewCell
@property (nonatomic,strong)UIView *backView;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UITextView *contentTV;
@property (nonatomic,strong)UILabel *coinLabel;
@property (nonatomic,strong)UILabel *coinTypeLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UIImageView *coinIV;
@property (nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic,strong)UIImageView *sharedIV;

//点击block
@property (nonatomic,copy)void (^SelectBlock)(NSIndexPath *indexPath);
@property (nonatomic,copy)void (^RefreshBlock)(void);

- (void)fillData:(WPRedPacketModel *)model isPersonal:(BOOL)personal isPush:(BOOL)push isShare:(BOOL)share;

@end
