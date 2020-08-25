//
//  WPTipsView.m
//  BiChat
//
//  Created by iMac on 2019/3/27.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPTipsView.h"

#define kTipTag 135
@implementation WPTipsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//title 16 content 14
+ (void)showTipWithContent:(NSString *)content {
    UIView *view = [UIView new];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(view.superview);
    }];
    view.tag = kTipTag;
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 3;
    
    CGRect rect = [content boundingRectWithSize:CGSizeMake(ScreenWidth - 60, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14),NSParagraphStyleAttributeName : paragraphStyle} context:nil];
    
    UIView *backView = [UIView new];
    [view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.right.equalTo(view).offset(-15);
        make.height.equalTo(@(rect.size.height + 125));
        make.centerY.equalTo(view);
    }];
    backView.backgroundColor = [UIColor whiteColor];
    
   
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:content];
    [mutableString addAttribute:NSFontAttributeName value:Font(14) range:NSMakeRange(0, content.length)];
    [mutableString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    [backView addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(15);
        make.right.equalTo(backView).offset(-15);
        make.top.equalTo(backView).offset(15);
        make.height.equalTo(@(rect.size.height + 20));
    }];
    contentLabel.numberOfLines = 0;
    contentLabel.attributedText = mutableString;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [backView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(60);
        make.right.equalTo(backView).offset(-60);
        make.bottom.equalTo(backView).offset(-30);
        make.height.equalTo(@40);
    }];
    button.backgroundColor = THEME_COLOR;
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = Font(16);
    [button setTitle:LLSTR(@"101023") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doRemove) forControlEvents:UIControlEventTouchUpInside];
}

+ (void)doRemove {
    for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
        if (view.tag == kTipTag) {
            [view removeFromSuperview];
            return;
        }
    }
}

@end
