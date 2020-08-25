//
//  PaymentPasswordSetupStep2ViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "PaymentPasswordSetupStep2ViewController.h"
#import "PaymentPasswordSetupStep3ViewController.h"

@interface PaymentPasswordSetupStep2ViewController ()

@end

@implementation PaymentPasswordSetupStep2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_transparent"];
    
    //create ui
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"103004");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    label4Hint.text = LLSTR(@"103005");
    label4Hint.textColor = [UIColor grayColor];
    label4Hint.font = [UIFont systemFontOfSize:13];
    label4Hint.adjustsFontSizeToFitWidth = YES;
    label4Hint.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Hint];
    
    input4Password = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    input4Password.keyboardType = UIKeyboardTypeNumberPad;
    input4Password.tintColor = [UIColor clearColor];
    [input4Password addTarget:self action:@selector(onInput4PasswordChanged:) forControlEvents:UIControlEventEditingChanged];
    [input4Password becomeFirstResponder];
    [self.view addSubview:input4Password];
    
    UIView *view4Frame = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 120, 150, 240, 40)];
    view4Frame.layer.borderColor = THEME_GRAY.CGColor;
    view4Frame.layer.borderWidth = 0.5;
    [self.view addSubview:view4Frame];
    
    //六根线和六个点
    UIView *view4Seperator;
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 80, 150, 0.5, 40)];
    view4Seperator.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40, 150, 0.5, 40)];
    view4Seperator.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2, 150, 0.5, 40)];
    view4Seperator.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 40, 150, 0.5, 40)];
    view4Seperator.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 80, 150, 0.5, 40)];
    view4Seperator.backgroundColor = THEME_GRAY;
    [self.view addSubview:view4Seperator];

    view4Password1 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 105, 165, 10, 10)];
    view4Password1.backgroundColor = [UIColor blackColor];
    view4Password1.layer.cornerRadius = 5;
    view4Password1.clipsToBounds = YES;
    view4Password1.hidden = YES;
    [self.view addSubview:view4Password1];
    view4Password2 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 65, 165, 10, 10)];
    view4Password2.backgroundColor = [UIColor blackColor];
    view4Password2.layer.cornerRadius = 5;
    view4Password2.clipsToBounds = YES;
    view4Password2.hidden = YES;
    [self.view addSubview:view4Password2];
    view4Password3 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 25, 165, 10, 10)];
    view4Password3.backgroundColor = [UIColor blackColor];
    view4Password3.layer.cornerRadius = 5;
    view4Password3.clipsToBounds = YES;
    view4Password3.hidden = YES;
    [self.view addSubview:view4Password3];
    view4Password4 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 15, 165, 10, 10)];
    view4Password4.backgroundColor = [UIColor blackColor];
    view4Password4.layer.cornerRadius = 5;
    view4Password4.clipsToBounds = YES;
    view4Password4.hidden = YES;
    [self.view addSubview:view4Password4];
    view4Password5 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 55, 165, 10, 10)];
    view4Password5.backgroundColor = [UIColor blackColor];
    view4Password5.layer.cornerRadius = 5;
    view4Password5.clipsToBounds = YES;
    view4Password5.hidden = YES;
    [self.view addSubview:view4Password5];
    view4Password6 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 95, 165, 10, 10)];
    view4Password6.backgroundColor = [UIColor blackColor];
    view4Password6.layer.cornerRadius = 5;
    view4Password6.clipsToBounds = YES;
    view4Password6.hidden = YES;
    [self.view addSubview:view4Password6];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_transparent"];
    input4Password.text = @"";
    [input4Password becomeFirstResponder];
    [self freshPassword];
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

- (void)onInput4PasswordChanged:(id)sender
{
    UITextField *input = (UITextField *)sender;
    if (input.text.length > 6) input.text = [input.text substringToIndex:6];
    
    [self freshPassword];
    
    if (input.text.length == 6)
    {
        input.userInteractionEnabled = NO;
        [self performSelector:@selector(doNextStep:) withObject:input afterDelay:0.3];
    }
}

- (void)doNextStep:(id)sender
{
    UITextField *input = (UITextField *)sender;
    input.userInteractionEnabled = YES;
    if ([input.text isEqualToString:self.password])
    {
        //进入下一层
        PaymentPasswordSetupStep3ViewController *wnd = [PaymentPasswordSetupStep3ViewController new];
        wnd.delegate = self.delegate;
        wnd.cookie = self.cookie;
        wnd.password = input4Password.text;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        [BiChatGlobal showInfo:LLSTR(@"301112") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        input.text = nil;
        view4Password1.hidden = YES;
        view4Password2.hidden = YES;
        view4Password3.hidden = YES;
        view4Password4.hidden = YES;
        view4Password5.hidden = YES;
        view4Password6.hidden = YES;
    }
}

- (void)freshPassword
{
    //显示
    view4Password1.hidden = !(input4Password.text.length >= 1);
    view4Password2.hidden = !(input4Password.text.length >= 2);
    view4Password3.hidden = !(input4Password.text.length >= 3);
    view4Password4.hidden = !(input4Password.text.length >= 4);
    view4Password5.hidden = !(input4Password.text.length >= 5);
    view4Password6.hidden = !(input4Password.text.length >= 6);
}

@end
