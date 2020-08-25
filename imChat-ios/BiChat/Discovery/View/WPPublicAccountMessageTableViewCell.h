//
//  WPPublicAccountMessageTableViewCell.h
//  BiChat
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPPublicAccountMessageModel.h"

@interface WPPublicAccountMessageTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UILabel *timeLabel;
- (void)fillData:(WPPublicAccountMessageModel *)model;

@end
