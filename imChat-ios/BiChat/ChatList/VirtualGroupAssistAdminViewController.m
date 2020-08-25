//
//  VirtualGroupAssistAdminViewController.m
//  BiChat Dev
//
//  Created by imac2 on 2018/11/22.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "VirtualGroupAssistAdminViewController.h"
#import "GroupMemberDeleteViewController.h"
#import "AllGroupMemberViewController.h"
#import "MessageHelper.h"

@interface VirtualGroupAssistAdminViewController ()

@end

@implementation VirtualGroupAssistAdminViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201303");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.00000001)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSString *str = LLSTR(@"201342");
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                        context:nil];
        
        return rect.size.height + 20;
    }
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor redColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSString *str = LLSTR(@"201342");
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                        context:nil];
        
        UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, rect.size.height + 20)];
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, rect.size.height + 9)];
        label4Title.text = str;
        label4Title.numberOfLines = 0;
        label4Title.font = [UIFont systemFontOfSize:14];
        label4Title.textColor = [UIColor grayColor];
        [view4Title addSubview:label4Title];
        
        return view4Title;
    }
    else
    {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor greenColor];
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        NSArray *array4GroupMember = [self.groupProperty objectForKey:@"groupUserList"];
        NSInteger userPerLine = self.view.frame.size.width / 60;
        
        NSInteger buttonCount = array4GroupMember.count + 1;    //添加了+按钮
        if ([self isIGroupOwner] || [self isIAssistant])
            buttonCount ++;
        if (buttonCount > userPerLine * 3)
            buttonCount = userPerLine * 3;
        
        //实际显示用户个数
        NSInteger userCount = buttonCount - 1;
        if ([self isIGroupOwner] || [self isIAssistant])
            userCount --;
        
        if (userCount < array4GroupMember.count || [[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        {
            NSInteger lines = buttonCount / userPerLine + (buttonCount % userPerLine == 0?0:1);
            return 15 + lines * 85 + 40;
        }
        else
        {
            NSInteger lines = buttonCount / userPerLine + (buttonCount % userPerLine == 0?0:1);
            return 15 + lines * 85;
        }
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        NSInteger userPerLine = self.view.frame.size.width / 60;
        CGFloat interval = (self.view.frame.size.width - userPerLine * 50) / (userPerLine + 1);
        NSArray *array4GroupMember = [self.groupProperty objectForKey:@"groupUserList"];
        
        NSInteger buttonCount = array4GroupMember.count + 1;    //添加了+按钮
        if ([self isIGroupOwner] || [self isIAssistant])
            buttonCount ++;
        if (buttonCount > userPerLine * 3)
            buttonCount = userPerLine * 3;
        
        //休整首页显示的用户个数
        NSInteger userCount = buttonCount - 1;
        if ([self isIGroupOwner] || [self isIAssistant])
            userCount --;
        
        NSInteger line = 0;
        NSInteger column = 0;
        for (int i = 0; i < userCount; i ++)
        {
            line = i / userPerLine;
            column = i % userPerLine;
            
            NSString *str4NickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]
                                                                                 groupProperty:_groupProperty
                                                                                      nickName:[[array4GroupMember objectAtIndex:i]objectForKey:@"nickName"]];
            
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]
                                                    nickName:str4NickName
                                                      avatar:[[array4GroupMember objectAtIndex:i]objectForKey:@"avatar"]
                                                       width:50 height:50];
            view4Avatar.frame = CGRectMake(interval + column * (50 + interval), 15 + line * 85, 50, 50);
            view4Avatar.userInteractionEnabled = YES;
            [cell.contentView addSubview:view4Avatar];
            
            //是否群主,管理员和嘉宾
            if ([[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
            {
                UIImageView *image4Owner = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupowner"]];
                image4Owner.center = CGPointMake(view4Avatar.center.x + 18, view4Avatar.center.y + 14);
                [cell.contentView addSubview:image4Owner];
            }
            else if ([self isAssistant:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]])
            {
                UIImageView *image4Assistant = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupassistant"]];
                image4Assistant.center = CGPointMake(view4Avatar.center.x + 18, view4Avatar.center.y + 14);
                [cell.contentView addSubview:image4Assistant];
            }
            else if ([self isVIP:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]])
            {
                UIImageView *image4VIP = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupVIP"]];
                image4VIP.center = CGPointMake(view4Avatar.center.x + 18, view4Avatar.center.y + 14);
                [cell.contentView addSubview:image4VIP];
            }
            
            if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
                ![[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid] &&
                ![[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"owner"]])
            {
                //给图片增加长按手势
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGroupUser:)];
                objc_setAssociatedObject(longPressGest, @"targetView", view4Avatar, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", [array4GroupMember objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
                [view4Avatar addGestureRecognizer:longPressGest];
            }
            
            //给图片增加点击手势
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUserAvatar:)];
            objc_setAssociatedObject(tapGest, @"targetData", [array4GroupMember objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
            [view4Avatar addGestureRecognizer:tapGest];
            
            //昵称
            UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(interval + column * (50 + interval), 15 + line * 85 + 50, 50, 20)];
            label4NickName.text = str4NickName;
            label4NickName.textAlignment = NSTextAlignmentCenter;
            label4NickName.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:label4NickName];
        }
        
        //添加按钮
        column ++;
        if (column >= userPerLine)
        {
            column = 0;
            line ++;
        }
        UIButton *button4Add = [[UIButton alloc]initWithFrame:CGRectMake(interval + column * (50 + interval), 15 + line * 85, 50, 50)];
        button4Add.layer.cornerRadius = 25;
        button4Add.clipsToBounds = YES;
        button4Add.titleLabel.font = [UIFont systemFontOfSize:30];
        [button4Add setBackgroundImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [button4Add addTarget:self action:@selector(onButtonAdd:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button4Add];
        
        //删除按钮
        if ([self isIGroupOwner] ||
            [self isIAssistant])
        {
            column ++;
            if (column >= userPerLine)
            {
                column = 0;
                line ++;
            }
            UIButton *button4Del = [[UIButton alloc]initWithFrame:CGRectMake(interval + column * (50 + interval), 15 + line * 85, 50, 50)];
            button4Del.layer.cornerRadius = 25;
            button4Del.clipsToBounds = YES;
            button4Del.titleLabel.font = [UIFont systemFontOfSize:30];
            [button4Del setBackgroundImage:[UIImage imageNamed:@"minus"] forState:UIControlStateNormal];
            [button4Del addTarget:self action:@selector(onButtonDel:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button4Del];
        }
        
        //是否需要显示“更多”按钮
        if (userCount < array4GroupMember.count)
        {
            UIButton *button4More = [[UIButton alloc]initWithFrame:CGRectMake(0, 7 + (line + 1) * 85, self.view.frame.size.width, 40)];
            button4More.titleLabel.font = [UIFont systemFontOfSize:16];
            button4More.titleLabel.numberOfLines = 0;
            button4More.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button4More setTitle:LLSTR(@"201202") forState:UIControlStateNormal];
            [button4More setTitleColor:THEME_GRAY forState:UIControlStateNormal];
            [button4More addTarget:self action:@selector(onButtonShowMoreUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button4More];
            
            UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
            image4RightArrow.center = CGPointMake(self.view.frame.size.width - 20, 20);
            [button4More addSubview:image4RightArrow];
        }
        
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

#pragma mark - ContactSelectDelegate function

- (void)contactSelected:(NSInteger)cookie contacts:(NSArray *)contacts
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //不管是虚拟群还是普通群，一律调用普通群入群
    [self groupAddMember:contacts directly:YES apply:nil];
}

- (void)groupAddMember:(NSArray *)contacts directly:(BOOL)directly apply:(NSString *)apply
{
    if (contacts.count == 0)
        return;
    
    //添加朋友
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule addGroupMember:contacts groupId:self.groupId source:@{@"source":@"INVITE",@"inviter":[BiChatGlobal sharedManager].uid} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //重新刷新group member
            [self getGroupProperty];
            
            //NSLog(@"%@", self.groupId);
            //uNSLog(@"%@", data);
            
            //先生成所有朋友的列表字符串
            NSMutableArray *array4PeersSuccess = [NSMutableArray array];
            NSMutableArray *array4PeersFail = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInGroup = [NSMutableArray array];
            NSMutableArray *array4PeersNeedApprove = [NSMutableArray array];
            NSMutableArray *array4PeersBlocked = [NSMutableArray array];
            NSMutableArray *array4PeersFull = [NSMutableArray array];
            NSMutableArray *array4PeersTrail = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInWaitingPayList = [NSMutableArray array];
            for (int i = 0; i < contacts.count; i ++)
            {
                NSMutableDictionary *peer = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [contacts objectAtIndex:i], @"uid",
                                             [[BiChatGlobal sharedManager]getFriendNickName:[contacts objectAtIndex:i]], @"nickName",
                                             [BiChatGlobal sharedManager].uid, @"sender",
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
                        if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
                            [array4PeersTrail addObject:peer];
                        else
                            [array4PeersSuccess addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_PENDING_LIST"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersNeedApprove addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"NOT_YOUR_FRIEND"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersFail addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersAlreadyInGroup addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"NEED_APPROVE"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersNeedApprove addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersBlocked addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersFull addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_WAITING_PAY_LIST"] ||
                             [[item objectForKey:@"result"]isEqualToString:@"JOIN_WAITING_PAY_LIST"])
                    {
                        [array4PeersAlreadyInWaitingPayList addObject:peer];
                        break;
                    }
                }
            }
            
            //NSLog(@"1-%@", array4PeersSuccess);
            //NSLog(@"2-%@", array4PeersFull);
            //NSLog(@"3-%@", array4PeersFail);
            //NSLog(@"4-%@", array4PeersNeedApprove);
            
            //处理各种状态的显示，首先全部成功
            if ((array4PeersSuccess.count > 0 || array4PeersTrail.count > 0 || array4PeersAlreadyInGroup.count > 0 || array4PeersAlreadyInWaitingPayList.count > 0) && array4PeersFail.count == 0)
                [BiChatGlobal showInfo:LLSTR(@"301712") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else if ((array4PeersSuccess.count > 0 || array4PeersTrail.count > 0 || array4PeersAlreadyInGroup.count > 0 || array4PeersAlreadyInWaitingPayList.count > 0) && array4PeersFail.count > 0)
                [BiChatGlobal showInfo:LLSTR(@"301714") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else if (array4PeersNeedApprove.count > 0)
                [BiChatGlobal showInfo:LLSTR(@"301708") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else
                [BiChatGlobal showInfo:LLSTR(@"301713") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            
            NSMutableArray *blockarray = [self.groupProperty objectForKey:@"groupBlockUserLevelTwo"];
            NSMutableArray *removeArray = [NSMutableArray array];
            if (array4PeersSuccess.count > 0) {
                for (NSDictionary *dic in array4PeersSuccess) {
                    for (NSDictionary *dic1 in blockarray) {
                        if ([[dic objectForKey:@"uid"] isEqualToString:[dic1 objectForKey:@"uid"]]) {
                            [removeArray addObject:dic1];
                        }
                    }
                }
            }
            [blockarray removeObjectsInArray:removeArray];
            //分别处理各种情况
            if (array4PeersSuccess.count > 0)
            {
                //同时开始发送一个邀请朋友的信息message
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUP], @"type",
                                                 [array4PeersSuccess mj_JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                      peerUserName:@""
                                                      peerNickName:[BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil]
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
                
                //发送到服务器
                [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
            
            //有因为对方不是好友而没有加成功的人
            if (array4PeersFail.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL], @"type",
                                                 [array4PeersFail mj_JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId peerUserName:@""
                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                        peerAvatar:[self.groupProperty objectForKey:@"avatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            
            //有需要批准的人
            if (array4PeersNeedApprove.count > 0)
            {
                //内部保存这些信息
                for (NSDictionary *item in array4PeersNeedApprove)
                {
                    NSString *key = [NSString stringWithFormat:@"%@_%@", [item objectForKey:@"uid"], self.groupId];
                    [[BiChatGlobal sharedManager].dict4ApplyList setObject:@"NEED_APPROVE" forKey:key];
                }
                [[BiChatGlobal sharedManager]saveUserAdditionInfo];
                
                //准备数据,发送给群成员
                NSDictionary *applyInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                           apply==nil?@"":apply, @"apply",
                                           array4PeersNeedApprove, @"friends", nil];
                
                //同时开始发送一个邀请朋友的信息message,本条信息所有人都可以看到
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER], @"type",
                                                 [applyInfo mj_JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //发送到服务器
                [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    if (success)
                    {
                        //加入本地一条消息
                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                        
                        //接下来发送一条邀请朋友的信息message，本条信息只有群主或者管理员可以看到，用于批准申请
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBER], @"type",
                                                         [applyInfo mj_JSONString], @"content",
                                                         self.groupId, @"receiver",
                                                         [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                         [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];
                        
                        [NetworkModule sendMessageToGroupOperator:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                            if (success)
                            {
                                //接下来将向所有的需要审批个人发送一条模拟群消息，以让用户可以和群主建立虚拟聊天
                                NSString *msgId = [BiChatGlobal getUuidString];
                                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE], @"type",
                                                                 @"", @"content",
                                                                 self.groupId, @"receiver",
                                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
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
                                    [NetworkModule sendMessageToUser:[item objectForKey:@"uid"] message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                    }];
                                }
                            }
                        }];
                    }
                }];
            }
            
            //有因为黑名单而被拒绝的人
            if (array4PeersBlocked.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_BLOCKED], @"type",
                                                 [array4PeersBlocked mj_JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId peerUserName:@""
                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                        peerAvatar:[self.groupProperty objectForKey:@"avatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            
            //有因为群满而被拒绝的人
            if (array4PeersFull.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_FULL], @"type",
                                                 [array4PeersFull mj_JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId peerUserName:@""
                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                        peerAvatar:[self.groupProperty objectForKey:@"avatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            
            //有加入试用名单的人
            if (array4PeersTrail.count > 0)
            {
                //同时开始发送一个邀请朋友的信息message
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPTRAIL], @"type",
                                                 [array4PeersTrail mj_JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                      peerUserName:@""
                                                      peerNickName:[BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil]
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
                
                //发送到服务器
                [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
            
            //有在待付费列表中的人
            if (array4PeersAlreadyInWaitingPayList.count > 0)
            {
                //同时开始发送一个邀请朋友的信息message
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY], @"type",
                                                 [array4PeersAlreadyInWaitingPayList mj_JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                      peerUserName:@""
                                                      peerNickName:[BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil]
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
                
                //这条消息发送给群管理员和所有的对方
                [MessageHelper sendGroupMessageToOperator:self.groupId
                                                     type:MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY
                                                  content:[array4PeersAlreadyInWaitingPayList mj_JSONString]
                                                 needSave:NO
                                                 needSend:YES
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                for (NSDictionary *item in array4PeersAlreadyInWaitingPayList)
                {
                    NSString *uid = [item objectForKey:@"uid"];
                    [MessageHelper sendGroupMessageToUser:uid
                                                  groupId:self.groupId
                                                     type:MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY
                                                  content:[array4PeersAlreadyInWaitingPayList mj_JSONString]
                                                 needSave:NO
                                                 needSend:YES
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301723") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

#pragma mark - 私有函数

- (BOOL)isIGroupOwner
{
    return [[BiChatGlobal sharedManager].uid isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]];
}

- (BOOL)isIAssistant
{
    for (NSString *str in [self.groupProperty objectForKey:@"assitantUid"])
    {
        if ([[BiChatGlobal sharedManager].uid isEqualToString:str])
            return YES;
    }
    return NO;
}

- (BOOL)isAssistant:(NSString *)uid
{
    for (NSString *str in [self.groupProperty objectForKey:@"assitantUid"])
    {
        if ([uid isEqualToString:str])
            return YES;
    }
    return NO;
}

- (BOOL)isVIP:(NSString *)uid
{
    for (NSString *str in [self.groupProperty objectForKey:@"vip"])
    {
        if ([uid isEqualToString:str])
            return YES;
    }
    return NO;
}

- (void)onButtonAdd:(id)sender
{
    //准备数据
    NSMutableArray *array4Selected = [NSMutableArray array];
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
        [array4Selected addObject:[item objectForKey:@"uid"]];
    
    //开始选择新人
    ContactListViewController *wnd = [ContactListViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.selectMode = SELECTMODE_MULTI;
    wnd.multiSelectMax = 30;
    wnd.multiSelectMaxError = LLSTR(@"301027");
    wnd.delegate = self;
    wnd.alreadySelected = array4Selected;
    wnd.defaultTitle = LLSTR(@"201001");
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

//删除
- (void)onButtonDel:(id)sender
{
    GroupMemberDeleteViewController *wnd = [GroupMemberDeleteViewController new];
    wnd.groupId = self.groupId;
    wnd.groupProperty = self.groupProperty;
    
    [self.navigationController pushViewController:wnd animated:YES];
}

//显示更多用户
- (void)onButtonShowMoreUser:(id)sender
{
    AllGroupMemberViewController *wnd = [AllGroupMemberViewController new];
    wnd.groupId = self.groupId;
    wnd.groupProperty = self.groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)getGroupProperty
{
    [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            [self.groupProperty setObject:[data objectForKey:@"groupUserList"] forKey:@"groupUserList"];
            [self.groupProperty setObject:[data objectForKey:@"assitantUid"] forKey:@"assitantUid"];
            
            NSString * userCount = [NSString stringWithFormat:@"%lu",(long)[[self.groupProperty objectForKey:@"joinedGroupUserCount"]integerValue]];
            self.navigationItem.title = [LLSTR(@"201201") llReplaceWithArray:@[userCount]];
            
            [self.tableView reloadData];
        }
    }];
}

@end
