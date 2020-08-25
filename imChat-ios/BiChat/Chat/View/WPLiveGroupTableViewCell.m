//
//  WPLiveGroupTableViewCell.m
//  BiChat
//
//  Created by iMac on 2018/8/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPLiveGroupTableViewCell.h"

@implementation WPLiveGroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.imageV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(10);
        make.width.height.equalTo(@40);
    }];
    self.imageV.layer.cornerRadius = 20;
    self.imageV.layer.masksToBounds = YES;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageV.mas_right).offset(10);
        make.top.equalTo(self.imageV);
        make.height.equalTo(@30);
        make.right.equalTo(self.contentView).offset(-10);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-30);
    }];
    self.titleLabel.font = Font(14);
    self.titleLabel.numberOfLines = 0;
    
    self.timeLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageV.mas_right).offset(10);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.right.equalTo(self.contentView).offset(-10);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-10);
    }];
    self.timeLabel.font = Font(14);
    self.timeLabel.textColor = [UIColor grayColor];
    
    return self;
}

- (void)fillData:(NSDictionary *)dict {
    self.titleLabel.text = [dict objectForKey:@"groupName"];
    if ([[dict objectForKey:@"groupName"] integerValue] == 0) {
        self.timeLabel.text = @"未设置";
    }else {
        self.timeLabel.text = nil;
    }
    NSString *avatar = [dict objectForKey:@"avatar"];
    [self.imageV setImageWithURL:avatar title:[dict objectForKey:@"groupName"] size:CGSizeMake(20, 20) placeHolde:nil color:nil textColor:nil];
    if ([[dict objectForKey:@"liveGroupStartTime"] integerValue] == 0) {
        self.timeLabel.text = @"未设置";
    } else {
        self.timeLabel.text = nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
