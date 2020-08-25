//
//  MyFollowedPublicAccountViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/4/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "MyFollowedPublicAccountViewController.h"
#import "ChatViewController.h"
#import "NetworkModule.h"
#import "BiChatDataModule.h"
#import "WPPublicAccountSearchViewController.h"
#import "WPPublicAccountDetailViewController.h"
#import "pinyin.h"
#import "UITableView+SCIndexView.h"

@interface MyFollowedPublicAccountViewController ()

@end

@implementation MyFollowedPublicAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onButtonAdd:)];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
    if (isIphonex)
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 90);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sc_indexViewDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];

    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configurationWithIndexViewStyle:SCIndexViewStyleDefault];
    configuration.indexItemSelectedBackgroundColor = THEME_COLOR;
    self.tableView.sc_indexViewConfiguration = configuration;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    array4AllPublicAccount = [NSMutableArray array];
    
    //开始添加所有条目
    for (int i = 0; i < 27; i ++)
        [array4AllPublicAccount addObject:[NSMutableArray array]];

    //整理数据
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4FollowList)
    {
        if ([[item objectForKey:@"groupName"]length] == 0)
            continue;
        char c = pinyinFirstLetter([[item objectForKey:@"groupName"]characterAtIndex:0]);
        if (c >= 'a' && c <= 'z')
            [[array4AllPublicAccount objectAtIndex:(c-'a')]addObject:item];
        else
            [[array4AllPublicAccount objectAtIndex:26]addObject:item];
    }
    [self.tableView reloadData];
    self.navigationItem.title = [NSString stringWithFormat:@"%@（%ld）",LLSTR(@"101215"),[BiChatGlobal sharedManager].array4FollowList.count];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 27;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[array4AllPublicAccount objectAtIndex:section]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[array4AllPublicAccount objectAtIndex:section]count] == 0)
        return 0;
    else
        return 20;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    if ([[array4AllPublicAccount objectAtIndex:section]count] == 0)
        return 0;
    else
        return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[array4AllPublicAccount objectAtIndex:section]count] == 0)
        return nil;
    
    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    view4Header.backgroundColor = THEME_TABLEBK_LIGHT;
    
    //title
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 20)];
    if (section <= 26)
        label4Title.text = [NSString stringWithFormat:@"%c", (int)('a' + section)];
    else
        label4Title.text = @"#";
    label4Title.text = [label4Title.text uppercaseString];
    label4Title.font = [UIFont systemFontOfSize:12];
    [view4Header addSubview:label4Title];
    
    return view4Header;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *toBeReturned = [[NSMutableArray alloc]init];
    for(char c = 'A' ;c<='Z';c++)
    {
        if ([[array4AllPublicAccount objectAtIndex:(c-'A')]count] > 0)
            [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
    }
    if ([[array4AllPublicAccount objectAtIndex:26]count] > 0)
        [toBeReturned addObject:@"#"];
    
    self.tableView.sc_indexViewDataSource = toBeReturned;
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:@"#"])
        return 26;
    else if ([title characterAtIndex:0] >= 'A' && [title characterAtIndex:0] <= 'Z')
        return ([title characterAtIndex:0] - 'A');
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    NSDictionary *item = [[array4AllPublicAccount objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    
    // Configure the cell...
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"uid"]
                                            nickName:[item objectForKey:@"groupName"]
                                              avatar:[item objectForKey:@"avatar"]
                                               frame:CGRectMake(15, 7, 36, 36)];
    [cell.contentView addSubview:view4Avatar];
    
    UILabel *label4Nickname = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
    label4Nickname.text = [item objectForKey:@"groupName"];
    label4Nickname.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4Nickname];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //进入聊天界面
    NSDictionary *item = [[array4AllPublicAccount objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    //NSLog(@"%@", item);
    
    //是否系统公号
    if ([[item objectForKey:@"systemPublicAccountGroup"]boolValue])
    {
        ChatViewController *wnd = [ChatViewController new];
        wnd.peerUid = [item objectForKey:@"ownerUid"];
        wnd.peerAvatar = [item objectForKey:@"avatar"];
        wnd.peerNickName = [item objectForKey:@"groupName"];
        wnd.isPublic = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        WPPublicAccountDetailViewController *wnd = [WPPublicAccountDetailViewController new];
        wnd.pubid = [item objectForKey:@"ownerUid"];
        wnd.pubnickname = [item objectForKey:@"groupName"];
        wnd.pubname = [item objectForKey:@"groupName"];
        wnd.avatar = [item objectForKey:@"avatar"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *item = [[BiChatGlobal sharedManager].array4FollowList objectAtIndex:indexPath.row];
    
    //删除按钮
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"101151") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //开始删除这个用户
        NSDictionary *item = [[BiChatGlobal sharedManager].array4FollowList objectAtIndex:indexPath.row];
        
        [NetworkModule unfollowPublicAccount:[item objectForKey:@"ownerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            //将全部和此人的聊天记录全部删除
            [[BiChatDataModule sharedDataModule]deleteChatItemInList:[item objectForKey:@"ownerUid"]];
            [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:[item objectForKey:@"ownerUid"]];
            
            //删除界面
            [[BiChatGlobal sharedManager].array4FollowList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];

        }];
    }];
    
    //是不是系统自动关注
    if ([[item objectForKey:@"systemPublicAccountGroup"]boolValue])
        return @[];
    else
        return @[];
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

#pragma mark - SCTableViewSectionIndexDelegate

/**
 当点击或者滑动索引视图时，回调这个方法
 
 @param tableView 列表视图
 @param section   索引位置
 */
- (void)tableView:(UITableView *)tableView didSelectIndexViewAtSection:(NSUInteger)section
{
    NSInteger index = 0;
    int i = 0;
    for (i = 0; i < array4AllPublicAccount.count; i ++)
    {
        if ([[array4AllPublicAccount objectAtIndex:i]count] > 0)
        {
            index ++;
        }
        
        if (index == section + 1)
            break;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

/**
 当滑动tableView时，索引位置改变，你需要自己返回索引位置时，实现此方法。
 不实现此方法，或者方法的返回值为 SCIndexViewInvalidSection 时，索引位置将由控件内部自己计算。
 
 @param tableView 列表视图
 @return          索引位置
 */
- (NSUInteger)sectionOfTableViewDidScroll:(UITableView *)tableView
{
    NSArray *array = [tableView indexPathsForVisibleRows];
    if (array.count > 0)
    {
        NSIndexPath *indexPath = [array firstObject];
        NSInteger count = indexPath.section;
        
        NSInteger index = 0;
        for (int i = 0; i < count; i ++)
        {
            if ([[array4AllPublicAccount objectAtIndex:i]count] > 0)
                index ++;
        }
        return index;
    }
    
    return 0;
}

#pragma mark - 私有函数

- (void)onButtonAdd:(id)sender {
    WPPublicAccountSearchViewController *searchVC = [[WPPublicAccountSearchViewController alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

@end
