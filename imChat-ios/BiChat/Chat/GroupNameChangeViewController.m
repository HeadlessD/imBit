//
//  GroupNameChangeViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "GroupNameChangeViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "NetworkModule.h"
#import "MessageHelper.h"

@interface GroupNameChangeViewController ()

@end

@implementation GroupNameChangeViewController

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
//    self.navigationItem.title = @"修改群名称";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    BOOL isVirtualSubGroup = NO;
    if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([self.groupId isEqualToString:[item objectForKey:@"groupId"]] &&
                [[item objectForKey:@"virtualGroupNum"]integerValue] > 0)
            {
                isVirtualSubGroup = YES;
                break;
            }
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101004") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonOK:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, self.view.frame.size.width - 60, 30)];
    if (isVirtualSubGroup)
        label4Title.text = LLSTR(@"201521");
    else
        label4Title.text = LLSTR(@"201221");
    label4Title.font = [UIFont systemFontOfSize:24];
    label4Title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4Title];
    
    UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 80, self.view.frame.size.width - 60, 40)];
    if (isVirtualSubGroup)
        label4Subtitle.text = LLSTR(@"201522");
    else
        label4Subtitle.text = LLSTR(@"101416");
    label4Subtitle.textAlignment = NSTextAlignmentCenter;
    label4Subtitle.numberOfLines = 0;
    label4Subtitle.font = [UIFont systemFontOfSize:14];
    label4Subtitle.textColor = THEME_GRAY;
    [self.view addSubview:label4Subtitle];
    
    self.input4NewGroupName = [[WPTextFieldView alloc]initWithFrame:CGRectMake(30, 150, self.view.frame.size.width - 60, 50)];
    [self.view addSubview:self.input4NewGroupName];
    if (isVirtualSubGroup)
        self.input4NewGroupName.tf.placeholder = LLSTR(@"201209");
    else
        self.input4NewGroupName.tf.placeholder = LLSTR(@"201209");
    
    //显示缺省的群名
    if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        //判断是不是管理群
        for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([self.groupId isEqualToString:[item objectForKey:@"groupId"]])
            {
                if ([[item objectForKey:@"virtualGroupNum"]integerValue] == 0)
                {
                    [self.input4NewGroupName.tf setText:[self.groupProperty objectForKey:@"groupName"]];
                }
                else
                {
                    if ([[item objectForKey:@"groupNickName"]length] > 0)
                        [self.input4NewGroupName.tf setText:[item objectForKey:@"groupNickName"]];
                    else
                        [self.input4NewGroupName.tf setText:[NSString stringWithFormat:@"%@", [item objectForKey:@"virtualGroupNum"]]];
                }
                break;
            }
        }
    }
    else
        [self.input4NewGroupName.tf setText:[self.groupProperty objectForKey:@"groupName"]];
    self.input4NewGroupName.tf.returnKeyType = UIReturnKeyDone;
    self.input4NewGroupName.tf.textAlignment = NSTextAlignmentCenter;
    self.input4NewGroupName.tf.font = Font(16);
    self.input4NewGroupName.limitCount = 30;
    WEAKSELF;
    self.input4NewGroupName.EditBlock = ^(UITextField *tf) {
        if (weakSelf.input4NewGroupName.tf.text.length > GROUPNAMELENGTH_MAX)
            weakSelf.input4NewGroupName.tf.text = [weakSelf.input4NewGroupName.tf.text substringToIndex:GROUPNAMELENGTH_MAX];
        
        if (weakSelf.input4NewGroupName.tf.text.length > 0)
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        else
            weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onButtonOK:nil];
    return YES;
}

- (void)onButtonOK:(id)sender
{
    [_input4NewGroupName.tf resignFirstResponder];
    
    //删除前后空格
    self.input4NewGroupName.tf.text = [self.input4NewGroupName.tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.input4NewGroupName.tf.text.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"201221") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //设置虚拟群
    if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        //是否主群
        for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([self.groupId isEqualToString:[item objectForKey:@"groupId"]])
            {
                if ([[item objectForKey:@"virtualGroupNum"]integerValue] == 0)
                    [self changeVirtualGroupName];
                else
                    [self changeVirtualSubGroupName];
                
                break;
            }
        }
    }
    else
        [self changeGroupName];
}

- (void)changeGroupName
{
    //开始设置
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.input4NewGroupName.tf.text, @"groupName", nil];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //修改中央数据库中本群的名字
            [BiChatGlobal showInfo:LLSTR(@"301724") withIcon:[UIImage imageNamed:@"icon_OK"]];
            [[BiChatDataModule sharedDataModule]setPeerNickName:self.groupId withNickName:self.input4NewGroupName.tf.text];
            [[BiChatDataModule sharedDataModule]changePeerNameFor:self.groupId withName:self.input4NewGroupName.tf.text];
            [self.groupProperty setObject:self.input4NewGroupName.tf.text forKey:@"groupName"];
            
            //发送一条消息通知所有成员群名称已经修改
            NSString *msgId = [BiChatGlobal getUuidString];
            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CHANGEGROUPNAME], @"type",
                                             self.input4NewGroupName.tf.text, @"content",
                                             self.groupId, @"receiver",
                                             self.input4NewGroupName.tf.text, @"receiverNickName",
                                             [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                             [BiChatGlobal sharedManager].uid, @"sender",
                                             [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                             [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                             [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                             @"1", @"isGroup",
                                             msgId, @"msgId",
                                             nil];
            
            [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                self.navigationItem.rightBarButtonItem.enabled = YES;
                if (success)
                {
                    //重新拉一下通讯录列表
                    [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                    
                    //修改全局群聊名称
                    [[BiChatDataModule sharedDataModule]changePeerNameFor:self.groupId withName:self.input4NewGroupName.tf.text];
                    [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                          peerUserName:@""
                                                          peerNickName:self.input4NewGroupName.tf.text
                                                            peerAvatar:self.groupAvatar
                                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:_groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                    
                    //加入本地一条消息
                    if (self.ownerChatWnd != nil)
                        [self.ownerChatWnd appendMessage:sendData];
                    else
                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                    
                    //返回
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
        else if (errorCode == 3021)
            [BiChatGlobal showInfo:LLSTR(@"204214") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        else
            [BiChatGlobal showInfo:LLSTR(@"301732") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)changeVirtualGroupName
{
    //先获取虚拟群的主群ID
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getMainGroupIdByVirtualGroup:[self.groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //开始设置
            NSString *mainGroupId = [data objectForKey:@"mainGroupId"];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.input4NewGroupName.tf.text, @"groupName", nil];
            [NetworkModule setGroupPublicProfile:mainGroupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (success)
                {
                    //修改中央数据库中本群的名字
                    [BiChatGlobal showInfo:LLSTR(@"301724") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    [self.groupProperty setObject:self.input4NewGroupName.tf.text forKey:@"groupName"];
                    [[BiChatDataModule sharedDataModule]setPeerNickName:self.groupId withNickName:self.input4NewGroupName.tf.text];

                    //发送一条消息通知所有成员群名称已经修改
                    for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                    {
                        //本虚拟子群是否已经被解散
                        NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
                        [groupProperty setObject:self.input4NewGroupName.tf.text forKey:@"groupName"];
                        [[BiChatDataModule sharedDataModule]setGroupProperty:[item objectForKey:@"groupId"] property:groupProperty];
                        if ([[groupProperty objectForKey:@"disabled"]boolValue])
                            continue;
                        
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CHANGEGROUPNAME], @"type",
                                                         [self.groupProperty objectForKey:@"groupName"], @"content",
                                                         [item objectForKey:@"groupId"], @"receiver",
                                                         [BiChatGlobal getGroupNickName:groupProperty defaultNickName:[NSString stringWithFormat:@"%@#%d", [self.groupProperty objectForKey:@"groupName"], (int)[[item objectForKey:@"virtualGroupNum"]integerValue]]], @"receiverNickName",
                                                         [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];
                        
                        [NetworkModule sendMessageToGroup:[item objectForKey:@"groupId"] message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                            self.navigationItem.rightBarButtonItem.enabled = YES;
                            if (success)
                            {
                                //修改全局群聊名称
                                [[BiChatDataModule sharedDataModule]changePeerNameFor:[item objectForKey:@"groupId"] withName:self.input4NewGroupName.tf.text];
                                [[BiChatDataModule sharedDataModule]setLastMessage:[item objectForKey:@"groupId"]
                                                                      peerUserName:@""
                                                                      peerNickName:[BiChatGlobal getGroupNickName:groupProperty defaultNickName:[NSString stringWithFormat:@"%@#%d", [self.groupProperty objectForKey:@"groupName"], (int)[[item objectForKey:@"virtualGroupNum"]integerValue]]]
                                                                        peerAvatar:self.groupAvatar
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:_groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:YES];
                                
                                //加入本地一条消息
                                [[BiChatDataModule sharedDataModule]addChatContentWith:[item objectForKey:@"groupId"] content:sendData];
                            }
                        }];
                    }
                    
                    //返回上一级
                    if (self.ownerChatWnd != nil)
                        self.ownerChatWnd.title = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName: [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName: self.input4NewGroupName.tf.text]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if (errorCode == 3021)
                    [BiChatGlobal showInfo:LLSTR(@"204214") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                else
                    [BiChatGlobal showInfo:LLSTR(@"301732") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301742") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)changeVirtualSubGroupName
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.input4NewGroupName.tf.text, @"groupNickName", nil];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [BiChatGlobal showInfo:LLSTR(@"301743") withIcon:[UIImage imageNamed:@"icon_OK"]];
            [NetworkModule getGroupPropertyLite:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {

                //修改中央数据库中本群的名字
                NSInteger num = 0;
                for (NSMutableDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                {
                    if ([[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                    {
                        [item setObject:self.input4NewGroupName.tf.text forKey:@"groupNickName"];
                        num = [[item objectForKey:@"virtualGroupNum"]integerValue];
                        
                        //发送一条消息通知所有成员群名称已经修改
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME], @"type",
                                                         self.input4NewGroupName.tf.text, @"content",
                                                         [item objectForKey:@"groupId"], @"receiver",
                                                         [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName:self.input4NewGroupName.tf.text], @"receiverNickName",
                                                         [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];
                        
                        [NetworkModule sendMessageToGroup:[item objectForKey:@"groupId"] message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                            self.navigationItem.rightBarButtonItem.enabled = YES;
                            if (success)
                            {
                                //修改全局群聊名称
                                [[BiChatDataModule sharedDataModule]changePeerNameFor:[item objectForKey:@"groupId"] withName:self.input4NewGroupName.tf.text];
                                [[BiChatDataModule sharedDataModule]setLastMessage:[item objectForKey:@"groupId"]
                                                                      peerUserName:@""
                                                                      peerNickName:self.input4NewGroupName.tf.text
                                                                        peerAvatar:self.groupAvatar
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:_groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:NO];
                                
                                //加入本地一条消息
                                if (self.ownerChatWnd != nil)
                                    [self.ownerChatWnd appendMessage:sendData];
                                else
                                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                            }
                        }];
                    }
                }
                
                //发一条系统消息到管理群
                [MessageHelper sendGroupMessageTo:[[[self.groupProperty objectForKey:@"virtualGroupSubList"]firstObject] objectForKey:@"groupId"]
                                             type:MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME2
                                          content:[@{@"virtualGroupNum":[NSString stringWithFormat:@"%ld", (long)num], @"newNickName":self.input4NewGroupName.tf.text} JSONString]
                                         needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                             }];

                //返回上一级
                if (self.ownerChatWnd != nil)
                    self.ownerChatWnd.title = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName: self.input4NewGroupName.tf.text];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301727") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

@end
