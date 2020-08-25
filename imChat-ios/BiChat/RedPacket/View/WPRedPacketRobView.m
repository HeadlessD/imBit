//
//  WPRedPacketRobView.m
//  BiChat
//
//  Created by 张迅 on 2018/5/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketRobView.h"
#import <QuartzCore/QuartzCore.h>
#import "WPRedpacketShareButton.h"

#define kBtnTag 999
#define kLabelTag 9999
@implementation WPRedPacketRobView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doClose)];
    [self addGestureRecognizer:tapGes];
    return self;
}

- (void)show {
    if (!self.superview) {
        return;
    }
    NSArray *titleArray = @[LLSTR(@"102207"),LLSTR(@"102206"),LLSTR(@"102209")];
    NSArray *imageArray = @[Image(@"redpacket_share_timeLine"),Image(@"redpacket_share_weChat"),Image(@"redpacket_share_friends")];
    UIButton *lastBtn = nil;
    
    self.shareView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    [self addSubview:self.shareView];
    
    self.backIV = [[UIImageView alloc]init];
    [self addSubview:self.backIV];
    self.backIV.image = Image(@"redPacket_body");
    self.backIV.userInteractionEnabled = YES;
    UITapGestureRecognizer *emptyGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(emptyMethod)];
    [self.backIV addGestureRecognizer:emptyGes];
    self.backIV.layer.cornerRadius = 5;
    self.backIV.layer.masksToBounds = YES;
    self.backIV.userInteractionEnabled = YES;
    
    for (int i = 0; i < titleArray.count; i++) {
        UIButton *button = [WPRedpacketShareButton button];
        [self.shareView addSubview: button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.backIV.mas_top).offset(-40);
            make.height.equalTo(@50);
            make.width.equalTo(@80);
            if (i == 0) {
                make.right.equalTo(self.shareView).offset(-30);
            } else if (i == 1) {
                make.centerX.equalTo(self.shareView);
            } else {
                make.left.equalTo(self.shareView).offset(30);
            }
        }];
        UIImage *image = imageArray[i];
        [button setImage:image forState:UIControlStateNormal];
        lastBtn = button;
        button.tag = kBtnTag + i;
        [button addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label = [[UILabel alloc]init];
        [self.shareView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(button);
            make.top.equalTo(button.mas_bottom).offset(-10);
            make.height.equalTo(@30);
        }];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = kLabelTag + i;
        label.text = titleArray[i];
        label.font = Font(12);
        label.numberOfLines = 2;
        label.textColor = [UIColor whiteColor];
    }
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backIV addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.backIV);
        make.width.height.equalTo(@50);
    }];
    [self.closeButton addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton setImage:Image(@"close") forState:UIControlStateNormal];
    self.closeButton.alpha = 0.3;
    
    self.complainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.complainButton];
    [self.complainButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.width.height.equalTo(@50);
    }];
    [self.complainButton addTarget:self action:@selector(doComplain) forControlEvents:UIControlEventTouchUpInside];
    [self.complainButton setImage:Image(@"complain") forState:UIControlStateNormal];
    self.complainButton.alpha = 0.4;
    
    self.headIV = [[UIImageView alloc]init];
    [self.backIV addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backIV).offset(40);;
        make.centerX.equalTo(self.backIV);
        make.width.height.equalTo(@50);
    }];
    self.headIV.layer.masksToBounds = YES;
    self.headIV.layer.cornerRadius = 25;
    
    self.nameLabel = [[UILabel alloc]init];
    [self.backIV addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.top.equalTo(self.headIV.mas_bottom).offset(5);
        make.height.equalTo(@25);
    }];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = Font(16);
    self.nameLabel.textColor = RGB(0xffe2b3);
    
    self.tipLabel = [[UILabel alloc]init];
    [self.backIV addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.height.equalTo(@25);
    }];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.font = Font(16);
    self.tipLabel.textColor = RGB(0xffe2b3);
    
    self.titleLabel = [[UILabel alloc]init];
    [self.backIV addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.centerY.equalTo(self.backIV).offset(-20);
        make.height.equalTo(@80);
    }];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 3;
    self.titleLabel.font = Font(22);
    self.titleLabel.textColor = RGB(0xffe2b3);
    
    self.titleAssistantLabel = [[UILabel alloc]init];
    [self.backIV addSubview:self.titleAssistantLabel];
    [self.titleAssistantLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.top.equalTo(self.tipLabel.mas_bottom).offset(5);
        make.height.equalTo(@20);
    }];
    self.titleAssistantLabel.textAlignment = NSTextAlignmentCenter;
    self.titleAssistantLabel.numberOfLines = 1;
    self.titleAssistantLabel.font = Font(16);
    self.titleAssistantLabel.textColor = RGB(0xffe2b3);
    
    self.titleAssistantLabel1 = [[UILabel alloc]init];
    [self.backIV addSubview:self.titleAssistantLabel1];
    [self.titleAssistantLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(-5);
        make.height.equalTo(@20);
    }];
    self.titleAssistantLabel1.textAlignment = NSTextAlignmentCenter;
    self.titleAssistantLabel1.numberOfLines = 1;
    self.titleAssistantLabel1.font = Font(14);
    self.titleAssistantLabel1.textColor = RGB(0xffe2b3);
    
    self.openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openButton.tag = 99999;
    [self.backIV addSubview:self.openButton];
    [self.openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backIV);
        make.bottom.equalTo(self.backIV).offset(-80);
        make.width.height.equalTo(@80);
    }];
    
    self.openButton.layer.cornerRadius = 40;
    self.openButton.backgroundColor = RGB(0xddbc87);
    self.openButton.layer.masksToBounds = YES;
    [self.openButton setTitle:@"開" forState:UIControlStateNormal];
    [self.openButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.openButton.titleLabel.font = Font(35);
    [self.openButton addTarget:self action:@selector(doRob) forControlEvents:UIControlEventTouchUpInside];
    
    self.inviteTipLabel2 = [[UILabel alloc]init];
    [self.backIV addSubview:self.inviteTipLabel2];
    [self.inviteTipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.bottom.equalTo(self.backIV.mas_bottom).offset(-60);
        make.height.equalTo(@20);
    }];
    self.inviteTipLabel2.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.inviteTipLabel2.textAlignment = NSTextAlignmentCenter;
    self.inviteTipLabel2.font = Font(16);
    self.inviteTipLabel2.textColor = RGB(0xffe2b3);
    self.inviteTipLabel2.hidden = YES;
    
    self.inviteTipLabel1 = [[UILabel alloc]init];
    [self.backIV addSubview:self.inviteTipLabel1];
    [self.inviteTipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.inviteTipLabel2);
        make.bottom.equalTo(self.inviteTipLabel2.mas_top).offset(-3);
        make.height.equalTo(@20);
    }];
    self.inviteTipLabel1.textAlignment = NSTextAlignmentCenter;
    self.inviteTipLabel1.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.inviteTipLabel1.font = Font(16);
    self.inviteTipLabel1.textColor = RGB(0xffe2b3);
    self.inviteTipLabel1.hidden = YES;
    
    self.inviteTipLabel3 = [[UILabel alloc]init];
    [self.backIV addSubview:self.inviteTipLabel3];
    [self.inviteTipLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.inviteTipLabel2);
        make.top.equalTo(self.inviteTipLabel2.mas_bottom).offset(3);
        make.height.equalTo(@20);
    }];
    self.inviteTipLabel3.textAlignment = NSTextAlignmentCenter;
    self.inviteTipLabel3.font = Font(16);
    self.inviteTipLabel3.textColor = RGB(0xffe2b3);
    self.inviteTipLabel3.hidden = YES;
    
    self.showDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backIV addSubview:self.showDetailButton];
    [self.showDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.backIV);
    }];
    CGRect rect = [LLSTR(@"101501") boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil];
    self.showDetailButton.titleLabel.font = Font(14);
    self.showDetailButton.tag = 99;
    [self.showDetailButton setTitleColor:RGB(0xffe2b3) forState:UIControlStateNormal];
    [self.showDetailButton setImage:Image(@"redPacket_showRedDetail") forState:UIControlStateNormal];
    [self.showDetailButton setTitle:LLSTR(@"101501") forState:UIControlStateNormal];
    [self.showDetailButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -3.5, 0, 3.5)];
    [self.showDetailButton setImageEdgeInsets:UIEdgeInsetsMake(0, rect.size.width + 8, 0, -rect.size.width - 8)];
    [self.showDetailButton addTarget:self action:@selector(showDetail) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = self.superview;
    self.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [UIView animateWithDuration:0 animations:^{
         [self toNormal];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)emptyMethod {
    //doNothing
}
//分享
- (void)doShare:(UIButton *)button {
    if (button.tag == 99999) {
        if (self.ShareBlock) {
            self.ShareBlock(1);
        }
    } else {
        if (self.ShareBlock) {
            self.ShareBlock(button.tag - kBtnTag);
        }
    }
}

- (void)toNormal {
    [self setNeedsUpdateConstraints];
    [self.backIV mas_makeConstraints:^(MASConstraintMaker *make) {
        if (isIPhone5) {
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self).offset(20);
            make.height.equalTo(@410);
        } else {
            make.left.equalTo(self).offset(25);
            make.right.equalTo(self).offset(-25);
            make.centerY.equalTo(self);
            make.height.equalTo(@435);
        }
    }];
}

- (void)toSmall {
    [self setNeedsUpdateConstraints];
    [self.backIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(35);
        make.right.equalTo(self).offset(-35);
        make.centerY.equalTo(self);
        make.height.equalTo(@430);
    }];
}

- (void)fillModel:(WPRedpacketRobRedPacketDetailModel *)model {
    self.shareView.hidden = YES;
    if (!model.isOwner && model.rewardType == 103 && [model.subType isEqualToString:@"0"] && !model.isOwner) {
        model.canForward = @"0";
        model.outside = @"0";
    }
    if ([model.canForward boolValue] || [model.outside boolValue]) {
        self.shareView.hidden = NO;
        if (![model.canForward boolValue]) {
            if ([self.shareView viewWithTag:kBtnTag + 2]) {
                [self.shareView viewWithTag:kBtnTag + 2].hidden = YES;
                [self.shareView viewWithTag:kLabelTag + 2].hidden = YES;
            }
        }
    }
    if (model.rewardType == 107) {
        self.shareView.hidden = NO;
        if (![model.canForward boolValue]) {
            if ([self.shareView viewWithTag:kBtnTag + 2]) {
                [self.shareView viewWithTag:kBtnTag + 2].hidden = YES;
                [self.shareView viewWithTag:kLabelTag + 2].hidden = YES;
            }
        }
    }
    
    if ([model.rewardStatus isEqualToString:@"2"] || [model.rewardStatus isEqualToString:@"3"]) {
        self.shareView.hidden = YES;
    }
    self.currentModel = model;
    
    self.nameLabel.text = model.nickname;
    [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,model.avatar] title:model.nickname size:CGSizeMake(50, 50) placeHolde:nil color:RGB(0xddbc87) textColor:[UIColor blackColor]];
    self.titleLabel.text = model.name;
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.centerY.equalTo(self.backIV);
        make.height.equalTo(@80);
    }];
    
    NSString *inviteNickName = model.inviteNickName.length < 9 ? model.inviteNickName : [NSString stringWithFormat:@"%@...",[model.inviteNickName substringToIndex:7]];
    if ([model.drawType isEqualToString:@"0"]) {
        self.tipLabel.text = [LLSTR(@"101503") llReplaceWithArray:@[model.dSymbol]];
        if (model.isShare && !model.isOwner) {
            self.tipLabel.text = [LLSTR(@"101505") llReplaceWithArray:@[inviteNickName,model.dSymbol]];
        }
    } else if ([model.drawType isEqualToString:@"1"]) {
        self.tipLabel.text = [LLSTR(@"101502") llReplaceWithArray:@[model.dSymbol]];
        if (model.isShare && !model.isOwner) {
            self.tipLabel.text = [LLSTR(@"101504") llReplaceWithArray:@[inviteNickName,model.dSymbol]];
        }
    } else {
        self.tipLabel.text = [LLSTR(@"101502") llReplaceWithArray:@[model.dSymbol]];
        if (model.isShare && !model.isOwner) {
            self.tipLabel.text = [LLSTR(@"101504") llReplaceWithArray:@[inviteNickName,model.dSymbol]];
        }
    }
    if (model.rewardType == 107) {
        self.tipLabel.text = [LLSTR(@"101502") llReplaceWithArray:@[model.dSymbol]];
    }
    
    //已抢待领，已抢已领
    if ([model.status isEqualToString:@"2"] || [model.status isEqualToString:@"3"]) {
        if ([model.status isEqualToString:@"3"]) {
            self.openButton.hidden = YES;
        }
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backIV).offset(20);
            make.right.equalTo(self.backIV).offset(-20);
            make.centerY.equalTo(self.backIV);
            make.height.equalTo(@40);
        }];
        if ([model.status isEqualToString:@"2"]) {
            self.titleAssistantLabel.text = LLSTR(@"101506");
        } else {
            self.titleAssistantLabel.text = LLSTR(@"101507");
        }
        self.titleLabel.font = Font(36);
        self.titleLabel.text = [model.drawAmount accuracyCheckWithFormatterString:model.bit auotCheck:YES];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineSpacing:1.0];
        self.titleAssistantLabel1.text = self.currentModel.dSymbol;
    }
    //可抢
   if ([model.rewardStatus isEqualToString:@"1"] &&
       ![model.status isEqualToString:@"2"] &&
       ![model.status isEqualToString:@"3"] &&
       ![model.status isEqualToString:@"5"] &&
       ![model.status isEqualToString:@"7"] &&
       ![model.status isEqualToString:@"8"] &&
       ![model.status isEqualToString:@"9"]) {
        [self.openButton setTitle:@"開" forState:UIControlStateNormal];
        self.openButton.hidden = NO;
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backIV).offset(20);
            make.right.equalTo(self.backIV).offset(-20);
            make.centerY.equalTo(self.backIV).offset(-13);
            make.height.equalTo(@80);
        }];
        //群拉人、公号拉人
        if ((model.rewardType == 103 || model.rewardType == 106 ) && ([model.status isEqualToString:@"4"] || [model.status isEqualToString:@"6"])) {
            self.openButton.hidden = YES;
//            self.inviteTipLabel1.hidden = NO;
            self.inviteTipLabel2.hidden = NO;
            self.inviteTipLabel3.hidden = NO;
            
            if ([model.subType isEqualToString:@"0"]) {
                [self setBottomLineTwo];
                self.inviteTipLabel2.text = [LLSTR(@"101508") llReplaceWithArray:@[model.groupName]];
                self.inviteTipLabel3.text = LLSTR(@"101509");
                if (model.isPublic) {
                    self.inviteTipLabel2.text = [LLSTR(@"101510") llReplaceWithArray:@[model.groupName]];
                    self.inviteTipLabel3.text = LLSTR(@"101511");
                }
                if (model.isOwner) {
                    self.inviteTipLabel3.text = LLSTR(@"101513");
                }
            } else if ([model.subType isEqualToString:@"1"]) {
                int rateValue = roundf([model.rate floatValue] * 100);
                NSString *rate = [NSString stringWithFormat:@"%d",rateValue];
                self.inviteTipLabel1.text = [NSString stringWithFormat:[LLSTR(@"101508") llReplaceWithArray:@[model.groupName]],model.groupName];
                self.inviteTipLabel2.text = nil;
                self.inviteTipLabel3.text = [LLSTR(@"101512") llReplaceWithArray:@[rate]];
                if (model.isPublic) {
                    self.inviteTipLabel1.text = [LLSTR(@"101510") llReplaceWithArray:@[model.groupName]];
                    self.inviteTipLabel2.text = nil;
                    self.inviteTipLabel3.text = [LLSTR(@"101512") llReplaceWithArray:@[rate]];
                }
            } else {
                [self setBottomLineTwo];
                if (model.isOwner) {
                    self.inviteTipLabel2.text = LLSTR(@"101513");
                    self.inviteTipLabel3.text = LLSTR(@"101514");
                    if (model.isPublic) {
                        self.inviteTipLabel2.text = LLSTR(@"101511");
                    }
                } else {
                    self.inviteTipLabel2.text = [NSString stringWithFormat:[LLSTR(@"101508") llReplaceWithArray:@[model.groupName]],model.groupName];
                    self.inviteTipLabel3.text = LLSTR(@"101509");
                    if (model.isPublic) {
                        self.inviteTipLabel2.text = [LLSTR(@"101510") llReplaceWithArray:@[model.groupName]];
                        self.inviteTipLabel3.text = LLSTR(@"101511");
                    }
                }
                
            }
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.backIV).offset(20);
                make.right.equalTo(self.backIV).offset(-20);
                make.centerY.equalTo(self.backIV);
                make.height.equalTo(@80);
            }];
        } else if (model.rewardType == 107) {
            if (model.isOwner) {
                self.openButton.hidden = YES;
                [self setBottomLineTwo];
                self.inviteTipLabel2.text = LLSTR(@"101515");
                int rateValue = roundf([self.currentModel.rate floatValue] * 100);
                NSString *rate = [NSString stringWithFormat:@"%d",rateValue];
                self.inviteTipLabel3.text = [LLSTR(@"101516") llReplaceWithArray:@[rate]];
            } else {
                self.inviteTipLabel1.text = nil;
                self.inviteTipLabel2.text = nil;
                self.inviteTipLabel3.text = nil;
                if ([model.status isEqualToString:@"0"]) {
                    [self setBottomLineTwo];
                    self.inviteTipLabel2.text = LLSTR(@"101517");
                    self.inviteTipLabel3.text = LLSTR(@"101518");
                }
            }
        }
        
    } else if ([model.status isEqualToString:@"2"] && ![model.rewardStatus isEqualToString:@"4"]) {
        [self.openButton setTitle:@"領" forState:UIControlStateNormal];
        self.openButton.hidden = NO;
    } else if ([model.status isEqualToString:@"3"]) {
        self.openButton.hidden = YES;
        self.inviteTipLabel2.hidden = NO;
        self.inviteTipLabel3.hidden = NO;
        self.inviteTipLabel2.text = LLSTR(@"301210");
        if (model.rewardType == 107) {
            [self setBottomLineTwo];
            self.inviteTipLabel2.text = LLSTR(@"101519");
            self.inviteTipLabel3.text = LLSTR(@"101520");
        }
        if ((model.rewardType == 103 || model.rewardType == 106) && ![model.subType isEqualToString:@"2"] && [model.rewardStatus isEqualToString:@"1"] && model.inviteCode.length > 0) {
            [self setBottomLineTwo];
            int rateValue = roundf([self.currentModel.rate floatValue] * 100);
            NSString *rate = [NSString stringWithFormat:@"%d",rateValue];
            self.inviteTipLabel2.text = nil;
            if (model.rewardType == 106) {
                self.inviteTipLabel2.text = nil;
            }
//            self.inviteTipLabel3.text = [NSString stringWithFormat:@"还可分得每份红包的%@%@",rate,@"%"];
            self.inviteTipLabel3.text = [LLSTR(@"101512") llReplaceWithArray:@[rate]];
            if (model.rewardType == 103 && [model.subType isEqualToString:@"0"]) {
                if (model.isOwner) {
                    [self setBottomLineTwo];
                    self.inviteTipLabel2.text = LLSTR(@"101521");
                    self.inviteTipLabel3.text = LLSTR(@"101522");
                } else {
                    self.inviteTipLabel2.text = LLSTR(@"301210");
                    self.inviteTipLabel3.text = nil;
                    
                }
            }
        }
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backIV).offset(20);
            make.right.equalTo(self.backIV).offset(-20);
            make.centerY.equalTo(self.backIV);
            make.height.equalTo(@40);
        }];
        self.titleAssistantLabel.text = LLSTR(@"101507");
        self.titleLabel.font = Font(36);
        self.titleLabel.text = [model.drawAmount accuracyCheckWithFormatterString:model.bit auotCheck:YES];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineSpacing:1.0];
        self.titleAssistantLabel1.text = self.currentModel.dSymbol;
        
//        if (model.rewardType == 107) {
//            if (model.isOwner) {
//                self.openButton.hidden = YES;
//                [self setBottomLineTwo];
//                self.inviteTipLabel2.text = LLSTR(@"101515");
//                int rateValue = roundf([self.currentModel.rate floatValue] * 100);
//                NSString *rate = [NSString stringWithFormat:@"%d",rateValue];
//                self.inviteTipLabel3.text = [LLSTR(@"101516") llReplaceWithArray:@[rate]];
//            } else {
//                self.inviteTipLabel1.text = nil;
//                self.inviteTipLabel2.text = nil;
//                self.inviteTipLabel3.text = nil;
//            }
//        }
        if (model.rewardType == 107) {
            self.shareView.hidden = NO;
        }
    } else if ([model.rewardStatus isEqualToString:@"4"]) {
        self.openButton.hidden = YES;
        self.inviteTipLabel2.hidden = NO;
        self.inviteTipLabel2.text = LLSTR(@"301208");
        if (model.rewardType != 107) {
            self.shareView.hidden = YES;
        }
    } else if ([model.rewardStatus isEqualToString:@"3"] || [model.rewardStatus isEqualToString:@"2"]){
        self.openButton.hidden = YES;
        self.inviteTipLabel2.hidden = NO;
        if (model.rewardType != 107) {
            self.shareView.hidden = YES;
        }
        self.inviteTipLabel2.text = LLSTR(@"301209");
    } else if ([model.rewardStatus isEqualToString:@"5"]){
        self.openButton.hidden = YES;
        self.inviteTipLabel2.hidden = NO;
        self.inviteTipLabel2.text = LLSTR(@"101523");
        self.shareView.hidden = YES;
    } else if ([model.rewardStatus isEqualToString:@"6"]){
        self.openButton.hidden = YES;
        self.inviteTipLabel2.hidden = NO;
        self.inviteTipLabel2.text = LLSTR(@"101524");
        self.shareView.hidden = YES;
    }
    //黑名单不可抢
    else if ([model.status isEqualToString:@"5"] || [model.status isEqualToString:@"7"]) {
        self.openButton.hidden = YES;
        [self setBottomLineTwo];
        self.inviteTipLabel2.hidden = NO;
        self.inviteTipLabel2.text = [LLSTR(@"101525") llReplaceWithArray:@[model.groupName]];
        self.inviteTipLabel3.text = LLSTR(@"101509");
        self.shareView.hidden = YES;
    }else if ([model.status isEqualToString:@"8"]){
        self.openButton.hidden = YES;
//        self.inviteTipLabel2.hidden = NO;
//        self.inviteTipLabel2.text = @"该群已开启「群聊邀请确认」，不可抢红包入群领取";
//        self.shareView.hidden = YES;
        [self setBottomLineTwo];
        self.inviteTipLabel2.hidden = NO;
        self.inviteTipLabel2.text = LLSTR(@"101526");
        self.inviteTipLabel3.text = LLSTR(@"101527");
        self.shareView.hidden = YES;
    } else if ([model.status isEqualToString:@"9"]){
        self.openButton.hidden = YES;
        self.inviteTipLabel2.hidden = NO;
        self.inviteTipLabel2.text = LLSTR(@"101423");
        self.shareView.hidden = YES;
    }
    
    if (model.receiveUid.length > 0 && ![model.receiveUid isEqualToString:[BiChatGlobal sharedManager].uid]) {
        self.openButton.hidden = YES;
        [self setBottomLineTwo];
        self.inviteTipLabel2.text = model.receiveNickName;
        self.inviteTipLabel3.text = LLSTR(@"101460");
    }
    
    //可分享的红包抢的按钮改为“转”
    if (!self.shareView.hidden && ![model.status isEqualToString:@"1"] && [model.subType integerValue] == 1) {
        self.openButton.hidden = NO;
        [self.openButton setTitle:@"转" forState:UIControlStateNormal];
        self.openButton.backgroundColor = RGB(0xa4856f);
        [self.openButton removeTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];
        [self.openButton removeTarget:self action:@selector(doRob) forControlEvents:UIControlEventTouchUpInside];
        [self.openButton addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    
}
//将下面的提示改为2行的样式
- (void)setBottomLineTwo {
    self.inviteTipLabel2.hidden = NO;
    [self.inviteTipLabel2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.bottom.equalTo(self.backIV.mas_bottom).offset(-70);
        make.height.equalTo(@20);
    }];
    self.inviteTipLabel1.hidden = YES;
    self.inviteTipLabel3.hidden = NO;
}

//关闭
- (void)doClose {
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        self.openButton.layer.cornerRadius = 0;
        [self.openButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.backIV);
            make.width.height.equalTo(@0);
        }];
        [self.backIV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@0);
            make.centerY.centerX.equalTo(self);
        }];
        [self.backIV layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.CloseBlock) {
            self.CloseBlock();
        }
    }];
}
//投诉
- (void)doComplain {
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        self.openButton.layer.cornerRadius = 0;
        [self.openButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.backIV);
            make.width.height.equalTo(@0);
        }];
        [self.backIV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@0);
            make.centerY.centerX.equalTo(self);
        }];
        [self.backIV layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.ComplainBlock) {
            self.ComplainBlock();
        }
    }];
}


- (void)setRobbedCount:(NSString *)robbedCount {
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.centerY.equalTo(self.backIV);
        make.height.equalTo(@40);
    }];
    if ([self.currentModel.status isEqualToString:@"3"]) {
        self.titleAssistantLabel.text = LLSTR(@"101507");
    } else {
        self.titleAssistantLabel.text = LLSTR(@"101506");
    }
    self.titleLabel.font = Font(36);
    self.titleLabel.text = robbedCount;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineSpacing:1.0];
    self.titleAssistantLabel1.text = self.currentModel.dSymbol;
    
    [self.openButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self);
//        make.width.equalTo(@150);
        make.bottom.equalTo(self.backIV).offset(-50);
        make.height.equalTo(@40);
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
    }];
    self.openButton.titleLabel.font = Font(16);
    if (self.currentModel.isPublic) {
//        [self.openButton setTitle:@"关注公众号领取" forState:UIControlStateNormal];
        [self.openButton setTitle:[LLSTR(@"101528") llReplaceWithArray:@[self.currentModel.groupName]] forState:UIControlStateNormal];
        [self.openButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        self.openButton.backgroundColor = RGB(0xddbc87);
    } else {
//        [self.openButton setTitle:@"进红包始发群领取" forState:UIControlStateNormal];
        [self.openButton setTitle:[LLSTR(@"101529") llReplaceWithArray:@[self.currentModel.groupName]] forState:UIControlStateNormal];
        [self.openButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        self.openButton.backgroundColor = RGB(0xddbc87);
    }
    self.openButton.layer.cornerRadius = 5;
    self.openButton.layer.masksToBounds = YES;
    [self.openButton removeTarget:self action:@selector(doRob) forControlEvents:UIControlEventTouchUpInside];
    [self.openButton addTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setRobbedTitle:(NSString *)robbedTitle {
    self.openButton.hidden = YES;
//    self.inviteTipLabel1.hidden = NO;
    self.inviteTipLabel2.hidden = NO;
    self.inviteTipLabel3.hidden = NO;
    [self.inviteTipLabel2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.bottom.equalTo(self.backIV.mas_bottom).offset(-70);
        make.height.equalTo(@20);
    }];
    int rateValue = roundf([self.currentModel.rate floatValue] * 100);
    NSString *rate = [NSString stringWithFormat:@"%d",rateValue];
    self.inviteTipLabel2.text = nil;
    self.inviteTipLabel3.text = [LLSTR(@"101512") llReplaceWithArray:@[rate]];
}

- (void)doChat {
    if (self.ChatBlock) {
        self.ChatBlock();
    }
}

//显示领取详情
- (void)showDetail {
    if (self.ShowDetailBlock) {
        self.ShowDetailBlock(self.currentModel);
    }
}
//抢红包
- (void)doRob {
    if (self.RobBlock) {
        self.RobBlock();
        [self startAnimation];
    }
}

- (void)startAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        self.openButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            self.openButton.transform = CGAffineTransformScale(self.openButton.transform,-1.0, 1.0);
        } completion:^(BOOL finished) {
            if (!self.doStop) {
                [self startAnimation];
            }
        }];
    }];
}

- (void)stopAnimation {
    self.doStop = YES;
    [_openButton.layer removeAllAnimations];
}

@end
