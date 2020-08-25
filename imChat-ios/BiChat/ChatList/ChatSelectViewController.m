//
//  ChatSelectViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "ChatSelectViewController.h"
#import "ChatNewFriendSelectViewController.h"
#import "ChatFoldSelectViewController.h"
#import "ChatGroupManageSelectViewController.h"
#import "ChatVirtualGroupSelectViewController.h"

@interface ChatSelectViewController ()

@end

@implementation ChatSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.title = self.defaultTitle.length == 0?LLSTR(@"102418"):self.defaultTitle;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if (!self.canPop) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:[[self view] window]];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:[[self view] window]];

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
    return [array4ChatList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    
    //如果不显示公号
    if ([[item objectForKey:@"isPublic"]boolValue] && self.hidePublicAccount)
        return 0;
    
    //如果是只显示群组
    if (self.showGroupOnly &&
        ![[item objectForKey:@"isGroup"]boolValue] &&
        ![[item objectForKey:@"type"]isEqualToString:@"1"] &&
        ![[item objectForKey:@"type"]isEqualToString:@"2"] &&
        ![[item objectForKey:@"type"]isEqualToString:@"3"])
        return 0;
    
    //如果是只显示用户
    if (self.showUserOnly &&
        ([[item objectForKey:@"isGroup"]boolValue] ||
         [[item objectForKey:@"isPublic"]boolValue] ||
         [[item objectForKey:@"type"]integerValue] == 2 ||
         [[item objectForKey:@"type"]integerValue] == 3))
        return 0;
    
    //如果不显示收费群
    if (self.hideChargeGroup && [[item objectForKey:@"isGroup"]boolValue])
    {
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
        if ([[groupProperty objectForKey:@"payGroup"]boolValue])
            return 0;
    }

    //有回调block
    if (self.canShowBlock != nil && !self.canShowBlock([item objectForKey:@"peerUid"]))
        return 0;
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    // Configure the cell...
    NSDictionary *item = [array4ChatList objectAtIndex:indexPath.row];
    
    //如果不显示公号
    if ([[item objectForKey:@"isPublic"]boolValue] && self.hidePublicAccount)
        return cell;
    
    //如果是只显示群组
    if (self.showGroupOnly &&
        ![[item objectForKey:@"isGroup"]boolValue] &&
        ![[item objectForKey:@"type"]isEqualToString:@"1"] &&
        ![[item objectForKey:@"type"]isEqualToString:@"2"] &&
        ![[item objectForKey:@"type"]isEqualToString:@"3"])
        return cell;
    
    //如果是只显示用户
    if (self.showUserOnly &&
        ([[item objectForKey:@"isGroup"]boolValue] ||
         [[item objectForKey:@"isPublic"]boolValue] ||
         [[item objectForKey:@"type"]integerValue] == 2 ||
         [[item objectForKey:@"type"]integerValue] == 3))
        return cell;
    
    //如果不显示收费群
    if (self.hideChargeGroup && [[item objectForKey:@"isGroup"]boolValue])
    {
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
        if ([[groupProperty objectForKey:@"payGroup"]boolValue])
            return cell;
    }
        
    //有回调block
    if (self.canShowBlock != nil && !self.canShowBlock([item objectForKey:@"peerUid"]))
        return cell;
    
    //是不是陌生人
    if ([[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"0"])
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 40, 40)];
        image4Avatar.image = [UIImage imageNamed:@"contact_newfriend"];
        [cell.contentView addSubview:image4Avatar];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 80, 50)];
        label4Title.text = LLSTR(@"101135");
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
    }
    //免打扰折叠
    else if ([[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"1"])
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 40, 40)];
        image4Avatar.image = [UIImage imageNamed:@"contact_fold"];
        [cell.contentView addSubview:image4Avatar];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 80, 50)];
        label4Title.text = LLSTR(@"101122");
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
    }
    //群管理
    else if ([[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"2"])
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 40, 40)];
        image4Avatar.image = [UIImage imageNamed:@"contact_groupmanage"];
        [cell.contentView addSubview:image4Avatar];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 80, 50)];
        label4Title.text = LLSTR(@"101145");
        label4Title.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Title];
    }
    //虚拟群折叠
    else if ([[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"3"])
    {
        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"peerUid"]
                                                nickName:[item objectForKey:@"peerNickName"]
                                                  avatar:[item objectForKey:@"peerAvatar"]
                                                   width:40 height:40];
        view4Avatar.center = CGPointMake(35, 25);
        [cell.contentView addSubview:view4Avatar];
        
        UIImageView *image4VirtualGroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_virtualgroup"]];
        image4VirtualGroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
        image4VirtualGroupFlag.center = CGPointMake(50, 36);
        image4VirtualGroupFlag.clipsToBounds = YES;
        [cell.contentView addSubview:image4VirtualGroupFlag];
        
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
            UIImageView *view4GroupFlag = [[UIImageView alloc]initWithFrame:CGRectMake(65 + rect4NickName.size.width + i * 28 + 5, 12.5, 26, 16)];
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
        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"peerUid"]
                                                nickName:[item objectForKey:@"peerNickName"]
                                                  avatar:[item objectForKey:@"peerAvatar"]
                                                   width:40 height:40];
        view4Avatar.center = CGPointMake(35, 25);
        [cell.contentView addSubview:view4Avatar];
        
        //是不是公号
        if ([[BiChatGlobal sharedManager]isFriendInFollowList:[item objectForKey:@"peerUid"]]||
            [[item objectForKey:@"isPublic"]boolValue])
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
            //是不是虚拟群
            NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
            if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            {
                UIImageView *image4GroupFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag_virtualgroup"]];
                image4GroupFlag.frame = CGRectMake(0, 0, 19.3, 19.3);
                image4GroupFlag.center = CGPointMake(50, 36);
                image4GroupFlag.clipsToBounds = YES;
                [cell.contentView addSubview:image4GroupFlag];
            }
            //是不是超大群
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
            
            //昵称
            UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width - 110, 50)];
            label4NickName.text = nickName4Display;
            label4NickName.font = [UIFont systemFontOfSize:16];
            [cell.contentView addSubview:label4NickName];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //是不是陌生人
    if ([[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"0"])
    {
        ChatNewFriendSelectViewController *wnd = [ChatNewFriendSelectViewController new];
        wnd.delegate = self.delegate;
        wnd.hidePublicAccount = self.hidePublicAccount;
        wnd.cookie = self.cookie;
        wnd.target = self.target;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    //免打扰折叠
    else if ([[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"1"])
    {
        ChatFoldSelectViewController *wnd = [ChatFoldSelectViewController new];
        wnd.delegate = self.delegate;
        wnd.hidePublicAccount = self.hidePublicAccount;
        wnd.showGroupOnly = self.showGroupOnly;
        wnd.showUserOnly = self.showUserOnly;
        wnd.cookie = self.cookie;
        wnd.target = self.target;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    //群管理
    else if ([[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"2"])
    {
        ChatGroupManageSelectViewController *wnd = [ChatGroupManageSelectViewController new];
        wnd.delegate = self.delegate;
        wnd.hidePublicAccount = self.hidePublicAccount;
        wnd.cookie = self.cookie;
        wnd.target = self.target;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    //虚拟群
    else if ([[[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"type"]isEqualToString:@"3"])
    {
        ChatVirtualGroupSelectViewController *wnd = [ChatVirtualGroupSelectViewController new];
        wnd.title = [[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"peerNickName"];
        wnd.delegate = self.delegate;
        wnd.groupId = [[array4ChatList objectAtIndex:indexPath.row]objectForKey:@"groupId"];
        wnd.hidePublicAccount = self.hidePublicAccount;
        wnd.hideChargeGroup = self.hideChargeGroup;
        wnd.hideVirtualManageGroup = self.hideVirtualManageGroup;
        wnd.cookie = self.cookie;
        wnd.target = self.target;
        [self.navigationController pushViewController:wnd animated:YES];
    }

    //开始选择(普通条目)
    else if (self.delegate && [self.delegate respondsToSelector:@selector(chatSelected:withCookie:andTarget:)])
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

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardWillShow:(NSNotification *)note
{
    //self.move = YES;
    NSDictionary *userInfo = [note userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system.
    // The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    //当前是否有prensentedView
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
    {
        CGRect frame = presentedView.frame;
        frame.origin.y = keyboardRect.origin.y - frame.size.height - 10;
        presentedView.frame = frame;
        
        if (presentedView.center.y > presentedView.superview.frame.size.height / 2)
            presentedView.center = CGPointMake(presentedView.superview.frame.size.width / 2, presentedView.superview.frame.size.height / 2);
    }
    
    //[UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    //    if(self.parentPageViewController) [self.parentPageViewController.view setFrame:viewFrame];
    //    else [self.view setFrame:viewFrame];
    //} completion:^(BOOL finished) {}];
    
    
    //if([self.inputText isFirstResponder]) [self.chatTable scrollBubbleViewToBottomAnimated:YES];
    //if([self.inputText isFirstResponder]) [self performSelector:@selector(delayedScroll) withObject:nil afterDelay:0.1];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    UIView *presentedView = [BiChatGlobal presentedModalView];
    if (presentedView != nil)
        presentedView.center = CGPointMake(presentedView.superview.frame.size.width / 2, presentedView.superview.frame.size.height / 2);
}

- (void)refreshGUI
{
    array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    //NSLog(@"1-%@", array4ChatList);
    
    //重新调整置顶的item
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *dict4VirtualGroupIndex = [NSMutableDictionary dictionary];

    //再次扫描，先找出所有的置顶条目（没有进折叠的）
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        //如果是虚拟群，是否置顶
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]];
        NSString *virtualGroupId = [groupProperty objectForKey:@"virtualGroupId"];
        if ([[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"] && virtualGroupId.length > 0)
        {
            NSInteger vCount = [[BiChatDataModule sharedDataModule]getSameVirtualGroupCountInChatList:[groupProperty objectForKey:@"virtualGroupId"]];

            if ([BiChatGlobal isMeGroupOperator:groupProperty] || vCount > 1)
            {
                if ([[BiChatGlobal sharedManager]isFriendInStickList:virtualGroupId])
                {
                    if ([dict4VirtualGroupIndex objectForKey:virtualGroupId] == nil)
                    {
                        //查一下新消息的条数
                        NSInteger newMessageCount = [self calcVirtualGroupNewMessageCount:virtualGroupId];
                        
                        //还没有添加界面，需要添加一条记录
                        [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"3", @"type",
                                          virtualGroupId, @"peerUid",
                                          [[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"], @"groupId",
                                          [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                          [groupProperty objectForKey:@"groupName"], @"peerNickName",
                                          [groupProperty objectForKey:@"avatar"]==nil?@"":[groupProperty objectForKey:@"avatar"], @"peerAvatar",
                                          [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"], @"lastMessage",
                                          [NSNumber numberWithInteger:newMessageCount], @"newMessageCount",
                                          nil]];
                        
                        //保存这条记录
                        [dict4VirtualGroupIndex setObject:[NSNumber numberWithInt:i] forKey:virtualGroupId];
                        continue;
                    }
                    else
                        continue;   //已经有条目了，直接忽略
                }
                else
                    continue;
            }
        }

        if ([[BiChatGlobal sharedManager]isFriendInStickList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
            ![[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
            ![[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue] &&
            ![[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:REQUEST_FOR_APPROVE])
            [array addObject:[array4ChatList objectAtIndex:i]];
    }
    
    //先找出所有的项目，需要折叠的信息
    NSInteger foldFriendIndex = -1;
    NSInteger nonFriendIndex = -1;
    NSInteger approveFriendIndex = -1;
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        NSDictionary *groupProperty = nil;
        NSInteger vCount = 0;
        if ([[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue])
        {
            groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]];
            vCount = [[BiChatDataModule sharedDataModule]getSameVirtualGroupCountInChatList:[groupProperty objectForKey:@"virtualGroupId"]];
        }

        //是不是一个我是管理员的虚拟群
        if ([[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue] &&
            [[groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
            ([BiChatGlobal isMeGroupOperator:groupProperty] || vCount > 1))
        {
            NSString *virtualGroupId = [groupProperty objectForKey:@"virtualGroupId"];
            if ([dict4VirtualGroupIndex objectForKey:virtualGroupId] == nil)
            {
                //查一下新消息的条数
                NSInteger newMessageCount = [self calcVirtualGroupNewMessageCount:virtualGroupId];
                
                //还没有添加界面，需要添加一条记录
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"3", @"type",
                                  virtualGroupId, @"peerUid",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"], @"groupId",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [groupProperty objectForKey:@"groupName"], @"peerNickName",
                                  [groupProperty objectForKey:@"avatar"]==nil?@"":[groupProperty objectForKey:@"avatar"], @"peerAvatar",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"], @"lastMessage",
                                  [NSNumber numberWithInteger:newMessageCount], @"newMessageCount",
                                  nil]];
                
                //保存这条记录
                [dict4VirtualGroupIndex setObject:[NSNumber numberWithInt:i] forKey:virtualGroupId];
            }
            else
                ;   //已经有条目了，直接忽略
        }

        //是不是一个陌生人项目
        else if (![[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue] &&
                 ![[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
                 ![[[array4ChatList objectAtIndex:i]objectForKey:@"isPublic"]boolValue] &&
                 ![[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue])
        {
            //不在聊天列表中，折叠起来
            if (nonFriendIndex == -1)
            {
                nonFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"0", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@: %@", [[array4ChatList objectAtIndex:i]objectForKey:@"peerNickName"],[[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]], @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        //是不是一个折叠项目
        else if ([[BiChatGlobal sharedManager]isFriendInFoldList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] &&
                 ([[BiChatGlobal sharedManager]isFriendInContact:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]] ||
                  [[[array4ChatList objectAtIndex:i]objectForKey:@"isGroup"]boolValue]) &&
                 ![[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue])
        {
            //不在聊天列表中，折叠起来
            if (foldFriendIndex == -1)
            {
                foldFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"1", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@",[[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]], @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        
        //是不是一个批准群项目
        else if ([[[array4ChatList objectAtIndex:i]objectForKey:@"isApprove"]boolValue])
        {
            if (approveFriendIndex == -1)
            {
                //折叠起来
                approveFriendIndex = array.count;
                [array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"2", @"type",
                                  [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessageTime"], @"lastMessageTime",
                                  [NSString stringWithFormat:@"%@_%@: %@",
                                   [[array4ChatList objectAtIndex:i]objectForKey:@"peerNickName"],
                                   [[array4ChatList objectAtIndex:i]objectForKey:@"applyUserNickName"],
                                   [[array4ChatList objectAtIndex:i]objectForKey:@"lastMessage"]],
                                  @"lastMessage",
                                  nil]];
            }
            else
                ;   //已经有条目了，直接忽略
        }
        
        //是不是一个入群批准请求
        else if ([[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:REQUEST_FOR_APPROVE])
        {
            //此处忽略本类型条目
        }
        
        else if (![[BiChatGlobal sharedManager]isFriendInStickList:[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]])
            [array addObject:[array4ChatList objectAtIndex:i]]; //其他类型，直接加入
    }
    
    //重新赋值
    array4ChatList = array;
    [self.tableView reloadData];
}

- (NSInteger)calcVirtualGroupNewMessageCount:(NSString *)virtualGruopId
{
    NSInteger count = 0;
    array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        NSDictionary *item = [array4ChatList objectAtIndex:i];
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"peerUid"]];
        if ([[groupProperty objectForKey:@"virtualGroupId"]isEqualToString:virtualGruopId])
        {
            count += [[item objectForKey:@"newMessageCount"]integerValue];
        }
    }
    
    return count;
}

@end
