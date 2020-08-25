//
//  AddFriendViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "AddFriendViewController.h"
#import "AddMemoViewController.h"
#import "UserDetailViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "FriendFromLocalContactViewController.h"
#import "ScanViewController.h"
#import "NetworkModule.h"
#import "ChatViewController.h"
#import "UserSelectorViewController.h"
#import "MessageHelper.h"
#import "WPGroupAddMiddleViewController.h"
#import "TextRenderViewController.h"
#import "WPNewsDetailViewController.h"
#import "WPAuthenticationConfirmViewController.h"
#import "WPProductInputView.h"
#import "WPPaySuccessViewController.h"
#import "TransferMoneyViewController.h"

@interface AddFriendViewController ()

@property (nonatomic,strong)WPProductInputView *inputV;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    self.navigationItem.title = LLSTR(@"101201");
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;

    //self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
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
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    cell.detailTextLabel.textColor = THEME_GRAY;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        UIImageView *image4Search = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search"]];
        image4Search.center = CGPointMake(30, 25);
        [cell.contentView addSubview:image4Search];
        
        if (input4UserMobile == nil)
        {
            input4UserMobile = [[UITextField alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 80, 50)];
            input4UserMobile.placeholder = LLSTR(@"106103");
            [input4UserMobile addTarget:self action:@selector(onInput4UserMobileChanged:) forControlEvents:UIControlEventEditingChanged];
            input4UserMobile.font = [UIFont systemFontOfSize:14];
            input4UserMobile.keyboardType = UIKeyboardTypePhonePad;
            input4UserMobile.returnKeyType = UIReturnKeySearch;
        }
        [input4UserMobile becomeFirstResponder];
        [cell.contentView addSubview:input4UserMobile];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.imageView.image = [UIImage imageNamed:@"add_fromscan"];
        cell.textLabel.text = LLSTR(@"101303");
        cell.detailTextLabel.text = LLSTR(@"101202");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        cell.imageView.image = [UIImage imageNamed:@"add_fromcontact"];
        cell.textLabel.text = LLSTR(@"101203");
        cell.detailTextLabel.text = LLSTR(@"101206");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
//    else if (indexPath.section == 1 && indexPath.row == 2)
//    {
//        cell.imageView.image = [UIImage imageNamed:@"add_service"];
////        cell.textLabel.text = @"公号";
//        cell.textLabel.text = LLSTR(@"101215");
//        cell.detailTextLabel.text = LLSTR(@"101315");
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        ScanViewController *scanViewContr = [[ScanViewController alloc] init];
        scanViewContr.view.backgroundColor = [UIColor whiteColor];
        scanViewContr.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:scanViewContr];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        FriendFromLocalContactViewController *wnd = [FriendFromLocalContactViewController new];
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

#pragma mark - UITextFieldDelegate function

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == input4UserMobile)
    {
        [self beginSearch];
    }
    return YES;
}

#pragma mark - QRCode scan delegate

- (void)license:(NSString *)license {
    WEAKSELF;
    NSDictionary *dict = [license judGroupWithRegex:[BiChatGlobal sharedManager].shortLinkPattern];
    if ([license hasPrefix:@"imChatGroupManageScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:29];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule scanGroupManagement:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301504") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301503") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    
    //扫码登录
    if ([license hasPrefix:@"imChatScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:18];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule scanLoginWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301502") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301501") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    
    //扫码登录公号管理平台
    if ([license hasPrefix:@"imChatManageScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:24];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule scanPublicManaemengLogingWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301504") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301503") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    else if ([license judgeWithRegex:[[BiChatGlobal sharedManager].urlList objectForKey:@"scanCodeLogin"]]) {
        NSDictionary *dict = [license getUrlParams];
        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/getScanCodeInfo" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"ticket":[NSString stringWithFormat:@"%@",[dict objectForKey:@"ticket"]],@"language":[DFLanguageManager getLanguageName]} success:^(id response) {
            if ([[response objectForKey:@"code"] integerValue] == 0) {
                //扫码登录
                if ([[response objectForKey:@"qrType"]integerValue] == 1) {
                    WPAuthenticationConfirmViewController *confirmVC = [[WPAuthenticationConfirmViewController alloc]init];
                    confirmVC.contentDic = response;
                    confirmVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:confirmVC animated:YES];
                    confirmVC.ConfirmBlock = ^{
                        [self.navigationController popViewControllerAnimated:YES];
                        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":[response objectForKey:@"uuid"],@"isCancel":@"0"} success:^(id resp) {
                            if ([[resp objectForKey:@"code"] integerValue] == 0) {
                                [BiChatGlobal showSuccessWithString:LLSTR(@"301507")];
                            } else {
                                [BiChatGlobal showFailWithString:[NSString stringWithFormat:@"%@",[resp objectForKey:@"mess"]]];
                            };
                        } failure:^(NSError *error) {
                            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
                        }];
                    };
                    confirmVC.CancelBlock = ^{
                        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":[response objectForKey:@"uuid"],@"isCancel":@"1"} success:^(id resp) {
                            if ([[response objectForKey:@"code"] integerValue] == 0) {
                                [self.navigationController popViewControllerAnimated:YES];
                                [BiChatGlobal showSuccessWithString:LLSTR(@"301809")];
                            } else {
                                [BiChatGlobal showFailWithString:[NSString stringWithFormat:@"%@",[response objectForKey:@"mess"]]];
                            };
                        } failure:^(NSError *error) {
                        }];
                    };
                }
                //扫码支付
                else if ([[response objectForKey:@"qrType"]integerValue] == 11) {
                    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:[response objectForKey:@"payCoinType"]];
                    [weakSelf inputClose];
                    self.inputV = [[WPProductInputView alloc] initWithFrame:CGRectMake(0, self.tableView.contentOffset.y, ScreenWidth, ScreenHeight)];
                    [self.view addSubview:self.inputV];
                    [self.inputV setCoinImag:[coinInfo objectForKey:@"imgGold"] count:[[NSString stringWithFormat:@"%@",[response objectForKey:@"payAmount"]] accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%@",[coinInfo objectForKey:@"bit"]] auotCheck:YES] coinName:[coinInfo objectForKey:@"dSymbol"] payTo:[response objectForKey:@"ownerName"] payDesc:[response objectForKey:@"orderDesc"] wallet:0];
                    self.tableView.scrollEnabled = NO;
                    
                    self.inputV.closeBlock = ^{
                        [weakSelf inputClose];
                    };
                    self.inputV.passwordInputBlock = ^(NSString * _Nonnull password) {
                        [[WPBaseManager baseManager] postInterface:@"Chat/ApiPay/requestOrder.do" parameters:@{@"transaction_id":[response objectForKey:@"transaction_id"],@"password":[password md5Encode]} success:^(id resp1) {
                            [weakSelf inputClose];
                            if ([[resp1 objectForKey:@"code"] integerValue] == 0) {
                                [weakSelf showPaySuccessWithInfo:resp1];
                                
                            } else {
                                [BiChatGlobal showFailWithString:[resp1 objectForKey:@"mess"]];
                            }
                        } failure:^(NSError *error) {
                            [weakSelf inputClose];
                            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
                        }];
                    };
                }
                //扫码授权
                else if ([[response objectForKey:@"qrType"]integerValue] == 14 ||
                         [[response objectForKey:@"qrType"]integerValue] == 15 ||
                         [[response objectForKey:@"qrType"]integerValue] == 16) {
                    WPAuthenticationConfirmViewController *confirmVC = [[WPAuthenticationConfirmViewController alloc]init];
                    confirmVC.scanDic = response;
                    confirmVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:confirmVC animated:YES];
                    confirmVC.ConfirmBlock = ^{
                        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":[response objectForKey:@"uuid"],@"isCancel":@"0"} success:^(id resp) {
                            if ([[response objectForKey:@"errorCode"] integerValue] == 0) {
                                [BiChatGlobal showSuccessWithString:LLSTR(@"301509")];
                                [self.navigationController popViewControllerAnimated:YES];
                                
                                //需要发消息
                                if ([[resp objectForKey:@"qrType"]integerValue] == 16)
                                {                                    
                                    //发给所有的subGroupId
                                    for (NSString *subGroupId in [resp objectForKey:@"subGroupList"])
                                    {
                                        [MessageHelper sendGroupMessageToUser:[resp objectForKey:@"authUid"]
                                                                      groupId:subGroupId
                                                                         type:MESSAGE_CONTENT_TYPE_ROLEAUTHORIZE
                                                                      content:[@{@"uid": [resp objectForKey:@"authUid"], @"nickName": [resp objectForKey:@"authNickName"], @"avatar": [resp objectForKey:@"authAvatar"]} mj_JSONString]
                                                                     needSave:YES
                                                                     needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                                     }];
                                    }
                                    
                                    //发给所有的authSubGroupList
                                    for (NSString *authSubGroupId in [resp objectForKey:@"authSubGroupList"])
                                    {
                                        [MessageHelper sendGroupMessageToUser:[resp objectForKey:@"authUid"]
                                                                      groupId:authSubGroupId
                                                                         type:MESSAGE_CONTENT_TYPE_ROLEAUTHORIZE
                                                                      content:[@{@"uid": [resp objectForKey:@"authUid"], @"nickName": [resp objectForKey:@"authNickName"], @"avatar": [resp objectForKey:@"authAvatar"]} mj_JSONString]
                                                                     needSave:NO
                                                                     needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                                     }];
                                    }
                                }

                            } else {
                                [BiChatGlobal showFailWithString:LLSTR(@"301510")];
                            }
                        } failure:^(NSError *error) {
                            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
                        }];
                    };
                    confirmVC.CancelBlock = ^{
                        [BiChatGlobal showSuccessWithString:LLSTR(@"301511")];
                        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/confirmScanCode" parameters:@{@"uuid":[response objectForKey:@"uuid"],@"isCancel":@"1"} success:^(id resp) {
                            
                        } failure:^(NSError *error) {
                            
                        }];
                    };
                }
                //扫码转账
                else if ([[response objectForKey:@"qrType"]integerValue] == 13) {
                    TransferMoneyViewController *wnd = [TransferMoneyViewController new];
                    wnd.peerId = [response objectForKey:@"ownerId"];
                    wnd.peerNickName = [response objectForKey:@"ownerName"];
                    wnd.peerAvatar = [response objectForKey:@"ownerPic"];
                    wnd.authCheck = YES;
                    wnd.ticket = [dict objectForKey:@"ticket"];
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                    nav.navigationBar.translucent = NO;
                    nav.navigationBar.tintColor = THEME_COLOR;
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }
            } else {
                [BiChatGlobal showFailWithString:[NSString stringWithFormat:@"%@",[response objectForKey:@"mess"]]];
            }
        } failure:^(NSError *error) {
            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
        }];
        return;
    }
    //是加入群组
    else if ([license rangeOfString:IMCHAT_GROUPLINK_MARK].length > 0 &&
             [license rangeOfString:IMCHAT_USERLINK_MARK].length > 0)
    {
        NSInteger pt = [license rangeOfString:IMCHAT_GROUPLINK_MARK].location;
        NSString *groupId = [license substringFromIndex:(pt + IMCHAT_GROUPLINK_MARK.length)];
        NSRange range = [groupId rangeOfString:@"&"];
        if (range.length > 0)
            groupId = [groupId substringToIndex:range.location];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success) {
                BOOL inner = NO;
                for (NSDictionary *dict in [data objectForKey:@"groupUserList"]) {
                    if ([[dict objectForKey:@"uid"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
                        inner = YES;
                    }
                }
                if (inner) {
                    for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]){
                        if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:groupId]) {
                            //进入聊天界面
                            ChatViewController *wnd = [ChatViewController new];
                            wnd.isGroup = YES;
                            wnd.peerUid = groupId;
                            wnd.peerNickName = [item objectForKey:@"peerNickName"];
                            wnd.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:wnd animated:YES];
                            return;
                        }
                    }
                    //没有发现条目，新增一条
                    [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                    //进入
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.isGroup = YES;
                    wnd.peerUid = groupId;
                    wnd.peerNickName = [data objectForKey:@"groupName"];
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                    
                    //添加一条进入群的消息(本地)
                }
                else {
                    NSDictionary *dict = [license getUrlParams];
                    WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                    middleVC.groupId = groupId;
                    middleVC.source = [@{@"source": @"APP_CODE",@"refCode":[dict objectForKey:@"RefCode"]} mj_JSONString];
                    middleVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:middleVC animated:YES];
                }
            }
            else {
                [BiChatGlobal HideActivityIndicator];
                [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
            }
        }];
    }
    
    //是加朋友？
    else if ([license rangeOfString:IMCHAT_USERLINK_MARK].length > 0)
    {
        NSInteger pt = [license rangeOfString:IMCHAT_USERLINK_MARK].location;
        NSString *userRefCode = [license substringFromIndex:(pt + IMCHAT_USERLINK_MARK.length)];
        NSRange range = [userRefCode rangeOfString:@"&"];
        if (range.length > 0)
            userRefCode = [userRefCode substringToIndex:range.location];
        
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getFriendByRefCode:userRefCode completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                if (![[BiChatGlobal sharedManager]isFriendInContact:[data objectForKey:@"uid"]] &&
                    [[BiChatDataModule sharedDataModule]isChatExist:[data objectForKey:@"uid"]])
                {
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.peerUid = [data objectForKey:@"uid"];
                    wnd.peerNickName = [data objectForKey:@"nickName"];
                    wnd.peerUserName = [data objectForKey:@"userName"];
                    wnd.peerAvatar = [data objectForKey:@"avatar"];
                    wnd.isGroup = NO;
                    wnd.isPublic = NO;
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else
                {
                    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
                    wnd.uid = [data objectForKey:@"uid"];
                    wnd.userName = [data objectForKey:@"userName"];
                    wnd.nickName = [data objectForKey:@"nickName"];
                    wnd.avatar = [data objectForKey:@"avatar"];
                    wnd.source = @"CODE";
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301019") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    //是加朋友？
    else if ([[dict objectForKey:@"action"] isEqualToString:@"u"]){
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getFriendByRefCode:[dict objectForKey:@"id"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                if (![[BiChatGlobal sharedManager]isFriendInContact:[data objectForKey:@"uid"]] &&
                    [[BiChatDataModule sharedDataModule]isChatExist:[data objectForKey:@"uid"]])
                {
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.peerUid = [data objectForKey:@"uid"];
                    wnd.peerNickName = [data objectForKey:@"nickName"];
                    wnd.peerUserName = [data objectForKey:@"userName"];
                    wnd.peerAvatar = [data objectForKey:@"avatar"];
                    wnd.isGroup = NO;
                    wnd.isPublic = NO;
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else
                {
                    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
                    wnd.uid = [data objectForKey:@"uid"];
                    wnd.userName = [data objectForKey:@"userName"];
                    wnd.nickName = [data objectForKey:@"nickName"];
                    wnd.avatar = [data objectForKey:@"avatar"];
                    wnd.source = @"CODE";
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301019") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    //是加入群组
    else if ([[dict objectForKey:@"action"] isEqualToString:@"g"]){
        [NetworkModule getShortUrlWithType:[dict objectForKey:@"action"] chatId:[dict objectForKey:@"id"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data1) {
            [BiChatGlobal ShowActivityIndicator];
            NSString *groupId = [[data1 objectForKey:@"data"] objectForKey:@"groupId"];
            [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [BiChatGlobal HideActivityIndicator];
                if (success) {
                    BOOL inner = NO;
                    for (NSDictionary *dict in [data objectForKey:@"groupUserList"]) {
                        if ([[dict objectForKey:@"uid"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
                            inner = YES;
                        }
                    }
                    if (inner) {
                        for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]){
                            if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:groupId]) {
                                //进入聊天界面
                                ChatViewController *wnd = [ChatViewController new];
                                wnd.isGroup = YES;
                                wnd.peerUid = groupId;
                                wnd.peerNickName = [item objectForKey:@"peerNickName"];
                                wnd.hidesBottomBarWhenPushed = YES;
                                [self.navigationController pushViewController:wnd animated:YES];
                                return;
                            }
                        }
                        //没有发现条目，新增一条
                        [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                        //进入
                        ChatViewController *wnd = [ChatViewController new];
                        wnd.isGroup = YES;
                        wnd.peerUid = groupId;
                        wnd.peerNickName = [data objectForKey:@"groupName"];
                        wnd.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:wnd animated:YES];
                        
                        //添加一条进入群的消息(本地)
                    }
                    else {
                        WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                        middleVC.groupId = groupId;
                        middleVC.source = [@{@"source": @"APP_CODE",@"refCode":[dict objectForKey:@"subid"] ? [dict objectForKey:@"subid"] : @""} mj_JSONString];
                        middleVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:middleVC animated:YES];
                    }
                }
                else {
                    [BiChatGlobal HideActivityIndicator];
                    [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
                }
            }];
        }];
    }
    else if ([[license lowercaseString]hasPrefix:@"http://"] ||
             [[license lowercaseString]hasPrefix:@"https://"])
    {
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = license;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else {
        TextRenderViewController *wnd = [TextRenderViewController new];
        wnd.navigationItem.title = LLSTR(@"101032");
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.text = license;
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

- (void)inputClose {
    [self.inputV removeFromSuperview];
    self.inputV = nil;
    self.tableView.scrollEnabled = YES;
}

- (void)showPaySuccessWithInfo:(NSDictionary *)dict {
    WPPaySuccessViewController *payVC = [[WPPaySuccessViewController alloc]init];
    payVC.resultDic = dict;
    payVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:payVC animated:YES];
}


#pragma mark - 私有函数

- (UIView *)createTitlePanel
{
    UIView *view4TitlePanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    button4Cancel.titleLabel.font = [UIFont systemFontOfSize:14];
    [button4Cancel setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
    [button4Cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button4Cancel addTarget:self action:@selector(onButtonCancel:) forControlEvents:UIControlEventTouchUpInside];
    [view4TitlePanel addSubview:button4Cancel];
    
    UIView *view4InputFrame = [[UIView alloc]initWithFrame:CGRectMake(45, 5, self.view.frame.size.width - 70, 30)];
    view4InputFrame.backgroundColor = [UIColor whiteColor];
    view4InputFrame.layer.cornerRadius = 5;
    [view4TitlePanel addSubview:view4InputFrame];
    
    UIImageView *image4Search = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search"]];
    image4Search.center = CGPointMake(61, 20);
    [view4TitlePanel addSubview:image4Search];
    
    input4UserMobile = [[UITextField alloc]initWithFrame:CGRectMake(75, 0, self.view.frame.size.width - 100, 40)];
    input4UserMobile.font = [UIFont systemFontOfSize:14];
    input4UserMobile.placeholder = LLSTR(@"106103");
    input4UserMobile.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    input4UserMobile.returnKeyType = UIReturnKeyNext;
    input4UserMobile.delegate = self;
    [view4TitlePanel addSubview:input4UserMobile];
    
    return view4TitlePanel;
}

- (void)onInput4UserMobileChanged:(id)sender
{
    if (input4UserMobile.text.length > 0)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101010") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSearch:)];
    else
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)onButtonSearch:(id)sender
{
    [self beginSearch];
}

- (void)beginSearch
{
    if (input4UserMobile.text.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301908") withIcon:nil];
        [input4UserMobile resignFirstResponder];
    }
    
    NSString *mobile = [BiChatGlobal normalizeMobileNumber:input4UserMobile.text];
    
    //先找一下本地
    NSDictionary *item = [[BiChatGlobal sharedManager]getFriendInfoInContactByMobile:mobile];
    if (item != nil)
    {
        //进入朋友信息界面
        UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
        wnd.uid = [item objectForKey:@"uid"];
        wnd.avatar = [item objectForKey:@"avatar"];
        wnd.nickName = [item objectForKey:@"nickName"];
        wnd.source = @"PHONE";
        [self.navigationController pushViewController:wnd animated:YES];
        return;
    }
    
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getFriendByPhone:input4UserMobile.text completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            if ([[data objectForKey:@"data"]count] == 1)
            {
                //进入用户详情页面
                UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
                wnd.uid = [[[data objectForKey:@"data"]firstObject]objectForKey:@"uid"];
                wnd.userName = [[[data objectForKey:@"data"]firstObject]objectForKey:@"userName"];
                wnd.nickName = [[[data objectForKey:@"data"]firstObject]objectForKey:@"nickName"];
                wnd.avatar = [[[data objectForKey:@"data"]firstObject]objectForKey:@"avatar"];
                wnd.source = @"PHONE";
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                UserSelectorViewController *wnd = [UserSelectorViewController new];
                wnd.navigationItem.title = LLSTR(@"102420");
                wnd.array4User = [data objectForKey:@"data"];
                [self.navigationController pushViewController:wnd animated:YES];
            }
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301020") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
    
    /*
    
    //没找到，去服务器查找(13862431992)
    mobile = input4UserMobile.text;
    NSData *data4Mobile = [mobile dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 10;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 28;
    HTONS(CommandType);
    short MobileLen = data4Mobile.length;
    HTONS(MobileLen);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&MobileLen length:2]];
    [data appendData:data4Mobile];
    
    //发送消息命令(15821926890)
    [BiChatGlobal ShowActivityIndicator];
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        [BiChatGlobal HideActivityIndicator];
        if (isTimeOut)
        {
            [BiChatGlobal showInfo:@"服务器没有响应\r\n请稍后再试" withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
            {
                NSLog(@"%@", obj);
                if ([[obj objectForKey:@"data"]count] == 1)
                {
                    //进入用户详情页面
                    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
                    wnd.uid = [[[obj objectForKey:@"data"]firstObject]objectForKey:@"uid"];
                    wnd.userName = [[[obj objectForKey:@"data"]firstObject]objectForKey:@"userName"];
                    wnd.nickName = [[[obj objectForKey:@"data"]firstObject]objectForKey:@"nickName"];
                    wnd.avatar = [[[obj objectForKey:@"data"]firstObject]objectForKey:@"avatar"];
                    wnd.source = @"PHONE";
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else
                {
                    UserSelectorViewController *wnd = [UserSelectorViewController new];
                    wnd.navigationItem.title = LLSTR(@"102420");
                    wnd.array4User = [obj objectForKey:@"data"];
                    [self.navigationController pushViewController:wnd animated:YES];
                }
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301020") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];*/
}

- (void)onButtonCancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

