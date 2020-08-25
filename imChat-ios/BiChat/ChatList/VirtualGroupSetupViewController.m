//
//  VirtualGroupSetupViewController.m
//  BiChat
//
//  Created by Admin on 2018/5/16.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatDataModule.h"
#import "VirtualGroupSetupViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import "JSONKit.h"
#import "GroupMemberSelectorViewController.h"
#import "SetGroupAvatarViewController.h"
#import "GroupNameChangeViewController.h"
#import "GroupBlockListViewController.h"
#import "GroupForbidListViewController.h"
#import "GroupApproveViewController.h"
#import "GroupContentSetupViewController.h"
#import "VirtualGroupMemberSetupViewController.h"
#import "VirtualGroupAssistAdminViewController.h"
#import "VirtualGroupSubListViewController.h"
#import "GroupBriefingChangeViewController.h"
#import "MessageHelper.h"

@interface VirtualGroupSetupViewController ()

@end

@implementation VirtualGroupSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201506");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    self.tableView.separatorColor = [UIColor colorWithWhite:.9 alpha:1];
    
    //NSLog(@"%@", self.groupProperty);
    
    //需要更改虚拟群内部数据
    [NetworkModule getMainGroupIdByVirtualGroup:[self.groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            NSString *mainGroupId = [data objectForKey:@"mainGroupId"];
            self.groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:mainGroupId];
            self.groupId = mainGroupId;
            
            if (self.groupProperty == nil)
            {
                [NetworkModule getGroupProperty:mainGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    self.groupProperty = data;
                    [self.tableView reloadData];
                }];
            }
            else
                [self.tableView reloadData];
        }
        
    }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
    else if (section == 1)
        return 3;
    else if (section == 2)
        return 3;
    else
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    NSString *virtualGroupId = [self.groupProperty objectForKey:@"virtualGroupId"];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"201207");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"201208");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"101417");
        cell.detailTextLabel.text = [self.groupProperty objectForKey:@"groupName"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"201210");
        cell.detailTextLabel.text = [self.groupProperty objectForKey:@"briefing"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if ([[self.groupProperty objectForKey:@"briefing"]length] == 0)
            cell.detailTextLabel.text = LLSTR(@"101005");
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"201211");
        
        //当前的群头像
        NSString *str4Avatar = [BiChatGlobal getGroupAvatar:self.groupProperty];
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil nickName:[self.groupProperty objectForKey:@"groupName"] avatar:str4Avatar width:30 height:30];
        view4Avatar.center = CGPointMake(self.view.frame.size.width - 50, 22);
        [cell.contentView addSubview:view4Avatar];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"201507");
        if (subGroupCreating)
            cell.textLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"201508");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"201504");
        
        UISwitch *switch4BroadcastGroup = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
        [switch4BroadcastGroup addTarget:self action:@selector(onSwitchBroadcastGroup:) forControlEvents:UIControlEventValueChanged];
        switch4BroadcastGroup.on = YES;
        if (![[self.groupProperty objectForKey:@"enableBroadCastGroup"]boolValue])
            switch4BroadcastGroup.on = NO;
        for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
                switch4BroadcastGroup.on = [[item objectForKey:@"enableBroadCast"]boolValue];
        }
        [cell.contentView addSubview:switch4BroadcastGroup];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    else if (indexPath.section == 3 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"101123");
        
        UISwitch *switch4Stick = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
        [switch4Stick addTarget:self action:@selector(onSwitchStick:) forControlEvents:UIControlEventValueChanged];
        switch4Stick.on = [[BiChatGlobal sharedManager]isFriendInStickList:virtualGroupId];
        [cell.contentView addSubview:switch4Stick];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 3 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"101124");
        BOOL isInContactList = [self isGroupInContactList:self.groupId];
        
        UISwitch *switch4Save2Contact = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
        [switch4Save2Contact addTarget:self action:@selector(onSwitchSave2Contact:) forControlEvents:UIControlEventValueChanged];
        switch4Save2Contact.on = isInContactList;
        [cell.contentView addSubview:switch4Save2Contact];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        VirtualGroupMemberSetupViewController *wnd = [[VirtualGroupMemberSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        GroupContentSetupViewController *wnd = [[GroupContentSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        GroupNameChangeViewController *wnd = [[GroupNameChangeViewController alloc]init];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        //设置群简介
        GroupBriefingChangeViewController *wnd = [GroupBriefingChangeViewController new];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        SetGroupAvatarViewController *wnd = [SetGroupAvatarViewController new];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        [self addSubGroup];
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        [self subGroupList];
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

- (BOOL)isGroupInContactList:(NSString *)groupId
{
    //NSLog(@"%@", groupId);
    //NSLog(@"%@", [BiChatGlobal sharedManager].array4AllGroup);
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4AllGroup)
    {
        if ([[item objectForKey:@"uid"]isEqualToString:groupId])
            return YES;
    }
    return NO;
}

- (void)onSwitchSave2Contact:(id)sender
{
    UISwitch *switch4Save2Contact = (UISwitch *)sender;
    
    //保存到通讯录或者从通讯录删除
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType;
    if (switch4Save2Contact.on) CommandType = 23;
    else CommandType = 24;
    HTONS(CommandType);
    
    
    //生成登录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加群id
    [data appendData:[self.groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送获取群成员命令
    //NSLog(@"%@", [data description]);
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            //没有成功
            NSLog(@"超期");
            switch4Save2Contact.on = !switch4Save2Contact.on;
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            
            //成功，需要重新加载一下通讯录
            if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
                [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {}];
        }
    }];
}

- (void)onSwitchMute:(id)sender
{
    NSString *virtualGroupId = [self.groupProperty objectForKey:@"virtualGroupId"];
    UISwitch *s = (UISwitch *)sender;
    if (s.on)
    {
        [NetworkModule muteItem:virtualGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    else
    {
        [NetworkModule unMuteItem:virtualGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
}

- (void)onSwitchFold:(id)sender
{
    NSString *virtualGroupId = [self.groupProperty objectForKey:@"virtualGroupId"];
    UISwitch *s = (UISwitch *)sender;
    if (s.on)
    {
        [NetworkModule foldItem:virtualGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    else
    {
        [NetworkModule unFoldItem:virtualGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
}

- (void)onSwitchStick:(id)sender
{
    NSString *virtualGroupId = [self.groupProperty objectForKey:@"virtualGroupId"];
    UISwitch *s = (UISwitch *)sender;
    if (s.on)
    {
        [NetworkModule stickItem:virtualGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    else
    {
        [NetworkModule unStickItem:virtualGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
}

- (void)onSwitchCanChangeGroupName:(id)sender
{
    UISwitch *s = (UISwitch *)sender;

    //设置高级消息
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:s.on], @"changeNameRightOnly", nil];
    [NetworkModule setGroupPublicProfile:[self.groupProperty objectForKey:@"virtualGroupId"] profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            [self.groupProperty setObject:[NSNumber numberWithBool:s.on] forKey:@"changeNameRightOnly"];
            [self.tableView reloadData];
            
            //装配一个新的通知消息
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid",
                                  [BiChatGlobal sharedManager].nickName, @"nickName",
                                  nil];
            
            //同时要发送一条数据通知群中的其他成员
            for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
            {
                //本子群是否已经被解散
                NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
                if ([[groupProperty objectForKey:@"disabled"]boolValue])
                    continue;

                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", s.on?MESSAGE_CONTENT_TYPE_SETADMINCHANGENAMEONLY:MESSAGE_CONTENT_TYPE_CLEARADMINCHANGENAMEONLY], @"type",
                                                 [dict mj_JSONString], @"content",
                                                 [item objectForKey:@"groupId"], @"receiver",
                                                 [NSString stringWithFormat:@"%@#%ld", [self.groupProperty objectForKey:@"groupName"], [[item objectForKey:@"virtualGroupNum"]integerValue]], @"receiverNickName",
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
                    if (success)
                    {
                        [[BiChatDataModule sharedDataModule]setLastMessage:[item objectForKey:@"groupId"]
                                                              peerUserName:@""
                                                              peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
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
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:nil];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 44", nil];
        }
    }];
}

//通知一个群，有人被拉入群
- (void)notifyVirtualGroupAssignMember:(NSString *)groupId
                         groupProperty:(NSMutableDictionary *)groupProperty
                            subGroupId:(NSString *)subGroupId
                     dict4PeersSuccess:(NSDictionary *)dict4PeersSuccess
{
    //查找这个子群的序号
    NSInteger subGroupIndex = 0;
    for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
    {
        if ([[item objectForKey:@"groupId"]isEqualToString:subGroupId])
        {
            subGroupIndex = [[item objectForKey:@"virtualGroupNum"]integerValue];
            break;
        }
    }
    NSString *subGroupNickName = [NSString stringWithFormat:@"%@#%ld", [groupProperty objectForKey:@"groupName"], subGroupIndex];
    NSDictionary *dict4Content = [NSDictionary dictionaryWithObjectsAndKeys:
                                  groupId, @"fromGroupId",
                                  subGroupId, @"groupId",
                                  subGroupNickName, @"groupNickName",
                                  [dict4PeersSuccess objectForKey:subGroupId], @"assignedMember",
                                  nil];
    
    //生成一条新消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP], @"type",
                                     [dict4Content JSONString], @"content",
                                     groupId, @"receiver",
                                     [groupProperty objectForKey:@"groupName"]==nil?@"":[groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                     [BiChatGlobal getGroupAvatar:groupProperty], @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     @"1", @"isGroup",
                                     msgId, @"msgId",
                                     nil];
    
    [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                  peerUserName:@""
                                                  peerNickName:[groupProperty objectForKey:@"groupName"]
                                                    peerAvatar:[groupProperty objectForKey:@"avatar"]
                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:YES
                                                      isPublic:NO
                                                     createNew:YES];
        }
    }];
    
    if (subGroupId != groupId)
    {
        //生成一条新消息
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP], @"type",
                                         [dict4Content JSONString], @"content",
                                         subGroupId, @"receiver",
                                         subGroupNickName, @"receiverNickName",
                                         [BiChatGlobal getGroupAvatar:groupProperty], @"receiverAvatar",
                                         [BiChatGlobal sharedManager].uid, @"sender",
                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         @"1", @"isGroup",
                                         msgId, @"msgId",
                                         nil];
        
        //发送到相应群
        [NetworkModule sendMessageToGroup:subGroupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                //这个地方不能使用ownerChatWnd
                [[BiChatDataModule sharedDataModule]addChatContentWith:subGroupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:subGroupId
                                                      peerUserName:@""
                                                      peerNickName:subGroupNickName
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            else
                NSLog(@"send message failure");
        }];
    }
}

- (void)onSwitchBroadcastGroup:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    if (s.on)
    {
        //是否已经创建了广播群
        if ([[self.groupProperty objectForKey:@"enableBroadCastGroup"]boolValue])
        {
            //寻找广播群
            for (NSMutableDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
            {
                if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
                {
                    //设置群属性
                    [BiChatGlobal ShowActivityIndicator];
                    [NetworkModule setGroupPublicProfile:[item objectForKey:@"groupId"] profile:@{@"enableBroadCast": [NSNumber numberWithBool:YES]} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        [BiChatGlobal HideActivityIndicator];
                        if (success)
                        {
                            [item setObject:[NSNumber numberWithBool:YES] forKey:@"enableBroadCast"];
                            [self.groupProperty setObject:[NSNumber numberWithBool:YES] forKey:@"enableBroadCastGroup"];
                            [self.tableView reloadData];
                            [MessageHelper sendGroupMessageTo:self.groupId type:s.on?MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON:MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF
                                                      content:@""
                                                     needSave:YES
                                                     needSend:YES
                                               completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                   ;
                                               }];
                            [BiChatGlobal showInfo:LLSTR(@"301739") withIcon:[UIImage imageNamed:@"icon_OK"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                            [MessageHelper sendGroupMessageTo:[item objectForKey:@"groupId"] type:s.on?MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON:MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF
                                                      content:@""
                                                     needSave:YES
                                                     needSend:NO
                                               completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                   ;
                                               }];
                        }
                        else
                            s.on = YES;
                    }];
                    break;
                }
            }
        }
        else
        {
            //新建广播群
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule createVirtualGroupBroadCastGroup:[self.groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [BiChatGlobal HideActivityIndicator];
                if (success)
                {
                    //重新获取群属性
                    [NetworkModule getGroupPropertyLite:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success)
                        {
                            self.groupProperty = data;
                            [self.tableView reloadData];
                            
                            //寻找广播群
                            for (NSMutableDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                            {
                                if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
                                    [MessageHelper sendGroupMessageTo:[item objectForKey:@"groupId"] type:s.on?MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON:MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF
                                                              content:@""
                                                             needSave:YES
                                                             needSend:NO
                                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                           ;
                                                       }];
                            }
                        }
                    }];
                    [MessageHelper sendGroupMessageTo:self.groupId type:s.on?MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON:MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF
                                              content:@""
                                             needSave:YES
                                             needSend:YES
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                           ;
                                       }];
                    [BiChatGlobal showInfo:LLSTR(@"301739") withIcon:[UIImage imageNamed:@"icon_OK"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                else
                    [BiChatGlobal showInfo:LLSTR(@"301705") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
    }
    else
    {
        //寻找广播群
        for (NSMutableDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
            {
                //设置群属性
                [BiChatGlobal ShowActivityIndicator];
                [NetworkModule setGroupPublicProfile:[item objectForKey:@"groupId"] profile:@{@"enableBroadCast": [NSNumber numberWithBool:NO]} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    [BiChatGlobal HideActivityIndicator];
                    if (success)
                    {
                        [item setObject:[NSNumber numberWithBool:NO] forKey:@"enableBroadCast"];
                        [self.tableView reloadData];
                        [MessageHelper sendGroupMessageTo:self.groupId type:s.on?MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON:MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF
                                                  content:@""
                                                 needSave:YES
                                                 needSend:YES
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                               ;
                                           }];
                        [MessageHelper sendGroupMessageTo:[item objectForKey:@"groupId"] type:s.on?MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON:MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF
                                                  content:@""
                                                 needSave:YES
                                                 needSend:NO
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                               ;
                                           }];

                        [BiChatGlobal showInfo:LLSTR(@"301740") withIcon:[UIImage imageNamed:@"icon_OK"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }
                    else
                        s.on = YES;
                }];
                break;
            }
        }
    }
}

//新增虚拟子群
- (void)addSubGroup
{
    //当前正在创建中...
    if (subGroupCreating)
        return;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"201507")
                                                                             message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"201509")]
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //开始创建一个虚拟群子群
        [BiChatGlobal ShowActivityIndicator];
        subGroupCreating = YES;
        [self.tableView reloadData];
        [NetworkModule createVirtualSubGroup:[self.groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
            subGroupCreating = NO;
            [self.tableView reloadData];
            if (success)
            {
                [BiChatGlobal showInfo:LLSTR(@"301726") withIcon:[UIImage imageNamed:@"icon_OK"]];
                NSString *newGroupId = [data objectForKey:@"groupId"];
                NSString *newGroupNickName = [NSString stringWithFormat:@"%@#%ld", [self.groupProperty objectForKey:@"groupName"], (long)[[data objectForKey:@"virtualGroupNum"]integerValue]];
                
                //刷新一下最新的群信息
                [NetworkModule getGroupProperty:newGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                
                //准备数据
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [self.groupProperty objectForKey:@"groupName"], @"groupNickName",
                                      [self.groupProperty objectForKey:@"virtualGroupId"], @"groupId",
                                      [NSString stringWithFormat:@"%@", [data objectForKey:@"virtualGroupNum"]], @"subGroupNickName",
                                      nil];
                
                //发送一条消息到管理群中
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDVIRTUALGROUP], @"type",
                                                 [dict mj_JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName:[self.groupProperty objectForKey:@"groupName"]], @"receiverNickName",
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
                    if (success)
                    {
                        [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                              peerUserName:@""
                                                              peerNickName:[[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName:[self.groupProperty objectForKey:@"groupName"]]
                                                                peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO
                                                                   isGroup:YES
                                                                  isPublic:NO
                                                                 createNew:YES];
                        
                        //加入本地一条消息
                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                        
                        //获取一些新建的群的群属性
                        [NetworkModule getGroupProperty:newGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        }];
                    }
                }];
                
                //同时要发送一条数据通知群中的其他成员
                msgId = [BiChatGlobal getUuidString];
                sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDVIRTUALGROUP], @"type",
                            [dict mj_JSONString], @"content",
                            newGroupId, @"receiver",
                            newGroupNickName, @"receiverNickName",
                            [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                            [BiChatGlobal sharedManager].uid, @"sender",
                            [BiChatGlobal sharedManager].nickName, @"senderNickName",
                            [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                            [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                            [BiChatGlobal getCurrentDateString], @"timeStamp",
                            @"1", @"isGroup",
                            msgId, @"msgId",
                            nil];
                
                [NetworkModule sendMessageToGroup:newGroupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success)
                    {
                        [[BiChatDataModule sharedDataModule]setLastMessage:newGroupId
                                                              peerUserName:@""
                                                              peerNickName:newGroupNickName
                                                                peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO
                                                                   isGroup:YES
                                                                  isPublic:NO
                                                                 createNew:YES];
                        
                        //加入本地一条消息
                        [[BiChatDataModule sharedDataModule]addChatContentWith:newGroupId content:sendData];
                        
                        //获取一些新建的群的群属性
                        [NetworkModule getGroupProperty:newGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        }];
                    }
                }];
                
                //进入虚拟群列表界面
                VirtualGroupListViewController *wnd = [VirtualGroupListViewController new];
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                wnd.hidesBottomBarWhenPushed = YES;
                NSMutableArray *array = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                if (array.count > 2)
                {
                    [array removeLastObject];
                    [array removeLastObject];
                    [array addObject:wnd];
                    [self.navigationController setViewControllers:array animated:YES];
                }
                else
                    [self.navigationController pushViewController:wnd animated:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301707") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)subGroupList
{
    VirtualGroupSubListViewController *wnd = [VirtualGroupSubListViewController new];
    wnd.groupId = self.groupId;
    wnd.groupProperty = self.groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
}

@end
