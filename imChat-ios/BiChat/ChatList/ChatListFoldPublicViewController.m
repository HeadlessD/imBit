//
//  ChatListFoldPublicViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/10/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "ChatListFoldPublicViewController.h"
#import "ChatViewController.h"

@interface ChatListFoldPublicViewController ()

@end

@implementation ChatListFoldPublicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101215");
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
    [BiChatGlobal sharedManager].FOLDPublicChatList = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [BiChatGlobal sharedManager].FOLDPublicChatList = nil;
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
                                            nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"peerUid"] groupProperty:nil nickName:[item objectForKey:@"peerNickName"]]
                                              avatar:[item objectForKey:@"peerAvatar"]
                                               width:50 height:50];
    view4Avatar.center = CGPointMake(38, 32);
    [cell.contentView addSubview:view4Avatar];
    
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
        UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_normalgroup"]];
        image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
        image4GroupFlag.center = CGPointMake(58, 47);
        image4GroupFlag.clipsToBounds = YES;
        [cell.contentView addSubview:image4GroupFlag];
        
        //先看看这个群有几个图标
        NSArray *array4GroupFlag = [[BiChatGlobal sharedManager]getGroupFlag:[item objectForKey:@"peerUid"]];
        
        //计算群昵称的空间大小
        NSString *str = [item objectForKey:@"peerNickName"];
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
        label4UserName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"peerUid"] groupProperty:nil nickName: [item objectForKey:@"peerNickName"]];
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
    }
    
    //消息条数
    if ([[item objectForKey:@"newMessageCount"]integerValue] > 0)
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
    
    //最后消息
    UILabel *label4LastMessage = [[UILabel alloc]initWithFrame:CGRectMake(72, 36, self.view.frame.size.width - 100, 15)];
    label4LastMessage.text = [item objectForKey:@"lastMessage"];
    label4LastMessage.font = [UIFont systemFontOfSize:13];
    label4LastMessage.textColor = THEME_GRAY;
    [cell.contentView addSubview:label4LastMessage];
    
    //if ([[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"peerUid"]])
    //{
    //    UIImageView *image4Silence = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"silent_gray"]];
    //    image4Silence.center = CGPointMake(self.view.frame.size.width - 18, 48);
    //    [cell.contentView addSubview:image4Silence];
    //}
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(10, 63.5, self.view.frame.size.width - 10, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.92 alpha:1];
    [cell.contentView addSubview:view4Seperator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    
    //进入聊天界面
    ChatViewController *wnd = [ChatViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.peerUid = [item objectForKey:@"peerUid"];
    wnd.peerUserName = [item objectForKey:@"peerUserName"];
    wnd.peerNickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"peerUid"] groupProperty:nil nickName: [item objectForKey:@"peerNickName"]];
    wnd.peerAvatar = [item objectForKey:@"peerAvatar"];
    wnd.isGroup = [[item objectForKey:@"isGroup"]boolValue];
    wnd.isPublic = [[item objectForKey:@"isPublic"]boolValue];
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
        
    }];
    
    //取消折叠按钮
    UITableViewRowAction *unFoldAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"101116") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //把本条目从折叠列表中删除
        for (int i = 0; i < [BiChatGlobal sharedManager].array4FoldList.count; i ++)
        {
            if ([[item objectForKey:@"peerUid"]isEqualToString:[[BiChatGlobal sharedManager].array4FoldList objectAtIndex:i]])
            {
                [[BiChatGlobal sharedManager].array4FoldList removeObjectAtIndex:i];
                break;
            }
        }
        [self refreshGUI];
        
        [NetworkModule unFoldItem:[item objectForKey:@"peerUid"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }];
    
    unFoldAction.backgroundColor = THEME_ORANGE;
    return @[unFoldAction, deleteAction];
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
    
    //再找出所有的被fold的条目
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        if ([[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
            ([[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue]))
        {
            //本条目不能是一个虚拟群
            NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]];
            if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
                [BiChatGlobal isMeGroupOperator:groupProperty])
                continue;
            
            [array addObject:[array4ChatList objectAtIndex:i]];
        }
    }
    
    //重新赋值
    array4ChatList = array;
    [self.tableView reloadData];
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
