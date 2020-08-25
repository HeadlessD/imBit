//
//  ChatVirtualGroupSelectViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/5/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatDataModule.h"
#import "ChatVirtualGroupSelectViewController.h"

@interface ChatVirtualGroupSelectViewController ()

@end

@implementation ChatVirtualGroupSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:self.groupId];
    self.navigationItem.title = [groupProperty objectForKey:@"groupName"];
    array4VirtualGroupList = [groupProperty objectForKey:@"virtualGroupSubList"];
    [array4VirtualGroupList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        if ([[obj1 objectForKey:@"virtualGroupNum"]integerValue] == 0)
            return NSOrderedAscending;
        else if ([[obj2 objectForKey:@"virtualGroupNum"]integerValue] == 0)
            return NSOrderedDescending;
        else if ([[obj1 objectForKey:@"isBroadCastGroup"]boolValue])
            return NSOrderedAscending;
        else if ([[obj2 objectForKey:@"isBroadCastGroup"]boolValue])
            return NSOrderedDescending;
        else if ([[obj1 objectForKey:@"virtualGroupNum"]integerValue] > [[obj2 objectForKey:@"virtualGroupNum"]integerValue])
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    [self.tableView reloadData];
    
    //需要从网上获取一下群属性（暂时不用，以后如果发现信息不全的现象再放开这部分代码）
    //[NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
    //
    //    NSLog(@"%@", data);
    //    if (success)
    //    {
    //        [[BiChatDataModule sharedDataModule]setGroupProperty:self.groupId property:data];
    //        self.navigationItem.title = [data objectForKey:@"groupName"];
    //        groupProperty = data;
    //        array4ChatList = [groupProperty objectForKey:@"virtualGroupSubList"];
    //        [self.tableView reloadData];
    //    }
    //}];
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
    return array4VirtualGroupList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //隐藏管理群
    if (self.hideVirtualManageGroup && indexPath.row == 0)
        return 0;
    
    //隐藏收费群
    if (self.hideChargeGroup)
    {
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]];
        if ([[groupProperty objectForKey:@"payGroup"]boolValue])
            return 0;
    }
    
    //找出这个聊天的具体信息
    NSMutableArray *array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    NSMutableDictionary *dict4ChatItem = nil;
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        //处理不同的版本
        if ([[array4VirtualGroupList objectAtIndex:indexPath.row]isKindOfClass:[NSDictionary class]])
        {
            if ([[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]])
            {
                dict4ChatItem = [array4ChatList objectAtIndex:i];
                break;
            }
        }
    }
    
    //有没有消息在里面
    if (dict4ChatItem == nil)
        return 0;
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    //隐藏管理群
    if (self.hideVirtualManageGroup && indexPath.row == 0)
        return cell;
    
    //隐藏收费群
    if (self.hideChargeGroup)
    {
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]];
        if ([[groupProperty objectForKey:@"payGroup"]boolValue])
            return cell;
    }
    
    // Configure the cell...
    //找出这个聊天的具体信息
    NSMutableArray *array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    NSMutableDictionary *dict4ChatItem = nil;
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        //处理不同的版本
        if ([[array4VirtualGroupList objectAtIndex:indexPath.row]isKindOfClass:[NSDictionary class]])
        {
            if ([[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]])
            {
                dict4ChatItem = [array4ChatList objectAtIndex:i];
                break;
            }
        }
    }
    
    //有没有消息在里面
    if (dict4ChatItem == nil)
        return cell;

    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 110, 50)];
    if (indexPath.row == 0)
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 40, 40)];
        image4Avatar.image = [UIImage imageNamed:@"vgroup_manage"];
        [cell.contentView addSubview:image4Avatar];
        label4NickName.text = LLSTR(@"201503");
    }
    else if ([[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"isBroadCastGroup"]boolValue])
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 40, 40)];
        image4Avatar.image = [UIImage imageNamed:@"vgroup_broadcast"];
        [cell.contentView addSubview:image4Avatar];
        label4NickName.text = LLSTR(@"201504");
    }
    else
    {
        //正常项目
        NSInteger groupUserCount = [[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupUserCount"]integerValue];
        NSString *groupName;
        if ([[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"]length] > 0)
            groupName = [NSString stringWithFormat:@"%@", [[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"]];
        else
            groupName = [NSString stringWithFormat:@"%@", [[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"virtualGroupNum"]];
        UIView *view4Avatar = [BiChatGlobal getVirtualGroupAvatarWnd:_groupId nickName:groupName groupUserCount:groupUserCount frame:CGRectMake(15, 5, 40, 40)];
        [cell.contentView addSubview:view4Avatar];
        label4NickName.text = [NSString stringWithFormat:@"#%@", groupName];
    }
        
    label4NickName.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4NickName];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //找出这个聊天的具体信息
    NSMutableArray *array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    NSMutableDictionary *dict4ChatItem = nil;
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        //处理不同的版本
        if ([[array4VirtualGroupList objectAtIndex:indexPath.row]isKindOfClass:[NSDictionary class]])
        {
            if ([[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]])
            {
                dict4ChatItem = [array4ChatList objectAtIndex:i];
                break;
            }
        }
    }
    
    //有没有消息在里面
    if (dict4ChatItem == nil)
        return;
    
    //开始选择(普通条目)
    NSString *subGroupId = [[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"];
    [dict4ChatItem setObject:[[BiChatGlobal sharedManager]adjustGroupNickName4Display:subGroupId nickName:@""]forKey:@"peerNickName"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatSelected:withCookie:andTarget:)])
    {
        [self.delegate chatSelected:[NSArray arrayWithObject:dict4ChatItem] withCookie:self.cookie andTarget:self.target];
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

@end
