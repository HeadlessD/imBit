//
//  BindWeChat@RegisterViewController.m
//  BiChat
//
//  Created by Admin on 2018/4/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BindWeChat@RegisterViewController.h"
#import "WPMyInviterViewController.h"
#import "WXApi.h"
#import "MessageHelper.h"

@interface BindWeChat_RegisterViewController ()

@end

@implementation BindWeChat_RegisterViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    //    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"107116") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSkip:)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Configure the cell...30, 80, self.view.frame.size.width - 60, 40
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"107117");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 90, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"107118");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = [UIColor grayColor];
    [self.view addSubview:label4Subtitle];

    
    UIButton *button4BindWeChat = [[UIButton alloc]initWithFrame:CGRectMake(30, 210, self.view.frame.size.width - 60, 44)];
    button4BindWeChat.backgroundColor = THEME_GREEN;
    button4BindWeChat.titleLabel.font = [UIFont systemFontOfSize:16];
    button4BindWeChat.layer.cornerRadius = 5;
    button4BindWeChat.clipsToBounds = YES;
    [button4BindWeChat setImage:[UIImage imageNamed:@"wechat_logo"] forState:UIControlStateNormal];
    [button4BindWeChat setTitle:LLSTR(@"107119") forState:UIControlStateNormal];
    [button4BindWeChat addTarget:self action:@selector(onButtonBindWeChat:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4BindWeChat];
    
    UILabel *label4Tips = [[UILabel alloc]initWithFrame:CGRectMake(30, 265, self.view.frame.size.width - 60, 20)];
    label4Tips.text = LLSTR(@"107120");
    label4Tips.textAlignment = NSTextAlignmentCenter;
    label4Tips.font = [UIFont systemFontOfSize:14];
    label4Tips.textColor = [UIColor grayColor];
    label4Tips.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:label4Tips];
    
    // Do any additional setup after loading the view.
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

- (void)onButtonSkip:(id)sender
{
    //进入推荐人界面
    WPMyInviterViewController *wnd = [WPMyInviterViewController new];
    wnd.inviterDic = self.myInviterInfo;
    wnd.dismissOnFinish = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonBindWeChat:(id)sender
{
    //判断是否已经安装了微信
    if (![WXApi isWXAppInstalled])
    {
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

#pragma WeChatBindingNotify function

- (void)weChatBindingSuccess:(NSString *)code {
    
    if (code.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301601") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    
    //开始进入微信登录阶段
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule bindingWeChat:code completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        //NSLog(@"%@", data);
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //调整inviter
            if (self.myInviterInfo == nil &&
                [data objectForKey:@"inviter"] != nil)
                self.myInviterInfo = [data objectForKey:@"inviter"];
            
            //进入推荐人界面
            WPMyInviterViewController *wnd = [WPMyInviterViewController new];
            wnd.inviterDic = self.myInviterInfo;
            wnd.dismissOnFinish = YES;
            [self.navigationController pushViewController:wnd animated:YES];
            
            //如果有群id，后台进行加入群操作
            if ([self.myInviterInfo objectForKey:@"groupId"] != [NSNull null] &&
                [[self.myInviterInfo objectForKey:@"groupId"]length] > 0)
                [self joinGroup:[self.myInviterInfo objectForKey:@"groupId"]];
            
            //重新获取一下本人的profile
            [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        }
        else if (errorCode == 100031)
            [BiChatGlobal showInfo:LLSTR(@"301602") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
            [BiChatGlobal showInfo:LLSTR(@"301604") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

//加入群聊
- (void)joinGroup:(NSString *)groupId
{
    [NetworkModule apply4Group:groupId
                        source:[@{@"source": @"WECHAT_CODE"} mj_JSONString]
                completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    if (success)
                    {
                        //看看是否加入成功
                        if ([[data objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[data objectForKey:@"data"]count] == 1)
                        {
                            NSDictionary *item = [[data objectForKey:@"data"]objectAtIndex:0];
                            
                            //检查一下是不是群已经满？
                            if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"])
                            {
                                return;
                            }
                            
                            //已经在黑名单
                            else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"])
                            {
                                return;
                            }
                            
                            //已经在群里了
                            else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"])
                            {
                                return;
                            }
                            
                            //检查一下是不是需要确认
                            if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_PENDING_LIST"] ||
                                [[item objectForKey:@"result"]isEqualToString:@"NEED_APPROVE"])
                            {
                                //添加一条申请进入群的消息
                                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [BiChatGlobal sharedManager].uid, @"uid",
                                                        [BiChatGlobal sharedManager].nickName, @"nickName",
                                                        @"WECHAT", @"source", nil];
                                [MessageHelper sendGroupMessageTo:groupId
                                                             type:MESSAGE_CONTENT_TYPE_APPLYGROUP
                                                          content:[myInfo mj_JSONString]
                                                         needSave:YES
                                                         needSend:NO
                                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                   }];
                            }
                            else
                            {
                                //添加一条进入群的消息
                                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [BiChatGlobal sharedManager].uid, @"uid",
                                                        [BiChatGlobal sharedManager].nickName, @"nickName",
                                                        @"WECHAT", @"source", nil];
                                [MessageHelper sendGroupMessageTo:groupId
                                                             type:MESSAGE_CONTENT_TYPE_JOINGROUP
                                                          content:[myInfo mj_JSONString]
                                                         needSave:YES
                                                         needSend:YES
                                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                   }];
                            }
                            
                            //成功加入了群，先查一下这个群聊天是否在列表里面
                            for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]){
                                if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:groupId]) {
                                    return;
                                }
                            }
                            
                            //没有发现条目，新增一条
                            [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                        }
                    }
                }];
}

@end
