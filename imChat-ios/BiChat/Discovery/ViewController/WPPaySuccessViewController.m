//
//  WPPaySuccessViewController.m
//  BiChat
//
//  Created by iMac on 2018/12/18.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPPaySuccessViewController.h"

@interface WPPaySuccessViewController ()

@end

@implementation WPPaySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)createUI {
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:[self.resultDic objectForKey:@"coinType"]];
    
    UIImageView *imageV = [[UIImageView alloc]init];
    [self.view addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(40);
        make.width.height.equalTo(@50);
        make.centerX.equalTo(self.view);
    }];
    NSString *avatar = [self.resultDic objectForKey:@"avatar"];
    if (![avatar isKindOfClass:[NSNull class]] && avatar.length > 0) {
        [imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,avatar]]];
    } else {
        [imageV setImage:Image(@"icon_blue")];
    }
    imageV.layer.cornerRadius = 25;
    imageV.contentMode = UIViewContentModeScaleAspectFill;
    imageV.layer.masksToBounds = YES;
    
    UILabel *aimLabel = [[UILabel alloc]init];
    [self.view addSubview:aimLabel];
    [aimLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(imageV.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    aimLabel.font = Font(16);
    aimLabel.textAlignment = NSTextAlignmentCenter;
    aimLabel.text = [self.resultDic objectForKey:@"nickName"];
    
    UILabel *productLabel = [[UILabel alloc]init];
    [self.view addSubview:productLabel];
    [productLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(aimLabel.mas_bottom).offset(20);
        make.height.equalTo(@20);
    }];
    productLabel.font = Font(14);
    productLabel.textColor = [UIColor grayColor];
    productLabel.textAlignment = NSTextAlignmentCenter;
    productLabel.text = [self.resultDic objectForKey:@"body"];
    
    UILabel *countLabel = [[UILabel alloc]init];
    [self.view addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(productLabel.mas_bottom).offset(40);
        make.height.equalTo(@30);
    }];
    countLabel.font = Font(30);
    countLabel.textAlignment = NSTextAlignmentCenter;
    
    countLabel.text = [[self.resultDic objectForKey:@"amount"] accuracyCheckWithFormatterString:[coinInfo objectForKey:@"bit"] auotCheck:YES];
    UILabel *coinLabel = [[UILabel alloc]init];
    [self.view addSubview:coinLabel];
    [coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(countLabel.mas_bottom).offset(1);
        make.height.equalTo(@20);
    }];
    coinLabel.font = Font(14);
    coinLabel.textAlignment = NSTextAlignmentCenter;
    coinLabel.text = [coinInfo objectForKey:@"dSymbol"];
    
    UILabel *timeLabel = [[UILabel alloc]init];
    [self.view addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(coinLabel.mas_bottom).offset(20);
        make.height.equalTo(@60);
    }];
    timeLabel.font = Font(14);
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.numberOfLines = 0;
    NSString *timeStampString = [self.resultDic objectForKey:@"ctime"];
    NSTimeInterval interval =[timeStampString doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate: date];
    timeLabel.text = [LLSTR(@"103017") llReplaceWithArray:@[dateString]];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view).offset(-50);
    }];
    [backBtn setTitle:LLSTR(@"101022") forState:UIControlStateNormal];
    
    backBtn.layer.cornerRadius = 3;
    backBtn.layer.masksToBounds = YES;
    [backBtn setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    backBtn.layer.borderWidth = 1;
    backBtn.layer.borderColor = THEME_COLOR.CGColor;
    [backBtn addTarget:self action:@selector(doBlock) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.font = Font(16);
}

- (void)doBlock {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.backBlock) {
        self.backBlock(@"");
    }
}

@end
