//
//  WPTextViewView.m
//  BiChat
//
//  Created by worm_kc on 2019/1/7.
//  Copyright © 2019年 worm_kc. All rights reserved.
//

#import "WPTextViewView.h"

@implementation WPTextViewView

- (id)init {
    self = [super init];
    self.tf = [[UIPlaceHolderTextView alloc]init];
    self.tf.delegate = self;
    [self addSubview:self.tf];
    self.countlabel = [[UILabel alloc]init];
    [self addSubview:self.countlabel];
    self.lineV = [[UIView alloc]init];
    [self addSubview:self.lineV];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.tf = [[UIPlaceHolderTextView alloc]init];
    self.tf.delegate = self;
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
    self.countlabel.text = [NSString stringWithFormat:@"0/%ld",self.limitCount];
    [self textViewDidChange:self.tf];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *toBeString = textView.text;
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if ([textView.text getLength] > self.limitCount) {
                textView.text = [toBeString substringToIndex:textView.text.length - 1];
                [self textViewDidChange:textView];
            }
        }
    }
    else{
        if ([textView.text getLength] > self.limitCount) {
            textView.text = [toBeString substringToIndex:textView.text.length - 1];
            [self textViewDidChange:textView];
        }
    }
    self.countlabel.text = [NSString stringWithFormat:@"%ld/%ld",[textView.text getLength],self.limitCount];
    if (self.EditBlock) {
        self.EditBlock(textView);
    }
}

- (void)setText:(NSString *)text {
    self.tf.text = text;
}

@end
