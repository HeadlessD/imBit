//
//  WPShareView.m
//  BiChat
//
//  Created by 张迅 on 2018/5/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPShareView.h"

#define cancelTag       999
#define sendTag         1000

@implementation WPShareView 

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backView = [[UIView alloc]init];
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
    }];
    self.backView.backgroundColor = [UIColor whiteColor];
    self.backView.layer.cornerRadius = 5;
    self.backView.layer.masksToBounds = YES;
    
    self.sendLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.sendLabel];
    [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.backView).offset(15);
        make.right.equalTo(self.backView).offset(-20);
        make.height.equalTo(@20);
    }];
    self.sendLabel.font = BoldFont(16);
    self.sendLabel.text = LLSTR(@"101026");
    
    self.headIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.headIV];
    self.headIV.layer.cornerRadius = 2;
    self.headIV.layer.masksToBounds = YES;
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(15);
        make.top.equalTo(self.sendLabel.mas_bottom).offset(7);
        make.width.height.equalTo(@40);
    }];
    self.headIV.layer.cornerRadius = 20;
    self.headIV.layer.masksToBounds = YES;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.top.bottom.equalTo(self.headIV);
        make.right.equalTo(self.backView).offset(-20);
    }];
    self.titleLabel.font = Font(14);
    
    UIView *lineV1 = [[UIView alloc]init];
    [self.backView addSubview:lineV1];
    [lineV1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(15);
        make.top.equalTo(self.headIV.mas_bottom).offset(12);
        make.height.equalTo(@1);
        make.right.equalTo(self.backView).offset(-15);
    }];
    lineV1.backgroundColor = RGB(0xe5e5e5);
    
    self.contentLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineV1.mas_bottom);
        make.left.equalTo(lineV1);
        make.height.equalTo(@55);
        make.right.equalTo(lineV1);
    }];
    self.contentLabel.font = Font(14);
    self.contentLabel.textColor = [UIColor grayColor];
    self.contentLabel.numberOfLines = 2;
    
    UIImageView *arrowIV = [[UIImageView alloc]init];
    [self.backView addSubview:arrowIV];
    [arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentLabel);
        make.right.equalTo(self.contentLabel.mas_right).offset(-5);
        make.width.equalTo(@20);
    }];
    arrowIV.contentMode = UIViewContentModeRight;
    
    UIView *lineV4 = [[UIView alloc]init];
    [self.backView addSubview:lineV4];
    [lineV4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(15);
        make.top.equalTo(self.contentLabel.mas_bottom);
        make.height.equalTo(@1);
        make.right.equalTo(self.backView).offset(-15);
    }];
    lineV4.backgroundColor = RGB(0xe5e5e5);
    
    self.messageTV = [[UITextView alloc]init];
    [self.backView addSubview:self.messageTV];
    [self.messageTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lineV1);
        make.top.equalTo(self.contentLabel.mas_bottom).offset(5);
        make.height.equalTo(@50);
    }];
    self.messageTV.font = Font(14);
    self.messageTV.textColor = THEME_GRAY;
    self.messageTV.text = LLSTR(@"101024");
    self.messageTV.delegate = self;
    
    UIView *lineV2 = [[UIView alloc]init];
    [self.backView addSubview:lineV2];
    [lineV2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backView);
        make.top.equalTo(self.messageTV.mas_bottom).offset(15);
        make.height.equalTo(@1);
    }];
    lineV2.backgroundColor = RGB(0xe5e5e5);
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backView addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView);
        make.right.equalTo(self.backView.mas_centerX);
        make.top.equalTo(lineV2.mas_bottom);
        make.height.equalTo(@50);
    }];
    [leftBtn setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = Font(16);
    leftBtn.tag = cancelTag;
    [leftBtn addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView.mas_centerX);
        make.right.equalTo(self.backView);
        make.top.equalTo(lineV2.mas_bottom);
        make.height.equalTo(@50);
    }];
    [rightBtn setTitle:LLSTR(@"101001") forState:UIControlStateNormal];
    [rightBtn setTitleColor:LightBlue forState:UIControlStateNormal];
    rightBtn.titleLabel.font = Font(16);
    rightBtn.tag = sendTag;
    [rightBtn addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *lineV3 = [[UIView alloc]init];
    [self.backView addSubview:lineV3];
    [lineV3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(rightBtn);
        make.width.equalTo(@1);
    }];
    lineV3.backgroundColor = RGB(0xe5e5e5);
    
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(rightBtn);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    return self;
}
//点击发送、取消
- (void)choose:(UIButton *)button {
    [self.messageTV resignFirstResponder];
    if (button.tag == cancelTag) {
        if (self.ChooseItemBlock) {
            self.ChooseItemBlock(0,self.messageTV.text);
        }
    } else {
        if (self.ChooseItemBlock) {
            if (self.hasChange) {
                self.ChooseItemBlock(1,self.messageTV.text);
            } else {
                self.ChooseItemBlock(1, nil);
            }
        }
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.hasChange) {
        self.messageTV.text = nil;
        self.messageTV.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.messageTV.text.length == 0) {
        self.hasChange = NO;
        self.messageTV.text = LLSTR(@"101024");
        self.messageTV.textColor = THEME_GRAY;
    } else {
        self.hasChange = YES;
    }
}

- (void)setSendString:(NSString *)sendString {
    _sendString = sendString;
    self.sendLabel.text = sendString;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setContent:(NSString *)content {
    self.contentLabel.text = content;
}

- (void)setAvatar:(NSString *)avatar {
    [self.headIV setImageWithURL:avatar title:self.title size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
}

- (void)keyboardWillShow:(NSNotification *)noti{
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [self layoutIfNeeded];
    CGFloat viewHeight = [self.backView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [UIView animateWithDuration:0.16 animations:^{
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_top).offset(ScreenHeight - keyboardHeight - viewHeight / 2.0);
        }];
    }];
    
    
}

- (void)keyboardWillHide:(NSNotification *)noti{
    [UIView animateWithDuration:0.16 animations:^{
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
        }];
    }];
}



@end
