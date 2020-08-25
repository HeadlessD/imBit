//
//  VerifyViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "NetworkModule.h"
#import "VerifyViewController.h"
#import "SetUserProfileViewController.h"
#import "WPMyInviterViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "JSONKit.h"
#import "pinyin.h"

@interface VerifyViewController ()

@end

@implementation VerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    view4VerifyCode1 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 140, 110, 30, 24)];
    view4VerifyCode1.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode1.font = [UIFont systemFontOfSize:24];
    view4VerifyCode2 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 90, 110, 30, 24)];
    view4VerifyCode2.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode2.font = [UIFont systemFontOfSize:24];
    view4VerifyCode3 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40, 110, 30, 24)];
    view4VerifyCode3.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode3.font = [UIFont systemFontOfSize:24];
    view4VerifyCode4 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 10, 110, 30, 24)];
    view4VerifyCode4.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode4.font = [UIFont systemFontOfSize:24];
    view4VerifyCode5 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 60, 110, 30, 24)];
    view4VerifyCode5.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode5.font = [UIFont systemFontOfSize:24];
    view4VerifyCode6 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 110, 110, 30, 24)];
    view4VerifyCode6.textAlignment = NSTextAlignmentCenter;
    view4VerifyCode6.font = [UIFont systemFontOfSize:24];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [input4VerifyCode becomeFirstResponder];
    
    label4Hint.text = [LLSTR(@"103007") llReplaceWithArray:@[[BiChatGlobal humanlizeMobileNumber:self.areaCode mobile:self.mobile]]];
    [self createResendTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer4ResendVerifyCode invalidate];
    timer4ResendVerifyCode = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 30, self.view.frame.size.width - 60, 30)];
    label4Title.text = LLSTR(@"103006");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label4Title];

    if (label4Hint == nil)
    {
        label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 20)];
        label4Hint.font = [UIFont systemFontOfSize:13];
        label4Hint.textColor = [UIColor grayColor];
        label4Hint.textAlignment = NSTextAlignmentCenter;
    }
    [cell.contentView addSubview:label4Hint];
    
    if (input4VerifyCode == nil)
    {
        input4VerifyCode = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 145, 100, 290, 40)];
        input4VerifyCode.font = [UIFont systemFontOfSize:0];
        input4VerifyCode.tintColor = [UIColor clearColor];
        input4VerifyCode.textAlignment = NSTextAlignmentCenter;
        [input4VerifyCode addTarget:self action:@selector(onVerifyCodeChanged:) forControlEvents:UIControlEventEditingChanged];
        input4VerifyCode.keyboardType = UIKeyboardTypeNumberPad;
    }
    [input4VerifyCode becomeFirstResponder];
    [cell.contentView addSubview:input4VerifyCode];
    
    //六根线和六个点
    view4Seperator1 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 145, 145, 40, 1)];
    view4Seperator1.backgroundColor = THEME_GRAY;
    [cell.contentView addSubview:view4Seperator1];
    view4Seperator2 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 95, 145, 40, 1)];
    view4Seperator2.backgroundColor = THEME_GRAY;
    [cell.contentView addSubview:view4Seperator2];
    view4Seperator3 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 45, 145, 40, 1)];
    view4Seperator3.backgroundColor = THEME_GRAY;
    [cell.contentView addSubview:view4Seperator3];
    view4Seperator4 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 5, 145, 40, 1)];
    view4Seperator4.backgroundColor = THEME_GRAY;
    [cell.contentView addSubview:view4Seperator4];
    view4Seperator5 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 55, 145, 40, 1)];
    view4Seperator5.backgroundColor = THEME_GRAY;
    [cell.contentView addSubview:view4Seperator5];
    view4Seperator6 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 105, 145, 40, 1)];
    view4Seperator6.backgroundColor = THEME_GRAY;
    [cell.contentView addSubview:view4Seperator6];
    
    [cell.contentView addSubview:view4VerifyCode1];
    [cell.contentView addSubview:view4VerifyCode2];
    [cell.contentView addSubview:view4VerifyCode3];
    [cell.contentView addSubview:view4VerifyCode4];
    [cell.contentView addSubview:view4VerifyCode5];
    [cell.contentView addSubview:view4VerifyCode6];
    
    [self freshVerifyCode];
    
    if (button4ResendVerifyCode == nil)
    {
        button4ResendVerifyCode = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 145, 150, 150, 40)];
        [button4ResendVerifyCode addTarget:self action:@selector(onButtonResendVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell.contentView addSubview:button4ResendVerifyCode];
    
    //是中国手机
    if ([self.areaCode isEqualToString:@"+86"])
    {
        button4VoiceVerify = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 145 - 80, 150, 80, 40)];
        button4VoiceVerify.titleLabel.font = [UIFont systemFontOfSize:12];
        button4VoiceVerify.titleLabel.textAlignment = NSTextAlignmentRight;
        [button4VoiceVerify setTitle:LLSTR(@"107121") forState:UIControlStateNormal];
        [button4VoiceVerify setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4VoiceVerify addTarget:self action:@selector(onButonVoiceVerify:) forControlEvents:UIControlEventTouchUpInside];
        button4VoiceVerify.hidden = YES;
        [cell.contentView addSubview:button4VoiceVerify];
    }
    
    if (label4ResendVerifyCodeHint == nil)
    {
        label4ResendVerifyCodeHint = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 145, 150, 150, 40)];
        label4ResendVerifyCodeHint.textAlignment = NSTextAlignmentLeft;
        label4ResendVerifyCodeHint.font = [UIFont systemFontOfSize:12];
        label4ResendVerifyCodeHint.adjustsFontSizeToFitWidth = YES;
    }
    [cell.contentView addSubview:label4ResendVerifyCodeHint];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 私有函数

- (void)createResendTimer
{
    //创建时钟
    [timer4ResendVerifyCode invalidate];
    timer4ResendVerifyCode = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        //获取当前手机号发送验证码的时间
        CGFloat intval = 100000;
        for (NSDictionary *item in [BiChatGlobal sharedManager].array4SendVerifyCodeInfo)
        {
            if ([[item objectForKey:@"mobile"]isEqualToString:self.mobile])
            {
                intval = [[NSDate date]timeIntervalSinceDate:[item objectForKey:@"timeStamp"]];
                break;
            }
        }
        
        if (intval > 60)
        {
            self->button4ResendVerifyCode.userInteractionEnabled = YES;
            self->label4ResendVerifyCodeHint.textColor = THEME_COLOR;
            self->label4ResendVerifyCodeHint.text = LLSTR(@"103009");
            self->button4VoiceVerify.hidden = NO;
            [self->timer4ResendVerifyCode invalidate];
            self->timer4ResendVerifyCode = nil;
        }
        else
        {
            self->button4ResendVerifyCode.userInteractionEnabled = NO;
            self->label4ResendVerifyCodeHint.textColor = THEME_GRAY;
            
            NSString * secTime = [NSString stringWithFormat:@"%d", (60 - (int)intval)];
            self->label4ResendVerifyCodeHint.text = [LLSTR(@"103008") llReplaceWithArray:@[secTime]];
        }
    }];
}

- (void)sendVerifyCode
{
    //开始发送获取验证码的命令
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule sendVerifyCode4Login:self.areaCode
                                 mobile:self.mobile
                         completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (isTimeOut)
        {
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:nil];
            
            //显示重新发送按钮
            button4ResendVerifyCode.userInteractionEnabled = YES;
            label4ResendVerifyCodeHint.textColor = THEME_COLOR;
            label4ResendVerifyCodeHint.text = LLSTR(@"103009");
            button4VoiceVerify.hidden = YES;
            [timer4ResendVerifyCode invalidate];
            timer4ResendVerifyCode = nil;
        }
        else if (success)
        {
            label4Hint.text = [LLSTR(@"103007") llReplaceWithArray:@[[BiChatGlobal humanlizeMobileNumber:self.areaCode mobile:self.mobile]]];
            [input4VerifyCode becomeFirstResponder];
            
            //记录一下当前时间
            if ([BiChatGlobal sharedManager].array4SendVerifyCodeInfo == nil)
                [BiChatGlobal sharedManager].array4SendVerifyCodeInfo = [NSMutableArray array];
            
            //先删除老数据
            for (int i = 0; i < [BiChatGlobal sharedManager].array4SendVerifyCodeInfo.count; i ++)
            {
                if ([[[[BiChatGlobal sharedManager].array4SendVerifyCodeInfo objectAtIndex:i]objectForKey:@"mobile"]isEqualToString:self.mobile])
                {
                    [[BiChatGlobal sharedManager].array4SendVerifyCodeInfo removeObjectAtIndex:i];
                    break;
                }
            }
            
            //加一个新的数据项
            [[BiChatGlobal sharedManager].array4SendVerifyCodeInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.mobile, @"mobile", [NSDate date], @"timeStamp", nil]];
            
            //开始进入倒计时
            [self createResendTimer];
        }
    }];
}

- (void)onButtonResendVerifyCode:(id)sender
{
    button4VoiceVerify.hidden = YES;
    [self sendVerifyCode];
}

- (void)onButonVoiceVerify:(id)sender
{
    //发送语音验证码
    button4VoiceVerify.userInteractionEnabled = NO;
    button4ResendVerifyCode.userInteractionEnabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule sendVoiceVerifyCode4Login:self.areaCode mobile:self.mobile completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        button4VoiceVerify.userInteractionEnabled = YES;
        button4ResendVerifyCode.userInteractionEnabled = YES;
        if (success)
            [BiChatGlobal showInfo:LLSTR(@"301911") withIcon:[UIImage imageNamed:@"icon_OK"]];
        else
            [BiChatGlobal showInfo:LLSTR(@"301912") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)onVerifyCodeChanged:(id)sender
{
    UITextField *input = (UITextField *)sender;
    if (input.text.length > 6) input.text = [input.text substringToIndex:6];
    if (input.text.length == 6)
        [self onButtonVerify:nil];
    [self freshVerifyCode];
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

- (void)onButtonVerify:(id)sender
{
    //检查参数
    if (input4VerifyCode.text.length != 6)
    {
        [BiChatGlobal showInfo:LLSTR(@"103006") withIcon:nil];
        return;
    }
    
    //判断是否重复发送命令
    if (verifyProcessing)
        return;
    
    NSString *weChatToken = [self.weChatLoginParameters objectForKey:@"token"];
    if (weChatToken.length != 32)
        weChatToken = @"";
    
    verifyProcessing = YES;
    input4VerifyCode.enabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    
    [NetworkModule loginByVerifyCode:self.areaCode
                              mobile:self.mobile
                          verifyCode:input4VerifyCode.text
                         weChatToken:weChatToken completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
     {
        [BiChatGlobal HideActivityIndicator];
        verifyProcessing = NO;
        input4VerifyCode.enabled = YES;
        if (success)
        {
            [BiChatGlobal sharedManager].bLogin = YES;
            [BiChatGlobal sharedManager].loginMode = LOGIN_MODE_BY_VERIFYCODE;
            [BiChatGlobal sharedManager].token = [data objectForKey:@"token"];
            [BiChatGlobal sharedManager].nickName = [data objectForKey:@"nickName"];
            [BiChatGlobal sharedManager].avatar = [data objectForKey:@"avatar"];
            [BiChatGlobal sharedManager].uid = [data objectForKey:@"uid"];
            [BiChatGlobal sharedManager].createdTime = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"createdTime"]doubleValue] / 1000];
            [BiChatGlobal sharedManager].lastLoginAreaCode = self.areaCode;
            [BiChatGlobal sharedManager].lastLoginUserName = self.mobile;
            [BiChatGlobal sharedManager].lastLoginPasswordMD5 = @"";
            [BiChatGlobal sharedManager].verifyCodeCount = 0;
            [[BiChatGlobal sharedManager]saveGlobalInfo];
            [[BiChatDataModule sharedDataModule]setuid:[data objectForKey:@"uid"]];
            
            //保存一下本人的头像到cache
            if ([BiChatGlobal sharedManager].avatar.length > 0)
                [[BiChatGlobal sharedManager].dict4AvatarCache setObject:[BiChatGlobal sharedManager].avatar forKey:[BiChatGlobal sharedManager].uid];
            
            //加载一些数据
            [[BiChatGlobal sharedManager]loadUserInfo];
            [[BiChatGlobal sharedManager]loadUserAdditionInfo];
            [[BiChatGlobal sharedManager]loadUserEmotionInfo];
            [[BiChatGlobal sharedManager]downloadAllPendingSound];
            [[DFYTKDBManager sharedInstance] getMomentFromUser];
            
            //看看是否需要设置昵称和头像
            if (![[data objectForKey:@"isNickNameSet"]boolValue] &&
                self.weChatLoginParameters == nil)
            {
                //进入设置界面
                SetUserProfileViewController *wnd = [SetUserProfileViewController new];
                wnd.bindWeChatOnDone = YES;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else if ([[data objectForKey:@"new"]boolValue])
            {
                WPMyInviterViewController *wnd = [WPMyInviterViewController new];
                wnd.inviterDic = self.myInviterInfo;
                wnd.dismissOnFinish = YES;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
                [self dismissViewControllerAnimated:YES completion:nil];
            
            //刷新主界面
            [[BiChatGlobal sharedManager].mainChatList refreshGUI];
            [BiChatGlobal sharedManager].mainGUI.selectedIndex = 0;
            
            //登录成功以后，马上获取通讯录列表
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id _Nullable data){}];
            [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data){
                if (success)
                {
                    [[DFYTKDBManager sharedInstance] getMomentFromUser];
                }
            }];
            
            //获取一下我的钱包信息
            [NetworkModule getWallet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    [BiChatGlobal sharedManager].dict4WalletInfo = data;
                    [[BiChatGlobal sharedManager]saveUserInfo];
                }
            }];
            
            //获取token信息
            [NetworkModule getTokenInfo:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                    [BiChatGlobal sharedManager].dict4MyTokenInfo = data;
            }];
            
            //全局通知一下
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGINOK object:nil];
            
            //获取一下最新的appconfig
            [NetworkModule getAppConfig:[BiChatGlobal sharedManager].systemConfigVersionNumber completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [[BiChatGlobal sharedManager]processSystemConfigMessage:[data objectForKey:@"data"]];
            }];
            
            //上传一下deviceid和环境
            [NetworkModule reportMyEnvironment:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            [NetworkModule reportMyNotificationId:[BiChatGlobal sharedManager].notificationDeviceToken completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        }
        else if (isTimeOut)
        {
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else if (errorCode == 111)
        {
            input4VerifyCode.text = nil;
            [self freshVerifyCode];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[BiChatGlobal sharedManager]forceUpgrade];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301913") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            input4VerifyCode.text = nil;
            [self freshVerifyCode];
        }
    }];
}

@end
