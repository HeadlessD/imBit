//
//  ChatListGroupApproveViewController.m
//  BiChat
//
//  Created by Admin on 2018/5/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "ChatListGroupApproveViewController.h"
#import "ChatViewController.h"
#import "GroupApproveViewController.h"

@interface ChatListGroupApproveViewController ()

@end

@implementation ChatListGroupApproveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101145");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshGUI];
    [BiChatGlobal sharedManager].APPROVEFriendChatList = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [BiChatGlobal sharedManager].APPROVEFriendChatList = nil;
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
        return array4ApproveList.count;
    else
        return array4ChatList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];

    // Configure the cell...
    if (indexPath.section == 0)
    {
        UIImageView *image4Icon = [[UIImageView alloc]initWithFrame:CGRectMake(13, 7, 50, 50)];
        image4Icon.image = [UIImage imageNamed:@"contact_groupapprove"];
        image4Icon.layer.cornerRadius = 25;
        image4Icon.clipsToBounds = YES;
        [cell.contentView addSubview:image4Icon];
        
        NSString *groupId = [[array4ApproveList objectAtIndex:indexPath.row]objectForKey:@"groupId"];
        NSString *groupNickName = [[array4ApproveList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"];
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(73, 11, self.view.frame.size.width - 100, 20)];
        label4Title.text = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:groupId nickName:groupNickName];
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
        
        UILabel *label4GroupNickName = [[UILabel alloc]initWithFrame:CGRectMake(73, 36, self.view.frame.size.width - 100, 15)];
        label4GroupNickName.text = LLSTR(@"201311");
        label4GroupNickName.font = [UIFont systemFontOfSize:13];
        label4GroupNickName.textColor = THEME_GRAY;
        [cell.contentView addSubview:label4GroupNickName];
        
        NSString *str4NewMessageCount = [NSString stringWithFormat:@"%ld", (long)[[[array4ApproveList objectAtIndex:indexPath.row]objectForKey:@"applyCount"]integerValue]];
        CGRect rect = [str4NewMessageCount boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                                        context:nil];
        if (rect.size.width < rect.size.height) rect.size.width = rect.size.height;
        
        UIImageView *image4RedBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 4, rect.size.height + 4)];
        image4RedBk.image = [UIImage imageNamed:@"red"];
        image4RedBk.center = CGPointMake(58, 16.5);
        image4RedBk.layer.cornerRadius = (rect.size.height + 4) / 2;
        image4RedBk.clipsToBounds = YES;
        [cell.contentView addSubview:image4RedBk];
        
        UILabel *label4NewMessageCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 4, rect.size.height + 4)];
        label4NewMessageCount.text = str4NewMessageCount;
        label4NewMessageCount.textAlignment = NSTextAlignmentCenter;
        label4NewMessageCount.textColor = [UIColor whiteColor];
        label4NewMessageCount.font = [UIFont systemFontOfSize:10];
        label4NewMessageCount.layer.cornerRadius = (rect.size.height + 4) / 2;
        label4NewMessageCount.clipsToBounds = YES;
        label4NewMessageCount.center = CGPointMake(58, 16);
        [cell.contentView addSubview:label4NewMessageCount];
    }
    else if (indexPath.section == 1)
    {
        NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
        NSString *applyUser = [item objectForKey:@"peerUid"];
        NSString *applyNickName = [item objectForKey:@"peerNickName"];
        NSString *applyAvatar = [item objectForKey:@"peerAvatar"];
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:applyUser
                                                nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:applyUser groupProperty:nil nickName:applyNickName]
                                                  avatar:applyAvatar
                                                   width:50 height:50];
        view4Avatar.center = CGPointMake(38, 32);
        [cell.contentView addSubview:view4Avatar];
        
        //最后消息时间
        CGRect rect4LastMessageTime;
        if ([[item objectForKey:@"lastMessageTime"]length] > 0)
        {
            NSString *str = [BiChatGlobal adjustDateString:[item objectForKey:@"lastMessageTime"]];
            rect4LastMessageTime = [str boundingRectWithSize:CGSizeMake(90, MAXFLOAT)
                                                     options:0
                                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11]}
                                                     context:nil];
            
            UILabel *label4LastMessageTime = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - rect4LastMessageTime.size.width, 12.5, rect4LastMessageTime.size.width, 12)];
            label4LastMessageTime.text = str;
            label4LastMessageTime.font = [UIFont systemFontOfSize:11];
            label4LastMessageTime.textAlignment = NSTextAlignmentRight;
            label4LastMessageTime.textColor = THEME_GRAY;
            label4LastMessageTime.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:label4LastMessageTime];
        }
        
        //是否群
        if ([[item objectForKey:@"isGroup"]boolValue] &&
            ![[item objectForKey:@"isPublic"]boolValue])
        {
            if (![BiChatGlobal isCustomerServiceGroup:[item objectForKey:@"peerUid"]])
            {
                UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_servicegroup"]];
                image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
                image4GroupFlag.center = CGPointMake(58, 47);
                image4GroupFlag.clipsToBounds = YES;
                image4GroupFlag.layer.cornerRadius = 9.7;
                image4GroupFlag.clipsToBounds = YES;
                [cell.contentView addSubview:image4GroupFlag];
            }

            //先看看这个群有几个图标
            NSArray *array4GroupFlag = [[BiChatGlobal sharedManager]getGroupFlag:[item objectForKey:@"peerUid"]];
            
            //计算群昵称的空间大小
            NSString *groupNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:[item objectForKey:@"orignalGroupId"] nickName:[item objectForKey:@"peerNickName"]];
            NSString *str = groupNickName;
            if ([[item objectForKey:@"isApprove"]boolValue])
            {
                str = [NSString stringWithFormat:@"%@ & %@", groupNickName, [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"applyUser"] groupProperty:nil nickName: [item objectForKey:@"applyUserNickName"]]];
            }
            CGRect rect4NickName = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 72 - 5 - array4GroupFlag.count * 28 - rect4LastMessageTime.size.width - 10, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                     context:nil];
            
            //昵称
            UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, rect4NickName.size.width, 20)];
            label4UserName.text = str;
            label4UserName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4UserName];
            
            //添加所有的图标
            for (int i = 0; i < array4GroupFlag.count; i ++)
            {
                UIImageView *view4GroupFlag = [[UIImageView alloc]initWithFrame:CGRectMake(72 + rect4NickName.size.width + i * 28 + 5, 12.5, 24, 16)];
                if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"normal_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_normalgroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"encrypt_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_encryptgroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"virtual_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_virtualgroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"big_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_biggroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"searchable_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_searchablegroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"charge_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_chargegroup"];
                else if ([[array4GroupFlag objectAtIndex:i]isEqualToString:@"service_group"])
                    view4GroupFlag.image = [UIImage imageNamed:@"flag_servicegroup"];
                [cell.contentView addSubview:view4GroupFlag];
            }
        }
        else
        {
            //昵称
            UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, self.view.frame.size.width - 170, 20)];
            label4UserName.text = [NSString stringWithFormat:@"%@_%@", [item objectForKey:@"peerNickName"], [item objectForKey:@"applyUserNickName"]];
            label4UserName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4UserName];
        }
        
        //消息条数
        if ([[item objectForKey:@"newMessageCount"]integerValue] > 0)
        {
            UIImageView *image4NewMessageFlag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            image4NewMessageFlag.image = [UIImage imageNamed:@"red"];
            image4NewMessageFlag.backgroundColor = [UIColor redColor];
            image4NewMessageFlag.layer.cornerRadius = 5;
            image4NewMessageFlag.clipsToBounds = YES;
            image4NewMessageFlag.center = CGPointMake(62, 11);
            [cell.contentView addSubview:image4NewMessageFlag];
        }
                
        //最后消息
        UILabel *label4LastMessage = [[UILabel alloc]initWithFrame:CGRectMake(72, 36, self.view.frame.size.width - 100, 15)];
        label4LastMessage.text = [item objectForKey:@"lastMessage"];
        label4LastMessage.font = [UIFont systemFontOfSize:13];
        label4LastMessage.textColor = THEME_GRAY;
        [cell.contentView addSubview:label4LastMessage];
    }
        
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 63.5, self.view.frame.size.width - 10, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.92 alpha:1];
    [cell.contentView addSubview:view4Seperator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        GroupApproveViewController *wnd = [GroupApproveViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.groupId = [[array4ApproveList objectAtIndex:indexPath.row]objectForKey:@"groupId"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1)
    {
        NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
        
        //清楚这个聊天的新消息条数
        [[BiChatDataModule sharedDataModule]clearNewMessageCountWith:[item objectForKey:@"peerUid"]];
        
        //进入聊天界面
        ChatViewController *wnd = [ChatViewController new];
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.peerUid = [item objectForKey:@"peerUid"];
        wnd.peerUserName = [item objectForKey:@"peerUserName"];
        wnd.peerNickName = [item objectForKey:@"peerNickName"];
        wnd.peerAvatar = [item objectForKey:@"peerAvatar"];
        wnd.isGroup = [[item objectForKey:@"isGroup"]boolValue];
        wnd.isApprove = YES;
        wnd.orignalGroupId = [item objectForKey:@"orignalGroupId"];
        wnd.applyUser = [item objectForKey:@"applyUser"];
        wnd.applyUserNickName = [item objectForKey:@"applyUserNickName"];
        wnd.applyUserAvatar = [item objectForKey:@"applyUserAvatar"];
        
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //删除按钮
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"101018") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [[BiChatDataModule sharedDataModule]deleteChatItemInList:[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"peerUid"]];
        [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"peerUid"]];
        //[[BiChatDataModule sharedDataModule]setLastMessageTime:[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"peerUid"] time:nil];
        [array4ChatList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
    }];
    
    if (indexPath.section == 0)
        return @[];
    else
        return @[deleteAction];
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

- (void)refreshGUI
{
    [self performSelectorOnMainThread:@selector(refreshGUIInternal) withObject:nil waitUntilDone:NO];
}

- (void)refreshGUIInternal
{
    //调整入群审批
    array4ApproveList = [NSMutableArray array];
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        //先从已有的条目里面查找
        BOOL found = NO;
        for (NSMutableDictionary *item2 in array4ApproveList)
        {
            if ([[item objectForKey:@"groupId"]isEqualToString:[item2 objectForKey:@"groupId"]])
            {
                found = YES;
                if ([item2 objectForKey:@"status"] == nil)
                    [item2 setObject:[NSNumber numberWithInteger:[[item2 objectForKey:@"applyCount"]integerValue] + 1]
                          forKey:@"applyCount"];
                break;
            }
        }
        
        //没发现，添加一条新的
        if (!found)
        {
            [array4ApproveList addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"groupId": [item objectForKey:@"groupId"],
                                                                                         @"groupNickName": [item objectForKey:@"groupNickName"],
                                                                                         @"applyCount": [NSNumber numberWithInteger:1]}]];
        }
    }
    
    //调整入群审批聊天
    array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    
    //重新调整置顶的item
    NSMutableArray *array = [NSMutableArray array];
    
    //再找出所有的没有置顶的项目，里面要处理所有的非朋友信息
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        if (([[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue] &&
             ![BiChatGlobal isQueryGroup:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]]) ||
            [BiChatGlobal isCustomerServiceGroup:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]])
            [array addObject:[array4ChatList objectAtIndex:i]];
    }
    
    //重新赋值
    array4ChatList = array;
    [self.tableView reloadData];
}

@end
