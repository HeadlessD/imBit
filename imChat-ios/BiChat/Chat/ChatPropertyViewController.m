//
//  ChatPropertyViewController.m
//  BiChat
//
//  Created by Admin on 2018/4/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "ChatPropertyViewController.h"
#import "ChatViewController.h"
#import "UserDetailViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import "JSONKit.h"

@interface ChatPropertyViewController ()

@end

@implementation ChatPropertyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201200");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) return 1;
    else if (section == 1)
    {
        if ([[BiChatGlobal sharedManager]isFriendInContact:self.peerUid])
            return 3;
        else
            return 1;
    }
    else return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        return 100;
    }
    else
        return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"item"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        NSInteger userPerLine = self.view.frame.size.width / 60;
        CGFloat interval = (self.view.frame.size.width - userPerLine * 50) / (userPerLine + 1);

        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:self.peerUid
                                                nickName:self.peerNickName
                                                  avatar:self.peerAvatar
                                                   width:50 height:50];
        view4Avatar.frame = CGRectMake(interval, 15, 50, 50);
        view4Avatar.userInteractionEnabled = YES;
        [cell.contentView addSubview:view4Avatar];
        
        UIButton *button4UserInfo = [[UIButton alloc]initWithFrame:view4Avatar.frame];
        [button4UserInfo addTarget:self action:@selector(onButtonUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4UserInfo];

        //昵称
        UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(interval, 15 + 50, 50, 20)];
        label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:self.peerUid groupProperty:nil nickName:self.peerNickName];
        label4NickName.textAlignment = NSTextAlignmentCenter;
        label4NickName.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:label4NickName];

        UIButton *button4Add = [[UIButton alloc]initWithFrame:CGRectMake(interval + (50 + interval), 15, 50, 50)];
        button4Add.layer.cornerRadius = 25;
        button4Add.clipsToBounds = YES;
        button4Add.titleLabel.font = [UIFont systemFontOfSize:30];
        [button4Add setBackgroundImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [button4Add addTarget:self action:@selector(onButtonAdd:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4Add];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"101121");
        
        UISwitch *switch4Mute = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
        [switch4Mute addTarget:self action:@selector(onSwitchMute:) forControlEvents:UIControlEventValueChanged];
        switch4Mute.on = [[BiChatGlobal sharedManager]isFriendInMuteList:self.peerUid];
        [cell.contentView addSubview:switch4Mute];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"101122");
        
        UISwitch *switch4Fold = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
        [switch4Fold addTarget:self action:@selector(onSwitchFold:) forControlEvents:UIControlEventValueChanged];
        switch4Fold.on = [[BiChatGlobal sharedManager]isFriendInFoldList:self.peerUid];
        [cell.contentView addSubview:switch4Fold];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"101123");
        
        UISwitch *switch4Stick = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
        [switch4Stick addTarget:self action:@selector(onSwitchStick:) forControlEvents:UIControlEventValueChanged];
        switch4Stick.on = [[BiChatGlobal sharedManager]isFriendInStickList:self.peerUid];
        [cell.contentView addSubview:switch4Stick];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
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

#pragma mark - ContactSelectDelegate

- (void)contactSelected:(NSInteger)cookie contacts:(NSArray *)contacts
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray *array4Contact = [NSMutableArray arrayWithArray:contacts];
    [array4Contact addObject:self.peerUid];
    
    //自动生成群名
    NSString *groupName = [LLSTR(@"201004") llReplaceWithArray:@[[BiChatGlobal sharedManager].nickName]];
    [NetworkModule createGroup:groupName
                      userList:array4Contact
                relatedGroupId:nil
              relatedGroupType:0
                completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
     {
        if (success)
        {
            if ([[data objectForKey:@"errorCode"]integerValue] == 0)
            {
                NSString *groupId = [data objectForKey:@"groupId"];
                
                //先生成所有朋友的列表字符串
                NSMutableArray *array4PeersSuccess = [NSMutableArray array];
                NSMutableArray *array4PeersFail = [NSMutableArray array];
                NSMutableArray *array4PeersNeedApprove = [NSMutableArray array];
                for (int i = 0; i < contacts.count; i ++)
                {
                    NSMutableDictionary *peer = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [contacts objectAtIndex:i], @"uid",
                                                 [[BiChatGlobal sharedManager]getFriendNickName:[contacts objectAtIndex:i]], @"nickName",
                                                 nil];
                    if ([[[BiChatGlobal sharedManager]getFriendAvatar:[contacts objectAtIndex:i]]length] > 0)
                        [peer setObject:[[BiChatGlobal sharedManager]getFriendAvatar:[contacts objectAtIndex:i]] forKey:@"avatar"];
                    if ([[[BiChatGlobal sharedManager]getFriendAvatar:[contacts objectAtIndex:i]]length] > 0)
                        [peer setObject:[[BiChatGlobal sharedManager]getFriendUserName:[contacts objectAtIndex:i]] forKey:@"userName"];
                    
                    //这一条是否添加进群组成功
                    for (NSDictionary *item in [data objectForKey:@"data"])
                    {
                        if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"] &&
                            [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                        {
                            [array4PeersSuccess addObject:peer];
                            break;
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"NOT_YOUR_FRIEND"] &&
                                 [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                        {
                            [array4PeersFail addObject:peer];
                            break;
                        }
                        else if ([[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                        {
                            [array4PeersNeedApprove addObject:peer];
                            break;
                        }
                    }
                }
                
                //本地加入一条时间消息
                NSDateFormatter *fmt = [NSDateFormatter new];
                [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                fmt.dateFormat = @"yyyy/MM/dd HH:mm";
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"2", @"type", [fmt stringFromDate:[NSDate date]], @"timeStamp", nil];
                [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:item];
                
                if (array4PeersSuccess.count > 0)
                {
                    //同时开始发送一个邀请朋友的信息message
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUP], @"type",
                                                     [array4PeersSuccess JSONString], @"content",
                                                     groupId, @"receiver",
                                                     [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]]
                                                     , @"receiverNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                     @"1", @"isGroup",
                                                     msgId, @"msgId",
                                                     nil];
                    
                    //加入本地一条消息
                    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                    
                    //发送到服务器
                    [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        
                        //主界面增加一个选项
                        [[BiChatDataModule sharedDataModule]addChatItem:groupId
                                                           peerNickName:groupName
                                                             peerAvatar:[BiChatGlobal sharedManager].avatar
                                                                isGroup:YES];
                        
                        [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                              peerUserName:@""
                                                              peerNickName:groupName
                                                                peerAvatar:[BiChatGlobal sharedManager].avatar
                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO
                                                                   isGroup:YES isPublic:NO
                                                                 createNew:YES];
                        
                    }];
                }
                
                if (array4PeersFail.count > 0)
                {
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL], @"type",
                                                     [array4PeersFail JSONString], @"content",
                                                     groupId, @"receiver",
                                                     [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                     @"1", @"isGroup",
                                                     msgId, @"msgId",
                                                     nil];
                    
                    //加入本地一条消息
                    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                    [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                          peerUserName:@""
                                                          peerNickName:groupName
                                                            peerAvatar:[BiChatGlobal sharedManager].avatar
                                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES isPublic:NO
                                                             createNew:YES];
                }
                
                if (array4PeersNeedApprove.count > 0)
                {
                    //准备数据,发送给群成员
                    NSDictionary *applyInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                               @"", @"apply",
                                               array4PeersNeedApprove, @"friends", nil];
                    
                    //同时开始发送一个邀请朋友的信息message,本条信息所有人都可以看到
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER], @"type",
                                                     [applyInfo JSONString], @"content",
                                                     groupId, @"receiver",
                                                     [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                     @"1", @"isGroup",
                                                     msgId, @"msgId",
                                                     nil];
                    
                    //发送到服务器
                    [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        
                        if (success)
                        {
                            //加入本地一条消息
                            [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                                  peerUserName:@""
                                                                  peerNickName:groupName
                                                                    peerAvatar:[BiChatGlobal sharedManager].avatar
                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO
                                                                       isGroup:YES isPublic:NO
                                                                     createNew:YES];
                            
                            //接下来发送一条邀请朋友的信息message，本条信息只有群主或者管理员可以看到，用于批准申请
                            NSString *msgId = [BiChatGlobal getUuidString];
                            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBER], @"type",
                                                             [applyInfo JSONString], @"content",
                                                             groupId, @"receiver",
                                                             [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                             [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                             [BiChatGlobal sharedManager].uid, @"sender",
                                                             [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                             [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                             [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                             @"1", @"isGroup",
                                                             msgId, @"msgId",
                                                             nil];
                            [NetworkModule sendMessageToGroupOperator:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                
                                if (success)
                                {
                                    //接下来将向所有的需要审批个人发送一条模拟群消息，以让用户可以和群主建立虚拟聊天
                                    NSString *msgId = [BiChatGlobal getUuidString];
                                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE], @"type",
                                                                     @"", @"content",
                                                                     groupId, @"receiver",
                                                                     [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                     @"1", @"isGroup",
                                                                     msgId, @"msgId",
                                                                     nil];
                                    for (NSDictionary *item in array4PeersNeedApprove)
                                    {
                                        [NetworkModule sendMessageToUser:[item objectForKey:@"peerUid"] message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                        }];
                                    }
                                }
                            }];
                        }
                    }];
                }
                
                //接着发送一条红包广告
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_GROUP_AD], @"type",
                                                 @"", @"content",
                                                 groupId, @"receiver",
                                                 [LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]], @"receiverNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                    [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                          peerUserName:@""
                                                          peerNickName:[LLSTR(@"201004") llReplaceWithArray:@[ [BiChatGlobal sharedManager].nickName]]
                                                            peerAvatar:[BiChatGlobal sharedManager].avatar
                                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                    
                    //这条消息不管成功不成功
                    //进入群聊界面
                    [BiChatGlobal HideActivityIndicator];
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.isGroup = YES;
                    wnd.peerUid = groupId;
                    wnd.peerNickName = groupName;
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301715") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301715") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

#pragma mark - 私有函数

- (void)onButtonUserInfo:(id)sender
{
    UserDetailViewController *wnd = [UserDetailViewController new];
    wnd.uid = self.peerUid;
    wnd.nickName = self.peerNickName;
    wnd.userName = self.peerUserName;
    wnd.avatar = self.peerAvatar;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonAdd:(id)sender
{
    ContactListViewController *wnd = [ContactListViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.selectMode = SELECTMODE_MULTI;
    wnd.multiSelectMax = 30;
    wnd.multiSelectMaxError = LLSTR(@"301027");
    wnd.delegate = self;
    wnd.defaultTitle = LLSTR(@"201001");
    wnd.alreadySelected = [NSArray arrayWithObjects:self.peerUid, [BiChatGlobal sharedManager].uid, nil];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)onSwitchMute:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    if (s.on)
    {
        [NetworkModule muteItem:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    else
    {
        [NetworkModule unMuteItem:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
}

- (void)onSwitchFold:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    if (s.on)
    {
        [NetworkModule foldItem:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    else
    {
        [NetworkModule unFoldItem:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
}

- (void)onSwitchStick:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    if (s.on)
    {
        [NetworkModule stickItem:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    else
    {
        [NetworkModule unStickItem:self.peerUid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
}

@end
