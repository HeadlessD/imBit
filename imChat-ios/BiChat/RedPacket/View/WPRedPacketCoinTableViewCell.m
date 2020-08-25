//
//  WPRedPacketCoinTableViewCell.m
//  BiChat
//
//  Created by 张迅 on 2018/5/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketCoinTableViewCell.h"

@implementation WPRedPacketCoinTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.coinIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.coinIV];
    [self.coinIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@40);
        make.left.equalTo(@15);
    }];
//    self.coinIV.layer.borderColor = THEME_GRAY.CGColor;
//    self.coinIV.layer.borderWidth = 1;
    self.coinIV.layer.masksToBounds = YES;
    self.coinIV.layer.cornerRadius = 30;
    self.coinIV.contentMode = UIViewContentModeScaleAspectFit;
    
    self.coinLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.coinLabel];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coinIV.mas_right).offset(10);
        make.bottom.equalTo(self.coinIV.mas_centerY);
        make.height.equalTo(@20);
        make.right.equalTo(self.contentView).offset(-100);
    }];
    self.coinLabel.font = Font(16);
    
    self.subLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.subLabel];
    [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coinIV.mas_right).offset(10);
        make.top.equalTo(self.coinIV.mas_centerY);
        make.height.equalTo(@20);
        make.right.equalTo(self.contentView).offset(-100);
    }];
    self.subLabel.font = Font(14);
    self.subLabel.textColor = THEME_GRAY;
    
    self.countLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-10);
        make.left.equalTo(self.contentView).offset(100);
    }];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.font = Font(16);
    return self;
}

- (void)fillData:(WPRedPacketSendCoinModel *)model {
    [self.coinIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,model.imgColor]]];
    self.coinLabel.text = model.dSymbol;
    if (model.name.count > 0) {
        self.subLabel.text = model.name[0];
    }
    self.countLabel.text = [model.amount accuracyCheckWithFormatterString:model.bit auotCheck:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
