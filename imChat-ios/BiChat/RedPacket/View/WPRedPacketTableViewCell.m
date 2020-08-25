//
//  WPRedPacketTableViewCell.m
//  BiChat
//
//  Created by 张迅 on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketTableViewCell.h"


@implementation WPRedPacketTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.nameLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(73);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.equalTo(@20);
    }];
    self.nameLabel.font = Font(12);
    self.nameLabel.textColor = [UIColor grayColor];
    
    self.backIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.backIV];
    [self.backIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(67);
        make.top.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-25);
        make.bottom.equalTo(self.contentView);
    }];
    self.backgroundColor = [UIColor clearColor];
    
    self.headIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@40);
        make.left.equalTo(self.contentView).offset(20);
        make.top.equalTo(self.contentView).offset(10);
    }];
    
    self.headIV.layer.cornerRadius = 20;
    self.headIV.layer.masksToBounds = YES;
    
    self.coinIV = [[UIImageView alloc]init];
    [self.backIV addSubview:self.coinIV];
    [self.coinIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@36);
        make.centerY.equalTo(self.backIV).offset(-8);
        make.left.equalTo(self.backIV).offset(15);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    [self.backIV addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coinIV.mas_right).offset(10);
        make.height.equalTo(@20);
        make.right.equalTo(self.backIV).offset(-10);
        make.bottom.equalTo(self.coinIV.mas_centerY).offset(-1);
    }];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = Font(16);
    
    self.subLabel = [[UILabel alloc]init];
    [self.backIV addSubview:self.subLabel];
    [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.height.equalTo(@20);
        make.top.equalTo(self.coinIV.mas_centerY).offset(1);
    }];
    self.subLabel.textColor = [UIColor whiteColor];
    self.subLabel.font = Font(14);
    
    self.weChatTF = [[UITextField alloc]init];
    [self.backIV addSubview:self.weChatTF];
    [self.weChatTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(14);
        make.height.equalTo(@20);
        make.bottom.equalTo(self.backIV);
        make.right.equalTo(self.backIV).offset(-74);
    }];
    self.weChatTF.userInteractionEnabled = NO;
    self.weChatTF.font = Font(12);
    self.weChatTF.textColor = [UIColor grayColor];
    
    self.timeLabel = [[UILabel alloc]init];
    [self.backIV addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backIV).offset(-10);
        make.top.bottom.equalTo(self.weChatTF);
        make.left.equalTo(self.weChatTF.mas_right).offset(10);
    }];
    self.timeLabel.font = Font(12);
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    return self;
}

- (void)fillData:(WPRedPacketModel *)model isWeChat:(BOOL)isWeChat {
    self.titleLabel.text = model.rewardName;
    self.subLabel.text = [LLSTR(@"101424") llReplaceWithArray:@[[model.value toPrise],[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
    if ([model.avatar rangeOfString:[BiChatGlobal sharedManager].S3URL].location != NSNotFound) {
        [self.headIV setImageWithURL:model.avatar title:model.nickName size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    } else {
        if (model.avatar.length > 0) {
            [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,model.avatar] title:model.nickName size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
        } else {
            [self.headIV setImageWithURL:model.avatar title:model.nickName size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
        }
    }
    
    [self.coinIV sd_setImageWithURL:[NSURL URLWithString:model.imgWhite]];
    NSTimeInterval interval = [model.createdTime doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
    
    NSString *timeStr = nil;
    if (timeInterval < 60) {
        timeStr = [LLSTR(@"101067") llReplaceWithArray:@[@"1"]];
//        timeStr = [NSString stringWithFormat:@"1分钟前"];
    } else if (timeInterval >= 60 && timeInterval < 60 * 60) {
        long minute = timeInterval / 60;
        timeStr = [LLSTR(@"101067") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",minute]]];
//        timeStr = [NSString stringWithFormat:@"%ld分钟前",minute];
    } else if (timeInterval >= 60 * 60  && timeInterval < 60 * 60 * 24) {
        long hour = timeInterval / 60 /60;
        timeStr = [LLSTR(@"101066") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",hour]]];
//        timeStr = [NSString stringWithFormat:@"%ld小时前",hour];
    } else if (timeInterval > 60 * 60 * 24 && timeInterval < 60 * 60 * 24 * 30){
        long day = timeInterval / 60 /60 / 24;
        timeStr = [LLSTR(@"101065") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",day]]];
//        timeStr = [NSString stringWithFormat:@"%ld天前",day];
    } else {
        long month = timeInterval / 60 /60 / 24 / 30;
        timeStr = [LLSTR(@"101064") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",month]]];
//        timeStr = [NSString stringWithFormat:@"%ld月前",month];
    }
    
    self.nameLabel.text = model.nickName;
    self.timeLabel.text = timeStr;
    
    if (isWeChat) {
//        UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
//        view.image = Image(@"logo_wechat");
//        view.contentMode = UIViewContentModeCenter;
        self.headBackView.backgroundColor = RGB(0xf04d38);
        self.coinIV.hidden = YES;
        self.weChatTF.text = model.groupName;
        self.subLabel.text = [LLSTR(@"101445") llReplaceWithArray:@[[model.amount toPrise],[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        self.backIV.image = [Image(@"redPacket_ListBack") resizableImageWithCapInsets:UIEdgeInsetsMake(31, 10, 21, 6)];
        
    } else {
        self.weChatTF.text = model.groupName;
        self.getButton.hidden = NO;
        self.coinIV.hidden = NO;
        self.headBackView.backgroundColor = RGB(0xfab2a3);
        NSTimeInterval interval = model.expiredTime / 1000.0;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        //已抢
        if (model.hasReceived) {
            self.getButton.hidden = YES;
            self.headBackView.backgroundColor = RGB(0xfab2a3);
            self.subLabel.text = LLSTR(@"301210");
            self.backIV.image = [Image(@"redPacket_ListBack_light") resizableImageWithCapInsets:UIEdgeInsetsMake(31, 10, 21, 6)];
        }
        //已抢完
        else if ([model.leftValue floatValue] == 0) {
            self.getButton.hidden = YES;
            self.headBackView.backgroundColor = RGB(0xfab2a3);
            self.subLabel.text = LLSTR(@"101431");
            self.backIV.image = [Image(@"redPacket_ListBack_light") resizableImageWithCapInsets:UIEdgeInsetsMake(31, 10, 21, 6)];
        }
        //已过期
        else if ([date compare:[NSDate date]] == NSOrderedAscending) {
            self.getButton.hidden = YES;
            self.headBackView.backgroundColor = RGB(0xfab2a3);
            self.subLabel.text = LLSTR(@"301208");
            self.backIV.image = [Image(@"redPacket_ListBack_light") resizableImageWithCapInsets:UIEdgeInsetsMake(31, 10, 21, 6)];
        } else {
            self.coinIV.hidden = YES;
            [self.getButton setTitle:@"抢" forState:UIControlStateNormal];
            self.headBackView.backgroundColor = RGB(0xf04d38);
            self.backIV.image = [Image(@"redPacket_ListBack") resizableImageWithCapInsets:UIEdgeInsetsMake(31, 10, 21, 6)];
        }
    }
    self.coinIV.hidden = NO;
    self.getButton.hidden = YES;
}

- (void)tapBlock {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
