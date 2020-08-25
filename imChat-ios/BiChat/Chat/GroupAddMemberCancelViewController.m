//
//  GroupAddMemberCancelViewController.m
//  BiChat
//
//  Created by Admin on 2018/5/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatDataModule.h"
#import "GroupAddMemberCancelViewController.h"
#import "JSONKit.h"
#import "UserDetailViewController.h"
#import "NetworkModule.h"

@interface GroupAddMemberCancelViewController ()

@end

@implementation GroupAddMemberCancelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"203015");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    friends_selected = [NSMutableArray array];
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *applyInfo = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    array4Friends = [NSMutableArray arrayWithArray:[applyInfo objectForKey:@"friends"]];
    
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
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return array4Friends.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    NSDictionary *item = [array4Friends objectAtIndex:indexPath.row];
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"uid"]
                                            nickName:[item objectForKey:@"nickName"]
                                              avatar:[item objectForKey:@"avatar"]
                                               frame:CGRectMake(15, 5, 40, 40)];
    [cell.contentView addSubview:view4Avatar];
    
    UIButton *button4UserDetail = [[UIButton alloc]initWithFrame:view4Avatar.frame];
    button4UserDetail.tag = indexPath.row;
    [button4UserDetail addTarget:self action:@selector(onButtonUserDetail:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button4UserDetail];
    
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 130, 50)];
    label4NickName.text = [item objectForKey:@"nickName"];
    label4NickName.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4NickName];
    
    UILabel *label4Status = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, 17, 50, 15)];
    label4Status.textAlignment = NSTextAlignmentCenter;
    label4Status.font = [UIFont systemFontOfSize:14];
    label4Status.clipsToBounds = YES;
    [cell.contentView addSubview:label4Status];
    
    //是否已经选择
    UIImageView *image4Check = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];
    if (![self isSelected:[[array4Friends objectAtIndex:indexPath.row]objectForKey:@"uid"]])
        image4Check.image = [UIImage imageNamed:@"CellNotSelected"];
    image4Check.center = CGPointMake(self.view.frame.size.width - 30, 25);
    [cell.contentView addSubview:image4Check];
    
    //处理状态
    NSString *key = [NSString stringWithFormat:@"%@_%@", [item objectForKey:@"uid"], self.groupId];
    if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        label4Status.text = LLSTR(@"201073");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    if ([[[array4Friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"APPROVED"])
    {
        label4Status.text = LLSTR(@"201071");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    else if ([[[array4Friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"REJECTED"])
    {
        label4Status.text = LLSTR(@"201070");
        label4Status.textColor = THEME_RED;
        image4Check.image = nil;
    }
    else if ([[[array4Friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"EXPIRED"])
    {
        label4Status.text = LLSTR(@"101421");
        label4Status.textColor = THEME_RED;
        image4Check.image = nil;
    }
    else if ([self isUserInGroup:[[array4Friends objectAtIndex:indexPath.row]objectForKey:@"uid"]])
    {
        label4Status.text = LLSTR(@"201071");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    else if ([self isUserInBlackList:[[array4Friends objectAtIndex:indexPath.row]objectForKey:@"uid"]])
    {
        label4Status.text = LLSTR(@"201072");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    else if ([[[BiChatGlobal sharedManager].dict4ApplyList objectForKey:key] isEqualToString:@"REJECTED"])
    {
        label4Status.text = LLSTR(@"201070");
        label4Status.textColor = THEME_RED;
        image4Check.image = nil;
    }
    else if ([[[BiChatGlobal sharedManager].dict4ApplyList objectForKey:key] isEqualToString:@"APPROVED"])
    {
        label4Status.text = LLSTR(@"201071");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    else if ([[[BiChatGlobal sharedManager].dict4ApplyList objectForKey:key] isEqualToString:@"CANCELLED"])
    {
        label4Status.text = LLSTR(@"201074");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    else if ([[[BiChatGlobal sharedManager].dict4ApplyList objectForKey:key] isEqualToString:@"EXPIRED"])
    {
        label4Status.text = LLSTR(@"101421");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *uid = [[array4Friends objectAtIndex:indexPath.row]objectForKey:@"uid"];
    
    //是否不可选择
    NSString *key = [NSString stringWithFormat:@"%@_%@", uid, self.groupId];
    if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] ||
        [[[array4Friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"APPROVED"] ||
        [[[array4Friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"REJECTED"] ||
        [self isUserInGroup:uid] ||
        [self isUserInBlackList:uid] ||
        [[[BiChatGlobal sharedManager].dict4ApplyList objectForKey:key] isEqualToString:@"REJECTED"] ||
        [[[BiChatGlobal sharedManager].dict4ApplyList objectForKey:key] isEqualToString:@"APPROVED"] ||
        [[[BiChatGlobal sharedManager].dict4ApplyList objectForKey:key] isEqualToString:@"CANCELLED"])
        return;
    
    if ([self isSelected:uid])
        [self unSelect:uid];
    else
        [self select:uid];
    [self.tableView reloadData];
    
    //是否有选择
    if (friends_selected.count > 0)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101001") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    else
        self.navigationItem.rightBarButtonItem = nil;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


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

- (void)onButtonUserDetail:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag;
    
    //进入用户信息
    NSDictionary *item = [array4Friends objectAtIndex:index];
    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
    wnd.uid = [item objectForKey:@"uid"];
    wnd.avatar = [item objectForKey:@"avatar"];
    wnd.nickName = [item objectForKey:@"nickName"];
    wnd.userName = [item objectForKey:@"userName"];
    [self.navigationController pushViewController:wnd animated:YES];
}

- (BOOL)isUserInGroup:(NSString *)uid
{
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:uid])
            return YES;
    }
    return NO;
}

- (BOOL)isUserInBlackList:(NSString *)uid
{
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupBlackList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:uid])
            return YES;
    }
    return NO;
}

- (void)select:(NSString *)uid
{
    for (NSString *item in friends_selected)
    {
        if ([item isEqualToString:uid])
            return;
    }
    [friends_selected addObject:uid];
}

- (void)unSelect:(NSString *)uid
{
    for (NSString *item in friends_selected)
    {
        if ([item isEqualToString:uid])
        {
            [friends_selected removeObject:uid];
            return;
        }
    }
}

- (BOOL)isSelected:(NSString *)uid
{
    for (NSString *item in friends_selected)
    {
        if ([uid isEqualToString:item])
            return YES;
    }
    return NO;
}

- (void)onButtonCancel:(id)sender
{
    [NetworkModule cancelGroupApplication:self.groupId
                                 userList:friends_selected
                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
     {
         if (!isTimeOut && success)
         {
             //提示用户
             if ([[data objectForKey:@"successData"]count] > 0 && [[data objectForKey:@"failData"]count] == 0)
                 [BiChatGlobal showInfo:LLSTR(@"301809") withIcon:[UIImage imageNamed:@"icon_OK"]];
             else if ([[data objectForKey:@"successData"]count] > 0 && [[data objectForKey:@"failData"]count] > 0)
                 [BiChatGlobal showInfo:LLSTR(@"301811") withIcon:[UIImage imageNamed:@"icon_OK"]];
             else
                 [BiChatGlobal showInfo:LLSTR(@"301810") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
             
             //调整数据
             [friends_selected removeAllObjects];
             [friends_selected addObjectsFromArray:[data objectForKey:@"successData"]];
             [self.tableView reloadData];
             if (friends_selected.count > 0)
             {
                 //生成取消的人的列表,并且重新生成消息
                 NSMutableArray *array4Display = [NSMutableArray array];
                 for (NSMutableDictionary *item in array4Friends)
                 {
                     if ([self isSelected:[item objectForKey:@"uid"]])
                     {
                         //内部记录数据
                         NSString *key = [NSString stringWithFormat:@"%@_%@", [item objectForKey:@"uid"], self.groupId];
                         [[BiChatGlobal sharedManager].dict4ApplyList setObject:@"CANCELLED" forKey:key];
                         [array4Display addObject:[NSDictionary dictionaryWithObjectsAndKeys:[item objectForKey:@"uid"], @"uid",
                                                   [item objectForKey:@"nickName"], @"nickName",
                                                   [item objectForKey:@"avatar"]==nil?@"":[item objectForKey:@"avatar"], @"avatar",
                                                   nil]];
                     }
                 }
                 [[BiChatGlobal sharedManager]saveUserAdditionInfo];
                 
                 //发送一条系统提示消息到群里
                 NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
                 NSString *msgId = [BiChatGlobal getUuidString];
                 NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [dict mj_JSONString], @"content",
                                                 [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_CANCELADDTOGROUP], @"type",
                                                 @"1", @"isGroup",
                                                 self.groupId, @"receiver",
                                                 [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                                 [self.groupProperty objectForKey:@"avatar"]==nil?@"":[self.groupProperty objectForKey:@"avatar"], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 msgId, @"msgId",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 nil];
                 
                 [NetworkModule sendMessageToGroup:self.groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                     
                     if (success)
                     {
                         [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:message];
                         [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                               peerUserName:@""
                                                               peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                 peerAvatar:[self.groupProperty objectForKey:@"groupAvatar"]
                                                                    message:[BiChatGlobal getMessageReadableString:message groupProperty:self.groupProperty]
                                                                messageTime:[BiChatGlobal getCurrentDateString]
                                                                      isNew:NO
                                                                    isGroup:YES
                                                                   isPublic:NO
                                                                  createNew:YES];
                         
                         for (NSString *uid in friends_selected)
                         {
                             NSString *nickName = @"";
                             for (NSDictionary *item in array4Friends)
                             {
                                 if ([uid isEqualToString:[item objectForKey:@"uid"]])
                                     nickName = [item objectForKey:@"nickName"];
                             }
                             NSDictionary *friendInfo = @{@"friends":@[@{@"uid":uid,@"nickName":nickName}]};
                             NSString *msgId = [BiChatGlobal getUuidString];
                             NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CANCELADDTOGROUP], @"type",
                                                              [friendInfo JSONString], @"content",
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
                             
                             [NetworkModule sendMessageToUser:uid message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                 ;
                             }];
                         }
                     }
                     
                     [friends_selected removeAllObjects];
                     self.navigationItem.rightBarButtonItem = nil;
                 }];
             }
         }
         else
             [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
     }];
}

@end
