//
//  InviteRewardRankViewController.m
//  BiChat
//
//  Created by imac2 on 2018/9/5.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "InviteRewardRankViewController.h"
#import "UserDetailViewController.h"

@interface InviteRewardRankViewController ()

@end

@implementation InviteRewardRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.defaultShowMode != 0)
        showMode = self.defaultShowMode;
    else
        showMode = 1;
    self.navigationItem.title = LLSTR(@"102104"); //LLSTR(@"101014"):LLSTR(@"102105")
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    
    //初始化数据
    [self freshRightButton];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ((showMode == 1 && array4MyFriends.count == 0) ||
        (showMode == 2 && array4InvitedUser.count == 0))
        [self initData];
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
    if (showMode == 1)
        return array4MyFriends.count + (myFriendsHasMore?1:0);
    else
        return array4InvitedUser.count + (invitedUserHasMore?1:0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showMode == 1)
    {
        if (indexPath.row >= array4MyFriends.count)
            return 40;
        else
            return 60;
    }
    else
    {
        if (indexPath.row >= array4InvitedUser.count)
            return 40;
        else
            return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    NSDictionary *item;
    if (showMode == 1)
    {
        if (indexPath.row >= array4MyFriends.count)
        {
            UILabel *label4More = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            label4More.text = LLSTR(@"101031");
            label4More.font = [UIFont systemFontOfSize:12];
            label4More.textColor = [UIColor lightGrayColor];
            label4More.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label4More];
            [self moreData];
            return cell;
        }
        else
            item = [array4MyFriends objectAtIndex:indexPath.row];
    }
    else
    {
        if (indexPath.row >= array4InvitedUser.count)
        {
            UILabel *label4More = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            label4More.text = LLSTR(@"101031");
            label4More.font = [UIFont systemFontOfSize:12];
            label4More.textColor = [UIColor lightGrayColor];
            label4More.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label4More];
            [self moreData];
            return cell;
        }
        else
            item = [array4InvitedUser objectAtIndex:indexPath.row];
    }
    
    // Configure the cell...
    UILabel *label4Index = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 30, 60)];
    label4Index.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
    label4Index.font = [UIFont systemFontOfSize:14];
    label4Index.textColor = [UIColor darkGrayColor];
    label4Index.adjustsFontSizeToFitWidth = YES;
    label4Index.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label4Index];
    
    NSString *nickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"uid"] groupProperty:nil nickName:[item objectForKey:@"nickName"]];
    
    //头像
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"uid"] nickName:[item objectForKey:@"nickName"] avatar:[item objectForKey:@"avatar"] frame:CGRectMake(50, 10, 40, 40)];
    [cell.contentView addSubview:view4Avatar];
    
    if ([[item objectForKey:@"status"]integerValue] == 1)
    {
        //昵称
        UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 210, 60)];
        label4NickName.text = nickName;
        label4NickName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4NickName];
    }
    else
    {
        //昵称
        UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(100, 10, self.view.frame.size.width - 210, 22)];
        label4NickName.text = nickName;
        label4NickName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4NickName];
        
        //状态
        UILabel *label4Status = [[UILabel alloc]initWithFrame:CGRectMake(100, 32, self.view.frame.size.width - 210, 18)];
        if ([[item objectForKey:@"status"]integerValue] == 0)
            label4Status.text = LLSTR(@"101706");
        else
            label4Status.text = LLSTR(@"101708");
        label4Status.textColor = [UIColor grayColor];
        label4Status.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:label4Status];
    }

    //数据
    NSInteger point = [[item objectForKey:@"point"]integerValue];
    UILabel *label4Value = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 120, 0, 70, 60)];
    label4Value.text = [NSString stringWithFormat:@"%ld", (long)point];
    if (point >= 100)
        label4Value.textColor = THEME_ORANGE;
    else
        label4Value.textColor = THEME_COLOR;
    label4Value.font = [UIFont systemFontOfSize:24];
    label4Value.textAlignment = NSTextAlignmentRight;
    label4Value.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label4Value];
    
    //点赞
    UIButton *button4Favorite = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 47, 0, 40, 60)];
    button4Favorite.tag = indexPath.row;
    if ([[item objectForKey:@"isLike"]boolValue])
        [button4Favorite setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    else
        [button4Favorite setImage:[UIImage imageNamed:@"unfavorite"] forState:UIControlStateNormal];
    [button4Favorite addTarget:self action:@selector(onButtonFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button4Favorite];
    [cell.contentView addSubview:button4Favorite];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (showMode == 1)
    {
        //进入个人详情页面
        UserDetailViewController *wnd = [UserDetailViewController new];
        wnd.uid = [[array4MyFriends objectAtIndex:indexPath.row]objectForKey:@"uid"];
        wnd.avatar = [[array4MyFriends objectAtIndex:indexPath.row]objectForKey:@"avatar"];
        wnd.nickName = [[array4MyFriends objectAtIndex:indexPath.row]objectForKey:@"nickName"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        //进入个人详情页面
        UserDetailViewController *wnd = [UserDetailViewController new];
        wnd.uid = [[array4InvitedUser objectAtIndex:indexPath.row]objectForKey:@"uid"];
        wnd.avatar = [[array4InvitedUser objectAtIndex:indexPath.row]objectForKey:@"avatar"];
        wnd.nickName = [[array4InvitedUser objectAtIndex:indexPath.row]objectForKey:@"nickName"];
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

#pragma mark - 私有函数

- (void)freshRightButton
{
    if (showMode == 1)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"102105") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonInvitedUser:)];
    else
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101014") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonMyFriends:)];
}

- (void)onButtonInvitedUser:(id)sender
{
    showMode = 2;
    [self freshRightButton];
    [self initData];
}

- (void)onButtonMyFriends:(id)sender
{
    showMode = 1;
    [self freshRightButton];
    [self initData];
}

- (void)initData
{
    if (showMode == 1)
        [self initData4MyFriends];
    else
        [self initData4InvitedUser];
}

- (void)moreData
{
    if (showMode == 1)
        [self moreData4MyFriends];
    else
        [self moreData4InvitedUser];
}

- (void)initData4MyFriends
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getMyFriendList:1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            array4MyFriends = [NSMutableArray arrayWithArray:[data objectForKey:@"list"]];
            myFriendsHasMore = (array4MyFriends.count == 20);
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301906") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        [self.tableView reloadData];
    }];
}

- (void)moreData4MyFriends
{
    if (moreMyFriendLoading)
        return;
    moreMyFriendLoading = YES;
    NSInteger page = array4MyFriends.count / 20;
    [NetworkModule getMyFriendList:page + 1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        moreMyFriendLoading = NO;
        if (success)
        {
            [array4MyFriends addObjectsFromArray:[data objectForKey:@"list"]];
            myFriendsHasMore = ([[data objectForKey:@"list"]count] == 20);
            [self.tableView reloadData];
        }
    }];
}

- (void)initData4InvitedUser
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getMyInvitedUserList:1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            array4InvitedUser = [NSMutableArray arrayWithArray:[data objectForKey:@"list"]];
            invitedUserHasMore = (array4InvitedUser.count == 20);
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301927") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        [self.tableView reloadData];
    }];
}

- (void)moreData4InvitedUser
{
    if (moreInvitedUserLoading)
        return;
    moreInvitedUserLoading = YES;
    NSInteger page = array4InvitedUser.count / 20;
    [NetworkModule getMyInvitedUserList:page + 1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        moreInvitedUserLoading = NO;
        if (success)
        {
            [array4InvitedUser addObjectsFromArray:[data objectForKey:@"list"]];
            invitedUserHasMore = ([[data objectForKey:@"list"]count] == 20);
            [self.tableView reloadData];
        }
    }];
}

- (void)onButtonFavorite:(id)sender
{
    //判断这个用户是否已经like过
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag;
    
    if (showMode == 1)
    {
        if ([[[array4MyFriends objectAtIndex:index]objectForKey:@"isLike"]boolValue])
            return;
        
        //马上显示成功
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:[array4MyFriends objectAtIndex:index]];
        [item setObject:[NSNumber numberWithBool:YES] forKey:@"isLike"];
        [array4MyFriends setObject:item atIndexedSubscript:index];
        [self.tableView reloadData];
        
        //NSLog(@"%@", [array4InvitedUser objectAtIndex:index]);
        
        //开始点赞
        [NetworkModule likeMyInvitedUser:[[array4MyFriends objectAtIndex:index]objectForKey:@"uid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            //NSLog(@"%@", data);
            
            //点赞不成功的话，再回去
            if (!success)
            {
                [item setObject:[NSNumber numberWithBool:NO] forKey:@"isLike"];
                [self.tableView reloadData];
            }
        }];
    }
    else
    {
        if ([[[array4InvitedUser objectAtIndex:index]objectForKey:@"isLike"]boolValue])
            return;
        
        //马上显示成功
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:[array4InvitedUser objectAtIndex:index]];
        [item setObject:[NSNumber numberWithBool:YES] forKey:@"isLike"];
        [array4InvitedUser setObject:item atIndexedSubscript:index];
        [self.tableView reloadData];
        
        //NSLog(@"%@", [array4InvitedUser objectAtIndex:index]);
        
        //开始点赞
        [NetworkModule likeMyInvitedUser:[[array4InvitedUser objectAtIndex:index]objectForKey:@"uid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            //NSLog(@"%@", data);
            
            //点赞不成功的话，再回去
            if (!success)
            {
                [item setObject:[NSNumber numberWithBool:NO] forKey:@"isLike"];
                [self.tableView reloadData];
            }
        }];
    }
}

@end
