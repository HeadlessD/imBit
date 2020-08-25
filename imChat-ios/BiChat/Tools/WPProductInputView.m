//
//  WPProductInputView.m
//  BiChat
//
//  Created by iMac on 2018/12/13.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPProductInputView.h"
#define kInputTag 999

@implementation WPProductInputView

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

- (void)setCoinImag:(NSString *)image count:(NSString *)count coinName:(NSString *)coinName payTo:(NSString *)payTo payDesc:(NSString *)payDesc wallet:(NSInteger)wallet {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.backView = [[UIView alloc]init];
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.centerY.equalTo(self);
        make.height.equalTo(@260);
    }];
    self.backView.backgroundColor = [UIColor whiteColor];
    self.backView.layer.cornerRadius = 5;
    self.backView.layer.masksToBounds = YES;
    
    UIView *grayView = [[UIView alloc]init];
    [self.backView addSubview:grayView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.backView);
        make.height.equalTo(@40);
    }];
    grayView.backgroundColor = RGB(0xe46e51);
    //    e46e51
    
    self.titleTF = [[UITextField alloc]init];
    [self.backView addSubview:self.titleTF];
    [self.titleTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.backView);
        make.height.equalTo(@40);
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
        make.width.height.equalTo(@40);
    }];
    [self.closeBtn setImage:Image(@"close") forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
    
    self.aimLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.aimLabel];
    [self.aimLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backView);
        make.top.equalTo(self.titleTF.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    self.aimLabel.font = Font(16);
    self.aimLabel.textAlignment = NSTextAlignmentCenter;
    
    self.productLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.productLabel];
    [self.productLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backView);
        make.top.equalTo(self.aimLabel.mas_bottom).offset(3);
        make.height.equalTo(@20);
    }];
    self.productLabel.textColor = [UIColor grayColor];
    self.productLabel.font = Font(14);
    self.productLabel.textAlignment = NSTextAlignmentCenter;
    self.productLabel.text = payDesc;
    
    self.coinLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.coinLabel];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.productLabel.mas_bottom).offset(15);
        make.left.right.equalTo(self.backView);
        make.height.equalTo(@40);
    }];
    self.coinLabel.font = Font(12);
    self.coinLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *lineV = [[UIView alloc]init];
    [self.backView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(20);
        make.right.equalTo(self.backView).offset(-20);
        make.height.equalTo(@0.5);
        make.top.equalTo(self.coinLabel.mas_bottom).offset(5);
    }];
    lineV.backgroundColor = RGB(0xddddddd);
    
    self.walletIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.walletIV];
    [self.walletIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineV.mas_bottom);
        make.width.equalTo(@20);
        make.left.equalTo(self.backView).offset(22);
        make.bottom.equalTo(self.backView.mas_bottom).offset(-65);
    }];
    self.walletIV.contentMode = UIViewContentModeCenter;
    
    self.walletLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.walletLabel];
    [self.walletLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.coinLabel.mas_bottom).offset(5);
        make.centerY.equalTo(self.walletIV);
        make.left.equalTo(self.walletIV.mas_right).offset(10);
        make.right.equalTo(self.backView).offset(-15);
        make.height.equalTo(@15);
    }];
    self.walletLabel.font = Font(14);
    self.walletLabel.textColor = [UIColor grayColor];
    self.walletLabel.textAlignment = NSTextAlignmentLeft;
    if (wallet == 1) {
        self.walletLabel.text = LLSTR(@"103016");
        self.walletIV.image = Image(@"bussinessWallet");
    } else {
        self.walletLabel.text = LLSTR(@"103000");
        self.walletIV.image = Image(@"my_wallet");
    }
    
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
    
    [self.leftIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,image]]];
    self.aimLabel.text = payTo;
    self.coinLabel.text = payDesc;
    
    NSString *coinString = [NSString stringWithFormat:@"%@ %@",count,coinName];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:coinString];
    [attStr addAttribute:NSFontAttributeName value:Font(30) range:NSMakeRange(0, count.length)];
    [attStr addAttribute:NSFontAttributeName value:Font(14) range:NSMakeRange(count.length + 1, coinName.length)];
    self.coinLabel.attributedText = attStr;
    [self.hideTF becomeFirstResponder];
}


- (void)doClose {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length >= 6) {
        return NO;
    }
    if ([string isInt] || string.length == 0) {
        NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = result;
        [self fillContent];
    }
    return NO;
}

@end
