//
//  GroupListViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "GroupListViewController.h"
#import "GroupChatProperyViewController.h"
#import "VirtualGroupListViewController.h"
#import "ChatViewController.h"

@interface GroupListViewController ()

@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101214");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
        
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
    return [BiChatGlobal sharedManager].array4AllGroup.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    NSDictionary *group = [[BiChatGlobal sharedManager].array4AllGroup objectAtIndex:indexPath.row];
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[group objectForKey:@"uid"]];
    
    //头像
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[group objectForKey:@"uid"] nickName:[group objectForKey:@"groupName"] avatar:[group objectForKey:@"avatar"] width:36 height:36];
    view4Avatar.frame = CGRectMake(15, 7, 36, 36);
    [cell.contentView addSubview:view4Avatar];
        
    //姓名
    UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
    label4Name.font = [UIFont systemFontOfSize:16];
    
    if ([[groupProperty objectForKey:@"virtualGroupId"]length] == 0 ||
        [BiChatGlobal isMeGroupOperator:groupProperty])
        label4Name.text = [group objectForKey:@"groupName"];
    else
    {
        for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([[item objectForKey:@"groupId"]isEqualToString:[group objectForKey:@"uid"]])
            {
                if ([[item objectForKey:@"groupNickName"]length] > 0)
                    label4Name.text = [NSString stringWithFormat:@"%@#%@", [group objectForKey:@"groupName"], [item objectForKey:@"groupNickName"]];
                else
                    label4Name.text = [NSString stringWithFormat:@"%@#%ld", [group objectForKey:@"groupName"], [[item objectForKey:@"virtualGroupNum"]integerValue]];
                break;
            }
        }
        
    }
        
    [cell.contentView addSubview:label4Name];

    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = [[BiChatGlobal sharedManager].array4AllGroup objectAtIndex:indexPath.row];
    
    //首先判断是不是自己是群主或者管理员的虚拟群
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"uid"]];
    if ([groupProperty objectForKey:@"virtualGroupId"] &&
        [BiChatGlobal isMeGroupOperator:groupProperty])
    {
        VirtualGroupListViewController *wnd = [VirtualGroupListViewController new];
        wnd.groupId = [item objectForKey:@"uid"];
        wnd.groupProperty = groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        //显示群聊界面
        NSString *groupId = [[[BiChatGlobal sharedManager].array4AllGroup objectAtIndex:indexPath.row]objectForKey:@"uid"];
        NSString *groupName = [[[BiChatGlobal sharedManager].array4AllGroup objectAtIndex:indexPath.row]objectForKey:@"groupName"];
        ChatViewController *wnd = [ChatViewController new];
        wnd.isGroup = YES;
        wnd.peerUid = groupId;
        wnd.peerNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:groupId nickName:groupName];
        wnd.peerAvatar = [[[BiChatGlobal sharedManager].array4AllGroup objectAtIndex:indexPath.row]objectForKey:@"avatar"];
        [self.navigationController pushViewController:wnd animated:YES];
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
