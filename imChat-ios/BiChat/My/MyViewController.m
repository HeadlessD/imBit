//
//  MyViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "MyViewController.h"
#import "SetupViewController.h"
#import "LoginPortalViewController.h"
#import "LoginViewController.h"
#import "MyVRCodeViewController.h"
#import "MyWalletViewController.h"
#import "MyFavoriteViewController.h"
#import "MyPorfileViewController.h"
#import "NetworkModule.h"
#import "MyWeChatBindingViewController.h"
#import "MyTokenViewController.h"
#import "MyInviteRewardViewController.h"
#import "MyForceViewController.h"
#import "PaymentPasswordSetupStep1ViewController.h"
#import "UIImageView+WebCache.h"
#import "JSONKit.h"
#import "ChatViewController.h"
#import "RewardPoolViewController.h"
#import "MyVersionViewController.h"
#import "RedPacketViewController.h"
#import "UserDetailViewController.h"
#import "DFTimeLineViewController.h"
#import "WPBiddingViewController.h"

@interface MyViewController ()


@end

@implementation MyViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (isIphonex)
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
        else
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    }
    else
    {
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101711");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    self.tableView.tableHeaderView = [self createMyInfoPanel];
    self.tableView.separatorColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    
    //扩展背景
    UIImageView *view4ExtentBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, -500, self.view.frame.size.width, 500)];
    view4ExtentBk.image = [UIImage imageNamed:@"nav_token"];
    [self.tableView addSubview:view4ExtentBk];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSysConfig) name:NOTIFICATION_SYSCONFIG object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    if (![BiChatGlobal sharedManager].bLogin)
    {
        [[BiChatGlobal sharedManager]loginPortal];
    }
    else
    {
        self.tableView.tableHeaderView = [self createMyInfoPanel];
        [self.tableView reloadData];
        
        //获取token信息
        [NetworkModule getTokenInfo:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                [BiChatGlobal sharedManager].dict4MyTokenInfo = data;
                [[BiChatGlobal sharedManager]saveGlobalInfo];
                self.tableView.tableHeaderView = [self createMyInfoPanel];
            }
        }];
        
        //获取我的钱包信息
        [NetworkModule getWallet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal sharedManager].dict4WalletInfo = data;
            [[BiChatGlobal sharedManager]saveUserInfo];
            self.tableView.tableHeaderView = [self createMyInfoPanel];
        }];
    }
    
    [timer4CountingDown invalidate];
    timer4CountingDown = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        label4CountingDown.text = [self getCountingDownTime];
    }];
    
    [timer4CheckMyBidInfo invalidate];
    timer4CheckMyBidInfo = [NSTimer scheduledTimerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self check4BidActiveHint];
    }];
    
//    //添加消息数提醒
//    [self addRedNum];
//    //添加红点提醒
//    [self addRedPointAvatar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [timer4CountingDown invalidate];
    [BiChatGlobal HideActivityIndicator];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([BiChatGlobal sharedManager].bLogin)
        return 5;
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0)
        return 1;
    else if (section == 1)
        return 1;
    else if (section == 2)
        return 2;
    else if (section == 3)
        return 3;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 0;
    else
        return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0.0000001;
    else
        return 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"my_wallet"]];
        image.center = CGPointMake(25, 25);
        [cell.contentView addSubview:image];
        UILabel *label4Text = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 70, 50)];
        label4Text.text = LLSTR(@"103000");
        label4Text.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Text];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        UIImageView *imageV = [[UIImageView alloc]initWithImage:Image(@"my_moments")];
        imageV.center = CGPointMake(25, 25);
        [cell.contentView addSubview:imageV];
        
        UILabel *label4Text = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 70, 50)];
        label4Text.text = LLSTR(@"104001");
        label4Text.text = LLSTR(@"104000");
        label4Text.font = [UIFont systemFontOfSize:16];
        
        label4Text.lineBreakMode = NSLineBreakByTruncatingTail;
        CGSize maximumLabelSize = CGSizeMake(100, 9999);
        CGSize expectSize = [label4Text sizeThatFits:maximumLabelSize];
        label4Text.frame = CGRectMake(50, 0, expectSize.width,50);
//        label4Text.backgroundColor = [UIColor greenColor];
        
        [cell.contentView addSubview:label4Text];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"my_favorite"]];
        image.center = CGPointMake(25, 25);
        [cell.contentView addSubview:image];
        
        UILabel *label4Text = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 70, 50)];
        label4Text.text = LLSTR(@"105000");
        label4Text.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Text];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 3 && indexPath.row == 0)
    {
        UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"my_feedback"]];
        image.center = CGPointMake(25, 25);
        [cell.contentView addSubview:image];
        
        UILabel *label4Text = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 170, 50)];
        label4Text.text = LLSTR(@"101013");
        label4Text.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Text];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 3 && indexPath.row == 1)
    {
        UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"group_setup"]];
        image.center = CGPointMake(25, 25);
        [cell.contentView addSubview:image];
        
        UILabel *label4Text = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 170, 50)];
        label4Text.text = LLSTR(@"106000");
        label4Text.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Text];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 3 && indexPath.row == 2)
    {
        UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"my_version"]];
        image.center = CGPointMake(25, 25);
        [cell.contentView addSubview:image];
        
        UILabel *label4Text = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 170, 50)];
        label4Text.text = LLSTR(@"107000");
        label4Text.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Text];
        
        //版本里面显示最新的版本号
        NSString *str4Version = [BiChatGlobal getAppVersion];
        UILabel *label4DetailText = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 120, 0, 90, 50)];
        label4DetailText.text = [NSString stringWithFormat:@"V %@", str4Version];
        label4DetailText.font = [UIFont systemFontOfSize:15];
        label4DetailText.textColor = [UIColor lightGrayColor];
        label4DetailText.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:label4DetailText];
        
        if ([[BiChatGlobal sharedManager].lastestVersion compare:str4Version options:NSNumericSearch] == NSOrderedDescending)
        {
            UIView *view4Attention = [[UIView alloc]initWithFrame:CGRectMake(85, 15, 10, 10)];
            view4Attention.layer.cornerRadius = 5;
            view4Attention.clipsToBounds = YES;
            view4Attention.backgroundColor = [UIColor redColor];
            [cell.contentView addSubview:view4Attention];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
    }
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        //先获取是否已经设置了支付密码
        if ([BiChatGlobal sharedManager].paymentPasswordSet)
        {
            MyWalletViewController * wnd = [MyWalletViewController new];
            wnd.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else    //还不确定，需要获取这个信息
        {
            [BiChatGlobal ShowActivityIndicator];
            self.view.userInteractionEnabled = NO;
            [NetworkModule isPaymentPasswordSet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                self.view.userInteractionEnabled = YES;
                //已经设置
                [BiChatGlobal HideActivityIndicator];
                if (success)
                {
                    //记录一下
                    [BiChatGlobal sharedManager].paymentPasswordSet = YES;
                    [[BiChatGlobal sharedManager]saveUserInfo];
                    
                    MyWalletViewController * wnd = [MyWalletViewController new];
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else if (errorCode == 1)    //还没有设置
                {
                    PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
                    wnd.resetPassword = NO;
                    wnd.hidesBottomBarWhenPushed = YES;
                    wnd.delegate = self;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else
                {
                    [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    [[BiChatGlobal sharedManager]imChatLog:@"----network error - 28", nil];
                }
            }];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {

        DFTimeLineViewController *controller = [[DFTimeLineViewController alloc] init];
        controller.timeLineId = [BiChatGlobal sharedManager].uid;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        MyFavoriteViewController *wnd = [MyFavoriteViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 3 && indexPath.row == 0)
    {
        if ([BiChatGlobal sharedManager].feedback.length == 0 ||
            feedbackProcessing) {
            return;
        }
        
        [BiChatGlobal ShowActivityIndicator];
        feedbackProcessing = YES;
        [self.tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
        [NetworkModule getPublicProperty:[BiChatGlobal sharedManager].feedback completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            feedbackProcessing = NO;
            [self.tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleDefault;
            [BiChatGlobal HideActivityIndicator];
            if (success) {
                
                ChatViewController *wnd = [ChatViewController new];
                wnd.peerUid = [data objectForKey:@"ownerUid"];
                wnd.peerAvatar = [data objectForKey:@"avatar"];
                wnd.peerNickName = [data objectForKey:@"groupName"];
                wnd.isPublic = YES;
                wnd.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wnd animated:YES];
                
                if ([[BiChatDataModule sharedDataModule] isChatExist:[data objectForKey:@"ownerUid"]]) {
                    return ;
                }
                NSString *strMessage = LLSTR(@"105103");
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_SYSTEM], @"type",
                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                             strMessage, @"content", nil];
                [[BiChatDataModule sharedDataModule]addChatContentWith:[data objectForKey:@"ownerUid"] content:item];
                [[BiChatDataModule sharedDataModule]setLastMessage:[data objectForKey:@"ownerUid"]
                                                      peerUserName:@""
                                                      peerNickName:[data objectForKey:@"groupName"]
                                                        peerAvatar:[data objectForKey:@"avatar"]
                                                           message:strMessage
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:NO
                                                          isPublic:YES
                                                         createNew:YES];
                
            } else {
                [BiChatGlobal showFailWithString:LLSTR(@"301003")];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 29", nil];
            }
        }];
    }
    else if (indexPath.section == 3 && indexPath.row == 1)
    {
        SetupViewController *wnd = [[SetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 3 && indexPath.row == 2)
    {
        MyVersionViewController *wnd = [[MyVersionViewController alloc]initWithStyle:UITableViewStyleGrouped];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
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

#pragma mark - paymentPasswordSetDelegate function

- (UIViewController *)paymentPasswordSetSuccess:(NSInteger)cookie
{
    //不用管cookie
    MyWalletViewController * wnd = [MyWalletViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    return wnd;
}

#pragma mark - 私有函数

- (void)check4BidActiveHint
{
    if ([BiChatGlobal sharedManager].myBidActiveInfo == nil ||
        [[NSDate date]compare:[NSDate dateWithTimeIntervalSince1970:[[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"nextTime"]longLongValue]/1000]] == NSOrderedDescending)
    {
        [NetworkModule getBidActiveTips:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
            {
                if ([[data objectForKey:@"batchNo"]isEqualToString:[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"batchNo"]] &&
                    [[data objectForKey:@"status"]integerValue] == [[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue])
                {
                    [BiChatGlobal sharedManager].myBidActiveInfo = data;
                }
                else
                {
                    [BiChatGlobal sharedManager].myBidActiveInfo = data;
                    if ([[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue] == 3 ||
                        ([[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue] == 9 &&
                         [[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"userOrder"]integerValue] > 0 &&
                         [[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"userStatus"]integerValue] != 2)||
                        [[[BiChatGlobal sharedManager].myBidActiveInfo objectForKey:@"status"]integerValue] == 17)
                        [BiChatGlobal sharedManager].showMyBidActiveHint = YES;
                    else
                        [BiChatGlobal sharedManager].showMyBidActiveHint = NO;
                }
                self.tableView.tableHeaderView = [self createMyInfoPanel];
            }
        }];
    }
}

- (void)onSysConfig
{
    [self.tableView reloadData];
}

- (void)onButtonSetup:(id)sender
{
    MyPorfileViewController *wnd = [[MyPorfileViewController alloc]initWithStyle:UITableViewStyleGrouped];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButton4MyVRCode:(id)sender
{
    MyVRCodeViewController *wnd = [MyVRCodeViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.tipType = @"fromProfile";
    [self.navigationController pushViewController:wnd animated:YES];
}

- (UIView *)createMyInfoPanel
{
#ifdef ENV_V_DEV
    UIView *view4MyInfoPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 230)];
#else
    UIView *view4MyInfoPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
#endif
    view4MyInfoPanel.clipsToBounds = YES;
    view4MyInfoPanel.backgroundColor = [UIColor whiteColor];
    
    //背景
    UIImageView *image4MyInfoBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, 232)];
    image4MyInfoBk.image = [UIImage imageNamed:@"myInfoBk"];
    [view4MyInfoPanel addSubview:image4MyInfoBk];
    
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil
                                            nickName:[BiChatGlobal sharedManager].nickName
                                              avatar:[BiChatGlobal sharedManager].avatar
                                               width:50 height:50];
    view4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 110);
    view4Avatar.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    view4Avatar.layer.borderWidth = 1;
    [view4MyInfoPanel addSubview:view4Avatar];
    
    UIButton *button4Avatar = [[UIButton alloc]initWithFrame:view4Avatar.frame];
    [button4Avatar addTarget:self action:@selector(onButtonSetup:) forControlEvents:UIControlEventTouchUpInside];
    [view4MyInfoPanel addSubview:button4Avatar];
    
    UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(10, 142, self.view.frame.size.width - 20, 20)];
    label4UserName.text = [BiChatGlobal sharedManager].nickName;
    label4UserName.font = [UIFont systemFontOfSize:16];
    label4UserName.textColor = [UIColor whiteColor];
    label4UserName.textAlignment = NSTextAlignmentCenter;
    [view4MyInfoPanel addSubview:label4UserName];
    
    //男女标识
    if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"gender"]integerValue] == 1)
    {
        UIImageView *image4Gender = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ico_man"]];
        image4Gender.center = CGPointMake(self.view.frame.size.width / 2 + 22, 126);
        [view4MyInfoPanel addSubview:image4Gender];
    }
    else if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"gender"]integerValue] == 2)
    {
        UIImageView *image4Gender = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ico_woman"]];
        image4Gender.center = CGPointMake(self.view.frame.size.width / 2 + 22, 126);
        [view4MyInfoPanel addSubview:image4Gender];
    }
    
    //手机号码
    UILabel *label4Mobile = [[UILabel alloc]initWithFrame:CGRectMake(10, 164, self.view.frame.size.width - 20, 20)];
    label4Mobile.text = [BiChatGlobal humanlizeMobileNumber:[BiChatGlobal sharedManager].lastLoginAreaCode mobile:[BiChatGlobal sharedManager].lastLoginUserName];
    label4Mobile.font = [UIFont systemFontOfSize:12];
    label4Mobile.textColor = [UIColor whiteColor];
    label4Mobile.textAlignment = NSTextAlignmentCenter;
    [view4MyInfoPanel addSubview:label4Mobile];
    
    UIButton *button4MyVRCode = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button4MyVRCode setImage:[UIImage imageNamed:@"my_vrcode"] forState:UIControlStateNormal];
    if (isIphonex)
        button4MyVRCode.center = CGPointMake(self.view.frame.size.width - 25, 55);
    else
        button4MyVRCode.center = CGPointMake(self.view.frame.size.width - 20, 45);
    [button4MyVRCode addTarget:self action:@selector(onButton4MyVRCode:) forControlEvents:UIControlEventTouchUpInside];
    [view4MyInfoPanel addSubview:button4MyVRCode];
    
    //箭头
    UIButton *button4Disclouser = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    button4Disclouser.center = CGPointMake(self.view.frame.size.width - 20, 110);
    [button4Disclouser setImage:[UIImage imageNamed:@"arrow_right"] forState:UIControlStateNormal];
    [button4Disclouser addTarget:self action:@selector(onButtonSetup:) forControlEvents:UIControlEventTouchUpInside];
    [view4MyInfoPanel addSubview:button4Disclouser];
        
    //计算项目的宽度
    CGFloat offset = 230;
    CGFloat itemWidth = (self.view.frame.size.width - 10) / 3;
    
    //奖池
    UILabel *label4AllPoolCount = [[UILabel alloc]initWithFrame:CGRectMake(5, offset + 3, itemWidth, 20)];
    label4AllPoolCount.text = [NSString stringWithFormat:@"%lld", [[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"rewardPool"]longLongValue]];
    label4AllPoolCount.font = [UIFont boldSystemFontOfSize:16];
    label4AllPoolCount.textAlignment = NSTextAlignmentCenter;
    [view4MyInfoPanel addSubview:label4AllPoolCount];
    
    //是否需要显示一个红点
    if ([BiChatGlobal sharedManager].showMyBidActiveHint)
    {
        UIView *view4RedPoint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
        view4RedPoint.layer.cornerRadius = 4;
        view4RedPoint.backgroundColor = [UIColor redColor];
        [label4AllPoolCount addSubview:view4RedPoint];
        
        CGRect rect = [label4AllPoolCount.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label4AllPoolCount.font} context:nil];
        view4RedPoint.center = CGPointMake(label4AllPoolCount.frame.size.width / 2 + rect.size.width / 2 + 5, 5);
    }

    UILabel *label4Waiting4UnlockTitle = [[UILabel alloc]initWithFrame:CGRectMake(5, offset + 25, itemWidth, 20)];
    label4Waiting4UnlockTitle.font = [UIFont systemFontOfSize:12];
    label4Waiting4UnlockTitle.textAlignment = NSTextAlignmentCenter;
    label4Waiting4UnlockTitle.textColor = THEME_GRAY;
    label4Waiting4UnlockTitle.text = [NSString stringWithFormat:@"    %@ ＞", LLSTR(@"108001")];
    
    [view4MyInfoPanel addSubview:label4Waiting4UnlockTitle];
    
    //获取bit信息
    NSDictionary *CoinInfo;
    for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:@"TOKEN"])
        {
            CoinInfo = item;
            break;
        }
    }
    NSString *format = [NSString stringWithFormat:@"%%.0%ldf", (long)[[CoinInfo objectForKey:@"bit"]integerValue]];
    
    //待解锁
    if ([BiChatGlobal sharedManager].dict4MyTokenInfo != nil)
    {
        UILabel *label4Locked = [[UILabel alloc]initWithFrame:CGRectMake(5 + itemWidth, offset + 3, itemWidth, 20)];
        if ([[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"tokenStatus"]integerValue] == 0)
            label4Locked.text = [NSString stringWithFormat:format, [[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"allotToken"]doubleValue]];
        else
            label4Locked.text = [NSString stringWithFormat:format, [[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"lockToken"]doubleValue]];
        label4Locked.font = [UIFont boldSystemFontOfSize:16];
        label4Locked.textAlignment = NSTextAlignmentCenter;
        [view4MyInfoPanel addSubview:label4Locked];
    }
    
    UILabel *label4LockedTitle = [[UILabel alloc]initWithFrame:CGRectMake(5 + itemWidth, offset + 25, itemWidth, 20)];
    if ([[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"tokenStatus"]integerValue] == 0)
        label4LockedTitle.text = [NSString stringWithFormat:@"    %@ ＞", LLSTR(@"101706")];

    else if ([[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"tokenStatus"]integerValue] == 1)
        label4LockedTitle.text = [NSString stringWithFormat:@"    %@ ＞", LLSTR(@"101701")];
    
    else
        label4LockedTitle.text = [NSString stringWithFormat:@"    %@ ＞", LLSTR(@"101708")];

    label4LockedTitle.font = [UIFont systemFontOfSize:12];
    label4LockedTitle.textAlignment = NSTextAlignmentCenter;
    label4LockedTitle.textColor = THEME_GRAY;
    [view4MyInfoPanel addSubview:label4LockedTitle];
    wizardStep1HighlightRect = CGRectMake(5 + itemWidth, offset + 10 - itemWidth / 2 + 10, itemWidth, itemWidth);

    //推荐奖励
    if ([BiChatGlobal sharedManager].dict4MyTokenInfo != nil)
    {
        UILabel *label4Bonu = [[UILabel alloc]initWithFrame:CGRectMake(5 + itemWidth * 2, offset + 3, itemWidth, 20)];
        label4Bonu.text = [NSString stringWithFormat:format, [[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"refUnlockToken"]doubleValue]];
        label4Bonu.font = [UIFont boldSystemFontOfSize:16];
        label4Bonu.textAlignment = NSTextAlignmentCenter;
        [view4MyInfoPanel addSubview:label4Bonu];
    }
    
    UILabel *label4BonuTitle = [[UILabel alloc]initWithFrame:CGRectMake(5 + itemWidth * 2, offset + 25, itemWidth, 20)];
    label4BonuTitle.text = [NSString stringWithFormat:@"    %@ ＞", LLSTR(@"101801")];

    label4BonuTitle.font = [UIFont systemFontOfSize:12];
    label4BonuTitle.textAlignment = NSTextAlignmentCenter;
    label4BonuTitle.textColor = THEME_GRAY;
    [view4MyInfoPanel addSubview:label4BonuTitle];
    
    view4TotalStep = [[UIView alloc]initWithFrame:CGRectMake(40, offset + 80, self.view.frame.size.width - 80, 4)];
    view4TotalStep.backgroundColor = THEME_TABLEBK;
    view4TotalStep.layer.cornerRadius = 2;
    view4TotalStep.clipsToBounds = YES;
    [view4MyInfoPanel addSubview:view4TotalStep];

    if ([BiChatGlobal sharedManager].dict4MyTokenInfo != nil)
    {        
        //进入按钮
        UIButton *button4MyAccount = [[UIButton alloc]initWithFrame:CGRectMake(0, 212, self.view.frame.size.width / 3, 80)];
        [button4MyAccount addTarget:self action:@selector(onButton4MyAccount:) forControlEvents:UIControlEventTouchUpInside];
        [view4MyInfoPanel addSubview:button4MyAccount];
        
        UIButton *button4MyToken = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 3, 212, self.view.frame.size.width / 3, 80)];
        [button4MyToken addTarget:self action:@selector(onButton4MyToken:) forControlEvents:UIControlEventTouchUpInside];
        [view4MyInfoPanel addSubview:button4MyToken];
        
        UIButton *button4MyInvite = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 3 * 2, 212, self.view.frame.size.width / 3, 80)];
        [button4MyInvite addTarget:self action:@selector(onButton4MyInvite:) forControlEvents:UIControlEventTouchUpInside];
        [view4MyInfoPanel addSubview:button4MyInvite];
    }

    return view4MyInfoPanel;
}

- (void)onButton4MyAccount:(id)sender
{
    [BiChatGlobal sharedManager].showMyBidActiveHint = NO;
    self.tableView.tableHeaderView = [self createMyInfoPanel];
    WPBiddingViewController *biddingVC = [[WPBiddingViewController alloc]init];
    biddingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:biddingVC animated:YES];
}

- (void)onButton4MyInvite:(id)sender
{
    MyInviteRewardViewController *wnd = [MyInviteRewardViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButton4MyToken:(id)sender
{
    MyTokenViewController *wnd = [[MyTokenViewController alloc]initWithStyle:UITableViewStyleGrouped];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButton4MyForce:(id)sender
{
    MyForceViewController *wnd = [MyForceViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.pushNAVC = self.navigationController;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (NSString *)getCountingDownTime
{
    //当前的日期的年月日
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm.ss";
    
    //起始点设置为东8区，北京时间
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3600 * 8]];
    
    //截止时间点
    fmt.dateFormat = @"yyyy/MM/dd 23:59:59";
    NSString *deadlineTimeString = [fmt stringFromDate:now];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm.ss";
    NSDate *deadlineTime = [fmt dateFromString:deadlineTimeString];
    
    NSTimeInterval interval = [deadlineTime timeIntervalSinceDate:now];    
    NSInteger i = (int)interval;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)i / 3600, (long)i % 3600 / 60, (long)i % 60];
}

- (void)showNewUserWizard
{
    if ([BiChatGlobal sharedManager].dict4MyTokenInfo == nil)
    {
        [self performSelector:@selector(showNewUserWizard) withObject:nil afterDelay:0.5];
        return;
    }
    self.tableView.contentOffset = CGPointMake(0, 0);
    newUserWizardStep = 1;
    [self createNewUserWizard];
}

- (void)createNewUserWizard
{
    //先清理
    [new4UserWizard removeFromSuperview];
    
    //开始创建
    if (newUserWizardStep == 1)
    {
        new4UserWizard = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.navigationController.tabBarController.view addSubview:new4UserWizard];
        
        //创建背景
        [BiChatGlobal createWizardBkForView:new4UserWizard highlightRect:wizardStep1HighlightRect];
        
        //创建Tip
        CGRect rect = [LLSTR(@"101883") boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:isIPhone5?[UIFont fontWithName:@"HYChenMeiZiW" size:18]:[UIFont fontWithName:@"HYChenMeiZiW" size:20]} context:nil];

        UILabel *label4Tips = [[UILabel alloc]initWithFrame:CGRectMake(20, wizardStep1HighlightRect.origin.y + wizardStep1HighlightRect.size.height + 20, self.view.frame.size.width - 20, rect.size.height)];
        label4Tips.text = [LLSTR(@"101883") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)[[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"allotToken"]integerValue]]]];
        label4Tips.textColor = [UIColor whiteColor];
        label4Tips.font = [UIFont fontWithName:@"HYChenMeiZiW" size:20];
        if (isIPhone5)
            label4Tips.font = [UIFont fontWithName:@"HYChenMeiZiW" size:18];
        label4Tips.numberOfLines = 0;
        [new4UserWizard addSubview:label4Tips];
        
        UIButton *button4NextStep = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 145, 52)];
        button4NextStep.titleLabel.font = [UIFont fontWithName:@"HYChenMeiZiW" size:20];
        button4NextStep.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 100);
        [button4NextStep setBackgroundImage:[UIImage imageNamed:@"wizard_button"] forState:UIControlStateNormal];
        [button4NextStep setTitle:LLSTR(@"101016") forState:UIControlStateNormal];
        [button4NextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button4NextStep addTarget:self action:@selector(onButtonNextStepWizard:) forControlEvents:UIControlEventTouchUpInside];
        [new4UserWizard addSubview:button4NextStep];
        
        if (!isIPhone5)
        {
            UIImageView *image4Decorate = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wizard_decorate1"]];
            image4Decorate.center = CGPointMake(self.view.frame.size.width - 40, wizardStep1HighlightRect.origin.y + 100);
            [new4UserWizard addSubview:image4Decorate];
        }
    }
}

- (void)onButtonNextStepWizard:(id)sender
{
    //进入下一步
    [new4UserWizard removeFromSuperview];
    
    self.navigationController.tabBarController.selectedIndex = 3;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SHOWFIRST object:nil];
    UINavigationController *nav = self.navigationController.tabBarController.selectedViewController;
    RedPacketViewController *wnd = (RedPacketViewController *)nav.topViewController;
    [wnd.myForceViewController showNewUserWizard];
}

@end
