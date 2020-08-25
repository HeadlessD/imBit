//
//  SetupViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "SetupViewController.h"
#import "SetupPrivacyViewController.h"
#import "WPNewsDetailViewController.h"
#import "SetupNotificationViewController.h"
#import "WPDiscoverCashCleanViewController.h"
#import "ImChatLogViewController.h"
#import "JSONKit.h"
#import "DFChangeLanguageViewController.h"
#import "WPAccreditManagementViewController.h"

@interface SetupViewController ()

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"106000");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    self.tableView.tableFooterView = [self createPanel];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef ENV_V_DEV
    return 1;
#else
    return 2;
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 3;
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"106010");
//        LLSTR(@"106010");
        //cell.detailTextLabel.text = [BiChatGlobal sharedManager].bNotifyEnable?LLSTR(@"201333"):@"设置";
        //cell.accessoryType = [BiChatGlobal sharedManager].bNotifyEnable?UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator;
        //cell.selectionStyle = [BiChatGlobal sharedManager].bNotifyEnable?UITableViewCellSelectionStyleNone:UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"106100");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"106020");
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSString *currLanguage = [def valueForKey:DFAPPLANGUAGE];
        NSString * lanStr = [DFLanguageManager getkeyForValue:currLanguage dic:[DFLanguageManager getLanguageList]];
        if (!lanStr)lanStr = @"中文简体";
        
        cell.detailTextLabel.text = lanStr;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
#ifdef ENV_DEV
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif
#ifdef ENV_TEST
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif
#ifdef ENV_LIVE
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif
#ifdef ENV_CN
        
#endif
#ifdef ENV_ENT
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif
#ifdef ENV_V_DEV
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif

    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"106118");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        SetupNotificationViewController *wnd = [[SetupNotificationViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        SetupPrivacyViewController *wnd = [[SetupPrivacyViewController alloc]initWithStyle:UITableViewStyleGrouped];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
#ifdef ENV_DEV
        DFChangeLanguageViewController *cleanVC = [[DFChangeLanguageViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:cleanVC animated:YES];
#endif
#ifdef ENV_TEST
        DFChangeLanguageViewController *cleanVC = [[DFChangeLanguageViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:cleanVC animated:YES];
#endif
#ifdef ENV_LIVE
        DFChangeLanguageViewController *cleanVC = [[DFChangeLanguageViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:cleanVC animated:YES];
#endif
#ifdef ENV_CN

#endif
#ifdef ENV_ENT
        DFV_ChangeLanguageViewController *cleanVC = [[DFChangeLanguageViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:cleanVC animated:YES];
#endif
#ifdef ENV_V_DEV
        DFChangeLanguageViewController *cleanVC = [[DFChangeLanguageViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:cleanVC animated:YES];
#endif
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
//        WPDiscoverCashCleanViewController *cleanVC = [[WPDiscoverCashCleanViewController alloc]init];
//        [self.navigationController pushViewController:cleanVC animated:YES];
        
        WPAccreditManagementViewController *wnd = [[WPAccreditManagementViewController alloc]init];
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

#pragma mark - 私有函数

- (UIView *)createPanel
{
    UIView *view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 260)];
    
    //退出登录按钮
    UIButton *button4Logout = [[UIButton alloc]initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 44)];
    button4Logout.backgroundColor = [UIColor whiteColor];
    button4Logout.layer.cornerRadius = 5;
    button4Logout.clipsToBounds = YES;
    button4Logout.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Logout setTitle:LLSTR(@"107007") forState:UIControlStateNormal];
    [button4Logout setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button4Logout addTarget:self action:@selector(onButtonLogout:) forControlEvents:UIControlEventTouchUpInside];
    [view4Panel addSubview:button4Logout];

    UIButton *button4ShowLog = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, view4Panel.frame.size.height - 40, 40, 40)];
    [button4ShowLog addTarget:self action:@selector(onButtonShowLog:) forControlEvents:UIControlEventTouchDownRepeat];
    [view4Panel addSubview:button4ShowLog];
    
    return view4Panel;
}

- (void)onButtonShowLog:(id)sender
{
    ImChatLogViewController *wnd = [ImChatLogViewController new];
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonLogout:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"107008") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        //当前没有成功登录
        if ([[BiChatGlobal sharedManager].token length] == 0)
        {
            //网络模块重新连接
            [BiChatGlobal sharedManager].date4NetworkBroken = nil;
            [NetworkModule reconnect];
            [self clearCurrentUser];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            //全局通知一下
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGOUTOK object:nil];
            return;
        }
        else
        {
            //[BiChatGlobal ShowActivityIndicator];
            [NetworkModule logout:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
            
            //网络模块重新连接
            [BiChatGlobal sharedManager].date4NetworkBroken = nil;
            [NetworkModule reconnect];
            [self clearCurrentUser];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            //全局通知一下
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGOUTOK object:nil];
        }
        [DFMomentsManager clearMomentFromUser];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)clearCurrentUser
{
    //清除本地数据
    [BiChatGlobal sharedManager].bLogin = NO;
    [BiChatGlobal sharedManager].nickName = @"";
    [BiChatGlobal sharedManager].avatar = @"";
    [BiChatGlobal sharedManager].token = nil;
    [BiChatGlobal sharedManager].uid = @"";
    [BiChatGlobal sharedManager].createdTime = nil;
    [BiChatGlobal sharedManager].array4AllFriendGroup = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4AllGroup = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4BlackList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4Invite = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4MuteList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4StickList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4FoldList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4FollowList = [NSMutableArray array];
    [[BiChatGlobal sharedManager]saveGlobalInfo];
    [[BiChatGlobal sharedManager].webArray removeAllObjects];
    
    //清除一些其他数据
    [BiChatGlobal sharedManager].dict4MyTokenInfo = nil;
    [BiChatGlobal sharedManager].dict4MyTodayForceInfo = nil;
    [BiChatGlobal sharedManager].array4MyTodayBubble = nil;
    
    //聊天数据清除
    [[BiChatDataModule sharedDataModule]clearCurrentUserData];
}

@end
