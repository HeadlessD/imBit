//
//  WPPublicAccountMessageTableViewCell.m
//  BiChat
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPPublicAccountMessageTableViewCell.h"

@implementation WPPublicAccountMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    CGFloat imageWidth = (ScreenWidth - 30) / 3.0;
    CGFloat imageHeight = imageWidth * 10 / 16;
    
    self.headIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-12);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(@(imageWidth));
        make.height.mas_equalTo(@(imageHeight));
    }];
    self.headIV.layer.cornerRadius = 3;
    self.headIV.layer.masksToBounds = YES;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.top.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.headIV.mas_left).offset(-12);
        make.height.equalTo(@40);
    }];
    self.titleLabel.font = Font(16);
    self.titleLabel.numberOfLines = 2;
    
    self.timeLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.right.equalTo(self.headIV.mas_left).offset(-12);
        make.height.equalTo(@20);
        make.bottom.equalTo(self.headIV).offset(3);
    }];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.font = Font(14);
    
    return self;
}

- (void)fillData:(WPPublicAccountMessageModel *)model {
    [self.headIV sd_setImageWithURL:[NSURL URLWithString:model.link]];
    self.titleLabel.text = model.title;
    [self.headIV sd_setImageWithURL:[NSURL URLWithString:model.img]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSTimeInterval interval = [model.time doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    self.timeLabel.text = [formatter stringFromDate:date];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
