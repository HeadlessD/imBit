//
//  WPPublicSearchResultTableViewCell.m
//  BiChat
//
//  Created by 张迅 on 2018/4/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPPublicSearchResultTableViewCell.h"

@implementation WPPublicSearchResultTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.headIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(@20);
        make.width.height.mas_equalTo(@40);
    }];
    self.headIV.layer.cornerRadius = 20;
    self.headIV.layer.masksToBounds = YES;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-80);
        make.bottom.equalTo(self.headIV.mas_centerY);
        make.height.equalTo(@20);
    }];
    self.titleLabel.font = Font(16);
    
    self.followIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.followIV];
    [self.followIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-20);
        make.top.bottom.equalTo(self.titleLabel);
        make.width.height.equalTo(@15);
    }];
    self.followIV.image = Image(@"publicAccount_follow");
    
    self.contentLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-20);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(1);
        make.height.equalTo(@20);
    }];
    self.contentLabel.font = Font(12);
    self.contentLabel.numberOfLines = 1;
    self.contentLabel.textColor = THEME_GRAY;
    self.lineV.backgroundColor = RGB(0xeeeeee);
    [self.lineV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.bottom.equalTo(self.contentView);
        make.height.equalTo(@1);
    }];
    
    return self;
}
- (void)fillData:(WPPublicSearchResultModel *)model {
    self.titleLabel.text = model.groupName;
    self.contentLabel.text = model.desc;
    [self.headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,model.avatar]] completed:nil];
    if ([model.status isEqualToString:@"1"]) {
        self.followIV.hidden = NO;
    } else {
        self.followIV.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
