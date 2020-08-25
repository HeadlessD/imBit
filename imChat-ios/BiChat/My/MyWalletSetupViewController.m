//
//  MyWalletSetupViewController.m
//  BiChat
//
//  Created by Admin on 2018/4/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "MyWalletSetupViewController.h"
#import "PaymentPasswordSetupStep1ViewController.h"
#import "ChatViewController.h"
#import "WPMyOrderViewController.h"

@interface MyWalletSetupViewController ()

@end

@implementation MyWalletSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"103000");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"103002");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"103010");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"103018");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        //查找用户
        [NetworkModule getFriendByRefCode:[BiChatGlobal sharedManager].business completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
            {
                if (![[BiChatGlobal sharedManager]isFriendInContact:[data objectForKey:@"uid"]])
                {
                    [NetworkModule getUserProfileByUid:[data objectForKey:@"uid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success)
                        {
                            NSDictionary *userProfile = data;
                            [NetworkModule addFriend:[data objectForKey:@"userName"] source:@"" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                if (success)
                                {
                                    //设置此人备注名
                                    [NetworkModule setUserMemoNameByUid:[userProfile objectForKey:@"uid"]memoName:@"imChat Business" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                        if (success)
                                        {
                                            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                
                                                //进入聊天界面
                                                [self enterBusinessChat:[userProfile objectForKey:@"uid"] peerNickName:[userProfile objectForKey:@"nickName"] peerAvatar:[userProfile objectForKey:@"avatar"]];
                                                
                                            }];
                                        }
                                    }];
                                }
                                else
                                {
                                    [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                                    [[BiChatGlobal sharedManager]imChatLog:@"----network error - 34", nil];
                                    return;
                                }
                            }];
                        }
                        else
                        {
                            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 35", nil];
                            return;
                        }
                    }];
                }
                else
                    [self enterBusinessChat:[data objectForKey:@"uid"] peerNickName:[data objectForKey:@"nickName"] peerAvatar:[data objectForKey:@"avatar"]];
            }
            else
            {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 36", nil];
            }
        }];
    }
    else if (indexPath.section == 2 && indexPath.row == 0) {
        WPMyOrderViewController *orderVC = [[WPMyOrderViewController alloc]init];
        [self.navigationController pushViewController:orderVC animated:YES];
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

- (void)enterBusinessChat:(NSString *)peerUid
             peerNickName:(NSString *)peerNickName
               peerAvatar:(NSString *)peerAvatar
{
    if (![[BiChatDataModule sharedDataModule]isChatExist:peerUid])
    {
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"", @"content",
                                        [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_IMCHATBUSINESS_AD], @"type",
                                        peerUid , @"receiver",
                                        peerNickName, @"receiverNickName",
                                        peerAvatar, @"receiverAvatar",
                                        [BiChatGlobal sharedManager].uid, @"sender",
                                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                        [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                        msgId, @"msgId",
                                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                                        nil];
        [[BiChatDataModule sharedDataModule]addChatContentWith:peerUid content:message];
        [[BiChatDataModule sharedDataModule]setLastMessage:peerUid
                                              peerUserName:@""
                                              peerNickName:peerNickName
                                                peerAvatar:peerAvatar
                                                   message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                     isNew:NO
                                                   isGroup:NO
                                                  isPublic:NO
                                                 createNew:YES];
    }
    
    //进入聊天
    ChatViewController *wnd = [ChatViewController new];
    //wnd.isBusiness = YES;
    wnd.peerUid = peerUid;
    wnd.peerNickName = peerNickName;
    wnd.peerAvatar = peerAvatar;
    wnd.peerUserName = @"";
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

@end
