//
//  TransferMoneyInfoViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "TransferMoneyInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "NetworkModule.h"

@interface TransferMoneyInfoViewController ()

@end

@implementation TransferMoneyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101601");
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    //获取转账状态
    [NetworkModule getTransferCoinInfo:self.transactionId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        transactionInfo = data;
        self.count = [[transactionInfo objectForKey:@"value"]doubleValue];
        [self freshGUI];
        
    }];
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

- (void)freshGUI
{
    for (UIView *subView in [self.view subviews])
        [subView removeFromSuperview];
    
    //币种图标
    UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 30, 60, 60, 60)];
    [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, self.selectedCoinIcon]]];
    [self.view addSubview:image4CoinIcon];

    if ([[transactionInfo objectForKey:@"status"]isEqualToString:@"ONGOING"])
    {
        //等待确认收款
        UILabel *label4WaitConfirm = [[UILabel alloc]initWithFrame:CGRectMake(0, 125, self.view.frame.size.width, 50)];
        if ([[BiChatGlobal sharedManager].uid isEqualToString:[transactionInfo objectForKey:@"receiverUid"]])
            label4WaitConfirm.text = [LLSTR(@"101606") llReplaceWithArray:@[ self.receiverNickName]];
        else
            label4WaitConfirm.text = [LLSTR(@"101602") llReplaceWithArray:@[ self.receiverNickName]];
        label4WaitConfirm.textAlignment = NSTextAlignmentCenter;
        label4WaitConfirm.font = [UIFont systemFontOfSize:18];
        label4WaitConfirm.numberOfLines = 0;
        [self.view addSubview:label4WaitConfirm];
        
        CGRect rect = [LLSTR(@"101615") boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
        
        UIButton *button4Recall = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - rect.size.width / 2 - 15, self.view.frame.size.height - 140, rect.size.width + 30, 40)];
        button4Recall.titleLabel.font = [UIFont systemFontOfSize:16];
        [button4Recall setTitle:LLSTR(@"101615") forState:UIControlStateNormal];
        [button4Recall setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4Recall addTarget:self action:@selector(onButtonRecall:) forControlEvents:UIControlEventTouchUpInside];
        button4Recall.layer.cornerRadius = 5;
        button4Recall.layer.borderColor = THEME_COLOR.CGColor;
        button4Recall.layer.borderWidth = 0.5;
        button4Recall.titleLabel.numberOfLines = 0;
        button4Recall.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:button4Recall];
        
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 20)];
        label4Hint.text = LLSTR(@"101614");
        label4Hint.font = [UIFont systemFontOfSize:12];
        label4Hint.textColor = THEME_GRAY;
        label4Hint.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label4Hint];
    }
    else if ([[transactionInfo objectForKey:@"status"]isEqualToString:@"DONE"])
    {
        //记录一下
        [[BiChatGlobal sharedManager]setTransferMoneyFinished:self.transactionId status:1];
        
        //等待确认收款
        UILabel *label4DoneConfirm = [[UILabel alloc]initWithFrame:CGRectMake(0, 125, self.view.frame.size.width, 50)];
        label4DoneConfirm.text = [LLSTR(@"101603") llReplaceWithArray:@[ self.receiverNickName]];
        label4DoneConfirm.textAlignment = NSTextAlignmentCenter;
        label4DoneConfirm.font = [UIFont systemFontOfSize:18];
        label4DoneConfirm.numberOfLines = 0;
        [self.view addSubview:label4DoneConfirm];
        
        //是否有确认时间
        if ([transactionInfo objectForKey:@"receiveTime"] != nil)
        {
            NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[transactionInfo objectForKey:@"receiveTime"]doubleValue]/1000];
            NSDateFormatter *fmt = [NSDateFormatter new];
            [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            fmt.dateFormat = @"yyyy/MM/dd HH:mm";
            
            //收款时间
            UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 20)];
            label4Time.text = [LLSTR(@"101611") llReplaceWithArray:@[ [BiChatGlobal adjustDateString2:[fmt stringFromDate:date]]]];
            label4Time.textAlignment = NSTextAlignmentCenter;
            label4Time.font = [UIFont systemFontOfSize:12];
            label4Time.textColor = THEME_GRAY;
            [self.view addSubview:label4Time];
        }
    }
    else if ([[transactionInfo objectForKey:@"status"]isEqualToString:@"RECALLED"])
    {
        //记录一下
        [[BiChatGlobal sharedManager]setTransferMoneyFinished:self.transactionId status:2];

        //等待确认收款
        UILabel *label4RecallConfirm = [[UILabel alloc]initWithFrame:CGRectMake(0, 125, self.view.frame.size.width, 50)];
        label4RecallConfirm.text = [LLSTR(@"101604") llReplaceWithArray:@[ self.receiverNickName]];
        label4RecallConfirm.textAlignment = NSTextAlignmentCenter;
        label4RecallConfirm.font = [UIFont systemFontOfSize:18];
        label4RecallConfirm.numberOfLines = 0;
        [self.view addSubview:label4RecallConfirm];
        
        //是否有确认时间
        if ([transactionInfo objectForKey:@"recallTime"] != nil)
        {
            NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[transactionInfo objectForKey:@"recallTime"]doubleValue]/1000];
            NSDateFormatter *fmt = [NSDateFormatter new];
            [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            fmt.dateFormat = @"yyyy/MM/dd HH:mm";
            
            //收款时间
            UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 20)];
            label4Time.text = [LLSTR(@"101613") llReplaceWithArray:@[ [BiChatGlobal adjustDateString2:[fmt stringFromDate:date]]]];
            label4Time.textAlignment = NSTextAlignmentCenter;
            label4Time.font = [UIFont systemFontOfSize:12];
            label4Time.textColor = THEME_GRAY;
            [self.view addSubview:label4Time];
        }
    }
    else if ([[transactionInfo objectForKey:@"status"]isEqualToString:@"EXPIRED"])
    {
        //记录一下
        [[BiChatGlobal sharedManager]setTransferMoneyFinished:self.transactionId status:3];

        //等待确认收款
        UILabel *label4ExpireConfirm = [[UILabel alloc]initWithFrame:CGRectMake(0, 125, self.view.frame.size.width, 50)];
        label4ExpireConfirm.text = [LLSTR(@"101605") llReplaceWithArray:@[ self.receiverNickName]];
        label4ExpireConfirm.textAlignment = NSTextAlignmentCenter;
        label4ExpireConfirm.font = [UIFont systemFontOfSize:18];
        label4ExpireConfirm.numberOfLines = 0;
        [self.view addSubview:label4ExpireConfirm];
        
        //是否有确认时间
        if ([transactionInfo objectForKey:@"recallTime"] != nil)
        {
            NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[transactionInfo objectForKey:@"recallTime"]doubleValue]/1000];
            NSDateFormatter *fmt = [NSDateFormatter new];
            [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            fmt.dateFormat = @"yyyy/MM/dd HH:mm";
            
            //收款时间
            UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 20)];
            label4Time.text = [LLSTR(@"101612") llReplaceWithArray:@[ [BiChatGlobal adjustDateString2:[fmt stringFromDate:date]]]];
            label4Time.textAlignment = NSTextAlignmentCenter;
            label4Time.font = [UIFont systemFontOfSize:12];
            label4Time.textColor = THEME_GRAY;
            [self.view addSubview:label4Time];
        }
    }
    
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
    
    //转账时间
    UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 20)];
    label4Time.text = [LLSTR(@"101610") llReplaceWithArray:@[ [BiChatGlobal adjustDateString2:self.time]]];
    label4Time.textAlignment = NSTextAlignmentCenter;
    label4Time.font = [UIFont systemFontOfSize:12];
    label4Time.textColor = THEME_GRAY;
    [self.view addSubview:label4Time];
}

- (void)onButtonRecall:(id)sender
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule recallTransferCoin:self.transactionId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            NSNumber *time = [NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970] * 1000];
            [transactionInfo setObject:@"RECALLED" forKey:@"status"];
            [transactionInfo setObject:time forKey:@"recallTime"];
            [self freshGUI];
            
            //通知
            if (self.delegate && [self.delegate respondsToSelector:@selector(transferMoneyRecalled:)])
                [self.delegate transferMoneyRecalled:self.transactionId];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301263") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        
    }];
}

@end
