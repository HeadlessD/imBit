//
//  WPRedPacketTableViewCell.h
//  BiChat
//
//  Created by 张迅 on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPRedPacketModel.h"

@interface WPRedPacketTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UIView *headBackView;
@property (nonatomic,strong)UIImageView *backIV;
@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *subLabel;
@property (nonatomic,strong)UITextField *weChatTF;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UIButton *getButton;
@property (nonatomic,strong)UIView *statusView;
@property (nonatomic,strong)UIImageView *coinIV;

@property (nonatomic,strong)NSIndexPath *indexPath;
//点击block
@property (nonatomic,copy)void (^SelectBlock)(NSIndexPath *indexPath);

- (void)fillData:(WPRedPacketModel *)model isWeChat:(BOOL)isWeChat;

@end
