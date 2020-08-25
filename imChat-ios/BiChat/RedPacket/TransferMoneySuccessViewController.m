//
//  TransferMoneySuccessViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/31.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "TransferMoneySuccessViewController.h"
#import "UIImageView+WebCache.h"

@interface TransferMoneySuccessViewController ()

@end

@implementation TransferMoneySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101601");
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    // Do any additional setup after loading the view.
    
    //币图标
    UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 30, 60, 60, 60)];
    [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, self.selectedCoinIcon]]];
    [self.view addSubview:image4CoinIcon];
    
    //等待确认收款
    UILabel *label4WaitConfirm = [[UILabel alloc]initWithFrame:CGRectMake(0, 140, self.view.frame.size.width, 20)];
    label4WaitConfirm.text = [LLSTR(@"101602") llReplaceWithArray:@[self.peerNickName]];
    label4WaitConfirm.textAlignment = NSTextAlignmentCenter;
    label4WaitConfirm.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:label4WaitConfirm];
    
    //数量
    UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(0, 180, self.view.frame.size.width, 40)];
    label4Count.text = [BiChatGlobal decimalNumberWithDouble:self.count];
    label4Count.font = [UIFont systemFontOfSize:30];
    label4Count.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Count];
    
    //币名字
    UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, 20)];
    label4CoinName.text = self.selectedCoinName;
    label4CoinName.font = [UIFont systemFontOfSize:16];
    label4CoinName.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4CoinName];

    //完成按钮
    UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 65, self.view.frame.size.height - 180, 130, 40)];
    button4OK.titleLabel.font = [UIFont systemFontOfSize:14];
    button4OK.layer.cornerRadius = 5;
    button4OK.layer.borderColor = THEME_COLOR.CGColor;
    button4OK.layer.borderWidth = 0.5;
    [button4OK setTitle:LLSTR(@"101022") forState:UIControlStateNormal];
    [button4OK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4OK addTarget:self action:@selector(onButtonOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4OK];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 私有函数

- (void)onButtonOK:(id)sender
{
    //通知
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(transferMoneySuccess:coinIconUrl:coinIconWhiteUrl:count:transactionId:memo:)])
            [self.delegate transferMoneySuccess:self.selectedCoinName
                                    coinIconUrl:self.selectedCoinIcon
                               coinIconWhiteUrl:self.selectedCoinIconWhite
                                          count:self.count
                                  transactionId:self.transactionId
                                           memo:self.memo];
    }];
}

@end
