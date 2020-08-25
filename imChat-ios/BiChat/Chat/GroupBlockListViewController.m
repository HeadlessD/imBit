//
//  GroupBlockListViewController.m
//  BiChat
//
//  Created by imac2 on 2018/6/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "GroupBlockListViewController.h"
#import "UserDetailViewController.h"
#import "GroupMemberSelectorViewController.h"
#import "MessageHelper.h"

@interface GroupBlockListViewController ()

@end

@implementation GroupBlockListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201318");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onButtonAdd:)];
    self.tableView.tableFooterView = [UIView new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.tableView reloadData];
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
    return [[self.groupProperty objectForKey:@"groupBlockUserLevelTwo"]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    NSDictionary *userInfo = [[_groupProperty objectForKey:@"groupBlockUserLevelTwo"]objectAtIndex:indexPath.row];
    
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
    wnd.uid = [[[self.groupProperty objectForKey:@"groupBlockUserLevelTwo"]objectAtIndex:indexPath.row]objectForKey:@"uid"];
    wnd.groupProperty = self.groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"201037") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule unBlockGroupMember:self.groupId
                                   userId:[[[_groupProperty objectForKey:@"groupBlockUserLevelTwo"]objectAtIndex:indexPath.row]objectForKey:@"uid"]
                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
        {
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                [BiChatGlobal showInfo:LLSTR(@"301313") withIcon:[UIImage imageNamed:@"icon_OK"]];
                NSMutableArray *array = [_groupProperty objectForKey:@"groupBlockUserLevelTwo"];
                [array removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301314") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
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
    //整理一下数据
    NSMutableArray *array4Uid = [NSMutableArray array];
    NSMutableArray *array4FullInfo = [NSMutableArray array];
    for (NSDictionary *item in member)
    {
        if (![self isBlocked:[item objectForKey:@"uid"]])
        {
            [array4Uid addObject:[item objectForKey:@"uid"]];
            [array4FullInfo addObject:item];
        }
    }
    if (array4Uid.count == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
        [self blockUsersFromPayGroup:array4Uid fullInfo:array4FullInfo];
    else
        [self blockUsers:array4Uid fullInfo:array4FullInfo];
}

- (void)blockUsersFromPayGroup:(NSArray *)array4Uid fullInfo:(NSArray *)array4FullInfo
{
    //先算一下需要返回多少钱
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getKickFromChargeGroupFee:self.groupId uids:array4Uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        
        //生成需要显示的消息字符串
        NSMutableArray *array1 = [NSMutableArray array];
        for (NSString *key in [data objectForKey:@"balance"])
        {
            NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:key];
            NSString *str = [NSString stringWithFormat:@"%@ %@", [[BiChatGlobal decimalNumberWithDouble: [[[data objectForKey:@"balance"]objectForKey:key]doubleValue]]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", (long)[[coinInfo objectForKey:@"bit"]integerValue]] auotCheck:YES], [coinInfo objectForKey:@"dSymbol"]];
            [array1 addObject:str];
        }
        NSMutableArray *array2 = [NSMutableArray array];
        for (NSString *key in [data objectForKey:@"requestBalance"])
        {
            NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:key];
            NSString *str = [NSString stringWithFormat:@"%@ %@", [[BiChatGlobal decimalNumberWithDouble: [[[data objectForKey:@"requestBalance"]objectForKey:key]doubleValue]]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", (long)[[coinInfo objectForKey:@"bit"]integerValue]] auotCheck:YES], [coinInfo objectForKey:@"dSymbol"]];
            [array2 addObject:str];
        }
        NSString *balance = [array1 componentsJoinedByString:@", "];
        NSString *requestBalance = [array2 componentsJoinedByString:@", "];
        NSString *number = [NSString stringWithFormat:@"%ld", (long)array4Uid.count];
        NSString *message;
        if (requestBalance.length == 0)
            message = [LLSTR(@"204126")llReplaceWithArray:@[number]];
        else
            message = [LLSTR(@"204125")llReplaceWithArray:@[number, requestBalance, balance]];
        
        if (success)
        {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"204123") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //正式开始踢人
                [self blockUsers:array4Uid fullInfo:array4FullInfo];
                
            }];
            UIAlertAction *act2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:act1];
            [alertC addAction:act2];
            [presented presentViewController:alertC animated:YES completion:nil];
        }
        else if (errorCode == 20011)
        {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"204123") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"204127") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *act2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [act1 setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
            [alertC addAction:act1];
            [alertC addAction:act2];
            [presented presentViewController:alertC animated:YES completion:nil];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)blockUsers:(NSArray *)array4Uid fullInfo:(NSArray *)array4FullInfo
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule blockGroupMembers:self.groupId userIds:array4Uid completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //重新获取一下群信
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [BiChatGlobal HideActivityIndicator];
                if (success)
                    [self.groupProperty setObject:[data objectForKey:@"groupBlockUserLevelTwo"] forKey:@"groupBlockUserLevelTwo"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            
            //发送一条消息
            [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_KICKOUTGROUP content:[array4FullInfo mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301315") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)memberSelectCancel:(NSInteger)cookie
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 私有函数

- (BOOL)isBlocked:(NSString *)uid
{
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupBlockUserLevelTwo"])
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]])
            return YES;
    }
    return NO;
}

- (void)onButtonAdd:(id)sender
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupBlockUserLevelTwo"])
        [array addObject:[item objectForKey:@"uid"]];
    
    //添加群禁言名单选择器
    GroupMemberSelectorViewController *wnd = [GroupMemberSelectorViewController new];
    wnd.delegate = self;
    wnd.cookie = 1;
    wnd.defaultTitle = LLSTR(@"201341");
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
    
    //记录一下，以后要用
    presented = (UIViewController *)wnd;
}

@end
