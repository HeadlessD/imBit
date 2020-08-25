//
//  MyNetworkTestViewController.m
//  BiChat
//
//  Created by imac2 on 2018/12/11.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "MyNetworkTestViewController.h"
#import "NetworkModule.h"

@interface MyNetworkTestViewController ()

@end

@implementation MyNetworkTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"107006");
    
    // Do any additional setup after loading the view.
    text4NetworkTestResult = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (isIphonex?88:64))];
    text4NetworkTestResult.backgroundColor = [UIColor whiteColor];
    text4NetworkTestResult.text = [NSString stringWithFormat:@"testUrl:\r\n%@\r\n\r\nrecently request urls:\r\n%@\r\n\r\n",
                                   [[BiChatGlobal sharedManager].systemConfig objectForKey:@"connectivityTestURL"],
                                   [[BiChatGlobal sharedManager].array4WebApiAccess componentsJoinedByString:@"\r\n"]];
    [self.view addSubview:text4NetworkTestResult];
    [self beginTest];
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

- (void)beginTest
{
    [BiChatGlobal ShowActivityIndicator];
    if (![NetworkModule networkTest:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        
        //获取一下body内的东西
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSRange range1 = [str rangeOfString:@"<body>"];
        if (range1.length > 0)
        {
            str = [str substringFromIndex:range1.location];
            NSRange range2 = [str rangeOfString:@"</body>"];
            if (range2.length > 0)
            {
                str = [str substringToIndex:range2.location + range2.length];
            }
        }
        
        text4NetworkTestResult.text = [text4NetworkTestResult.text stringByAppendingString:str];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101012") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSend:)];
    }])
    {
        [BiChatGlobal HideActivityIndicator];
    }
}

- (void)onButtonSend:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSString *str4Title = [NSString stringWithFormat:@"IOS Akamai %@ %@ %@",
                           [BiChatGlobal sharedManager].lastLoginAreaCode,
                           [BiChatGlobal sharedManager].lastLoginUserName,
                           [BiChatGlobal sharedManager].nickName];
    network = [NetworkModule new];
    [BiChatGlobal ShowActivityIndicator];
    [network sendEmailToServiceCenter:str4Title content:text4NetworkTestResult.text completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (success)
        {
            [BiChatGlobal showInfo:LLSTR(@"301930") withIcon:[UIImage imageNamed:@"icon_OK"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301931") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

@end
