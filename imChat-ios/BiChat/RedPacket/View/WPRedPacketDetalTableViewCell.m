//
//  WPRedPacketDetalTableViewCell.m
//  BiChat
//
//  Created by 张迅 on 2018/5/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketDetalTableViewCell.h"

@implementation WPRedPacketDetalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.headIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.top.equalTo(self.contentView).offset(10);
        make.width.height.equalTo(@40);
    }];
    self.headIV.layer.cornerRadius = 20;
    self.headIV.layer.masksToBounds = YES;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-180);
        make.height.equalTo(@20);
        make.bottom.equalTo(self.headIV.mas_centerY);
    }];
    self.titleLabel.font = Font(14);
    
    self.timeLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.equalTo(@20);
        make.top.equalTo(self.headIV.mas_centerY);
    }];
    self.timeLabel.font = Font(12);
    self.timeLabel.textColor = THEME_GRAY;
    
    self.priceLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.top.bottom.equalTo(self.titleLabel);
    }];
    self.priceLabel.font = Font(12);
    self.priceLabel.textAlignment = NSTextAlignmentRight;
    
    self.getStatusLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.getStatusLabel];
    [self.getStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.top.bottom.equalTo(self.timeLabel);
    }];
    self.getStatusLabel.font = Font(12);
    self.getStatusLabel.textColor = THEME_GRAY;
    self.getStatusLabel.textAlignment = NSTextAlignmentRight;
    
    return self;
}

- (void)fillData:(WPRedPacketGetRedPacketPeopleModel *)model withBit:(NSString *)bit {
    
    if ([model.platformType isEqualToString:@"1"]) {
        [self.headIV setImage:Image(@"redPacket_robListWeChat")];
        [self.headIV sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:Image(@"redPacket_robListWeChat")];
    } else {
        [self.headIV setImageWithURL:model.avatar title:model.nickName size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    }
    
    self.titleLabel.text = model.nickName;
    if ([model.platformType isEqualToString:@"1"]) {
        self.titleLabel.text = LLSTR(@"102073");
    }
    NSTimeInterval interval = [model.timestamp doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *dateStr = [formatter stringFromDate:date];
    self.timeLabel.text = dateStr;
    self.priceLabel.text = [BiChatGlobal decimalNumberWithDouble:[model.amount doubleValue]] ;
    if ([model.status isEqualToString:@"0"]) {
        self.getStatusLabel.text = LLSTR(@"101420");
    } else {
        self.getStatusLabel.text = nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
