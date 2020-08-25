//
//  WPNearByTableViewCell.m
//  BiChat
//
//  Created by iMac on 2018/11/5.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPNearByTableViewCell.h"

@implementation WPNearByTableViewCell

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
        make.top.equalTo(self.contentView).offset(7);
        make.width.height.equalTo(@50);
    }];
    self.headIV.layer.cornerRadius = 25;
    self.headIV.layer.masksToBounds = YES;
    
    self.genderIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.genderIV];
    [self.genderIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headIV).offset(3);
        make.bottom.equalTo(self.headIV).offset(1);
        make.width.height.equalTo(@18);
    }];
    self.genderIV.layer.cornerRadius = 9;
    self.genderIV.layer.masksToBounds = YES;
    
    self.tagLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView).offset(-90);
    }];
    self.tagLabel.font = Font(12);
    self.tagLabel.textColor = [UIColor whiteColor];
    self.tagLabel.backgroundColor = LightBlue;
    self.tagLabel.layer.cornerRadius = 3;
    self.tagLabel.layer.masksToBounds = YES;
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    
    self.nameLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(5);
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView).offset(-90);
    }];
    self.nameLabel.font = Font(16);
    
    self.desLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.desLabel];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.top.equalTo(self.contentView.mas_centerY);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.right.equalTo(self.contentView).offset(-60);
        
    }];
    self.desLabel.textColor = THEME_GRAY;
    self.desLabel.font = Font(12
                              );
    
    self.distanceLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.distanceLabel];
    [self.distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right);
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView).offset(-10);
    }];
    self.distanceLabel.textAlignment = NSTextAlignmentRight;
    self.distanceLabel.textColor = THEME_GRAY;
    self.distanceLabel.font = Font(14);
    return self;
}

- (void)fillData:(WPNearbyModel *)model {
    [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,model.avatar] title:model.nickName size:CGSizeMake(36, 36) placeHolde:nil color:nil textColor:nil];
    self.nameLabel.text = model.nickName;
    if ([[BiChatGlobal sharedManager]getFriendMemoName:model.uid].length > 0) {
        self.nameLabel.text = [[BiChatGlobal sharedManager]getFriendMemoName:model.uid];
    } else {
        self.nameLabel.text = model.nickName;
    }
    self.desLabel.text = model.sign;
    if ([[BiChatGlobal sharedManager] isFriendInContact:model.uid]) {
        self.tagLabel.text = @"好友";
        self.tagLabel.hidden = NO;
    } else {
        self.tagLabel.hidden = YES;
        self.tagLabel.text = nil;
    }
    CGRect rect = [LLSTR(@"101014") boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.tagLabel.font} context:nil];
    [self.tagLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.height.equalTo(@16);
        make.width.equalTo(@(rect.size.width + 6));
        make.top.equalTo(self.contentView).offset(10);
    }];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.tagLabel.text.length > 0) {
            make.left.equalTo(self.tagLabel.mas_right).offset(5);
        } else {
            make.left.equalTo(self.headIV.mas_right).offset(10);
        }
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView).offset(-90);
    }];
    if ([model.gender isEqualToString:@"1"]) {
        self.genderIV.image = Image(@"ico_man");
    } else if ([model.gender isEqualToString:@"2"]) {
        self.genderIV.image = Image(@"ico_woman");
    } else {
        self.genderIV.image = nil;
    }
    
    NSString * distance = [NSString stringWithFormat:@"%ld",[model.distance integerValue]];
    self.distanceLabel.text = [LLSTR(@"101218") llReplaceWithArray:@[distance]];
//    [NSString stringWithFormat:@"%ld米",[model.distance integerValue]];
    if ([model.distance integerValue] < 100) {
        self.distanceLabel.text = LLSTR(@"101219");
    } else if ([model.distance integerValue] < 900) {
        NSString * distance2 = [NSString stringWithFormat:@"%ld",[model.distance integerValue] /100 + 1];
        self.distanceLabel.text = [LLSTR(@"101220") llReplaceWithArray:@[distance2]];
//        [NSString stringWithFormat:@"%ld00米以内",[model.distance integerValue] /100 + 1];
    } else if ([model.distance integerValue] < 1000) {
        self.distanceLabel.text = LLSTR(@"101221");
    }
    else if ([model.distance integerValue] >= 1000) {
        NSString * distance3 = [NSString stringWithFormat:@"%.1f",[model.distance doubleValue] / 1000.0];
        self.distanceLabel.text = [LLSTR(@"101222") llReplaceWithArray:@[distance3]];
//        [NSString stringWithFormat:@"%.1f公里",[model.distance doubleValue] / 1000.0];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    

    // Configure the view for the selected state
}

@end
