//
//  ChatFoldSelectViewController.m
//  BiChat
//
//  Created by Admin on 2018/5/14.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatDataModule.h"
#import "ChatFoldSelectViewController.h"

@interface ChatFoldSelectViewController ()

@end

@implementation ChatFoldSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101112");
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
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    
    //如果是只显示群组
    if (self.showGroupOnly &&
        ![[item objectForKey:@"isGroup"]boolValue] &&
        ![[item objectForKey:@"peerUid"]isEqualToString:@"1"] &&
        ![[item objectForKey:@"peerUid"]isEqualToString:@"2"])
        return 0;
    
    //如果是只显示用户
    if (self.showUserOnly &&
        ([[item objectForKey:@"isGroup"]boolValue] ||
         [[item objectForKey:@"peerUid"]integerValue] == 2 ||
         [[item objectForKey:@"peerUid"]integerValue] == 3))
        return 0;
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    
    //如果是只显示群组
    if (self.showGroupOnly &&
        ![[item objectForKey:@"isGroup"]boolValue] &&
        ![[item objectForKey:@"peerUid"]isEqualToString:@"1"] &&
        ![[item objectForKey:@"peerUid"]isEqualToString:@"2"])
        return cell;
    
    //如果是只显示用户
    if (self.showUserOnly &&
        ([[item objectForKey:@"isGroup"]boolValue] ||
         [[item objectForKey:@"peerUid"]integerValue] == 2 ||
         [[item objectForKey:@"peerUid"]integerValue] == 3))
        return cell;
    
    //头像
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"peerUid"]
                                            nickName:[item objectForKey:@"peerNickName"]
                                              avatar:[item objectForKey:@"peerAvatar"]
                                               width:40 height:40];
    view4Avatar.center = CGPointMake(35, 25);
    [cell.contentView addSubview:view4Avatar];
    
    //是不是公号
    if ([[BiChatGlobal sharedManager]isFriendInFollowList:[item objectForKey:@"peerUid"]])
    {
        //计算群昵称的空间大小
        NSString *str = [item objectForKey:@"peerNickName"];
        CGRect rect4NickName = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 72 - 5, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                 context:nil];
        
        //昵称
        UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(65, 15, rect4NickName.size.width, 20)];
        label4UserName.text = str;
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
        
        UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_public"]];
        image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
        image4GroupFlag.center = CGPointMake(50, 36);
        image4GroupFlag.clipsToBounds = YES;
        [cell.contentView addSubview:image4GroupFlag];
    }
    //是不是群聊
    else if ([[item objectForKey:@"isGroup"]boolValue])
    {
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
        if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
        {
            UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_virtualgroup"]];
            image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
            image4GroupFlag.center = CGPointMake(50, 36);
            image4GroupFlag.clipsToBounds = YES;
            [cell.contentView addSubview:image4GroupFlag];
        }
        else if ([[groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        {
            UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_biggroup"]];
            image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
            image4GroupFlag.center = CGPointMake(50, 36);
            image4GroupFlag.clipsToBounds = YES;
            [cell.contentView addSubview:image4GroupFlag];
        }
        else
        {
            UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_normalgroup"]];
            image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
            image4GroupFlag.center = CGPointMake(50, 36);
            image4GroupFlag.clipsToBounds = YES;
            [cell.contentView addSubview:image4GroupFlag];
        }

        //先看看这个群有几个图标
        NSArray *array4GroupFlag = [[BiChatGlobal sharedManager]getGroupFlag:[item objectForKey:@"peerUid"]];
        
        //计算群昵称的空间大小
        NSString *str = [item objectForKey:@"peerNickName"];
        CGRect rect4NickName = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 72 - 5 - array4GroupFlag.count * 28, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                 context:nil];
        
        //昵称
        UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(65, 15, rect4NickName.size.width, 20)];
        label4UserName.text = str;
        label4UserName.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4UserName];
        
        //添加所有的图标
        for (int i = 0; i < array4GroupFlag.count; i ++)
        {
            UIImageView *view4GroupFlag = [[UIImageView alloc]initWithFrame:CGRectMake(65 + rect4NickName.size.width + i * 28 + 5, 17, 24, 16)];
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
        NSString *nickName4Display = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"peerUid"] groupProperty:nil nickName:[item objectForKey:@"peerNickName"]];
        if ([nickName4Display isEqualToString:[item objectForKey:@"peerNickName"]])
        {
            //昵称
            UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 110, 50)];
            label4NickName.text = [item objectForKey:@"peerNickName"];
            label4NickName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4NickName];
        }
        else
        {
            //实际显示昵称
            UILabel *label4NickName4Display = [[UILabel alloc]initWithFrame:CGRectMake(65, 5, self.view.frame.size.width - 110, 20)];
            label4NickName4Display.text = nickName4Display;
            label4NickName4Display.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4NickName4Display];
            
            //昵称
            UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 25, self.view.frame.size.width - 110, 20)];
            label4NickName.text = [NSString stringWithFormat:@"%@: %@",LLSTR(@"102021"), [item objectForKey:@"peerNickName"]];
            label4NickName.font = [UIFont systemFontOfSize:14];
            label4NickName.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4NickName];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //开始选择(普通条目)
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatSelected:withCookie:andTarget:)])
    {
        NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
        [self.delegate chatSelected:[NSArray arrayWithObject:item] withCookie:self.cookie andTarget:self.target];
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

- (void)refreshGUI
{
    array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    
    //重新调整置顶的item
    NSMutableArray *array = [NSMutableArray array];
    
    //再找出所有的被fold的条目
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        if ([[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
            ([[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue] ||
             [[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]]))
        {
            [array addObject:[array4ChatList objectAtIndex:i]];
        }
    }
    
    //重新赋值
    array4ChatList = array;
    [self.tableView reloadData];
}

@end
