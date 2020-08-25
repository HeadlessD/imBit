//
//  LoginPortalViewController.m
//  BiChat
//
//  Created by imac2 on 2018/7/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "LoginPortalViewController.h"
#import "LoginViewController.h"
#import "WXApi.h"

@interface LoginPortalViewController ()

@end

@implementation LoginPortalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"empty"];
    
    CGFloat bk_height = self.view.frame.size.width / 766 * 911;
    UIImageView *image4Bk = [[UIImageView alloc]initWithFrame:CGRectMake(-5, 0, self.view.frame.size.width + 10, bk_height)];
    image4Bk.image = [UIImage imageNamed:@"loginPortal_bk"];
#ifdef ENV_V_DEV
    image4Bk.image = [UIImage imageNamed:@"loginPortal_bk_v"];
#endif
    [self.view addSubview:image4Bk];
    
    button4WeChatLogin = [[UIButton alloc]initWithFrame:CGRectMake(40, bk_height - 80, self.view.frame.size.width - 80, 50)];
    button4WeChatLogin.backgroundColor = [UIColor clearColor];
    button4WeChatLogin.layer.cornerRadius = 5;
    button4WeChatLogin.clipsToBounds = YES;
    button4WeChatLogin.layer.borderColor = [UIColor whiteColor].CGColor;
    button4WeChatLogin.layer.borderWidth = 0.5;
    [button4WeChatLogin setTitle:LLSTR(@"107108") forState:UIControlStateNormal];
    [button4WeChatLogin setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button4WeChatLogin setImage:[UIImage imageNamed:@"wechat_logo"] forState:UIControlStateNormal];
    [button4WeChatLogin addTarget:self action:@selector(onButtonWeChatLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4WeChatLogin];
    
    //其他登录方式
    if (self.loginOrder.count - 1 > 0)
    {
        NSInteger count = self.loginOrder.count - 1;
        UIView *view4OtherLoginMode = [[UIView alloc]initWithFrame:CGRectMake(0, 0, count * 80, 110)];
        
        for (int i = 0; i < count; i ++)
        {
            if ([[self.loginOrder objectAtIndex:(i + 1)]isEqualToString:@"m"])
            {
                button4MobileLogin = [[UIButton alloc]initWithFrame:CGRectMake(i * 80, 0, 80, 110)];
                [button4MobileLogin setTitleColor:THEME_COLOR forState:UIControlStateNormal];
                [button4MobileLogin setImage:[UIImage imageNamed:@"mobile_login"] forState:UIControlStateNormal];
                [button4MobileLogin addTarget:self action:@selector(onButtonMobileLogin:) forControlEvents:UIControlEventTouchUpInside];
                [view4OtherLoginMode addSubview:button4MobileLogin];
                
                UILabel *label4MobileLoginTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 90, 80, 20)];
                label4MobileLoginTitle.text = LLSTR(@"107109");
                label4MobileLoginTitle.font = [UIFont systemFontOfSize:12];
                label4MobileLoginTitle.textColor = [UIColor grayColor];
                label4MobileLoginTitle.textAlignment = NSTextAlignmentCenter;
                label4MobileLoginTitle.adjustsFontSizeToFitWidth = YES;
                [button4MobileLogin addSubview:label4MobileLoginTitle];
            }
        }
        
        view4OtherLoginMode.center = CGPointMake(self.view.frame.size.width / 2, bk_height + (self.view.frame.size.height - bk_height) / 2);
        [self.view addSubview:view4OtherLoginMode];
        
        //版本号
        UILabel *label4Version = [[UILabel alloc]initWithFrame:CGRectMake(15, self.view.frame.size.height - (isIphonex?50:30), self.view.frame.size.width - 30, 20)];
        label4Version.text = [NSString stringWithFormat:@"V %@", [BiChatGlobal getAppVersion]];
        label4Version.font = [UIFont systemFontOfSize:12];
        label4Version.textColor = [UIColor grayColor];
        label4Version.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label4Version];
    }
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (void)onButtonWeChatLogin:(id)sender
{
    //判断是否已经安装了微信
    if (![WXApi isWXAppInstalled]) {
        [BiChatGlobal showInfo:LLSTR(@"301608") withIcon:Image(@"icon_alert")];
        return;
    }
    
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"fulishe_wechat_logon_1290234" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
    
    //记录一下本窗口
    [BiChatGlobal sharedManager].weChatBindTarget = self;
}

- (void)onButtonMobileLogin:(id)sender
{
    LoginViewController *wnd = [LoginViewController new];
    wnd.canBack = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

#pragma mark - WeChatBindingNotify function

- (void)weChatBindingSuccess:(NSString *)code {
    
    if (code.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301601") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
        
    //开始进入微信登录阶段
    [BiChatGlobal ShowActivityIndicator];
    button4MobileLogin.userInteractionEnabled = NO;
    button4WeChatLogin.userInteractionEnabled = NO;
    [NetworkModule loginByWeChat:code completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //是新用户还是老用户
            if ([[data objectForKey:@"type"]integerValue] == 1)
            {                
                //进入下一步
                LoginViewController *wnd = [LoginViewController new];
                wnd.canBack = NO;
                wnd.weChatLoginParameters = data;
                wnd.myInviterInfo = [data objectForKey:@"inviter"];
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                [BiChatGlobal sharedManager].bLogin = YES;
                [BiChatGlobal sharedManager].loginMode = LOGIN_MODE_BY_VERIFYCODE;
                [BiChatGlobal sharedManager].token = [data objectForKey:@"token"];
                [BiChatGlobal sharedManager].uid = [data objectForKey:@"uid"];
                [BiChatGlobal sharedManager].createdTime = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"createdTime"]doubleValue] / 1000];
                [BiChatGlobal sharedManager].nickName = [data objectForKey:@"nickname"];
                [BiChatGlobal sharedManager].avatar = [data objectForKey:@"avatar"];
                NSArray *array = [[data objectForKey:@"username"]componentsSeparatedByString:@" "];
                if (array.count == 0)
                {
                    [BiChatGlobal sharedManager].lastLoginAreaCode = @"";
                    [BiChatGlobal sharedManager].lastLoginUserName = @"";
                }
                if (array.count == 1)
                {
                    [BiChatGlobal sharedManager].lastLoginAreaCode = @"";
                    [BiChatGlobal sharedManager].lastLoginUserName = [array firstObject];
                }
                else if (array.count > 1)
                {
                    [BiChatGlobal sharedManager].lastLoginAreaCode = [array firstObject];
                    [BiChatGlobal sharedManager].lastLoginUserName = [array objectAtIndex:1];
                }
                [[BiChatGlobal sharedManager]saveGlobalInfo];
                
                //加载一些数据
                [[BiChatGlobal sharedManager]loadUserInfo];
                [[BiChatGlobal sharedManager]loadUserAdditionInfo];
                [[BiChatGlobal sharedManager]loadUserEmotionInfo];
                [[BiChatGlobal sharedManager]downloadAllPendingSound];
                [[BiChatDataModule sharedDataModule]setuid:[BiChatGlobal sharedManager].uid];
                [[DFYTKDBManager sharedInstance] getMomentFromUser];

                [BiChatGlobal sharedManager].date4NetworkBroken = nil;
                [NetworkModule reconnect];
                [self dismissViewControllerAnimated:YES completion:nil];
                
                //进入首页
                [BiChatGlobal sharedManager].mainGUI.selectedIndex = 0;
                [[BiChatGlobal sharedManager].mainChatList refreshGUI];
                
                //全局通知一下
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGINOK object:nil];

                //获取一下最新的appconfig
                [NetworkModule getAppConfig:[BiChatGlobal sharedManager].systemConfigVersionNumber completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    [[BiChatGlobal sharedManager]processSystemConfigMessage:[data objectForKey:@"data"]];
                }];
                
                //重新获取一下本人的profile
                [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                
                //上传一下deviceid和环境
                [NetworkModule reportMyEnvironment:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                [NetworkModule reportMyNotificationId:[BiChatGlobal sharedManager].notificationDeviceToken completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
        }
        else if (errorCode == 111)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[BiChatGlobal sharedManager]forceUpgrade];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301604") withIcon:[UIImage imageNamed:@"icon_alert"]];
            button4WeChatLogin.userInteractionEnabled = YES;
            button4MobileLogin.userInteractionEnabled = YES;
        }
    }];
}

@end
