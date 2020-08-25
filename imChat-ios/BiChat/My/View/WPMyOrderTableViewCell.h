//
//  WPMyOrderTableViewCell.h
//  BiChat
//
//  Created by iMac on 2019/1/21.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPMyOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPMyOrderTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UIImageView *avatarIV;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UILabel *subTitleLabel;
@property (nonatomic,strong)UILabel *coinLabel;
//@property (nonatomic,strong)UILabel *coinTypeLabel;


- (void)fillData:(WPMyOrderModel *)model;

@end

NS_ASSUME_NONNULL_END
