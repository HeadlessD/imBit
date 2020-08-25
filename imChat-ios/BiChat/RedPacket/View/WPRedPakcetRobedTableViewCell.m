//
//  WPRedPakcetRobedTableViewCell.m
//  BiChat
//
//  Created by 张迅 on 2018/5/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPakcetRobedTableViewCell.h"

@implementation WPRedPakcetRobedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    
    self.backView = [[UIView alloc]init];
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.bottom.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@280);
    }];
    self.backView.layer.cornerRadius = 5;
    self.backView.layer.masksToBounds = YES;
    
    self.coinIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.coinIV];
    [self.coinIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@36);
        make.left.equalTo(self.backView).offset(15);
        make.centerY.equalTo(self.backView).offset(-10);
    }];
    
    self.coinTypeLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.coinTypeLabel];
    [self.coinTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coinIV).offset(-5);
        make.right.equalTo(self.coinIV).offset(5);
        make.top.equalTo(self.coinIV.mas_bottom).offset(-2);
        make.height.equalTo(@18);
    }];
    self.coinTypeLabel.textAlignment = NSTextAlignmentCenter;
    self.coinTypeLabel.textColor = [UIColor whiteColor];
    self.coinTypeLabel.font = Font(9);
    
    self.sharedIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.sharedIV];
    [self.sharedIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@38);
        make.right.top.equalTo(self.backView);
    }];
    self.sharedIV.image = Image(@"redPacket_shared");
    self.sharedIV.hidden = YES;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coinIV.mas_right).offset(10);
        make.height.equalTo(@20);
        make.right.equalTo(self.backView).offset(-10);
        make.bottom.equalTo(self.coinIV.mas_centerY).offset(-1);
    }];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = Font(16);
    
    self.contentTV = [[UITextView alloc]init];
    self.shimmeringView = [[FBShimmeringView alloc] init];
    [self.backView addSubview:self.shimmeringView];
    self.shimmeringView.contentView = self.contentTV;
    [self.shimmeringView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.height.equalTo(@20);
        make.top.equalTo(self.coinIV.mas_centerY).offset(3);
    }];
    
//    [self.backView addSubview:self.contentTV];
    [self.contentTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.height.equalTo(@20);
        make.top.equalTo(self.coinIV.mas_centerY).offset(3);
    }];
    self.contentTV.textColor = [UIColor whiteColor];
    self.contentTV.font = Font(12);
    self.contentTV.editable = NO;
    self.contentTV.userInteractionEnabled = NO;
    self.contentTV.textContainerInset = UIEdgeInsetsZero;
    self.contentTV.textContainer.lineFragmentPadding = 0;
    self.contentTV.backgroundColor = [UIColor clearColor];
    
    UIView *bottomV = [[UIView alloc]init];
    [self.backView addSubview:bottomV];
    [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
    }];
    bottomV.backgroundColor = [UIColor whiteColor];
    
    self.timeLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView).offset(-10);
        make.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
        make.left.equalTo(self.backView).offset(10);
    }];
    self.timeLabel.font = Font(12);
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    self.overTimeLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.overTimeLabel];
    [self.overTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView).offset(-10);
        make.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
        make.left.equalTo(self.backView).offset(10);
    }];
    self.overTimeLabel.font = Font(12);
    self.overTimeLabel.textColor = [UIColor grayColor];
    self.overTimeLabel.textAlignment = NSTextAlignmentRight;
    
    self.coinLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.coinLabel];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeLabel.mas_left).offset(-10);
        make.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
        make.left.equalTo(self.backView).offset(10);;
    }];
    self.coinLabel.textColor = [UIColor grayColor];
    self.coinLabel.font = Font(12);
    self.coinLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;    
    return self;
}

- (void)fillData:(WPRedPacketModel *)model isPersonal:(BOOL)personal isPush:(BOOL)push isShare:(BOOL)share{
    self.overTimeLabel.hidden = YES;
    //设置标题
    self.titleLabel.text = model.rewardName;
    [self.coinIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,model.imgWhite]]];
    self.coinLabel.text = model.coinType;
    //红包过期时间到了刷新列表
    NSTimeInterval a = [[BiChatGlobal getCurrentDate] timeIntervalSince1970];
    long long timeInterval = model.expiredTime / 1000.0 - a;
    if (timeInterval < 0) {
        timeInterval = 0;
        if (self.RefreshBlock && personal) {
            self.RefreshBlock();
        }
    }
    self.coinTypeLabel.text = [[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType];
    NSString *timeStr = nil;
    if (timeInterval <= 0) {
        timeStr = LLSTR(@"101045");
//        timeStr = LLSTR(@"101421");
    } else if (timeInterval < 60) {
        timeStr = LLSTR(@"101044");
//        timeStr = @"1分钟内过期";
    } else if (timeInterval >= 60 && timeInterval < 60 * 60) {
        long minute = timeInterval / 60;
        timeStr = [LLSTR(@"101043") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",minute]]];
//        timeStr = [NSString stringWithFormat:@"%ld分钟后过期",minute];
    } else if (timeInterval >= 60 * 60  && timeInterval < 60 * 60 * 24) {
        long hour = timeInterval / 60 / 60;
        timeStr = [LLSTR(@"101042") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",hour]]];
//        timeStr = [NSString stringWithFormat:@"%ld小时后过期",hour];
    } else if (timeInterval > 60 * 60 * 24 && timeInterval < 60 * 60 * 24 * 30){
        long day = timeInterval / 60 /60 / 24;
        timeStr = [LLSTR(@"101041") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",day]]];
//        timeStr = [NSString stringWithFormat:@"%ld天后过期",day];
    }
    self.timeLabel.text = timeStr;
    if (model.groupName) {
        self.coinLabel.text = [NSString stringWithFormat:@"「%@」",model.groupName];
    } else {
        self.coinLabel.text = [NSString stringWithFormat:@"「%@」",model.nickName];
    }
    if (model.isPublic) {
        self.coinLabel.text = [NSString stringWithFormat:@"「%@」",model.groupName];
    }
    
    //来源
    if (personal) {
        self.backView.backgroundColor = RGB(0xf56547);
        self.contentTV.text = [LLSTR(@"101424") llReplaceWithArray:@[[model.amount toPrise],[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        if (model.isPublic) {
            self.contentTV.text = [LLSTR(@"101425") llReplaceWithArray:@[[model.amount toPrise],[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        }
        NSTimeInterval a = [[BiChatGlobal getCurrentDate] timeIntervalSince1970];
        long long marginInterval = [model.holdExpired doubleValue] / 1000.0 - a;
        if (marginInterval <= 0) {
            self.timeLabel.text = LLSTR(@"101426");
            self.timeLabel.font = Font(12);
        } else if ([model.status isEqualToString:@"2"]) {
            self.overTimeLabel.hidden = NO;
            long hour = marginInterval / 3600;
            long minute = (marginInterval % 3600) / 60;
            long second = (marginInterval % 60);
            self.timeLabel.font = [UIFont fontWithName:@"Monaco" size:12];
            if (hour == 0) {
                self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",minute,second];
            } else {
                self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
            }
            self.overTimeLabel.text = @"";
            [self.overTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.backView).offset(-10);
                make.bottom.equalTo(self.backView);
                make.height.equalTo(@20);
                make.width.equalTo(@(0));
            }];
        }
        
    } else if (push) {
        self.timeLabel.font = Font(12);
        NSTimeInterval a = [[BiChatGlobal getCurrentDate] timeIntervalSince1970];
        long long timeInterval = model.expiredTime / 1000.0 - a;
        NSString *timeStr = nil;
        if (timeInterval <= 0) {
            timeStr = LLSTR(@"101045");
            //        timeStr = LLSTR(@"101421");
        } else if (timeInterval < 60) {
            timeStr = LLSTR(@"101044");
            //        timeStr = @"1分钟内过期";
        } else if (timeInterval >= 60 && timeInterval < 60 * 60) {
            long minute = timeInterval / 60;
            timeStr = [LLSTR(@"101043") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",minute]]];
            //        timeStr = [NSString stringWithFormat:@"%ld分钟后过期",minute];
        } else if (timeInterval >= 60 * 60  && timeInterval < 60 * 60 * 24) {
            long hour = timeInterval / 60 / 60;
            timeStr = [LLSTR(@"101042") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",hour]]];
            //        timeStr = [NSString stringWithFormat:@"%ld小时后过期",hour];
        } else if (timeInterval > 60 * 60 * 24 && timeInterval < 60 * 60 * 24 * 30){
            long day = timeInterval / 60 /60 / 24;
            timeStr = [LLSTR(@"101041") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",day]]];
            //        timeStr = [NSString stringWithFormat:@"%ld天后过期",day];
        }
        self.timeLabel.text = timeStr;
        if (model.expiredTime == 0) {
            self.timeLabel.text = nil;
        }
    } else {
        self.timeLabel.font = Font(12);
        self.titleLabel.text = model.rewardName;
        self.contentTV.text = [LLSTR(@"101427") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        self.timeLabel.text = nil;
    }
    CGRect rect = [self.timeLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.timeLabel.font} context:nil];
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.overTimeLabel.hidden) {
            make.right.equalTo(self.backView).offset(-10);
            make.bottom.equalTo(self.backView);
        } else {
            make.right.equalTo(self.overTimeLabel.mas_left);
            make.bottom.equalTo(self.backView).offset(0.2);
        }
        make.height.equalTo(@20);
        make.width.equalTo(@(rect.size.width + 5));
    }];
    self.backView.backgroundColor = RGB(0xf56547);
    model.beGray = NO;
    if (model.rewardType == 101) {
        if ([model.ownerUid isEqualToString:[BiChatGlobal sharedManager].uid]) {
            if ([model.status isEqualToString:@"3"]) {
                self.contentTV.text = [LLSTR(@"101428") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
                self.backView.backgroundColor = RGB(0xfab2a3);
                model.beGray = YES;
                self.timeLabel.text = nil;
            } else if ([model.rewardStatus isEqualToString:@"3"]) {
                self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
                self.backView.backgroundColor = RGB(0xfab2a3);
                model.beGray = YES;
                self.timeLabel.text = nil;
            } else {
                self.contentTV.text = [LLSTR(@"101430") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            }
        } else {
            if ([model.status isEqualToString:@"3"]) {
                self.contentTV.text = [LLSTR(@"101428") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
                self.backView.backgroundColor = RGB(0xfab2a3);
                model.beGray = YES;
                self.timeLabel.text = nil;
            } else if ([model.rewardStatus isEqualToString:@"4"]) {
                self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
                model.beGray = YES;
                self.backView.backgroundColor = RGB(0xfab2a3);
                self.timeLabel.text = nil;
            } else {
                self.contentTV.text = [LLSTR(@"101430") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            }
        }
    } else if (model.rewardType == 102) {
        if ([model.status isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101428") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"2"] || [model.rewardStatus isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101431") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else {
            self.contentTV.text = [LLSTR(@"101427") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        }
    } else if (model.rewardType == 103 && model.subType == 0) {
        if ([model.status isEqualToString:@"3"] && !share) {
            self.contentTV.text = [LLSTR(@"101428") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.status isEqualToString:@"2"]) {
            self.contentTV.text = [LLSTR(@"101432") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        } else if ([model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"2"] || [model.rewardStatus isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101431") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.status isEqualToString:@"5"] || [model.status isEqualToString:@"7"]) {
            self.contentTV.text = [LLSTR(@"101433") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.status isEqualToString:@"4"] && ![model.ownerUid isEqualToString:[BiChatGlobal sharedManager].uid]) {
            self.contentTV.text = [LLSTR(@"101433") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.timeLabel.text = nil;
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
        } else {
            self.contentTV.text = [LLSTR(@"101427") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            if ([model.ownerUid isEqualToString:[BiChatGlobal sharedManager].uid]) {
                self.contentTV.text = [LLSTR(@"101434") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            }
        }
    } else if (model.rewardType == 103 && model.subType == 1) {
        if ([model.status isEqualToString:@"3"] && ![model.rewardStatus isEqualToString:@"3"] && ![model.rewardStatus isEqualToString:@"2"] && ![model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101435") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        } else if ([model.status isEqualToString:@"2"]) {
            self.contentTV.text = [LLSTR(@"101432") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        } else if ([model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"2"]) {
            self.contentTV.text = [LLSTR(@"101431") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
        } else if ([model.rewardStatus isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101437") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
        } else if ([model.status isEqualToString:@"5"] || [model.status isEqualToString:@"7"]) {
            self.contentTV.text = [LLSTR(@"101433") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.status isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101433") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.timeLabel.text = nil;
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            if ([model.rewardStatus isEqualToString:@"1"]) {
                self.contentTV.text = [LLSTR(@"101436") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
                self.backView.backgroundColor = RGB(0xf56547);
                model.beGray = NO;
            }
        } else {
            self.contentTV.text = [LLSTR(@"101427") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            if (model.inviteCode.length > 0 || [model.ownerUid isEqualToString:[BiChatGlobal sharedManager].uid] || share) {
                self.contentTV.text = [LLSTR(@"101436") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            }
        }
    } else if (model.rewardType == 103 && model.subType == 2) {
        if ([model.status isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101428") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.status isEqualToString:@"2"]) {
            self.contentTV.text = [LLSTR(@"101432") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        } else if ([model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.status isEqualToString:@"5"] || [model.status isEqualToString:@"7"]) {
            self.contentTV.text = [LLSTR(@"101433") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"2"]) {
            self.contentTV.text = [LLSTR(@"101431") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101437") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else {
            self.contentTV.text = [LLSTR(@"101427") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        }
    } else if (model.rewardType == 104) {
        if ([model.status isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101428") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else {
            self.contentTV.text = [LLSTR(@"101430") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        }
    } else if (model.rewardType == 105) {
        if ([model.status isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101428") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"2"] || [model.rewardStatus isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101431") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else {
            self.contentTV.text = [LLSTR(@"101427") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        }
    } else if (model.rewardType == 106 && model.subType == 1) {
        if ([model.status isEqualToString:@"3"] && ![model.rewardStatus isEqualToString:@"3"] && ![model.rewardStatus isEqualToString:@"2"] && ![model.rewardStatus isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101435") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        } else if ([model.status isEqualToString:@"2"]) {
            self.contentTV.text = [LLSTR(@"101432") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        } else if ([model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.status isEqualToString:@"5"] || [model.status isEqualToString:@"7"]) {
            self.contentTV.text = [LLSTR(@"101433") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"2"]) {
            self.contentTV.text = [LLSTR(@"101431") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
        } else if ([model.rewardStatus isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101437") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
        } else if ([model.status isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101433") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.timeLabel.text = nil;
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            if ([model.rewardStatus isEqualToString:@"1"]) {
                self.contentTV.text = [LLSTR(@"101436") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
                self.backView.backgroundColor = RGB(0xf56547);
                model.beGray = NO;
            }
        } else {
            self.contentTV.text = [LLSTR(@"101436") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
    
        }
    } else if (model.rewardType == 106 && model.subType == 2) {
        if ([model.status isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101428") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.status isEqualToString:@"2"]) {
            self.contentTV.text = [LLSTR(@"101432") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        } else if ([model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.status isEqualToString:@"5"] || [model.status isEqualToString:@"7"]) {
            self.contentTV.text = [LLSTR(@"101433") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"2"]) {
            self.contentTV.text = [LLSTR(@"101431") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else if ([model.rewardStatus isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101437") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else {
            self.contentTV.text = [LLSTR(@"101427") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        }
    } else if (model.rewardType == 107) {
        if ([model.status isEqualToString:@"3"]) {
            self.contentTV.text = [LLSTR(@"101428") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xf56547);
            self.timeLabel.text = nil;
            if (share) {
                self.contentTV.text = [LLSTR(@"101435") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            }
            if (push) {
                self.backView.backgroundColor = RGB(0xfab2a3);
                model.beGray = YES;
            }
        } else if ([model.rewardStatus isEqualToString:@"4"]) {
            self.contentTV.text = [LLSTR(@"101429") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
            self.backView.backgroundColor = RGB(0xfab2a3);
            model.beGray = YES;
            self.timeLabel.text = nil;
        } else {
            self.contentTV.text = [LLSTR(@"101430") llReplaceWithArray:@[[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]]];
        }
    }
    if (push && [model.rewardStatus isEqualToString:@"1"]
        && ([model.status isEqualToString:@"4"]
        || [model.status isEqualToString:@"5"]
        || [model.status isEqualToString:@"6"]
        || [model.status isEqualToString:@"7"])) {
            self.timeLabel.text = nil;
            self.backView.backgroundColor = RGB(0xfab2a3);
    }
    if (model.hasShared && ![model.status isEqualToString:@"2"]) {
        self.timeLabel.text = LLSTR(@"101438");
        CGRect rect = [self.timeLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.timeLabel.font} context:nil];
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.overTimeLabel.hidden) {
                make.right.equalTo(self.backView).offset(-10);
                make.bottom.equalTo(self.backView);
            } else {
                make.right.equalTo(self.overTimeLabel.mas_left);
                make.bottom.equalTo(self.backView).offset(0.2);
            }
            make.height.equalTo(@20);
            make.width.equalTo(@(rect.size.width + 5));
        }];
    }
    //包含已抢待领的文字做个动效
    if ([self.contentTV.text containsString:LLSTR(@"101420")]) {
////        将文字生成图片,设置gradientLayer的mask属性为图片,裁剪掉文字以外的部分
//        UIGraphicsBeginImageContext(self.bounds.size);
//
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        dict[NSForegroundColorAttributeName] = [UIColor redColor];
//        dict[NSFontAttributeName] = [UIFont systemFontOfSize:30.0];
//        [self.contentTV.text drawInRect:self.contentView.bounds withAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:30.0]}];
//
//        CGContextRef context= UIGraphicsGetCurrentContext ();
//
//        CGContextDrawPath (context, kCGPathStroke );
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        CALayer *maskLayer = [CALayer layer];
//        maskLayer.backgroundColor = [UIColor clearColor].CGColor;
//        maskLayer.frame = CGRectOffset(self.bounds, self.bounds.size.width, 0);
//        maskLayer.contents = (__bridge id _Nullable)(image.CGImage);
//        //使用蒙版裁剪掉没用的区域
//        self.gradientLayer.mask = maskLayer;
//        self.contentTV.alpha = 1;
//        [UIView animateWithDuration:1 animations:^{
//            self.contentTV.alpha = 0;
//        }];
        self.shimmeringView.shimmering = YES;
    } else {
        self.shimmeringView.shimmering = NO;
    }
    
    CGRect rect1 = [self.timeLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.timeLabel.font} context:nil];
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView).offset(-10);
        make.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
        make.width.equalTo(@(rect1.size.width + 5));
    }];
    
    [self.coinLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeLabel.mas_left).offset(-10);
        make.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
        make.left.equalTo(self.backView).offset(3);;
    }];
}
////使用CAGradientLayer处理颜色渐变
//-(CAGradientLayer *)gradientLayer{
//
//    if (!_gradientLayer) {
//        _gradientLayer = [CAGradientLayer layer];
//        [self.contentTV layoutIfNeeded];
//        _gradientLayer.frame = self.contentTV.frame;
//        _gradientLayer.startPoint = CGPointMake(_gradientLayer.frame.origin.x, _gradientLayer.frame.origin.y);
//        _gradientLayer.endPoint = CGPointMake(ScreenWidth - 10, _gradientLayer.frame.origin.y + 20);
//
//        _gradientLayer.colors = @[
//                                  (__bridge id)[UIColor blackColor].CGColor,
//                                  (__bridge id)[UIColor whiteColor].CGColor,
//                                  (__bridge id)[UIColor blackColor].CGColor
//                                  ];
//        _gradientLayer.locations = @[@0.25,@0.5,@0.75];
//    }
//    return _gradientLayer;
//
//
//}
////使用CABasicAnimation为CAGradientLayer添加动画
//-(void)animationWithGradientLayer{
//    CABasicAnimation *gradientAnimation = [CABasicAnimation animationWithKeyPath:@"locations"];
//    gradientAnimation.fromValue = @[@0.0,@0.0,@0.25];
//    gradientAnimation.toValue = @[@0.75,@1.0,@1.0];
//    gradientAnimation.duration = 1.0;
//    gradientAnimation.repeatCount = MAXFLOAT;
//    [self.gradientLayer addAnimation:gradientAnimation forKey:nil];
//}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
