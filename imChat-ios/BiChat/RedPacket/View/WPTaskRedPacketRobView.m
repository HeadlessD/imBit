//
//  WPTaskRedPacketRobView.m
//  BiChat
//
//  Created by iMac on 2018/12/7.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPTaskRedPacketRobView.h"
#import <QuartzCore/QuartzCore.h>
#import "WPRedpacketShareButton.h"


#define kBtnTag 999
#define kLabelTag 9999

@implementation WPTaskRedPacketRobView

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
    
    self.backIV = [[UIImageView alloc]init];
    [self addSubview:self.backIV];
    self.backIV.image = Image(@"redPacket_body");
    self.backIV.userInteractionEnabled = YES;
    UITapGestureRecognizer *emptyGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(emptyMethod)];
    [self.backIV addGestureRecognizer:emptyGes];
    self.backIV.layer.cornerRadius = 5;
    self.backIV.layer.masksToBounds = YES;
    self.backIV.userInteractionEnabled = YES;
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backIV addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.backIV);
        make.width.height.equalTo(@50);
    }];
    [self.closeButton addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton setImage:Image(@"close") forState:UIControlStateNormal];
    self.closeButton.alpha = 0.3;
    
    
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
    self.titleLabel.font = Font(36);
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
        make.top.equalTo(self.titleLabel.mas_bottom).offset(-2);
        make.height.equalTo(@20);
    }];
    self.titleAssistantLabel1.textAlignment = NSTextAlignmentCenter;
    self.titleAssistantLabel1.numberOfLines = 1;
    self.titleAssistantLabel1.font = Font(14);
    self.titleAssistantLabel1.textColor = RGB(0xffe2b3);
    
    self.openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backIV addSubview:self.openButton];
    [self.openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backIV);
        make.bottom.equalTo(self.backIV).offset(-80);
        make.width.height.equalTo(@80);
    }];
    
    self.openButton.layer.cornerRadius = 40;
    self.openButton.backgroundColor = RGB(0xddbc87);
    self.openButton.layer.masksToBounds = YES;
    [self.openButton setTitle:@"領" forState:UIControlStateNormal];
    [self.openButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.openButton.titleLabel.font = Font(35);
    [self.openButton addTarget:self action:@selector(doRob) forControlEvents:UIControlEventTouchUpInside];
    
//    self.openLabel = [[UILabel alloc]init];
//    [self.backIV addSubview:self.openLabel];
//    [self.openLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.backIV).offset(10);
//        make.right.equalTo(self.backIV).offset(-10);
//        make.bottom.top.equalTo(self.openButton);
//    }];
//    self.openLabel.textAlignment = NSTextAlignmentCenter;
//    self.openLabel.numberOfLines = 3;
//    self.openLabel.font = Font(14);
//    self.openLabel.textColor = RGB(0xffe2b3);
    
    self.showDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backIV addSubview:self.showDetailButton];
    [self.showDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.backIV);
    }];
    CGRect rect = [LLSTR(@"101473") boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil];
    self.showDetailButton.titleLabel.font = Font(14);
    self.showDetailButton.tag = 99;
    [self.showDetailButton setTitleColor:RGB(0xffe2b3) forState:UIControlStateNormal];
    [self.showDetailButton setImage:Image(@"redPacket_showRedDetail") forState:UIControlStateNormal];
    [self.showDetailButton setTitle:LLSTR(@"101473") forState:UIControlStateNormal];
    [self.showDetailButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -3.5, 0, 3.5)];
    [self.showDetailButton setImageEdgeInsets:UIEdgeInsetsMake(0, rect.size.width + 8, 0, -rect.size.width - 8)];
    [self.showDetailButton addTarget:self action:@selector(showDetail) forControlEvents:UIControlEventTouchUpInside];
    self.showDetailButton.hidden = YES;
    
    self.bottomLabel = [[UILabel alloc]init];
    [self.backIV addSubview:self.bottomLabel];
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.bottom.equalTo(self.backIV).offset(-10);
        make.height.equalTo(@20);
    }];
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.font = Font(14);
    self.bottomLabel.textColor = RGB(0xffe2b3);
    self.bottomLabel.text = LLSTR(@"101904");
    
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

- (void)fillData:(NSDictionary *)data {
    self.dict = data;
    self.nameLabel.text = [data objectForKey:@"nickName"];
    self.tipLabel.text = LLSTR(@"101905");
    if ([[data objectForKey:@"coinType"] isEqualToString:@"POINT"]) {
        self.tipLabel.text = LLSTR(@"101906");
        self.bottomLabel.hidden = YES;
    }
    if ([[data objectForKey:@"isTask"]boolValue]) {
        self.tipLabel.text = [data objectForKey:@"name"];
    }
    [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[data objectForKey:@"avatar"]] title:[data objectForKey:@"coinType"]size:CGSizeMake(50, 50) placeHolde:nil color:RGB(0xddbc87) textColor:[UIColor blackColor]];
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:[self.dict objectForKey:@"coinType"]];
    self.titleLabel.text = [[NSString stringWithFormat:@"%@",[self.dict objectForKey:@"value"]] accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%@",[coinInfo objectForKey:@"bit"]] auotCheck:YES];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backIV).offset(20);
        make.right.equalTo(self.backIV).offset(-20);
        make.centerY.equalTo(self.backIV);
        make.height.equalTo(@40);
    }];
    self.titleAssistantLabel1.text = [coinInfo objectForKey:@"dSymbol"];
    if ([[data objectForKey:@"status"] integerValue] == 3) {
        [self setFinish];
    }
    
}

- (void)setFinish {
    self.bottomLabel.hidden = YES;
//    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:[self.dict objectForKey:@"coinType"]];
//    self.titleAssistantLabel1.text = [coinInfo objectForKey:@"dSymbol"];
//    self.tipLabel.text = LLSTR(@"101428");
//    if ([[self.dict objectForKey:@"coinType"] isEqualToString:@"POINT"]) {
//        self.tipLabel.text = LLSTR(@"101428");
//    }
    self.openButton.hidden = YES;
    self.titleLabel.font = Font(36);
    self.showDetailButton.hidden = NO;
    NSString *shareString = [self.dict objectForKey:@"shareUrl"];
    if ([[self.dict objectForKey:@"isTask"]boolValue] && shareString.length > 0 && ![[self.dict objectForKey:@"shareUrl"] isEqualToString:@"(null)"]) {
        self.tipLabel.text = [LLSTR(@"101909") llReplaceWithArray:@[[self.dict objectForKey:@"name"]]];
        
        NSArray *titleArray = @[LLSTR(@"102207"),LLSTR(@"102206")];
        NSArray *imageArray = @[Image(@"redpacket_share_timeLine"),Image(@"redpacket_share_weChat")];
        UIButton *lastBtn = nil;
        self.shareView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
        [self addSubview:self.shareView];
        
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
        
        UILabel *tipLabel = [[UILabel alloc]init];
        [self.backIV addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backIV).offset(30);
            make.right.equalTo(self.backIV).offset(-30);
//            make.top.bottom.equalTo(self.openButton);
            make.bottom.equalTo(self.backIV).offset(-30);
        }];
        tipLabel.textColor = RGB(0xffe2b3);
        tipLabel.numberOfLines = 2;
        tipLabel.text = [LLSTR(@"101910") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[[BiChatGlobal sharedManager].systemConfig objectForKey:@"inviteNewFriendPoint"]]]];
        tipLabel.font = Font(14);
        tipLabel.textAlignment = NSTextAlignmentCenter;
        self.openButton.hidden = NO;
        [self.openButton setTitle:@"转" forState:UIControlStateNormal];
        self.openButton.backgroundColor = RGB(0xa4856f);
        [self.openButton removeTarget:self action:@selector(doRob) forControlEvents:UIControlEventTouchUpInside];
        [self.openButton addTarget:self action:@selector(shareToWechat) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.openButton.hidden = YES;
    }
}

//分享
- (void)doShare:(UIButton *)button {
    if (self.ShareBlock) {
        self.ShareBlock(button.tag - kBtnTag);
    }
}

- (void)shareToWechat {
    if (self.ShareBlock) {
        self.ShareBlock(1);
    }
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

//显示领取详情
- (void)showDetail {
    if (self.ShowDetailBlock) {
        self.ShowDetailBlock();
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
