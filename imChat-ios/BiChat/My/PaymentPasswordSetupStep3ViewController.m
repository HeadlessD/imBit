//
//  PaymentPasswordSetupStep3ViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "PaymentPasswordSetupStep3ViewController.h"
#import "NetworkModule.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>

@interface PaymentPasswordSetupStep3ViewController ()

@end

@implementation PaymentPasswordSetupStep3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    self.navigationItem.title = @"";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //create ui
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    label4Title.text = LLSTR(@"103006");
    label4Title.font = [UIFont systemFontOfSize:18];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    label4CodeTarget = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width - 20, 20)];
    label4CodeTarget.font = [UIFont systemFontOfSize:12];
    label4CodeTarget.textColor = THEME_GRAY;
    label4CodeTarget.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4CodeTarget];
    
    input4VerifyCode = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    input4VerifyCode.keyboardType = UIKeyboardTypeNumberPad;
    [input4VerifyCode addTarget:self action:@selector(onInput4VerifyCodeChanged:) forControlEvents:UIControlEventEditingChanged];
    [input4VerifyCode becomeFirstResponder];
    [self.view addSubview:input4VerifyCode];
    
    //六根线和六个点
    view4Seperator1 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 145, 120, 40, 1)];
    view4Seperator1.backgroundColor = THEME_COLOR;
    [self.view addSubview:view4Seperator1];
    view4Seperator2 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 95, 120, 40, 1)];
    view4Seperator2.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator2];
    view4Seperator3 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 45, 120, 40, 1)];
    view4Seperator3.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator3];
    view4Seperator4 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 5, 120, 40, 1)];
    view4Seperator4.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator4];
    view4Seperator5 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 55, 120, 40, 1)];
    view4Seperator5.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator5];
    view4Seperator6 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 105, 120, 40, 1)];
    view4Seperator6.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator6];
    
    view4VerifyCode1 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 140, 90, 30, 24)];
    view4VerifyCode1.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode1.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:view4VerifyCode1];
    view4VerifyCode2 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 90, 90, 30, 24)];
    view4VerifyCode2.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode2.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:view4VerifyCode2];
    view4VerifyCode3 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40, 90, 30, 24)];
    view4VerifyCode3.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode3.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:view4VerifyCode3];
    view4VerifyCode4 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 10, 90, 30, 24)];
    view4VerifyCode4.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode4.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:view4VerifyCode4];
    view4VerifyCode5 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 60, 90, 30, 24)];
    view4VerifyCode5.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode5.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:view4VerifyCode5];
    view4VerifyCode6 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 110, 90, 30, 24)];
    view4VerifyCode6.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode6.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:view4VerifyCode6];
    
    label4ResendHintInfo = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 145, 120, 150, 40)];
    label4ResendHintInfo.textAlignment = NSTextAlignmentLeft;
    label4ResendHintInfo.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:label4ResendHintInfo];
    
    button4ResendVerifyCode = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 145, 120, 150, 40)];
    [button4ResendVerifyCode addTarget:self action:@selector(onButtonResendVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4ResendVerifyCode];
        
    //是否需要发送验证码
    CGFloat intval = 100000;
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4SendVerifyCodeInfo)
    {
        if ([[item objectForKey:@"mobile"]isEqualToString:[BiChatGlobal sharedManager].lastLoginUserName])
        {
            intval = [[NSDate date]timeIntervalSinceDate:[item objectForKey:@"timeStamp"]];
            break;
        }
    }
    if (intval > 60)
    {
        //马上自动发送验证码
        [self sendVerifyCode];
    }
    else
        [self createResendTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_transparent"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.shadowImage = nil;
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

- (void)onInput4VerifyCodeChanged:(id)sender
{
    UITextField *input = (UITextField *)sender;
    if (input.text.length > 6) input.text = [input.text substringToIndex:6];
    
    [self freshVerifyCode];
    
    if (input.text.length == 6)
    {
        if (verifyProcessing)
            return;
        
        //先检查验证码是否正确
        verifyProcessing = YES;
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule checkVerifyCode:[BiChatGlobal sharedManager].lastLoginAreaCode
                                mobile:[BiChatGlobal sharedManager].lastLoginUserName verifyCode:input.text
                        completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {

            verifyProcessing = NO;
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                //计算一下MD5
                const char *c = [self.password cStringUsingEncoding:NSUTF8StringEncoding];
                unsigned char r[CC_MD5_DIGEST_LENGTH];
                CC_MD5(c, (CC_LONG)strlen(c), r);
                NSString *passwordMD5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                         r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
                
                //开始修改支付密码
                [NetworkModule changePaymentPassword:[BiChatGlobal sharedManager].lastLoginAreaCode
                                              mobile:[BiChatGlobal sharedManager].lastLoginUserName
                                          verifyCode:input.text password:passwordMD5
                                      completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
                {
                    //成功
                    if (success)
                    {
                        [BiChatGlobal showInfo:LLSTR(@"301113") withIcon:[UIImage imageNamed:@"icon_OK"]];
                        [BiChatGlobal sharedManager].paymentPasswordSet = YES;
                        [[BiChatGlobal sharedManager]saveUserInfo];
                        
                        //返回原来的界面
                        NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                        if (array.count > 3)
                        {
                            [array removeLastObject];
                            [array removeLastObject];
                            [array removeLastObject];
                            
                            //是不是有新的界面需要添加
                            UIViewController *wnd = nil;
                            if (self.delegate && [self.delegate respondsToSelector:@selector(paymentPasswordSetSuccess:)])
                                wnd = [self.delegate paymentPasswordSetSuccess:self.cookie];

                            if (wnd)
                                [array addObject:wnd];
                            
                            //进入新的界面
                            [self.navigationController setViewControllers:array animated:YES];
                        }
                    }
                    else
                    {
                        [BiChatGlobal showInfo:LLSTR(@"301124") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        input4VerifyCode.text = nil;
                        [self freshVerifyCode];
                    }
                }];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301913") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                input.text = nil;
                [self freshVerifyCode];
            }
        }];
    }
}

- (void)freshVerifyCode
{
    NSString *str = input4VerifyCode.text;
    
    //调整显示
    view4VerifyCode1.text = (input4VerifyCode.text.length >= 1)?[str substringWithRange:NSMakeRange(0, 1)]:@"";
    view4VerifyCode2.text = (input4VerifyCode.text.length >= 2)?[str substringWithRange:NSMakeRange(1, 1)]:@"";
    view4VerifyCode3.text = (input4VerifyCode.text.length >= 3)?[str substringWithRange:NSMakeRange(2, 1)]:@"";
    view4VerifyCode4.text = (input4VerifyCode.text.length >= 4)?[str substringWithRange:NSMakeRange(3, 1)]:@"";
    view4VerifyCode5.text = (input4VerifyCode.text.length >= 5)?[str substringWithRange:NSMakeRange(4, 1)]:@"";
    view4VerifyCode6.text = (input4VerifyCode.text.length >= 6)?[str substringWithRange:NSMakeRange(5, 1)]:@"";
    
    view4Seperator1.backgroundColor = input4VerifyCode.text.length == 0?THEME_COLOR:THEME_GRAY;
    view4Seperator2.backgroundColor = input4VerifyCode.text.length == 1?THEME_COLOR:THEME_GRAY;
    view4Seperator3.backgroundColor = input4VerifyCode.text.length == 2?THEME_COLOR:THEME_GRAY;
    view4Seperator4.backgroundColor = input4VerifyCode.text.length == 3?THEME_COLOR:THEME_GRAY;
    view4Seperator5.backgroundColor = input4VerifyCode.text.length == 4?THEME_COLOR:THEME_GRAY;
    view4Seperator6.backgroundColor = input4VerifyCode.text.length == 5?THEME_COLOR:THEME_GRAY;
}

- (void)createResendTimer
{
    //创建时钟
    [timer4ResendVerifyCode invalidate];
    timer4ResendVerifyCode = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        //获取当前手机号发送验证码的时间
        CGFloat intval = 100000;
        for (NSDictionary *item in [BiChatGlobal sharedManager].array4SendVerifyCodeInfo)
        {
            if ([[item objectForKey:@"mobile"]isEqualToString:[BiChatGlobal sharedManager].lastLoginUserName])
            {
                intval = [[NSDate date]timeIntervalSinceDate:[item objectForKey:@"timeStamp"]];
                break;
            }
        }
        
        if (intval > 60)
        {
            label4ResendHintInfo.text = LLSTR(@"103009");
            label4ResendHintInfo.textColor = THEME_COLOR;
            button4ResendVerifyCode.userInteractionEnabled = YES;
        }
        else
        {
            
            NSString * secTime = [NSString stringWithFormat:@"%d", (60 - (int)intval)];
            label4ResendHintInfo.text = [LLSTR(@"103008") llReplaceWithArray:@[secTime]];
            label4ResendHintInfo.textColor = THEME_GRAY;
            button4ResendVerifyCode.userInteractionEnabled = NO;
        }
    }];
}

- (void)onButtonResendVerifyCode:(id)sender
{
    [self sendVerifyCode];
}

- (void)sendVerifyCode
{
    [NetworkModule sendVerifyCode4ChangePaymentPassword:[BiChatGlobal sharedManager].lastLoginAreaCode
                                                 mobile:[BiChatGlobal sharedManager].lastLoginUserName completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            label4CodeTarget.text = [LLSTR(@"103007") llReplaceWithArray:@[[BiChatGlobal humanlizeMobileNumber:[BiChatGlobal sharedManager].lastLoginAreaCode mobile:[BiChatGlobal sharedManager].lastLoginUserName]]];
            
            [input4VerifyCode becomeFirstResponder];
            
            //记录一下当前时间
            if ([BiChatGlobal sharedManager].array4SendVerifyCodeInfo == nil)
                [BiChatGlobal sharedManager].array4SendVerifyCodeInfo = [NSMutableArray array];
            
            //先删除老数据
            for (int i = 0; i < [BiChatGlobal sharedManager].array4SendVerifyCodeInfo.count; i ++)
            {
                if ([[[[BiChatGlobal sharedManager].array4SendVerifyCodeInfo objectAtIndex:i]objectForKey:@"mobile"]isEqualToString:[BiChatGlobal sharedManager].lastLoginUserName])
                {
                    [[BiChatGlobal sharedManager].array4SendVerifyCodeInfo removeObjectAtIndex:i];
                    break;
                }
            }
            
            //加一个新的数据项
            [[BiChatGlobal sharedManager].array4SendVerifyCodeInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].lastLoginUserName, @"mobile", [NSDate date], @"timeStamp", nil]];
            
            //开始进入倒计时
            [self createResendTimer];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301912") withIcon:nil];
        
    }];
}

@end
