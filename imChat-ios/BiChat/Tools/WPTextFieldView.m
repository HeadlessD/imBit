//
//  WPTextFieldView.m
//  BiChat
//
//  Created by iMac on 2018/6/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPTextFieldView.h"

@implementation WPTextFieldView

- (id)init {
    self = [super init];
    self.tf = [[UITextField alloc]init];
    [self addSubview:self.tf];
    self.countlabel = [[UILabel alloc]init];
    [self addSubview:self.countlabel];
    self.lineV = [[UIView alloc]init];
    [self addSubview:self.lineV];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.tf = [[UITextField alloc]init];
    [self addSubview:self.tf];
    self.countlabel = [[UILabel alloc]init];
    [self addSubview:self.countlabel];
    self.lineV = [[UIView alloc]init];
    [self addSubview:self.lineV];
    return self;
}

- (void)setLimitCount:(NSInteger)limitCount {
    _limitCount = limitCount;
    [self.countlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@18);
    }];
    self.countlabel.textAlignment = NSTextAlignmentRight;
    self.countlabel.textColor = THEME_GRAY;
    self.countlabel.font = Font(12);
    
    [self.lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.countlabel);
        make.height.equalTo(@0.5);
    }];
    self.lineV.backgroundColor = RGB(0xdddddd);
    
    [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.countlabel);
        make.top.equalTo(self);
        make.bottom.equalTo(self.countlabel.mas_top);
    }];
    if (self.font) {
        self.tf.font = self.font;
    }
    [self.tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.countlabel.text = [NSString stringWithFormat:@"0/%ld",self.limitCount];
    [self textFieldDidChange:self.tf];
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSString *toBeString = textField.text;
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if ([textField.text getLength] > self.limitCount) {
                textField.text = [toBeString substringToIndex:textField.text.length - 1];
                [self textFieldDidChange:textField];
            }
        }
    }
    else{
        if ([textField.text getLength] > self.limitCount) {
            textField.text = [toBeString substringToIndex:textField.text.length - 1];
            [self textFieldDidChange:textField];
        }
    }
    self.countlabel.text = [NSString stringWithFormat:@"%ld/%ld",[textField.text getLength],self.limitCount];
    if (self.EditBlock) {
        self.EditBlock(textField);
    }
}

- (void)setText:(NSString *)text {
    self.tf.text = text;
    self.countlabel.text = [NSString stringWithFormat:@"%ld/%ld",[text getLength],self.limitCount];
}

@end
