//
//  WPRedPacketPayWorkdInputView.m
//  BiChat
//
//  Created by 张迅 on 2018/5/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketPayWorkdInputView.h"

#define kInputTag 999

@implementation WPRedPacketPayWorkdInputView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init {
    self = [super init];
    return self;
}
//重新设置内容
- (void)fillContent {
    for (int i = 0; i < 6; i++) {
        UILabel *label = (UILabel *)[self.backView viewWithTag:kInputTag + i];
        for (UIView *view in label.subviews) {
            [view removeFromSuperview];
        }
    }
    NSInteger count = self.hideTF.text.length;
    for (int i = 0; i < count; i++) {
        UILabel *label = (UILabel *)[self.backView viewWithTag:kInputTag + i];
//        label.text = @"*";
        UIView *view = [[UIView alloc]init];
        [label addSubview:view];
        if (label) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.centerY.equalTo(label);
                make.width.height.equalTo(@14);
            }];
        }
        view.layer.cornerRadius = 7;
        view.backgroundColor = [UIColor blackColor];
    }
    if (count == 6) {
        [self performSelector:@selector(doBlock) withObject:nil afterDelay:0.3];
    }
}

- (void)doBlock {
    if (self.passwordInputBlock) {
        self.passwordInputBlock([self.hideTF.text substringWithRange:NSMakeRange(0, 6)]);
    }
}

- (void)setCoinImag:(NSString *)image count:(NSString *)count coinName:(NSString *)name {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    self.backView = [[UIView alloc]init];
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.centerY.equalTo(self);
        make.height.equalTo(@200);
    }];
    self.backView.backgroundColor = [UIColor whiteColor];
    self.backView.layer.cornerRadius = 5;
    self.backView.layer.masksToBounds = YES;
    
    UIView *grayView = [[UIView alloc]init];
    [self.backView addSubview:grayView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.backView);
        make.height.equalTo(@50);
    }];
    grayView.backgroundColor = RGB(0xe46e51);
//    e46e51
    
    self.titleTF = [[UITextField alloc]init];
    [self.backView addSubview:self.titleTF];
    [self.titleTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.backView);
        make.height.equalTo(@50);
        make.right.equalTo(self.backView).offset(-50);
    }];
    self.titleTF.userInteractionEnabled = NO;
    self.leftIV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 20, 20)];
    self.leftIV.contentMode = UIViewContentModeScaleAspectFit;
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 45, 50)];
    [leftView addSubview:self.leftIV];
    self.titleTF.leftView = leftView;
    self.titleTF.leftViewMode = UITextFieldViewModeAlways;
    self.titleTF.text = LLSTR(@"103011");
    self.titleTF.font = Font(16);
    self.titleTF.textColor = RGB(0xffe2b3);
//    self.titleTF.textAlignment = NSTextAlignmentCenter;
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backView addSubview:self.closeBtn];
    self.closeBtn.alpha = 0.2;
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self.backView);
        make.width.height.equalTo(@50);
    }];
    [self.closeBtn setImage:Image(@"close") forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
    
//    UIView *lineV = [[UIView alloc]init];
//    [self.backView addSubview:lineV];
//    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self.titleTF);
//        make.height.equalTo(@1);
//    }];
//    lineV.backgroundColor = RGB(0x999999);
    
    self.countLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backView);
        make.top.equalTo(self.titleTF.mas_bottom).offset(20);
        make.height.equalTo(@30);
    }];
    self.countLabel.font = Font(25);
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    
    self.coinLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.coinLabel];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.countLabel.mas_bottom);
        make.left.right.equalTo(self.backView);
        make.height.equalTo(@15);
    }];
    self.coinLabel.font = Font(12);
    self.coinLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *whiteLineV = [[UIView alloc]init];
    [self.backView addSubview:whiteLineV];
    [whiteLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(20);
        make.right.equalTo(self.backView).offset(-20);
        make.bottom.equalTo(self.backView).offset(-20);
        make.height.equalTo(@45);
    }];
    whiteLineV.layer.borderColor = THEME_GRAY.CGColor;
    whiteLineV.layer.borderWidth = 0.5;
    float width = (ScreenWidth - 40 - 60) / 6.0;
    for (int i = 0; i < 6; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.tag = kInputTag + i;
        [self.backView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(whiteLineV).offset(width * i);
            make.top.bottom.equalTo(whiteLineV);
            make.width.equalTo(@(width));
        }];
        label.textAlignment = NSTextAlignmentCenter;
        if (i != 0) {
            UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0.5, 45)];
            lineV.backgroundColor = THEME_GRAY;
            [whiteLineV addSubview:lineV];
            [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(whiteLineV).offset(width * i);
                make.top.bottom.equalTo(whiteLineV);
                make.width.equalTo(@0.5);
            }];
        }
    }
    self.hideTF = [[UITextField alloc]init];
    [self.backView addSubview:self.hideTF];
    self.hideTF.hidden = YES;
    self.hideTF.delegate = self;
    self.hideTF.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.leftIV sd_setImageWithURL:[NSURL URLWithString:image]];
    self.countLabel.text = count;
    self.coinLabel.text = name;
    [self.hideTF becomeFirstResponder];
}

- (void)doClose {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.hasFinish) {
        return NO;
    }
    if (result.length > 6) {
        self.hasFinish = YES;
        return NO;
    }
    if ([string isInt] || string.length == 0) {
        [self performSelector:@selector(fillContent) withObject:nil afterDelay:0.01];
        return YES;
    }
    return NO;
}

@end
