//
//  WPBiddingOrderView.m
//  BiChat
//
//  Created by iMac on 2019/3/4.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPBiddingOrderView.h"

@implementation WPBiddingOrderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    return self;
}

- (void)fillData:(WPBiddingActivityDetailModel *)data {
    self.model = data;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doCancel)];
    [self addGestureRecognizer:tapGes];
    
    self.bottomV = [[UIView alloc]init];
    [self addSubview:self.bottomV];
    [self.bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.height.equalTo(@(400));
    }];
    self.bottomV.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *emptyGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(emptyMethod)];
    [self.bottomV addGestureRecognizer:emptyGes];
    
    UILabel *countLabel = [[UILabel alloc]init];
    [self.bottomV addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo (self.bottomV).offset(10);
        make.right.equalTo (self.bottomV).offset(-100);
        make.top.equalTo(self.bottomV).offset(30);
        make.height.equalTo(@(20));
    }];
    countLabel.font = Font(14);
    countLabel.text = @"竞价份数";
    
    self.countTF = [[UITextField alloc]init];
    [self.bottomV addSubview:self.countTF];
    [self.countTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(countLabel);
        make.height.equalTo(@30);
        make.width.equalTo(@80);
        make.right.equalTo(self).offset(-50);
    }];
    self.countTF.delegate = self;
    self.countTF.textAlignment = NSTextAlignmentCenter;
    self.countTF.layer.borderColor = [UIColor blackColor].CGColor;
    self.countTF.layer.borderWidth = 1;
    self.countTF.font = Font(14);
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomV addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.countTF);
        make.right.equalTo(self.countTF.mas_left);
        make.width.equalTo(@(30));
    }];
    [leftButton setTitle:@"-" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomV addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.countTF);
        make.left.equalTo(self.countTF.mas_right);
        make.width.equalTo(@(30));
    }];
    [rightButton setTitle:@"+" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    UILabel *countSubLabel = [[UILabel alloc]init];
    [self.bottomV addSubview:countSubLabel];
    [countSubLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo (leftButton);
        make.right.equalTo (rightButton);
        make.top.equalTo(self.countTF.mas_bottom).offset(10);
        make.height.equalTo(@(20));
    }];
    countSubLabel.font = Font(14);
    countSubLabel.text = @"还可投入1份";
    countSubLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *amountLabel = [[UILabel alloc]init];
    [self.bottomV addSubview:amountLabel];
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countLabel);
        make.top.equalTo(countSubLabel.mas_bottom).offset(20);
        make.right.equalTo(self.bottomV).offset(-20);
        make.height.equalTo(@(20));
    }];
    amountLabel.font = Font(14);
    amountLabel.text = @"投入FORCE";
    
    self.amountTF = [[UITextField alloc]init];
    [self.bottomV addSubview:self.amountTF];
    [self.amountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(amountLabel);
        make.height.equalTo(@30);
        make.width.equalTo(@80);
        make.right.equalTo(self).offset(-50);
    }];
    self.amountTF.delegate = self;
    self.amountTF.textAlignment = NSTextAlignmentCenter;
    self.amountTF.layer.borderColor = [UIColor blackColor].CGColor;
    self.amountTF.layer.borderWidth = 1;
    self.amountTF.font = Font(14);
    
    UILabel *amountSubLabel = [[UILabel alloc]init];
    [self.bottomV addSubview:amountSubLabel];
    [amountSubLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo (leftButton);
        make.right.equalTo (rightButton);
        make.top.equalTo(self.amountTF.mas_bottom).offset(10);
        make.height.equalTo(@(20));
    }];
    amountSubLabel.font = Font(14);
    amountSubLabel.text = @"最大可投入";
    amountSubLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *desLabel = [[UILabel alloc]init];
    [self.bottomV addSubview:desLabel];
    [desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomV).offset(15);
        make.right.equalTo(self.bottomV).offset(-15);
        make.height.equalTo(@(80));
        make.top.equalTo(amountSubLabel.mas_bottom).offset(20);
    }];
    desLabel.font = Font(14);
    desLabel.textAlignment = NSTextAlignmentCenter;
    desLabel.numberOfLines = 3;
    desLabel.text = @"aaa\nbbb\nccc";
    
    UIButton *biddingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomV addSubview:biddingButton];
    [biddingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(desLabel.mas_bottom).offset(20);
        make.height.equalTo(@(40));
        make.width.equalTo(@(180));
        make.centerX.equalTo(self.bottomV);
    }];
    biddingButton.titleLabel.font = Font(14);
    [biddingButton addTarget:self action:@selector(doBiddding) forControlEvents:UIControlEventTouchUpInside];
    biddingButton.layer.cornerRadius = 3;
    biddingButton.layer.masksToBounds = YES;
    biddingButton.backgroundColor = RGB(0x2f93fa);
    [biddingButton setTitle:@"参与竞价" forState:UIControlStateNormal];
}

- (void)show {
    [UIView animateWithDuration:1 animations:^{
        [self.bottomV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(@(400));
        }];
    }];
}

- (void)emptyMethod {
    
}

- (void)doBiddding {
    if (self.BiddingBlock) {
        self.BiddingBlock(self.countTF.text, [self.amountTF.text toPrise]);
    }
}

- (void)doCancel {
    if (self.CancelBlock) {
        self.CancelBlock();
    }
}

//加
- (void)doAdd {
    
}
//减
- (void)doReduce {
    
}

#pragma mark-- UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *tmpStr = [[NSMutableString alloc]initWithString:textField.text];
    [tmpStr replaceCharactersInRange:range withString:string];
    
    if ([textField isEqual:self.countTF]) {
        if (![string isInt]) {
            return NO;
        }
        if ([tmpStr integerValue] > [self.model.userMaxAmount integerValue]) {
            return NO;
        }
        return YES;
    } else {
        if ([textField.text containsString:@"."] && [string isEqualToString:@"."]) {
            return NO;
        }
        NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.model.coinType];
        NSArray *array = [tmpStr componentsSeparatedByString:@"."];
        if (array.count == 2) {
            NSString *pointStr = array[1];
            if (pointStr.length > [[coinInfo objectForKey:@"bit"] integerValue]) {
                return NO;
            }
        }
        return YES;
    }
}


@end
