//
//  GroupForbidListViewController.m
//  BiChat Dev
//
//  Created by imac2 on 2018/11/15.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "GroupForbidListViewController.h"
#import "GroupMemberSelectorViewController.h"
#import "UserDetailViewController.h"
#import "MessageHelper.h"

@interface GroupForbidListViewController ()

@end

@implementation GroupForbidListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201320");
    if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onButtonAdd:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.groupProperty objectForKey:@"muteUsers"]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    NSDictionary *userInfo = [[_groupProperty objectForKey:@"muteUsers"]objectAtIndex:indexPath.row];
    
    //avatar
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[userInfo objectForKey:@"uid"] nickName:[userInfo objectForKey:@"nickName"] avatar:[userInfo objectForKey:@"avatar"] frame:CGRectMake(15, 5, 40, 40)];
    [cell.contentView addSubview:view4Avatar];
    
    //nickname
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 100, 50)];
    label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[userInfo objectForKey:@"uid"] groupProperty:self.groupProperty nickName:[userInfo objectForKey:@"nickName"]];
    [cell.contentView addSubview:label4NickName];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailViewController *wnd = [UserDetailViewController new];
    wnd.uid = [[[self.groupProperty objectForKey:@"muteUsers"]objectAtIndex:indexPath.row]objectForKey:@"uid"];
    wnd.groupProperty = self.groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //删除按钮
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LLSTR(@"201034") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        NSString *uid = [[[self.groupProperty objectForKey:@"muteUsers"]objectAtIndex:indexPath.row]objectForKey:@"uid"];
        [NetworkModule unForbidGroupMember:self.groupId userIds:@[uid] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
            {
                NSDictionary *item = @{@"friends":@[[[self.groupProperty objectForKey:@"muteUsers"]objectAtIndex:indexPath.row]]};
                [[self.groupProperty objectForKey:@"muteUsers"]removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
                //发送一条消息
                [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_GROUPDELMUTEUSERS content:[item mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301320") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }];

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

#pragma mark - GroupMemberSelectDelegate functions

- (void)memberSelected:(NSArray *)member withCookie:(NSInteger)cookie
{
    NSMutableArray *array4Uid = [NSMutableArray array];
    NSMutableArray *array4Full = [NSMutableArray array];
    for (NSDictionary *item in member)
    {
        if (![self isForbid:[item objectForKey:@"uid"]])
        {
            [array4Uid addObject:[item objectForKey:@"uid"]];
            [array4Full addObject:item];
        }
    }
    if (array4Uid.count == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule forbidGroupMember:self.groupId userIds:array4Uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //重新获取一下群信
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [BiChatGlobal HideActivityIndicator];
                if (success)
                    [self.groupProperty setObject:[data objectForKey:@"muteUsers"] forKey:@"muteUsers"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            
            //发送一条消息
            NSDictionary *item = @{@"friends":array4Full};
            [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_GROUPADDMUTEUSERS content:[item mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301304") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)memberSelectCancel:(NSInteger)cookie
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 私有函数

- (BOOL)isForbid:(NSString *)uid
{
    for (NSDictionary *item in [self.groupProperty objectForKey:@"muteUsers"])
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]])
            return YES;
    }
    
    return NO;
}

- (void)onButtonAdd:(id)sender
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *item in [self.groupProperty objectForKey:@"muteUsers"])
        [array addObject:[item objectForKey:@"uid"]];
    
    //添加群禁言名单选择器
    GroupMemberSelectorViewController *wnd = [GroupMemberSelectorViewController new];
    wnd.delegate = self;
    wnd.cookie = 1;
    wnd.defaultTitle = LLSTR(@"201338");
    wnd.groupId = self.groupId;
    wnd.groupProperty = self.groupProperty;
    wnd.multiSelect = YES;
    wnd.canSelectOwner = NO;
    wnd.canSelectAssistant = NO;
    wnd.canSelectDefaultSelected = NO;
    wnd.showMemo = YES;
    wnd.showAll = NO;
    wnd.needConfirm = YES;
    wnd.defaultSelected = array;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

@end
