//
//  WPRedPacketCoinTableViewCell.h
//  BiChat
//
//  Created by 张迅 on 2018/5/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPRedPacketSendCoinModel.h"

@interface WPRedPacketCoinTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UIImageView *coinIV;
@property (nonatomic,strong)UILabel *coinLabel;
@property (nonatomic,strong)UILabel *subLabel;
@property (nonatomic,strong)UILabel *countLabel;

- (void)fillData:(WPRedPacketSendCoinModel *)model;

@end
