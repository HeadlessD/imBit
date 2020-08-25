//
//  GroupAddMemberConfirmViewController.m
//  BiChat
//
//  Created by Admin on 2018/5/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "GroupAddMemberConfirmViewController.h"
#import "JSONKit.h"

@interface GroupAddMemberConfirmViewController ()

@end

@implementation GroupAddMemberConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"确认邀请";
    self.tableView.tableFooterView = [UIView new];
    
    if (self.friends == nil)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *item = [dec objectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        friends_total = [item objectForKey:@"friends"];
    }
    else
        friends_total = self.friends;
    friends_selected = [NSMutableArray array];

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
    return friends_total.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[[friends_total objectAtIndex:indexPath.row]objectForKey:@"peerUid"]
                                            nickName:[[friends_total objectAtIndex:indexPath.row]objectForKey:@"peerNickName"]
                                              avatar:[[friends_total objectAtIndex:indexPath.row]objectForKey:@"peerAvatar"]
                                               frame:CGRectMake(15, 5, 40, 40)];
    [cell.contentView addSubview:view4Avatar];
    
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 100, 50)];
    label4NickName.text = [[friends_total objectAtIndex:indexPath.row]objectForKey:@"peerNickName"];
    label4NickName.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:label4NickName];
    
    UIImageView *image4Check = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];
    if (![self isSelected:[[friends_total objectAtIndex:indexPath.row]objectForKey:@"peerUid"]])
        image4Check.image = [UIImage imageNamed:@"CellNotSelected"];
    image4Check.center = CGPointMake(self.view.frame.size.width - 30, 25);
    [cell.contentView addSubview:image4Check];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 设置置顶按钮
    UITableViewRowAction *rejectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"拒绝" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [NetworkModule rejectGroupApplication:self.groupId userList:[NSArray arrayWithObject:[[_friends objectAtIndex:indexPath.row]objectForKey:@"peerUid"]] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data){
            
            if (success)
            {
                //生成可以显示的拒绝列表
                NSMutableArray *array4Display = [NSMutableArray array];
                [array4Display addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [[friends_total objectAtIndex:indexPath.row]objectForKey:@"peerUid"], @"uid",
                                          [[friends_total objectAtIndex:indexPath.row]objectForKey:@"peerNickName"], @"nickName",
                                          [[friends_total objectAtIndex:indexPath.row]objectForKey:@"peerAvatar"], @"avatar",
                                          nil]];

                //生成一个新的消息
                NSString *msgId = [NSUUID UUID].UUIDString;
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [dict JSONString], @"content",
                                                [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER], @"type",
                                                self.groupId , @"receiver",
                                                [_groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                                [_groupProperty objectForKey:@"avatar"], @"receiverAvatar",
                                                [BiChatGlobal sharedManager].uid, @"sender",
                                                [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                [BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                msgId, @"msgId",
                                                @"1", @"isGroup",
                                                [BiChatGlobal getCurrentDateString], @"time",
                                                nil];
                
                //将本消息发送到群里面
                [NetworkModule sendMessageToGroup:self.groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
                
                //最后添加到本会话里面
                if (self.ownerChatWnd)
                    [self.ownerChatWnd appendMessage:message];
                
                //修改本条消息内容
                JSONDecoder *dec = [JSONDecoder new];
                NSMutableDictionary *dict4Target = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                NSMutableArray *array4Friends = [dict4Target objectForKey:@"friends"];
                
                for (NSMutableDictionary *friend in array4Friends)
                {
                    if ([[friend objectForKey:@"peerUid"]isEqualToString:[[friends_total objectAtIndex:indexPath.row]objectForKey:@"peerUid"]])
                    {
                        [friend setObject:@"REJECTED" forKey:@"status"];
                        break;
                    }
                }
                
                [self.message setObject:[dict4Target mj_JSONString] forKey:@"content"];
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.groupId index:[[self.message objectForKey:@"index"]integerValue] message:self.message];
                
                [friends_total removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            else
                [BiChatGlobal showInfo:@"拒绝入群失败" withIcon:[UIImage imageNamed:@"icon_alert"]];
        }];
    }];
    
    rejectAction.backgroundColor = [UIColor redColor];
    return @[rejectAction];
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

- (void)onButtonApprove:(id)sender
{
    //开始批准
    [NetworkModule approveGroupApplication:self.groupId userList:friends_selected completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            //生成可以显示的批准列表
            NSMutableArray *array4Display = [NSMutableArray array];
            for (int i = 0; i < _friends.count; i ++)
            {
                if ([self isSelected:[[_friends objectAtIndex:i]objectForKey:@"peerUid"]])
                {
                    [array4Display addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [[_friends objectAtIndex:i]objectForKey:@"peerUid"], @"uid",
                                              [[_friends objectAtIndex:i]objectForKey:@"peerNickName"], @"nickName",
                                              [[_friends objectAtIndex:i]objectForKey:@"peerAvatar"], @"avatar",
                                              nil]];
                }
            }
            
            //生成一个新的消息
            NSString *msgId = [NSUUID UUID].UUIDString;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
            NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [dict JSONString], @"content",
                                            [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER], @"type",
                                            self.groupId , @"receiver",
                                            [_groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                            [_groupProperty objectForKey:@"avatar"], @"receiverAvatar",
                                            [BiChatGlobal sharedManager].uid, @"sender",
                                            [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                            [BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                            [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                            msgId, @"msgId",
                                            @"1", @"isGroup",
                                            [BiChatGlobal getCurrentDateString], @"time",
                                            nil];
            
            //将本消息发送到群里面
            [NetworkModule sendMessageToGroup:self.groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
            
            //最后添加到本会话里面
            if (self.ownerChatWnd)
                [self.ownerChatWnd appendMessage:message];
            
            //修改本条消息内容
            JSONDecoder *dec = [JSONDecoder new];
            NSMutableDictionary *dict4Target = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            NSMutableArray *array4Friends = [dict4Target objectForKey:@"friends"];
        
            for (NSMutableDictionary *friend in array4Friends)
            {
                if ([self isSelected:[friend objectForKey:@"peerUid"]])
                {
                    [friend setObject:@"APPROVED" forKey:@"status"];
                }
            }
            
            [self.message setObject:[dict4Target mj_JSONString] forKey:@"content"];
            [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.groupId index:[[self.message objectForKey:@"index"]integerValue] message:self.message];
            
            //关闭本界面
            [BiChatGlobal showInfo:@"已同意" withIcon:[UIImage imageNamed:@"icon_OK"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            [BiChatGlobal showInfo:@"同意入群失败" withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

@end
