//
//  WPLiveGroupTableViewCell.h
//  BiChat
//
//  Created by iMac on 2018/8/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"

@interface WPLiveGroupTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UIImageView *imageV;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UILabel *statusLabel;

- (void)fillData:(NSDictionary *)dict;

@end
