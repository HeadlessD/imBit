//
//  WPRedPacketHeaderView.m
//  BiChat
//
//  Created by 张迅 on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketHeaderView.h"

@implementation WPRedPacketHeaderView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    
//    UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
//    view.image = Image(@"logo_wechat");
    
//    self.iconIV = [[UIImageView alloc]init];
//    [self.contentView addSubview:self.iconIV];
//    [self.iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(10);
////        make.top.equalTo(self.contentView).offset(3);
//        make.centerY.equalTo(self.contentView);
//        make.width.height.equalTo(@20);
//    }];
//    self.iconIV.contentMode = UIViewContentModeCenter;
//    self.iconIV.image = Image(@"logo_wechat");
    
    self.bindLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.bindLabel];
    [self.bindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.height.equalTo(@30);
        make.left.right.equalTo(self.contentView);
    }];
    self.bindLabel.userInteractionEnabled = YES;
    self.bindLabel.font = Font(14);
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusWeChat)];
    [self.bindLabel addGestureRecognizer:tapGes];
    self.bindLabel.textAlignment = NSTextAlignmentCenter;
    NSString *bindStr = [NSString stringWithFormat:@"%@  %@",LLSTR(@"102070"),LLSTR(@"102071")];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:bindStr];
    [attStr addAttribute:NSFontAttributeName value:Font(14) range:NSMakeRange(0, bindStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:THEME_GRAY range:NSMakeRange(0, bindStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:RGB(0x2f93fa) range:NSMakeRange(0, LLSTR(@"102070").length)];
    self.bindLabel.attributedText = attStr;
    
    return self;
}

- (void)focusWeChat {
    if (self.BindBlock) {
        self.BindBlock();
    }
}

- (void)setStatus:(NSInteger)status hasBind:(BOOL)bindStatus{
//    if (status == 0) {
////        self.titleLabel.textColor = RGB(0x999999);
//        self.leftLV.backgroundColor = RGB(0x999999);
//        self.rightLV.backgroundColor = RGB(0x999999);
//    }
//    else if (status == 1) {
//        self.titleLabel.text = @"可抢红包";
//        self.titleLabel.textColor = RGB(0x999999);
//        self.leftLV.backgroundColor = RGB(0x999999);
//        self.rightLV.backgroundColor = RGB(0x999999);
//    } else {
//        self.titleLabel.text = LLSTR(@"101509");
//        self.titleLabel.textColor = RGB(0x999999);
//        self.leftLV.backgroundColor = RGB(0x999999);
//        self.rightLV.backgroundColor = RGB(0x999999);
//    }
    
//    CGRect rect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil];
//    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@(rect.size.width + 5));
//        make.centerX.equalTo(self.contentView);
//        if (status == 0) {
//            if (bindStatus) {
//                make.bottom.equalTo(self.contentView);
//            } else {
//                make.bottom.equalTo(self.contentView).offset(-30);
//            }
//        } else {
//            make.bottom.equalTo(self.contentView);
//        }
//        make.height.equalTo(@20);
//    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
