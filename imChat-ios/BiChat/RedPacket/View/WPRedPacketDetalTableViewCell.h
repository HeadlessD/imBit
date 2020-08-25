//
//  WPRedPacketDetalTableViewCell.h
//  BiChat
//
//  Created by 张迅 on 2018/5/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPRedPacketGetRedPacketPeopleModel.h"

@interface WPRedPacketDetalTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UILabel *priceLabel;
@property (nonatomic,strong)UILabel *getStatusLabel;

- (void)fillData:(WPRedPacketGetRedPacketPeopleModel *)model withBit:(NSString *)bit;

@end
