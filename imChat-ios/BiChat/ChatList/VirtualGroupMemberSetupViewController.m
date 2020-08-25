//
//  VirtualGroupMemberSetupViewController.m
//  BiChat Dev
//
//  Created by worm_kc on 2018/11/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "VirtualGroupMemberSetupViewController.h"
#import "GroupMemberSelectorViewController.h"
#import "VirtualGroupAssistAdminViewController.h"
#import "GroupBlockListViewController.h"
#import "GroupForbidListViewController.h"

@interface VirtualGroupMemberSetupViewController ()

@end

@implementation VirtualGroupMemberSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201207");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([[BiChatGlobal sharedManager].uid isEqualToString:[_groupProperty objectForKey:@"ownerUid"]])
        return 3;
    else
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[BiChatGlobal sharedManager].uid isEqualToString:[_groupProperty objectForKey:@"ownerUid"]])
    {
        if (section == 0)
            return 2;
        else if (section == 1)
            return 1;
        else
            return 1;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([[BiChatGlobal sharedManager].uid isEqualToString:[_groupProperty objectForKey:@"ownerUid"]])
    {
        if (section == 1)
        {
            NSString *str;
            str = LLSTR(@"201319");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            return rect.size.height + 20;
        }
    }
    else
    {
        if (section == 0)
        {
            NSString *str;
            str = LLSTR(@"201319");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            return rect.size.height + 20;
        }
    }
    
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([[BiChatGlobal sharedManager].uid isEqualToString:[_groupProperty objectForKey:@"ownerUid"]])
    {
        if (section == 1)
        {
            NSString *str;
            str = LLSTR(@"201319");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, rect.size.height + 20)];
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, self.view.frame.size.width - 30, rect.size.height)];
            label4Title.text = str;
            label4Title.numberOfLines = 0;
            label4Title.font = [UIFont systemFontOfSize:14];
            label4Title.textColor = [UIColor grayColor];
            [view4Title addSubview:label4Title];
            
            return view4Title;
        }
        else if (section == 2)
        {
            NSString *str;
            str = LLSTR(@"201321");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, rect.size.height + 20)];
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, self.view.frame.size.width - 30, rect.size.height)];
            label4Title.text = str;
            label4Title.numberOfLines = 0;
            label4Title.font = [UIFont systemFontOfSize:14];
            label4Title.textColor = [UIColor grayColor];
            [view4Title addSubview:label4Title];
            
            return view4Title;
        }
    }
    else
    {
        if (section == 0)
        {
            NSString *str;
            str = LLSTR(@"201319");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, rect.size.height + 20)];
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, self.view.frame.size.width - 30, rect.size.height)];
            label4Title.text = str;
            label4Title.numberOfLines = 0;
            label4Title.font = [UIFont systemFontOfSize:14];
            label4Title.textColor = [UIColor grayColor];
            [view4Title addSubview:label4Title];
            
            return view4Title;
        }
        else if (section == 1)
        {
            NSString *str;
            str = LLSTR(@"201321");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, rect.size.height + 20)];
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, self.view.frame.size.width - 30, rect.size.height)];
            label4Title.text = str;
            label4Title.numberOfLines = 0;
            label4Title.font = [UIFont systemFontOfSize:14];
            label4Title.textColor = [UIColor grayColor];
            [view4Title addSubview:label4Title];
            
            return view4Title;
        }
    }

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    // Configure the cell...
    if ([[BiChatGlobal sharedManager].uid isEqualToString:[_groupProperty objectForKey:@"ownerUid"]])
    {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            cell.textLabel.text = LLSTR(@"201301");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
            cell.textLabel.text = LLSTR(@"201303");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.section == 1 && indexPath.row == 0)
        {
            cell.textLabel.text = LLSTR(@"201318");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (long)[[self.groupProperty objectForKey:@"groupBlockUserLevelTwo"]count]];
            if ([[self.groupProperty objectForKey:@"groupBlockUserLevelTwo"]count] > 0)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            else
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (indexPath.section == 2 && indexPath.row == 0)
        {
            cell.textLabel.text = LLSTR(@"201320");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (long)[[self.groupProperty objectForKey:@"muteUsers"]count]];
            if ([[self.groupProperty objectForKey:@"muteUsers"]count] > 0)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            else
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else
    {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            cell.textLabel.text = LLSTR(@"201318");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (long)[[self.groupProperty objectForKey:@"groupBlockUserLevelTwo"]count]];
            if ([[self.groupProperty objectForKey:@"groupBlockUserLevelTwo"]count] > 0)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            else
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (indexPath.section == 1 && indexPath.row == 0)
        {
            cell.textLabel.text = LLSTR(@"201320");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (long)[[self.groupProperty objectForKey:@"muteUsers"]count]];
            if ([[self.groupProperty objectForKey:@"muteUsers"]count] > 0)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            else
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[BiChatGlobal sharedManager].uid isEqualToString:[_groupProperty objectForKey:@"ownerUid"]])
    {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            GroupMemberSelectorViewController *wnd = [GroupMemberSelectorViewController new];
            wnd.defaultTitle = LLSTR(@"201301");
            wnd.canSelectOwner = NO;
            wnd.canSelectAssistant = YES;
            wnd.needConfirm = YES;
            wnd.multiSelect = NO;
            wnd.cookie = 1;
            wnd.delegate = self;
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            wnd.showMemo = YES;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
            nav.navigationBar.translucent = NO;
            nav.navigationBar.tintColor = THEME_COLOR;
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
            VirtualGroupAssistAdminViewController *wnd = [[VirtualGroupAssistAdminViewController alloc]initWithStyle:UITableViewStyleGrouped];
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else if (indexPath.section == 1 && indexPath.row == 0)
        {
            if ([[self.groupProperty objectForKey:@"groupBlockUserLevelTwo"]count] > 0)
            {
                GroupBlockListViewController *wnd = [GroupBlockListViewController new];
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                [self.navigationController pushViewController:wnd animated:YES];
            }
        }
        else if (indexPath.section == 2 && indexPath.row == 0)
        {
            if ([[self.groupProperty objectForKey:@"muteUsers"]count] > 0)
            {
                GroupForbidListViewController *wnd = [GroupForbidListViewController new];
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                [self.navigationController pushViewController:wnd animated:YES];
            }
        }
    }
    else
    {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            if ([[self.groupProperty objectForKey:@"groupBlockUserLevelTwo"]count] > 0)
            {
                GroupBlockListViewController *wnd = [GroupBlockListViewController new];
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                [self.navigationController pushViewController:wnd animated:YES];
            }
        }
        else if (indexPath.section == 1 && indexPath.row == 0)
        {
            if ([[self.groupProperty objectForKey:@"muteUsers"]count] > 0)
            {
                GroupForbidListViewController *wnd = [GroupForbidListViewController new];
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                [self.navigationController pushViewController:wnd animated:YES];
            }
        }
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

- (void)memberSelected:(NSArray *)member withCookie:(NSInteger)cookie
{
    if ([member count] == 0)
        return;
    
    //关闭选择框
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //开始处理
    NSMutableArray *array4MemberUid = [NSMutableArray array];
    for (NSDictionary *item in member)
        [array4MemberUid addObject:[item objectForKey:@"uid"]];
    
    //获取主群id
    [NetworkModule getMainGroupIdByVirtualGroup:[self.groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            NSString *mainGroupId = [data objectForKey:@"mainGroupId"];
            
            if (cookie == 1)
            {
                if (array4MemberUid.count > 0)
                {
                    //设置新的群主
                    [NetworkModule setGroupOwner:mainGroupId
                                           owner:[array4MemberUid firstObject]
                                  completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
                     {
                         if (success)
                         {
                             [self.groupProperty setObject:[array4MemberUid firstObject] forKey:@"ownerUid"];
                             [self.tableView reloadData];
                             
                             //将本人
                             
                             //获取新群主的昵称
                             NSString *str = @"";
                             for (NSDictionary *item in member)
                             {
                                 if ([[array4MemberUid firstObject]isEqualToString:[item objectForKey:@"uid"]])
                                 {
                                     str = [item objectForKey:@"nickName"];
                                     break;
                                 }
                             }
                             
                             //装配一个新的通知消息
                             NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[array4MemberUid firstObject], @"uid",
                                                   str, @"nickName",
                                                   nil];
                             
                             //同时要发送一条数据通知群中的其他成员
                             for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                             {
                                 //本子群是否已经被解散
                                 NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
                                 if ([[groupProperty objectForKey:@"disabled"]boolValue])
                                     continue;

                                 NSString *msgId = [BiChatGlobal getUuidString];
                                 NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CHANGEGROUPOWNER], @"type",
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
                                                                               peerNickName:[NSString stringWithFormat:@"%@#%ld", [self.groupProperty objectForKey:@"groupName"], [[item objectForKey:@"virtualGroupNum"]integerValue]]
                                                                                 peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                                    message:[BiChatGlobal getMessageReadableString:sendData  groupProperty:self.groupProperty]
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
                     }];
                }
            }
            else if (cookie == 2)
            {
                //先找出添加了谁，删除了谁
                NSMutableArray *array4Delete = [NSMutableArray arrayWithArray:[self.groupProperty objectForKey:@"assitantUid"]];
                NSMutableArray *array4DeleteDelete = [NSMutableArray array];
                for (NSString *item in array4Delete)
                {
                    for (NSString *item2 in array4MemberUid)
                    {
                        if ([item isEqualToString:item2])
                        {
                            [array4DeleteDelete addObject:item];
                            break;
                        }
                    }
                }
                [array4Delete removeObjectsInArray:array4DeleteDelete];
                NSMutableArray *array4Add = [NSMutableArray arrayWithArray:array4MemberUid];
                NSMutableArray *array4DeleteAdd = [NSMutableArray array];
                for (NSString *item in array4Add)
                {
                    for (NSString *item2 in [self.groupProperty objectForKey:@"assitantUid"])
                    {
                        if ([item isEqualToString:item2])
                        {
                            [array4DeleteAdd addObject:item];
                            break;
                        }
                    }
                }
                [array4Add removeObjectsInArray:array4DeleteAdd];
                
                //第一步，添加群管理员
                if (array4Add.count > 0)
                {
                    [NetworkModule addGroupAssistant:mainGroupId assistant:array4Add completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        
                        if (success)
                        {
                            [self.groupProperty setObject:array4MemberUid forKey:@"assitantUid"];
                            [self.tableView reloadData];
                            
                            //通知窗口
                            NSMutableArray *array4NewAssistant = [NSMutableArray array];
                            
                            for (NSString *str in array4Add)
                            {
                                //获取新群管理员的昵称
                                NSString *str4NickName = @"";
                                for (NSDictionary *item in member)
                                {
                                    if ([str isEqualToString:[item objectForKey:@"uid"]])
                                    {
                                        str4NickName = [item objectForKey:@"nickName"];
                                        break;
                                    }
                                }
                                
                                //装配一个新的通知消息
                                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"uid",
                                                      str4NickName, @"nickName",
                                                      nil];
                                
                                [array4NewAssistant addObject:dict];
                            }
                            
                            //同时要发送一条数据通知群中的其他成员
                            for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                            {
                                //本子群是否已经被解散
                                NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
                                if ([[groupProperty objectForKey:@"disabled"]boolValue])
                                    continue;

                                NSString *msgId = [BiChatGlobal getUuidString];
                                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDASSISTANT], @"type",
                                                                 [array4NewAssistant mj_JSONString], @"content",
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
                                                                              peerNickName:[NSString stringWithFormat:@"%@#%ld", [self.groupProperty objectForKey:@"groupName"], [[item objectForKey:@"virtualGroupNum"]integerValue]]
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
                    }];
                }
                
                //第二部，删除管理员
                if (array4Delete.count > 0)
                {
                    [NetworkModule delGroupAssistant:mainGroupId assistant:array4Delete completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        
                        if (success)
                        {
                            [self.groupProperty setObject:array4MemberUid forKey:@"assitantUid"];
                            [self.tableView reloadData];
                            
                            //通知窗口
                            NSMutableArray *array4OldAssistant = [NSMutableArray array];
                            
                            for (NSString *str in array4Delete)
                            {
                                //获取新群管理员的昵称
                                NSString *str4NickName = @"";
                                for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                                {
                                    if ([str isEqualToString:[item objectForKey:@"uid"]])
                                    {
                                        str4NickName = [item objectForKey:@"nickName"];
                                        break;
                                    }
                                }
                                
                                //装配一个新的通知消息
                                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"uid",
                                                      str4NickName, @"nickName",
                                                      nil];
                                
                                [array4OldAssistant addObject:dict];
                            }
                            
                            //同时要发送一条数据通知群中的其他成员
                            for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                            {
                                //本子群是否已经被解散
                                NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"groupId"]];
                                if ([[groupProperty objectForKey:@"disabled"]boolValue])
                                    continue;
                                
                                NSString *msgId = [BiChatGlobal getUuidString];
                                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_DELASSISTANT], @"type",
                                                                 [array4OldAssistant mj_JSONString], @"content",
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
                                                                              peerNickName:[NSString stringWithFormat:@"%@#%ld", [self.groupProperty objectForKey:@"groupName"], [[item objectForKey:@"virtualGroupNum"]integerValue]]
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
                    }];
                }
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301742") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        
    }];
}


@end
