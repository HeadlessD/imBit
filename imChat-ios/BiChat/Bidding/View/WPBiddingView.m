//
//  WPBiddingView.m
//  BiChat
//
//  Created by iMac on 2019/2/27.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPBiddingView.h"
#import "WPAESEncrypt.h"

@implementation WPBiddingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//screenwidth - 30
- (void)fillData:(NSDictionary *)data {
    self.receiveData = data;
    CGFloat width = ScreenWidth - 60;
    UILabel *dateLabel = [[UILabel alloc]init];
//    objc_setAssociatedObject(self, &overviewKey, data, OBJC_ASSOCIATION_RETAIN);
    [self addSubview:dateLabel];
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(dateLabel);
        make.left.equalTo(self).offset(15);
        make.width.equalTo(@(width * 0.3));
    }];
    NSString *time = [NSString stringWithFormat:@"%ld",[[data objectForKey:@"createTime"] longValue]];
    dateLabel.text = [time getTimeWithTimestamp:@"MM/dd HH:mm"];
    dateLabel.font = Font(14);
//    CGRect rect = [dateLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil];
    dateLabel.textColor = [UIColor grayColor];
    
    UILabel *countLabel = [[UILabel alloc]init];
    [self addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(dateLabel);
        make.left.equalTo(dateLabel.mas_right);
        make.width.equalTo(@(width * 0.4));
    }];
    countLabel.font = Font(14);
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.model.castCoinType];
    NSString *bit = [NSString stringWithFormat:@"%d",[[coinInfo objectForKey:@"bit"] intValue]];
    NSString * accuVolume = [NSString stringWithFormat:@"%@",[data objectForKey:@"accuVolume"]];
    NSString *bitString = [accuVolume accuracyCheckWithFormatterString:bit auotCheck:NO];
    if ([[data objectForKey:@"status"] integerValue] == 5) {
        countLabel.text = [LLSTR(@"108020") llReplaceWithArray:@[bitString,[data objectForKey:@"accuAmount"]]];
    } else {
        countLabel.text = [LLSTR(@"108020") llReplaceWithArray:@[bitString,@"***"]];
    }
    if ([self.model.status integerValue] == 17) {
        countLabel.text = [LLSTR(@"108020") llReplaceWithArray:@[bitString,[[data objectForKey:@"accuAmount"] integerValue] == 0 ? @"***" : [data objectForKey:@"accuAmount"]]];
    } else {
        YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"bidding.db"];
        NSString * storeStr =[store getStringById:[self.receiveData objectForKey:@"batchNo"] fromTable:[NSString stringWithFormat:@"b%@",[BiChatGlobal sharedManager].uid]];
        if ([storeStr boolValue]) {
            NSData *amountData = [[WPAESEncrypt decryptStringWithString:[self.receiveData objectForKey:@"encryptData"] andKey:[self.receiveData objectForKey:@"encryptKey"]] dataUsingEncoding:NSUTF8StringEncoding];
            if (!amountData) {
                countLabel.text = [LLSTR(@"108020") llReplaceWithArray:@[bitString,@"***"]];
            } else {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:amountData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
                countLabel.text = [LLSTR(@"108020") llReplaceWithArray:@[bitString,[dic objectForKey:@"amount"]]];
            }
        } else {
            countLabel.text = [LLSTR(@"108020") llReplaceWithArray:@[bitString,@"***"]];
        }
    }
    countLabel.textColor = [UIColor grayColor];
    UIButton *showDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:showDetailButton];
    [showDetailButton setTitleColor:DarkBlue forState:UIControlStateNormal];
    //0提交竟价，1已提交密钥等待解密，2未提交密钥，3解密失败，4已解密,5竞价成功，6已分配完部分竟价成功,7 超过中标份额部分竟价成功，8竞价失败，9超过中标份额竞价失败
//    [showDetailButton setTitle:[NSString stringWithFormat:@"%@ >",LLSTR(@"108021")] forState:UIControlStateNormal];
    if ([self.model.status integerValue] == 17) {
        if ([[data objectForKey:@"status"] integerValue] == 5) {
            [showDetailButton setTitle:[NSString stringWithFormat:@"%@ >",LLSTR(@"108024")] forState:UIControlStateNormal];
            [showDetailButton setTitleColor:THEME_GREEN forState:UIControlStateNormal];
        } else if ([[data objectForKey:@"status"] integerValue] == 6 || [[data objectForKey:@"status"] integerValue] == 7) {
            [showDetailButton setTitle:[NSString stringWithFormat:@"%@ >",LLSTR(@"108025")] forState:UIControlStateNormal];
            [showDetailButton setTitleColor:THEME_GREEN forState:UIControlStateNormal];
        } else if ([[data objectForKey:@"status"] integerValue] == 2 || [[data objectForKey:@"status"] integerValue] == 3) {
            [showDetailButton setTitle:[NSString stringWithFormat:@"%@ >",LLSTR(@"108027")] forState:UIControlStateNormal];
            [showDetailButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        } else {
            [showDetailButton setTitle:[NSString stringWithFormat:@"%@ >",LLSTR(@"108026")] forState:UIControlStateNormal];
            [showDetailButton setTitleColor:THEME_RED forState:UIControlStateNormal];
        }
        
    } else if ([self.model.status integerValue] > 17) {
        [showDetailButton setTitle:[NSString stringWithFormat:@"%@ >",LLSTR(@"108027")] forState:UIControlStateNormal];
        [showDetailButton setTitleColor:THEME_RED forState:UIControlStateNormal];
    }
    else if ([self.model.status integerValue] >= 9 && [self.model.status integerValue] < 17) {
        if ([[data objectForKey:@"status"] integerValue] == 0 || [[data objectForKey:@"status"] integerValue] == 2) {
            [showDetailButton setTitle:[NSString stringWithFormat:@"%@ >",LLSTR(@"108023")] forState:UIControlStateNormal];
            [showDetailButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        } else {
            [showDetailButton setTitle:[NSString stringWithFormat:@"%@ >",LLSTR(@"108022")] forState:UIControlStateNormal];
        }
    }
    else {
        [showDetailButton setTitle:[NSString stringWithFormat:@"%@ >",LLSTR(@"108021")] forState:UIControlStateNormal];
    }
    CGRect rect1 = [showDetailButton.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil];
    showDetailButton.titleLabel.font = Font(14);
    [showDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(dateLabel);
        make.right.equalTo(self).offset(-10);
        make.width.equalTo(@(rect1.size.width + 10));
    }];
    [showDetailButton addTarget:self action:@selector(doTap) forControlEvents:UIControlEventTouchUpInside];
}


- (void)doTap {
//    NSDictionary *dict = objc_getAssociatedObject(self, &overviewKey);
    if (self.CheckBlock) {
        self.CheckBlock(self.receiveData);
    }
    if (self.ResultCheckBlock) {
        self.ResultCheckBlock();
    }
}

@end
