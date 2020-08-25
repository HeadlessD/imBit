//
//  ChatListNewFriendViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/24.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "ChatListNewFriendViewController.h"
#import "ChatViewController.h"

@interface ChatListNewFriendViewController ()

@end

@implementation ChatListNewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101135");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshGUI];
    [BiChatGlobal sharedManager].NEWFriendChatList = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [BiChatGlobal sharedManager].NEWFriendChatList = nil;
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
    return array4ChatList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self itemShouldShow:[array4ChatList objectAtIndex:indexPath.row]]?64:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    if (![self itemShouldShow:item])
        return cell;
    
    // Configure the cell...
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"peerUid"]
                                            nickName:[item objectForKey:@"peerNickName"]
                                              avatar:[item objectForKey:@"peerAvatar"]
                                               width:50 height:50];
    view4Avatar.center = CGPointMake(38, 32);
    [cell.contentView addSubview:view4Avatar];
    
    //是否群
    if ([[item objectForKey:@"isGroup"]boolValue] &&
        ![[item objectForKey:@"isPublic"]boolValue])
    {
        //群标识
        UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"group_flag"]];
        image4GroupFlag.center = CGPointMake(82, 22.5);
        [cell.contentView addSubview:image4GroupFlag];
        
        //昵称
        UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(97, 11, self.view.frame.size.width - 190, 20)];
        label4UserName.text = [item objectForKey:@"peerNickName"];
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
    }
    else
    {
        //昵称
        UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, self.view.frame.size.width - 170, 20)];
        label4UserName.text = [item objectForKey:@"peerNickName"];
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
    }
    
    if ([[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"peerUid"]])
    {
        UIImageView *image4Silence = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"silent_gray"]];
        image4Silence.center = CGPointMake(self.view.frame.size.width - 18, 43);
        [cell.contentView addSubview:image4Silence];
        
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
    }
    else if ([[item objectForKey:@"newMessageCount"]integerValue] > 0)
    {
        NSString *str4NewMessageCount = [NSString stringWithFormat:@"%@", [item objectForKey:@"newMessageCount"]];
        CGRect rect = [str4NewMessageCount boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                                        context:nil];
        if (rect.size.width < rect.size.height) rect.size.width = rect.size.height;
        
        UIImageView *image4RedBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 4, rect.size.height + 4)];
        image4RedBk.image = [UIImage imageNamed:@"red"];
        image4RedBk.center = CGPointMake(58, 14.5);
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
        label4NewMessageCount.center = CGPointMake(58, 14);
        [cell.contentView addSubview:label4NewMessageCount];
    }
    
    //最后消息日期
    if ([[item objectForKey:@"lastMessageTime"]length] > 0)
    {
        UILabel *label4LastMessageTime = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 12.5, 90, 12)];
        label4LastMessageTime.text = [BiChatGlobal adjustDateString:[item objectForKey:@"lastMessageTime"]];
        label4LastMessageTime.font = [UIFont systemFontOfSize:11];
        label4LastMessageTime.textAlignment = NSTextAlignmentRight;
        label4LastMessageTime.textColor = THEME_GRAY;
        label4LastMessageTime.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4LastMessageTime];
    }
    
    //最后消息
    UILabel *label4LastMessage = [[UILabel alloc]initWithFrame:CGRectMake(72, 36, self.view.frame.size.width - 100, 15)];
    label4LastMessage.text = [item objectForKey:@"lastMessage"];
    label4LastMessage.font = [UIFont systemFontOfSize:13];
    label4LastMessage.textColor = THEME_GRAY;
    [cell.contentView addSubview:label4LastMessage];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 63.5, self.view.frame.size.width - 10, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.92 alpha:1];
    [cell.contentView addSubview:view4Seperator];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    
    //进入聊天界面
    ChatViewController *wnd = [ChatViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.peerUid = [item objectForKey:@"peerUid"];
    wnd.peerUserName = [item objectForKey:@"peerUserName"];
    wnd.peerNickName = [item objectForKey:@"peerNickName"];
    wnd.peerAvatar = [item objectForKey:@"peerAvatar"];
    wnd.isGroup = [[item objectForKey:@"isGroup"]boolValue];
    wnd.newMessageCount = [[item objectForKey:@"newMessageCount"]integerValue];
    [self.navigationController pushViewController:wnd animated:YES];
    
    //清楚这个聊天的新消息条数
    [[BiChatDataModule sharedDataModule]clearNewMessageCountWith:[item objectForKey:@"peerUid"]];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    
    //删除按钮
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"101018") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [[BiChatDataModule sharedDataModule]deleteChatItemInList:[item objectForKey:@"peerUid"]];
        [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:[item objectForKey:@"peerUid"]];
        //[[BiChatDataModule sharedDataModule]setLastMessageTime:[item objectForKey:@"peerUid"] time:nil];
        [array4ChatList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        if (array4ChatList.count == 0)
            [self setEmptyHint];
        
    }];
    
    //设置静音按钮
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101114") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //检查网络
        if ([BiChatGlobal sharedManager].networkState != 200)
        {
            [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //把这个条目加入静音列表
        [[BiChatGlobal sharedManager].array4MuteList addObject:[item objectForKey:@"peerUid"]];
        [self.tableView reloadData];
        [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
        
        //发送网络命令
        [NetworkModule muteItem:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }];
    
    //取消设置静音按钮
    UITableViewRowAction *unMuteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101118") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //检查网络
        if ([BiChatGlobal sharedManager].networkState != 200)
        {
            [BiChatGlobal showInfo:LLSTR(@"301018") withIcon:[UIImage imageNamed:@"icon_alert"]];
            return;
        }
        
        //把这个条目清出静音列表
        for (int i = 0; i < [BiChatGlobal sharedManager].array4MuteList.count; i ++)
        {
            if ([[item objectForKey:@"peerUid"]isEqualToString:[[BiChatGlobal sharedManager].array4MuteList objectAtIndex:i]])
            {
                [[BiChatGlobal sharedManager].array4MuteList removeObjectAtIndex:i];
                [self.tableView reloadData];
                [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
                break;
            }
        }
        
        //发送网络命令
        [NetworkModule unMuteItem:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }];
    muteAction.backgroundColor = THEME_GREEN;
    unMuteAction.backgroundColor = THEME_GREEN;
    return @[deleteAction, [[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"peerUid"]]?unMuteAction:muteAction];
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
    array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    
    //重新调整置顶的item
    NSMutableArray *array = [NSMutableArray array];
    
    //再找出所有的没有置顶的项目，里面要处理所有的非朋友信息
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        //是一个公号？
        if ([[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue])
            continue;
        
        //看看是不是在通讯录里面
        if (![[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue] &&
            ![[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]])
            [array addObject:[array4ChatList objectAtIndex:i]]; //在通讯录中，直接加入
    }
    
    //重新赋值
    array4ChatList = array;
    [self.tableView reloadData];
    if (array4ChatList.count == 0)
        [self setEmptyHint];
    else
        [self clearEmptyHint];
}

- (void)setEmptyHint
{
    UIView *view4EmptyHint = [[UILabel alloc]initWithFrame:self.view.bounds];
    self.tableView.backgroundView = view4EmptyHint;
    
    UILabel *label4EmptyHint = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 2 / 3)];
    label4EmptyHint.text = LLSTR(@"101231");
    label4EmptyHint.textAlignment = NSTextAlignmentCenter;
    label4EmptyHint.font = [UIFont systemFontOfSize:16];
    label4EmptyHint.numberOfLines = 0;
    label4EmptyHint.textColor = [UIColor lightGrayColor];
    [view4EmptyHint addSubview:label4EmptyHint];
}

- (void)clearEmptyHint
{
    self.tableView.backgroundView = nil;
}

- (BOOL)itemShouldShow:(NSDictionary *)itemInfo
{
    //不在搜索态
    if (self.str4SearchKey.length == 0)
        return YES;
    
    //获取memoName
    NSString *str4MemoName = [[BiChatGlobal sharedManager]getFriendMemoName:[itemInfo objectForKey:@"peerUid"]];
    if ([[str4MemoName lowercaseString] rangeOfString:[self.str4SearchKey lowercaseString]].length > 0)
        return YES;
    if ([[BiChatGlobal getAlphabet:str4MemoName]rangeOfString:[self.str4SearchKey lowercaseString]].length > 0)
        return YES;
    
    //实际名称
    NSString *str4PeerName = [itemInfo objectForKey:@"peerNickName"];
    if ([[str4PeerName lowercaseString] rangeOfString:[self.str4SearchKey lowercaseString]].length > 0)
        return YES;
    if ([[BiChatGlobal getAlphabet:str4PeerName]rangeOfString:[self.str4SearchKey lowercaseString]].length > 0)
        return YES;

    return NO;
}

@end
