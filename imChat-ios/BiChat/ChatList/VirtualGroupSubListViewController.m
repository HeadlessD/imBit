//
//  VirtualGroupSubListViewController.m
//  BiChat Dev
//
//  Created by worm_kc on 2018/12/3.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "VirtualGroupSubListViewController.h"
#import "ChatViewController.h"
#import "MessageHelper.h"

@interface VirtualGroupSubListViewController ()

@end

@implementation VirtualGroupSubListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201508");
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
    
    //每次都刷新一下子群的信息
    [self refreshVirtualGroupList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return array4SubGroupList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 0;
    else
        return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    // Configure the cell...
    //管理群不用显示
    if (indexPath.row == 0)
        return cell;
    
    //这个子群是否有群信息在本地
    NSString *subGroupId = [[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"];
    NSDictionary *subGroupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:subGroupId];
    if (subGroupProperty == nil ||
        [[subGroupProperty objectForKey:@"createdTime"]longLongValue] == 0 ||
        [[subGroupProperty objectForKey:@"creatorNickname"]length] == 0)
    {
        UILabel *label4SubGroupName = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 50)];
        label4SubGroupName.font = [UIFont systemFontOfSize:16];
        if ([[[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"]length] == 0)
            label4SubGroupName.text = [NSString stringWithFormat:@"#%ld", (long)[[[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"virtualGroupNum"]integerValue]];
        else
            label4SubGroupName.text = [NSString stringWithFormat:@"#%ld ( %@ )", (long)indexPath.row, [[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"]];
        [cell.contentView addSubview:label4SubGroupName];
        
        if ([[[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"disabled"]boolValue])
            label4SubGroupName.frame = CGRectMake(15, 0, self.view.frame.size.width - 100, 50);
        
        //获取群信息
        [NetworkModule getGroupProperty:subGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    else
    {
        UILabel *label4SubGroupName = [[UILabel alloc]initWithFrame:CGRectMake(15, 3, self.view.frame.size.width - 30, 25)];
        label4SubGroupName.font = [UIFont systemFontOfSize:16];
        if ([[subGroupProperty objectForKey:@"isBroadCastGroup"]boolValue])
            label4SubGroupName.text = [NSString stringWithFormat:@"#%ld ( %@ )", (long)[[[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"virtualGroupNum"]integerValue],LLSTR(@"201504")];
        else if ([[[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"]length] == 0)
            label4SubGroupName.text = [NSString stringWithFormat:@"#%ld", (long)[[[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"virtualGroupNum"]integerValue]];
        else
            label4SubGroupName.text = [NSString stringWithFormat:@"#%ld ( %@ )", (long)[[[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"virtualGroupNum"]integerValue], [[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"]];
        [cell.contentView addSubview:label4SubGroupName];
        
        UILabel *label4SubGroupInfo = [[UILabel alloc]initWithFrame:CGRectMake(15, 29, self.view.frame.size.width - 30, 15)];
        label4SubGroupInfo.font = [UIFont systemFontOfSize:12];
        label4SubGroupInfo.textColor = [UIColor lightGrayColor];
        
        if ([[subGroupProperty objectForKey:@"creatorType"]isEqualToString:@"SYSTEM"])
            label4SubGroupInfo.text = [LLSTR(@"201517") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[subGroupProperty objectForKey:@"createdTime"]longLongValue]/1000]]]]];
        else if ([[subGroupProperty objectForKey:@"creatorType"]isEqualToString:@"REWARD"])
            label4SubGroupInfo.text = [LLSTR(@"201518") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[subGroupProperty objectForKey:@"createdTime"]longLongValue]/1000]]]]];
        else if ([[subGroupProperty objectForKey:@"creatorType"]isEqualToString:@"URL"])
            label4SubGroupInfo.text = [LLSTR(@"201524") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[subGroupProperty objectForKey:@"createdTime"]longLongValue]/1000]]]]];
        else if ([[subGroupProperty objectForKey:@"creatorType"]isEqualToString:@"DISCOVER"])
            label4SubGroupInfo.text = [LLSTR(@"201523") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[subGroupProperty objectForKey:@"createdTime"]longLongValue]/1000]]]]];
        else
            label4SubGroupInfo.text = [LLSTR(@"201519") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[subGroupProperty objectForKey:@"createdTime"]longLongValue]/1000]]],
                                       [NSString stringWithFormat:@"%@",[subGroupProperty objectForKey:@"creatorNickname"]]]];
        [cell.contentView addSubview:label4SubGroupInfo];
        
        if ([[[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"disabled"]boolValue])
        {
            label4SubGroupName.frame = CGRectMake(15, 3, self.view.frame.size.width - 100, 25);
            label4SubGroupInfo.frame = CGRectMake(15, 29, self.view.frame.size.width - 100, 15);
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([[[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"disabled"]boolValue])
    {
        UILabel *label4Dismissed = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 85, 0, 55, 50)];
        label4Dismissed.text = LLSTR(@"201520");
        label4Dismissed.font = [UIFont systemFontOfSize:14];
        label4Dismissed.textColor = [UIColor lightGrayColor];
        label4Dismissed.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:label4Dismissed];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //进入虚拟子群
    ChatViewController *wnd = [ChatViewController new];
    wnd.isGroup = YES;
    wnd.peerUid = [[array4SubGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"];
    [self.navigationController pushViewController:wnd animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //解散按钮
    UITableViewRowAction *dismissAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LLSTR(@"201323") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        //提示用户是否要解散本群
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:LLSTR(@"201325")
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule dismissGroup:[[[self.groupProperty objectForKey:@"virtualGroupSubList"]objectAtIndex:indexPath.row]objectForKey:@"groupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [BiChatGlobal HideActivityIndicator];
                if (success)
                {
                    [BiChatGlobal showInfo:LLSTR(@"301728") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    
                    //刷新群信息
                    [self refreshVirtualGroupList];
                    [NetworkModule getGroupProperty:[[[self.groupProperty objectForKey:@"virtualGroupSubList"]objectAtIndex:indexPath.row]objectForKey:@"groupId"]
                                     completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
                else
                    [BiChatGlobal showInfo:LLSTR(@"301729") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{}];
    }];

    //重启按钮
    UITableViewRowAction *restartAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LLSTR(@"201324") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule setGroupPublicProfile:[[[self.groupProperty objectForKey:@"virtualGroupSubList"]objectAtIndex:indexPath.row]objectForKey:@"groupId"] profile:@{@"disabled" : [NSNumber numberWithBool:NO]} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
            if (success) {
                [BiChatGlobal showInfo:LLSTR(@"301730") withIcon:Image(@"icon_OK")];
                
                //刷新群信息
                [self refreshVirtualGroupList];
                [NetworkModule getGroupProperty:[[[self.groupProperty objectForKey:@"virtualGroupSubList"]objectAtIndex:indexPath.row]objectForKey:@"groupId"]
                                 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                
                //添加一条消息到本地
                [MessageHelper sendGroupMessageTo:[[[self.groupProperty objectForKey:@"virtualGroupSubList"]objectAtIndex:indexPath.row]objectForKey:@"groupId"] type:MESSAGE_CONTENT_TYPE_GROUPRESTART content:@"" needSave:YES needSend:NO completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301731") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }];

    if ([[self.groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        if ([[[[self.groupProperty objectForKey:@"virtualGroupSubList"]objectAtIndex:indexPath.row]objectForKey:@"disabled"]boolValue])
            return @[restartAction];
        else
            return @[dismissAction];
    }
    else
        return @[]; 
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

- (void)refreshVirtualGroupList
{
    [NetworkModule getVirtualGroupList:[self.groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success && [[data objectForKey:@"data"]count] > 0)
        {
            [self.groupProperty setObject:[data objectForKey:@"data"] forKey:@"virtualGroupSubList"];
            [[BiChatDataModule sharedDataModule]setGroupProperty:self.groupId property:self.groupProperty];
            
            array4SubGroupList = [self.groupProperty objectForKey:@"virtualGroupSubList"];
            [array4SubGroupList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                
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
        }
    }];
}

@end
