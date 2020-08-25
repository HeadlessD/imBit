//
//  WPMyInviterViewController.m
//  BiChat Dev
//
//  Created by iMac on 2018/9/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPMyInviterViewController.h"
#import "WPInviteView.h"
#import "MessageHelper.h"

@interface WPMyInviterViewController ()

@property (nonatomic,strong)UILabel *titleLabel;

@end

@implementation WPMyInviterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int a = self.navigationController.navigationBarHidden ? 64 : 0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"107124") style:UIBarButtonItemStylePlain target:self action:@selector(doDelay:)];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 50 + a, self.view.frame.size.width - 60, 30)];
    self.titleLabel.text = LLSTR(@"102101");
    self.titleLabel.font = [UIFont systemFontOfSize:24];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80 + a, self.view.frame.size.width - 60, 40)];
    label4Subtitle.text = LLSTR(@"107125");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];

    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:changeButton];
    [changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.equalTo(@30);
        make.width.equalTo(@80);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(230);
    }];
    [changeButton setTitle:LLSTR(@"107126") forState:UIControlStateNormal];
    [changeButton setTitleColor:LightBlue forState:UIControlStateNormal];
    changeButton.titleLabel.font = Font(16);
    [changeButton addTarget:self action:@selector(doChange) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:confirmButton];
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.equalTo(@45);
        make.top.equalTo(changeButton.mas_bottom).offset(40);
        make.width.equalTo(@(ScreenWidth - 60));
    }];
    [confirmButton setTitle:LLSTR(@"101003") forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setBackgroundColor:LightBlue];
    confirmButton.titleLabel.font = Font(16);
    confirmButton.layer.cornerRadius = 3;
    confirmButton.layer.masksToBounds = YES;
    [confirmButton addTarget:self action:@selector(doConfirm:) forControlEvents:UIControlEventTouchUpInside];
    button4Confirm = confirmButton;
    [self freshConfirmButton];
    
    UILabel *label4Hint = [[UILabel alloc]init];
    [self.view addSubview:label4Hint];
    [label4Hint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20);
        make.top.equalTo(confirmButton.mas_bottom).offset(10);
        make.width.equalTo(@(ScreenWidth - 60));
    }];
    label4Hint.text = LLSTR(@"107127");
    label4Hint.textAlignment = NSTextAlignmentCenter;
    label4Hint.numberOfLines = 0;
    label4Hint.font = [UIFont systemFontOfSize:14];
    label4Hint.textColor = THEME_GRAY;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:[[self view] window]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:[[self view] window]];
}

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
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //如果没有邀请人，立即弹出输入框
    if ([[self.inviterDic objectForKey:@"uid"]length] == 0)
        [self doChange];
    else
        [self createUI];
}

- (void)createUI {
    for (WPInviteView *view in self.view.subviews) {
        if ([view isKindOfClass:[WPInviteView class]]) {
            [view removeFromSuperview];
        }
    }
    
    if ([[self.inviterDic objectForKey:@"wxInfo"]count] > 0)
    {
        WPInviteView *inviteV = [[WPInviteView alloc]init];
        inviteV.headIV.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [inviteV.headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [[[self.inviterDic objectForKey:@"wxInfo"]firstObject]objectForKey:@"avatar"]]]];
        inviteV.nameLabel.text = [[[self.inviterDic objectForKey:@"wxInfo"]firstObject]objectForKey:@"nickname"];
        inviteV.inveteLabel.text = [LLSTR(@"201030") llReplaceWithArray:@[[self.inviterDic objectForKey:@"nickName"]]];
        inviteV.headTypeIV.image = [UIImage imageNamed:@"icon_invite_weChat"];
        [self.view addSubview:inviteV];
        [inviteV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.width.equalTo(@(ScreenWidth - 40));
            make.top.equalTo(self.titleLabel.mas_bottom).offset(40);
            make.height.equalTo(@200);
        }];
    }
    else
    {
        WPInviteView *inviteV = [[WPInviteView alloc]init];
        [inviteV.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [self.inviterDic objectForKey:@"avatar"]] title:[self.inviterDic objectForKey:@"nickName"] size:CGSizeMake(50, 50) placeHolde:nil color:[UIColor lightGrayColor] textColor:[UIColor whiteColor]];
        inviteV.nameLabel.text = [self.inviterDic objectForKey:@"nickName"];
        inviteV.headTypeIV.image = [UIImage imageNamed:@"icon_invite_imChat"];
        [self.view addSubview:inviteV];
        [inviteV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.width.equalTo(@(ScreenWidth - 40));
            make.top.equalTo(self.titleLabel.mas_bottom).offset(40);
            make.height.equalTo(@200);
        }];
    }
}

- (void)doChange {
    
    //自定义一个窗口，用于输入RefCode
    UIView *view4InputRefCode = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 175)];
    view4InputRefCode.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    view4InputRefCode.layer.cornerRadius = 5;
    view4InputRefCode.clipsToBounds = YES;
    
    //title
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 270, 20)];
    label4Title.text = LLSTR(@"301925");
    label4Title.font = [UIFont systemFontOfSize:18];
    label4Title.numberOfLines = 0;
    label4Title.textAlignment = NSTextAlignmentCenter;
    [view4InputRefCode addSubview:label4Title];
    
    //subtitle
    UILabel *label4SubTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 40, 270, 20)];
    label4SubTitle.text = LLSTR(@"107128");
    label4SubTitle.font = [UIFont systemFontOfSize:14];
    label4SubTitle.textColor = [UIColor grayColor];
    label4SubTitle.numberOfLines = 0;
    label4SubTitle.textAlignment = NSTextAlignmentCenter;
    [view4InputRefCode addSubview:label4SubTitle];
    
    //输入框
    UIView *view4InputFrame = [[UIView alloc]initWithFrame:CGRectMake(15, 75, 270, 40)];
    view4InputFrame.backgroundColor = [UIColor whiteColor];
    view4InputFrame.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
    view4InputFrame.layer.borderWidth = 0.5;
    view4InputFrame.layer.cornerRadius = 3;
    [view4InputRefCode addSubview:view4InputFrame];
    
    UITextField *input4RefCode = [[UITextField alloc]initWithFrame:CGRectMake(20, 75, 250, 40)];
    input4RefCode.font = [UIFont systemFontOfSize:14];
    input4RefCode.placeholder = LLSTR(@"106121");
    input4RefCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    input4RefCode.delegate = self;
    [view4InputRefCode addSubview:input4RefCode];
    
    //确定取消按钮
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 125, 300, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    [view4InputRefCode addSubview:view4Seperator];
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(150, 125, 0.5, 50)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    [view4InputRefCode addSubview:view4Seperator];
    
    UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 125, 150, 50)];
    button4Cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Cancel setTitle:LLSTR(@"107124") forState:UIControlStateNormal];
    [button4Cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button4Cancel addTarget:self action:@selector(onButtonCancelInputRefCode:) forControlEvents:UIControlEventTouchUpInside];
    [view4InputRefCode addSubview:button4Cancel];
    
    UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(150, 125, 150, 50)];
    button4OK.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4OK setTitle:LLSTR(@"101001") forState:UIControlStateNormal];
    [button4OK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4OK addTarget:self action:@selector(onButtonOKInputRefCode:) forControlEvents:UIControlEventTouchUpInside];
    [view4InputRefCode addSubview:button4OK];
    objc_setAssociatedObject(button4OK, @"input4RefCode", input4RefCode, OBJC_ASSOCIATION_RETAIN);
    button4RefCodeInputOK = button4OK;
    [self disableRefCodeInputOKButton];
    
    [BiChatGlobal presentModalView:view4InputRefCode clickDismiss:NO delayDismiss:0 andDismissCallback:nil];
    [input4RefCode becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //非字母和数字要过滤掉
    for (int i = 0; i < string.length; i ++)
    {
        unichar c = [string characterAtIndex:i];
        if (!((c >= '0' && c <= '9')||(c >= 'a' && c <= 'z')||(c >= 'A' && c <= 'Z')))
            return NO;
    }

    if (string.length == 0 ){
        NSString *str = textField.text;
        str = [str stringByReplacingCharactersInRange:range withString:string];
        if (str.length >= 4 &&
            str.length <= 20)
            [self enableRefCodeInputOKButton];
        else
            [self disableRefCodeInputOKButton];
        return YES;
    }
    char commitChar = [string characterAtIndex:0];
    if (commitChar > 96 && commitChar < 123){
        NSString * lowercaseString = string.lowercaseString;
        NSString * str1 = [textField.text substringToIndex:range.location];
        NSString * str2 = [textField.text substringFromIndex:range.location];
        textField.text = [NSString stringWithFormat:@"%@%@%@",str1,lowercaseString,str2].lowercaseString;
        if (textField.text.length > 20)
            textField.text = [textField.text substringToIndex:20];
        if (textField.text.length >= 4 &&
            textField.text.length <= 20)
            [self enableRefCodeInputOKButton];
        else
            [self disableRefCodeInputOKButton];
        return NO;
    }
    else
    {
        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (str.length > 20)
        {
            textField.text = [str substringToIndex:20];
            [self enableRefCodeInputOKButton];
            return NO;
        }
        else
        {
            NSString *str = textField.text;
            str = [str stringByReplacingCharactersInRange:range withString:string];
            if (str.length >= 4 &&
                str.length <= 20)
                [self enableRefCodeInputOKButton];
            else
                [self disableRefCodeInputOKButton];
            return YES;
        }
    }
}

- (void)onButtonCancelInputRefCode:(id)sender
{
    [BiChatGlobal dismissModalView];
    
    //直接进入下一步
    [self doDelay:nil];    
}

- (void)onButtonOKInputRefCode:(id)sender
{
    UITextField *input4RefCode = objc_getAssociatedObject(sender, @"input4RefCode");
    if (input4RefCode.text.length == 0)
    {
        [self doChange];
        [BiChatGlobal showInfo:LLSTR(@"103006") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }
    else
    {
        //开始获取refCode详细信息
        [self requestRefCodeInfoWithCode:input4RefCode.text];
        [BiChatGlobal dismissModalView];
    }
}

- (void)freshConfirmButton
{
    if ([[self.inviterDic objectForKey:@"uid"]length] == 0)
    {
        button4Confirm.backgroundColor = [UIColor lightGrayColor];
        button4Confirm.enabled = NO;
    }
    else
    {
        button4Confirm.backgroundColor = THEME_COLOR;
        button4Confirm.enabled = YES;
    }
}

- (void)enableRefCodeInputOKButton
{
    [button4RefCodeInputOK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    button4RefCodeInputOK.enabled = YES;
}

- (void)disableRefCodeInputOKButton
{
    [button4RefCodeInputOK setTitleColor:THEME_GRAY forState:UIControlStateNormal];
    button4RefCodeInputOK.enabled = NO;
}

- (void)doConfirm:(id)sender
{
    if ([[self.inviterDic objectForKey:@"uid"]length] == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301916") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    if ([[self.inviterDic objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        [BiChatGlobal showInfo:LLSTR(@"301917") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //go
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule addMyInviter:[self.inviterDic objectForKey:@"uid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [BiChatGlobal showInfo:LLSTR(@"301918") withIcon:[UIImage imageNamed:@"icon_OK"]];
            
            //NSLog(@"%@", data);
            
            //重新下载通讯录
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [[BiChatGlobal sharedManager].mainChatList refreshGUI];
                [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
                [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
            }];
            
            //是否添加了好友
            if ([[data objectForKey:@"newFriend"]isKindOfClass:[NSArray class]] &&
                [[data objectForKey:@"newFriend"]count] > 0)
            {
                //添加一条系统消息
                NSMutableDictionary *peerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self.inviterDic objectForKey:@"uid"], @"uid",
                                                 [self.inviterDic objectForKey:@"nickName"], @"nickName", nil];
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInteger:1], @"index",
                                             [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND], @"type",
                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                             [peerInfo mj_JSONString], @"content",
                                             nil];
                if (![[BiChatDataModule sharedDataModule]isChatExist:[self.inviterDic objectForKey:@"uid"]])
                {
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[self.inviterDic objectForKey:@"uid"] content:item];
                    [[BiChatDataModule sharedDataModule]setLastMessage:[self.inviterDic objectForKey:@"uid"]
                                                          peerUserName:[self.inviterDic objectForKey:@"userName"]
                                                          peerNickName:[self.inviterDic objectForKey:@"nickName"]
                                                            peerAvatar:[self.inviterDic objectForKey:@"avatar"]
                                                               message:[BiChatGlobal getMessageReadableString:item groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:NO
                                                              isPublic:NO
                                                             createNew:YES];
                }
                
                //同时发给对方一条系统消息
                peerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid", [BiChatGlobal sharedManager].nickName, @"nickName", nil];
                item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInteger:1], @"index",
                        [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND], @"type",
                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                        [peerInfo mj_JSONString], @"content",
                        @"0", @"isGroup",
                        [BiChatGlobal sharedManager].uid, @"sender",
                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                        [self.inviterDic objectForKey:@"uid"], @"receiver",
                        [self.inviterDic objectForKey:@"nickName"], @"receiverNickName",
                        [self.inviterDic objectForKey:@"avatar"]==nil?@"":[self.inviterDic objectForKey:@"avatar"], @"receiverAvatar",
                        nil];
                
                //发给对方用于显示
                [NetworkModule sendMessageToUser:[self.inviterDic objectForKey:@"uid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
                
                //发送一条对方通讯录已经改变的消息
                item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInteger:2], @"index",
                        [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CONTACTCHANGED], @"type",
                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                        @"", @"content",
                        @"0", @"isGroup",
                        [BiChatGlobal sharedManager].uid, @"sender",
                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                        [self.inviterDic objectForKey:@"uid"], @"receiver",
                        [self.inviterDic objectForKey:@"nickName"], @"receiverNickName",
                        [self.inviterDic objectForKey:@"avatar"]==nil?@"":[self.inviterDic objectForKey:@"avatar"], @"receiverAvatar",
                        nil];
                [NetworkModule sendMessageToUser:[self.inviterDic objectForKey:@"uid"] message:item completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
            }
            
            //是否加入了群
            if ([[[data objectForKey:@"joinGroupResult"]objectForKey:@"data"]isKindOfClass:[NSArray class]] &&
                [[[data objectForKey:@"joinGroupResult"]objectForKey:@"data"]count] > 0)
            {
                NSDictionary *joinGroupData = [[[data objectForKey:@"joinGroupResult"]objectForKey:@"data"]firstObject];
                if ([[joinGroupData objectForKey:@"result"]isEqualToString:@"NEED_APPROVE"])
                {
                    if ([[joinGroupData objectForKey:@"joinedGroupId"]length] > 0)
                    {
                        //获取群信息
                        NSString *groupId = [joinGroupData objectForKey:@"joinedGroupId"];
                        [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            if (success)
                            {
                                //添加一条申请进入群的消息
                                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [BiChatGlobal sharedManager].uid, @"uid",
                                                        [BiChatGlobal sharedManager].nickName, @"nickName",
                                                        [self.inviterDic objectForKey:@"uid"], @"refUid",
                                                        [self.inviterDic objectForKey:@"nickName"], @"refNickName",
                                                        @"REFCODE", @"source", nil];
                                [MessageHelper sendGroupMessageTo:[joinGroupData objectForKey:@"joinedGroupId"]
                                                             type:MESSAGE_CONTENT_TYPE_APPLYGROUP
                                                          content:[myInfo mj_JSONString]
                                                         needSave:YES
                                                         needSend:NO
                                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                   }];
                            }
                        }];
                    }
                }
                else
                {
                    //以上发送了一条点对点消息，建立了点对点会话，接下来发送群消息
                    if ([[joinGroupData objectForKey:@"joinedGroupId"]length] > 0)
                    {
                        //获取群信息
                        NSString *groupId = [joinGroupData objectForKey:@"joinedGroupId"];
                        [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            if (success)
                            {
                                //添加一条进入群的消息
                                NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [BiChatGlobal sharedManager].uid, @"uid",
                                                        [BiChatGlobal sharedManager].nickName, @"nickName",
                                                        [self.inviterDic objectForKey:@"uid"], @"refUid",
                                                        [self.inviterDic objectForKey:@"nickName"], @"refNickName",
                                                        @"REFCODE", @"source", nil];
                                [MessageHelper sendGroupMessageTo:groupId
                                                             type:MESSAGE_CONTENT_TYPE_JOINGROUP
                                                          content:[myInfo mj_JSONString]
                                                         needSave:YES
                                                         needSend:YES
                                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                       [[BiChatGlobal sharedManager].mainChatList refreshGUI];
                                                    }];
                            }
                        }];
                    }
                }
            }
            
            if (self.dismissOnFinish)
                [self dismissViewControllerAnimated:YES completion:nil];
            else
                [self.navigationController popViewControllerAnimated:YES];
        }
        else if (errorCode == 2)
            [BiChatGlobal showInfo:LLSTR(@"301920") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else if (errorCode == 3)
            [BiChatGlobal showInfo:LLSTR(@"301917") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else if (errorCode == 4)
            [BiChatGlobal showInfo:LLSTR(@"301921") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
            [BiChatGlobal showInfo:LLSTR(@"301919") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)doDelay:(id)sender
{
    long interval = [[NSDate date] timeIntervalSinceDate:[BiChatGlobal sharedManager].createdTime];
    long resultInterval = 24 * 3600 - interval;
    if (resultInterval <= 0) {
        if (self.dismissOnFinish)
            [self dismissViewControllerAnimated:YES completion:nil];
    }
    long hour = resultInterval / 3600;
    long minute = (resultInterval % 3600) / 60;
    long second = resultInterval % 60;
    NSString *titleStr = nil;
    if (hour > 0 && minute == 0) {
        NSString * hourStr = [NSString stringWithFormat:@"%ld",hour];
        titleStr = [LLSTR(@"101046") llReplaceWithArray:@[hourStr]];
//        [NSString stringWithFormat:@"%ld小时",hour];
    } else if (hour > 0 && minute > 0) {
        NSString * hourStr = [NSString stringWithFormat:@"%ld",hour];
        NSString * minuteStr = [NSString stringWithFormat:@"%ld",minute];
        titleStr = [LLSTR(@"101048") llReplaceWithArray:@[hourStr,minuteStr]];
//        [NSString stringWithFormat:@"%ld小时%ld分钟",hour,minute];
    } else if (hour == 0 && minute > 0) {
        NSString * minuteStr = [NSString stringWithFormat:@"%ld",minute];
        titleStr = [LLSTR(@"101047") llReplaceWithArray:@[minuteStr]];
//        [NSString stringWithFormat:@"%ld分钟",minute];
    } else if (hour == 0 && minute == 0 && second > 0) {
        titleStr = [LLSTR(@"101047") llReplaceWithArray:@[@"1"]];
//        @"1分钟";
    } else {
        if (self.dismissOnFinish)
            [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:[LLSTR(@"107130") llReplaceWithArray:@[titleStr]] message:LLSTR(@"107131") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101023") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.dismissOnFinish)
            [self dismissViewControllerAnimated:YES completion:nil];
        else
            [self.navigationController popViewControllerAnimated:YES];

    }];
    [action1 setValue:LightBlue forKey:@"_titleTextColor"];
    [alertC addAction:action1];
    [self presentViewController:alertC animated:YES completion:nil];
}

//根据RefCode获取用户信息
- (void)requestRefCodeInfoWithCode:(NSString *)RefCode {
    if (RefCode.length == 0) {
        [BiChatGlobal showFailWithString:LLSTR(@"301925")];
        return;
    }
    
    //输入的refCode需要修正
    RefCode = [RefCode stringByReplacingOccurrencesOfString:@"I" withString:@"1"];
    RefCode = [RefCode stringByReplacingOccurrencesOfString:@"O" withString:@"0"];
    
    //网络操作
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getFriendByRefCode:RefCode completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //NSLog(@"%@", data);
            self.inviterDic = data;
            [self createUI];
            [self freshConfirmButton];
        }
        else if (errorCode == 2)
            [BiChatGlobal showInfo:LLSTR(@"301922") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
            [BiChatGlobal showInfo:LLSTR(@"301929") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
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

- (void)keyboardWillShow:(NSNotification *)note
{
    //self.move = YES;
    NSDictionary *userInfo = [note userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system.
    // The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    //当前是否有prensentedView
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
    {
        CGRect frame = presentedView.frame;
        frame.origin.y = keyboardRect.origin.y - frame.size.height - 10;
        presentedView.frame = frame;
        
        if (presentedView.center.y > presentedView.superview.frame.size.height / 2)
            presentedView.center = CGPointMake(presentedView.superview.frame.size.width / 2, presentedView.superview.frame.size.height / 2);
    }
    
    //[UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    //    if(self.parentPageViewController) [self.parentPageViewController.view setFrame:viewFrame];
    //    else [self.view setFrame:viewFrame];
    //} completion:^(BOOL finished) {}];
    
    
    //if([self.inputText isFirstResponder]) [self.chatTable scrollBubbleViewToBottomAnimated:YES];
    //if([self.inputText isFirstResponder]) [self performSelector:@selector(delayedScroll) withObject:nil afterDelay:0.1];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
        presentedView.center = CGPointMake(presentedView.superview.frame.size.width / 2, presentedView.superview.frame.size.height / 2);
}

@end
