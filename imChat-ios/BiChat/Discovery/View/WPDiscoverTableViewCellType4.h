//
//  WPDiscoverTableViewCellType4.h
//  BiChat
//
//  Created by iMac on 2018/7/24.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import <YYText.h>

@interface WPDiscoverTableViewCellType4 : WPBaseTableViewCell

@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *descLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UIButton *shareBtn;
@property (nonatomic,strong)WPDiscoverModel *model;
@property (nonatomic,copy) void (^ShareBlock)(WPDiscoverModel *model);

- (void)fillData:(WPDiscoverModel *)model;
@end
