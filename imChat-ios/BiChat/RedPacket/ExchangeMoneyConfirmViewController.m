//
//  ExchangeMoneyConfirmViewController.m
//  BiChat
//
//  Created by imac2 on 2018/11/7.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "ExchangeMoneyConfirmViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "WPRedPacketPayWorkdInputView.h"
#import "PaymentPasswordSetupStep1ViewController.h"

@interface ExchangeMoneyConfirmViewController ()

@property (nonatomic,strong)WPRedPacketPayWorkdInputView *passView;

@end

@implementation ExchangeMoneyConfirmViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [BiChatGlobal HideActivityIndicator];
}

- (void)keyboardWillShow:(NSNotification *)noti{
    if (!self.passView) {
        return;
    }
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.26 animations:^{
        [self.passView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo([UIApplication sharedApplication].keyWindow);
            make.bottom.equalTo([UIApplication sharedApplication].keyWindow).offset(-keyboardHeight);
        }];
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti {
    if (self.passView) {
        [self.passView removeFromSuperview];
        self.passView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101651");
    self.view.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getExchangeCoinInfo:self.transactionId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        //NSLog(@"%@", data);
        
        [BiChatGlobal HideActivityIndicator];
        if (success)    
        {
            exchangeMoneyInfo = [NSMutableDictionary dictionaryWithDictionary:data];
            [self initGUI];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301283") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
    
    // Do any additional setup after loading the view.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)initGUI
{
    //删除所有的窗口
    for (UIView *subView in [self.view subviews])
        [subView removeFromSuperview];
    
    UIScrollView *scroll4Container = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scroll4Container.contentSize = CGSizeMake(self.view.frame.size.width, 650);
    [self.view addSubview:scroll4Container];
    
    // Configure the cell...
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:self.peerUid nickName:self.peerNickName avatar:self.peerAvatar frame:CGRectMake(self.view.frame.size.width / 2 - 25, 25, 50, 50)];
    [scroll4Container addSubview:view4Avatar];
    
    UILabel *label4PeerNickName = [[UILabel alloc]initWithFrame:CGRectMake(15, 80, self.view.frame.size.width - 30, 20)];
    label4PeerNickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:self.peerUid groupProperty:nil nickName:self.peerNickName];
    label4PeerNickName.font = [UIFont systemFontOfSize:16];
    label4PeerNickName.textAlignment = NSTextAlignmentCenter;
    [scroll4Container addSubview:label4PeerNickName];
    
    //输入框
    UIView *view4SelectedCoinInfoFrame = [[UIView alloc]initWithFrame:CGRectMake(20, 120, self.view.frame.size.width - 40, 350)];
    view4SelectedCoinInfoFrame.backgroundColor = [UIColor whiteColor];
    view4SelectedCoinInfoFrame.layer.cornerRadius = 10;
    view4SelectedCoinInfoFrame.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
    view4SelectedCoinInfoFrame.layer.borderWidth = 0.5;
    [scroll4Container addSubview:view4SelectedCoinInfoFrame];
    
    //分割块
    UIView *view4GweiFrame = [[UIView alloc]initWithFrame:CGRectMake(20.5, 220, self.view.frame.size.width - 41, 25)];
    view4GweiFrame.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    [scroll4Container addSubview:view4GweiFrame];
    view4GweiFrame = [[UIView alloc]initWithFrame:CGRectMake(20.5, 345, self.view.frame.size.width - 41, 25)];
    view4GweiFrame.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    [scroll4Container addSubview:view4GweiFrame];
    
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 170, self.view.frame.size.width - 40, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [scroll4Container addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 220, self.view.frame.size.width - 40, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [scroll4Container addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 245, self.view.frame.size.width - 40, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [scroll4Container addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 295, self.view.frame.size.width - 40 , 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [scroll4Container addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 345, self.view.frame.size.width - 40 , 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [scroll4Container addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 370, self.view.frame.size.width - 40 , 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [scroll4Container addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(20, 420, self.view.frame.size.width - 40 , 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [scroll4Container addSubview:view4Seperator];
    
    //币种
    UILabel *label4CoinTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 120, 100, 50)];
    label4CoinTypeTitle.text = LLSTR(@"101652");
    label4CoinTypeTitle.font = [UIFont systemFontOfSize:16];
    [scroll4Container addSubview:label4CoinTypeTitle];
    
    if (self.selectedCoinName.length > 0)
    {
        CGRect rect = [self.selectedCoinName boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 130, MAXFLOAT)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                          context:nil];
        UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 35 - rect.size.width, 120, rect.size.width, 50)];
        label4CoinName.text = self.selectedCoinName;
        label4CoinName.font = [UIFont systemFontOfSize:16];
        [scroll4Container addSubview:label4CoinName];
        
        UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        image4CoinIcon.center = CGPointMake(self.view.frame.size.width - rect.size.width - 55, 145);
        [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, self.selectedCoinIcon]]];
        [scroll4Container addSubview:image4CoinIcon];
    }
    
    //数量
    UILabel *label4CountTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 170, 100, 50)];
    label4CountTitle.text = LLSTR(@"101653");
    label4CountTitle.font = [UIFont systemFontOfSize:16];
    [scroll4Container addSubview:label4CountTitle];
        
    UILabel *label4CoinCount = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 35 - 200, 170, 200, 50)];
    label4CoinCount.text = [BiChatGlobal decimalNumberWithDouble:self.count];
    label4CoinCount.textAlignment = NSTextAlignmentRight;
    label4CoinCount.font = [UIFont systemFontOfSize:16];
    [scroll4Container addSubview:label4CoinCount];
    
    if ([[[exchangeMoneyInfo objectForKey:@"fromCoin"]objectForKey:@"symbol"]isEqualToString:@"BTC"])
    {
        long long sat = [[BiChatGlobal decimalNumberWithDouble:self.count]doubleValue] * 100000000;
        if (sat > 0)
        {
            UILabel *label4Sat = [[UILabel alloc]initWithFrame:CGRectMake(35, 220, self.view.frame.size.width - 70, 25)];
            label4Sat.font = [UIFont systemFontOfSize:13];
            label4Sat.textColor = [UIColor grayColor];
            label4Sat.textAlignment = NSTextAlignmentRight;
            label4Sat.text = [NSString stringWithFormat:@"= %lld sat", sat];
            [scroll4Container addSubview:label4Sat];
        }
    }
    else if ([[[exchangeMoneyInfo objectForKey:@"fromCoin"]objectForKey:@"symbol"]isEqualToString:@"ETH"])
    {
        long long Gwei = [[BiChatGlobal decimalNumberWithDouble:self.count]doubleValue] * 1000000000;
        if (Gwei > 0)
        {
            UILabel *label4Gwei = [[UILabel alloc]initWithFrame:CGRectMake(35, 220, self.view.frame.size.width - 70, 25)];
            label4Gwei.font = [UIFont systemFontOfSize:13];
            label4Gwei.textColor = [UIColor grayColor];
            label4Gwei.textAlignment = NSTextAlignmentRight;
            label4Gwei.text = [NSString stringWithFormat:@"= %lld Gwei", Gwei];
            [scroll4Container addSubview:label4Gwei];
        }
    }
    
    //交换币种
    UILabel *label4ExchangeCoinTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 245, 100, 50)];
    label4ExchangeCoinTypeTitle.text = LLSTR(@"101654");
    label4ExchangeCoinTypeTitle.font = [UIFont systemFontOfSize:16];
    [scroll4Container addSubview:label4ExchangeCoinTypeTitle];
    
    if (self.selectedExchangeCoinName.length > 0)
    {
        CGRect rect = [self.selectedExchangeCoinName boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 135, MAXFLOAT)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                                  context:nil];
        UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 35 - rect.size.width, 245, rect.size.width, 50)];
        label4CoinName.text = self.selectedExchangeCoinName;
        label4CoinName.font = [UIFont systemFontOfSize:16];
        [scroll4Container addSubview:label4CoinName];
        
        UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        image4CoinIcon.center = CGPointMake(self.view.frame.size.width - rect.size.width - 55, 270);
        [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, self.selectedExchangeCoinIcon]]];
        [scroll4Container addSubview:image4CoinIcon];
    }
    
    //交换数量
    UILabel *label4ExchangeCountTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 295, 100, 50)];
    label4ExchangeCountTitle.text = LLSTR(@"101655");
    label4ExchangeCountTitle.font = [UIFont systemFontOfSize:16];
    [scroll4Container addSubview:label4ExchangeCountTitle];
    
    UILabel *label4ExchangeCoinCount = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 35 - 200, 295, 200, 50)];
    label4ExchangeCoinCount.text = [BiChatGlobal decimalNumberWithDouble:self.exchangeCount];
    label4ExchangeCoinCount.textAlignment = NSTextAlignmentRight;
    label4ExchangeCoinCount.font = [UIFont systemFontOfSize:16];
    [scroll4Container addSubview:label4ExchangeCoinCount];
    
    if ([[[exchangeMoneyInfo objectForKey:@"toCoin"]objectForKey:@"symbol"]isEqualToString:@"BTC"])
    {
        long long sat = [[BiChatGlobal decimalNumberWithDouble:self.exchangeCount]doubleValue] * 100000000;
        if (sat > 0)
        {
            UILabel *label4Sat = [[UILabel alloc]initWithFrame:CGRectMake(35, 345, self.view.frame.size.width - 70, 25)];
            label4Sat.font = [UIFont systemFontOfSize:13];
            label4Sat.textColor = [UIColor grayColor];
            label4Sat.textAlignment = NSTextAlignmentRight;
            label4Sat.text = [NSString stringWithFormat:@"= %lld sat", sat];
            [scroll4Container addSubview:label4Sat];
        }
    }
    else if ([[[exchangeMoneyInfo objectForKey:@"toCoin"]objectForKey:@"symbol"]isEqualToString:@"ETH"])
    {
        long long Gwei = [[BiChatGlobal decimalNumberWithDouble:self.exchangeCount]doubleValue] * 1000000000;
        if (Gwei > 0)
        {
            UILabel *label4Gwei = [[UILabel alloc]initWithFrame:CGRectMake(35, 345, self.view.frame.size.width - 70, 25)];
            label4Gwei.font = [UIFont systemFontOfSize:13];
            label4Gwei.textColor = [UIColor grayColor];
            label4Gwei.textAlignment = NSTextAlignmentRight;
            label4Gwei.text = [NSString stringWithFormat:@"= %lld Gwei", Gwei];
            [scroll4Container addSubview:label4Gwei];
        }
    }
    
    //手续费
    UILabel *label4FeeTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 370, 100, 50)];
    label4FeeTitle.text = LLSTR(@"101657");
    label4FeeTitle.font = [UIFont systemFontOfSize:16];
    [scroll4Container addSubview:label4FeeTitle];
    
    UILabel *label4Fee = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 370, 65, 50)];
    label4Fee.text = LLSTR(@"101005");
    label4Fee.font = [UIFont systemFontOfSize:17];
    label4Fee.textColor = [UIColor lightGrayColor];
    label4Fee.textAlignment = NSTextAlignmentRight;
    [scroll4Container addSubview:label4Fee];
    
    //留言
    UILabel *label4MemoTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 420, 50, 50)];
    label4MemoTitle.text = LLSTR(@"101024");
    label4MemoTitle.font = [UIFont systemFontOfSize:16];
    [scroll4Container addSubview:label4MemoTitle];
    
    UILabel *label4Memo = [[UILabel alloc]initWithFrame:CGRectMake(95, 420, self.view.frame.size.width - 130 , 50)];
    label4Memo.text = self.memo;
    label4Memo.textAlignment = NSTextAlignmentRight;
    label4Memo.font = [UIFont systemFontOfSize:16];
    [scroll4Container addSubview:label4Memo];

    //正常状态
    if ([[exchangeMoneyInfo objectForKey:@"status"]integerValue] == 0)
    {
        UIButton *button4Confirm = [[UIButton alloc]initWithFrame:CGRectMake(20, 480, self.view.frame.size.width - 40, 50)];
        button4Confirm.backgroundColor = THEME_COLOR;
        button4Confirm.layer.cornerRadius = 5;
        button4Confirm.clipsToBounds = YES;
        [button4Confirm setTitle:LLSTR(@"101670") forState:UIControlStateNormal];
        [button4Confirm addTarget:self action:@selector(onButtonConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [scroll4Container addSubview:button4Confirm];
        
        NSString *expireTime;
        if ([[exchangeMoneyInfo objectForKey:@"expireMinutes"]floatValue] > 60){
            NSString * str = [NSString stringWithFormat:@"%ld", (long)[[exchangeMoneyInfo objectForKey:@"expireMinutes"]floatValue] / 60];

            expireTime = [LLSTR(@"101046") llReplaceWithArray:@[str]];
//            [NSString stringWithFormat:@"%ld小时", (long)[[exchangeMoneyInfo objectForKey:@"expireMinutes"]floatValue] / 60];
        }else{
            NSString * str = [NSString stringWithFormat:@"%ld", (long)[[exchangeMoneyInfo objectForKey:@"expireMinutes"]floatValue]];

            expireTime = [LLSTR(@"101047") llReplaceWithArray:@[str]];
//            [NSString stringWithFormat:@"%ld分钟", (long)[[exchangeMoneyInfo objectForKey:@"expireMinutes"]floatValue]];
        }
        UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(0, 540, self.view.frame.size.width, 50)];
        label4Time.text = [LLSTR(@"101667") llReplaceWithArray:@[ [BiChatGlobal adjustDateString2:self.time], expireTime]];
        label4Time.font = [UIFont systemFontOfSize:12];
        label4Time.textColor = THEME_GRAY;
        label4Time.numberOfLines = 0;
        [scroll4Container addSubview:label4Time];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Time.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:3];
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
        label4Time.attributedText = str;
        label4Time.textAlignment = NSTextAlignmentCenter;
    }
    //已确认
    else if ([[exchangeMoneyInfo objectForKey:@"status"]integerValue] == 1)
    {
        UILabel *label4Status = [[UILabel alloc]initWithFrame:CGRectMake(20, 480, self.view.frame.size.width - 40, 50)];
        label4Status.text = LLSTR(@"101660");
        label4Status.backgroundColor = [UIColor lightGrayColor];
        label4Status.textColor = [UIColor whiteColor];
        label4Status.font = [UIFont systemFontOfSize:18];
        label4Status.layer.cornerRadius = 5;
        label4Status.clipsToBounds = YES;
        label4Status.textAlignment = NSTextAlignmentCenter;
        [scroll4Container addSubview:label4Status];
        
        UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(0, 540, self.view.frame.size.width, 40)];
        label4Time.text = [LLSTR(@"101664") llReplaceWithArray:@[ [BiChatGlobal adjustDateString2:self.time], [BiChatGlobal adjustDateString2:[NSString stringWithFormat:@"%lld", [[exchangeMoneyInfo objectForKey:@"utime"]longLongValue]]]]];
        label4Time.font = [UIFont systemFontOfSize:12];
        label4Time.textColor = THEME_GRAY;
        label4Time.numberOfLines = 0;
        [scroll4Container addSubview:label4Time];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Time.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:3];
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
        label4Time.attributedText = str;
        label4Time.textAlignment = NSTextAlignmentCenter;

        [[BiChatGlobal sharedManager]setExchangeMoneyFinished:self.transactionId status:1];
    }
    //已取消
    else if ([[exchangeMoneyInfo objectForKey:@"status"]integerValue] == 2)
    {
        UILabel *label4Status = [[UILabel alloc]initWithFrame:CGRectMake(20, 480, self.view.frame.size.width - 40, 50)];
        label4Status.text = LLSTR(@"101661");
        label4Status.backgroundColor = [UIColor lightGrayColor];
        label4Status.textColor = [UIColor whiteColor];
        label4Status.font = [UIFont systemFontOfSize:18];
        label4Status.layer.cornerRadius = 5;
        label4Status.clipsToBounds = YES;
        label4Status.textAlignment = NSTextAlignmentCenter;
        [scroll4Container addSubview:label4Status];
        
        UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(0, 540, self.view.frame.size.width, 40)];
        label4Time.text = [LLSTR(@"101664") llReplaceWithArray:@[ [BiChatGlobal adjustDateString2:self.time], [BiChatGlobal adjustDateString2:[NSString stringWithFormat:@"%lld", [[exchangeMoneyInfo objectForKey:@"utime"]longLongValue]]]]];
        label4Time.font = [UIFont systemFontOfSize:12];
        label4Time.textColor = THEME_GRAY;
        label4Time.numberOfLines = 0;
        [scroll4Container addSubview:label4Time];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Time.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:3];
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
        label4Time.attributedText = str;
        label4Time.textAlignment = NSTextAlignmentCenter;

        [[BiChatGlobal sharedManager]setExchangeMoneyFinished:self.transactionId status:2];
    }
    //已拒绝
    else if ([[exchangeMoneyInfo objectForKey:@"status"]integerValue] == 3)
    {
        UILabel *label4Status = [[UILabel alloc]initWithFrame:CGRectMake(20, 480, self.view.frame.size.width - 40, 50)];
        label4Status.text = LLSTR(@"101663");
        label4Status.backgroundColor = [UIColor lightGrayColor];
        label4Status.textColor = [UIColor whiteColor];
        label4Status.font = [UIFont systemFontOfSize:18];
        label4Status.layer.cornerRadius = 5;
        label4Status.clipsToBounds = YES;
        label4Status.textAlignment = NSTextAlignmentCenter;
        [scroll4Container addSubview:label4Status];
        
        UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(0, 540, self.view.frame.size.width, 20)];
        label4Time.text = [LLSTR(@"101671") llReplaceWithArray:@[ [BiChatGlobal adjustDateString2:self.time]]];
        label4Time.textAlignment = NSTextAlignmentCenter;
        label4Time.font = [UIFont systemFontOfSize:12];
        label4Time.textColor = THEME_GRAY;
        label4Time.numberOfLines = 0;
        [scroll4Container addSubview:label4Time];
    }
    //已过期
    else if ([[exchangeMoneyInfo objectForKey:@"status"]integerValue] == 4)
    {
        UILabel *label4Status = [[UILabel alloc]initWithFrame:CGRectMake(20, 480, self.view.frame.size.width - 40, 50)];
        label4Status.text = LLSTR(@"101662");
        label4Status.backgroundColor = [UIColor lightGrayColor];
        label4Status.textColor = [UIColor whiteColor];
        label4Status.font = [UIFont systemFontOfSize:18];
        label4Status.layer.cornerRadius = 5;
        label4Status.clipsToBounds = YES;
        label4Status.textAlignment = NSTextAlignmentCenter;
        [scroll4Container addSubview:label4Status];
        
        UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(0, 540, self.view.frame.size.width, 40)];
        label4Time.text = [LLSTR(@"101664") llReplaceWithArray:@[ [BiChatGlobal adjustDateString2:self.time], [BiChatGlobal adjustDateString2:[NSString stringWithFormat:@"%lld", [[exchangeMoneyInfo objectForKey:@"expired"]longLongValue]]]]];
        label4Time.font = [UIFont systemFontOfSize:12];
        label4Time.textColor = THEME_GRAY;
        label4Time.numberOfLines = 0;
        [scroll4Container addSubview:label4Time];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Time.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:3];
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
        label4Time.attributedText = str;
        label4Time.textAlignment = NSTextAlignmentCenter;

        [[BiChatGlobal sharedManager]setExchangeMoneyFinished:self.transactionId status:3];
    }
}

- (void)onButtonConfirm:(id)sender
{
    if ([[exchangeMoneyInfo objectForKey:@"status"]integerValue] == 0)
    {
        //账号里面是否足够
        if ([[[[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"asset"]objectForKey:[[exchangeMoneyInfo objectForKey:@"toCoin"]objectForKey:@"symbol"]]floatValue] < self.exchangeCount)
        {
            [BiChatGlobal showInfo:[LLSTR(@"301125") llReplaceWithArray:@[self.selectedExchangeCoinName]]
              withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            return;
        }

        //开始输入密码
        [self.view endEditing:YES];
        [self showPassView];
    }
}

//显示密码输入页
- (void)showPassView {
    
    //获取bit信息
    NSDictionary *CoinInfo;
    for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:[[exchangeMoneyInfo objectForKey:@"toCoin"]objectForKey:@"symbol"]])
        {
            CoinInfo = item;
            break;
        }
    }
    NSString *format = [NSString stringWithFormat:@"%%.0%ldf", [[CoinInfo objectForKey:@"bit"]integerValue]];
    
    [self hidePassView];
    self.passView = [[WPRedPacketPayWorkdInputView alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:self.passView];
    [self.passView setCoinImag:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [[exchangeMoneyInfo objectForKey:@"toCoin"]objectForKey:@"imgGold"]]
                         count:[NSString stringWithFormat:format, self.exchangeCount]
                      coinName:[[exchangeMoneyInfo objectForKey:@"toCoin"]objectForKey:@"dSymbol"]];
    [self.passView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
    WEAKSELF;
    self.passView.closeBlock = ^{
        [weakSelf hidePassView];
    };
    self.passView.passwordInputBlock = ^(NSString *password) {
        [weakSelf hidePassView];
        const char *c = [password cStringUsingEncoding:NSUTF8StringEncoding];
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(c, (CC_LONG)strlen(c), r);
        NSString *passwordMD5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                 r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        
        //开始交换
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule confirmExchangeCoin:self.transactionId password:passwordMD5 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            NSLog(@"%ld", (long)errorCode);
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                //交换成功
                [BiChatGlobal showInfo:LLSTR(@"301281") withIcon:[UIImage imageNamed:@"icon_OK"]];
                [exchangeMoneyInfo setObject:@"1" forKey:@"status"];
                [self initGUI];
                
                [self performSelector:@selector(notifyConfirmSuccess) withObject:nil afterDelay:1];
                
                //重新获取一下我的钱包数据
                [NetworkModule getWallet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success)
                    {
                        [BiChatGlobal sharedManager].dict4WalletInfo = data;
                        [[BiChatGlobal sharedManager]saveUserInfo];
                    }
                }];
            }
            else {
                [weakSelf hidePassView];
                if (errorCode == 1) {
                    [BiChatGlobal showInfo:LLSTR(@"301282") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                else if (errorCode == 2)
                    [BiChatGlobal showInfo:LLSTR(@"301111") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else if (errorCode == 100026) {
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"103012") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"103013") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf showPassView];
                        });
                        
                    }];
                    UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"103014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        PaymentPasswordSetupStep1ViewController *passVC = [[PaymentPasswordSetupStep1ViewController alloc]init];
                        [self.navigationController pushViewController:passVC animated:YES];
                    }];
                    [action2 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                    [action1 setValue:LightBlue forKey:@"_titleTextColor"];
                    [alertC addAction:action1];
                    [alertC addAction:action2];
                    [weakSelf presentViewController:alertC animated:YES completion:nil];
                }
                else if (errorCode == 100027)
                    [BiChatGlobal showInfo:LLSTR(@"301114") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else if (errorCode == 100035)
                    [BiChatGlobal showInfo:LLSTR(@"301284") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else if (errorCode == 100036)
                    [BiChatGlobal showInfo:LLSTR(@"301287") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else if (errorCode == 100037)
                    [BiChatGlobal showInfo:LLSTR(@"301285") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:[NSString stringWithFormat:@"%@\r\n(%ld)",LLSTR(@"301282"),(long)errorCode] withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            };
        }];
    };
}

- (void)hidePassView {
    [self.passView resignFirstResponder];
    [self.passView removeFromSuperview];
    self.passView = nil;
}

- (void)notifyConfirmSuccess
{
    //通知
    if (self.delegate && [self.delegate respondsToSelector:@selector(exchangeMoneyReceived:)])
        [self.delegate exchangeMoneyReceived:self.transactionId];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
