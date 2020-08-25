//
//  WPMyOrderTableViewCell.m
//  BiChat
//
//  Created by iMac on 2019/1/21.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPMyOrderTableViewCell.h"

@implementation WPMyOrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.avatarIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.avatarIV];
    [self.avatarIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@36);
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(15);
    }];
    self.avatarIV.layer.cornerRadius = 18;
    self.avatarIV.layer.masksToBounds = YES;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarIV.mas_right).offset(10);
        make.top.equalTo(self.avatarIV);
        make.height.equalTo(@20);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    self.titleLabel.font = Font(16);
    
    self.subTitleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.height.equalTo(@20);
        make.right.equalTo(self.contentView).offset(-15 - 80);
    }];
    self.subTitleLabel.font = Font(13);
    self.subTitleLabel.textColor = THEME_GRAY;
    
    self.timeLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.subTitleLabel.mas_bottom);
        make.height.equalTo(@20);
        make.width.equalTo(@120);
    }];
    self.timeLabel.font = Font(12);
    self.timeLabel.textColor = THEME_GRAY;
    
    self.coinLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.coinLabel];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.mas_right);
        make.top.equalTo(self.timeLabel);
        make.height.equalTo(@20);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    self.coinLabel.font = Font(14);
    self.coinLabel.textAlignment = NSTextAlignmentRight;
//    self.coinTypeLabel = [[UILabel alloc]init];
//    [self.contentView addSubview:self.coinTypeLabel];
//    [self.coinTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.contentView).offset(-15);
//        make.top.equalTo(self.coinLabel.mas_bottom);
//        make.height.equalTo(@20);
//        make.width.equalTo(@80);
//    }];
//    self.coinTypeLabel.font = Font(14);
//    self.coinTypeLabel.textAlignment = NSTextAlignmentRight;
    return self;
}


- (void)fillData:(WPMyOrderModel *)model {
    [self.avatarIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,model.avatar] title:model.nickName size:CGSizeMake(50, 50) placeHolde:nil color:nil textColor:nil];
    self.titleLabel.text = model.nickName;
    NSTimeInterval interval =[model.utime doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString *dateString = [formatter stringFromDate: date];
    self.timeLabel.text = dateString;
    self.subTitleLabel.text = model.body;
//    self.coinLabel.text = [NSString stringWithFormat:@"%@ %@",model.total_fee,model.cash_fee_type];
    NSString *coinString = [NSString stringWithFormat:@"%@ %@",model.total_fee,model.cash_fee_type];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:coinString];
    [attStr addAttribute:NSForegroundColorAttributeName value:THEME_GRAY range:NSMakeRange(model.total_fee.length + 1, model.cash_fee_type.length)];
    [attStr addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(model.total_fee.length + 1, model.cash_fee_type.length)];
    self.coinLabel.attributedText = attStr;
//    self.coinTypeLabel.text = model.cash_fee_type;
    
//    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:model.cash_fee_type];
//    self.coinLabel.text = [[NSString stringWithFormat:@"%@",model.total_fee] accuracyCheckWithFormatterString:[coinInfo objectForKey:@""] auotCheck:YES];
//    self.coinTypeLabel.text = [coinInfo objectForKey:@""];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
