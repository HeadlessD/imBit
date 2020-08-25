//
//  GroupChatProperyViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "NetworkModule.h"
#import "GroupChatProperyViewController.h"
#import "ContactListViewController.h"
#import "JSONKit.h"
#import <TTStreamer/TTStreamerClient.h>
#import "GroupNameChangeViewController.h"
#import "GroupBriefingChangeViewController.h"
#import "NicknameInGroupChangeViewController.h"
#import "GroupVRCodeViewController.h"
#import "GroupPinBoardViewController.h"
#import "GroupMemberDeleteViewController.h"
#import "UserDetailViewController.h"
#import "GroupSetupViewController.h"
#import "VirtualSubGroupMemberSetupViewController.h"
#import "GroupContentSetupViewController.h"
#import "AllGroupMemberViewController.h"
#import "SetGroupAvatarViewController.h"
#import "objc/runtime.h"
#import "WPItemChangeViewController.h"
#import "WPGroupLiveViewController.h"
#import "TextRenderViewController.h"
#import "UpgradeChargeGroupViewController.h"
#import "ChargeGroupManageViewController.h"
#import "ChargeGroupInfoViewController.h"
#import "MessageHelper.h"
#import "WPShortLinkViewController.h"

@interface GroupChatProperyViewController ()

@end

@implementation GroupChatProperyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.00001)];
    self.tableView.tableFooterView = [self createOperationPanel];
    self.tableView.separatorColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    
    button4RemoveGroupUser = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button4RemoveGroupUser setImage:[UIImage imageNamed:@"removeMember"] forState:UIControlStateNormal];
    [button4RemoveGroupUser addTarget:self action:@selector(onButtonRemoveGroupUser:) forControlEvents:UIControlEventTouchUpInside];
    
    //NSLog(@"%@", _groupProperty);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//- (void)showLive {
//    WPLiveGroupManageViewController *manageVC = [[WPLiveGroupManageViewController alloc]init];
//    manageVC.groupProperty = self.groupProperty;
//    [self.navigationController pushViewController:manageVC animated:YES];
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_shadow"];

    NSString * userCount = [NSString stringWithFormat:@"%lu",[[self.groupProperty objectForKey:@"joinedGroupUserCount"]integerValue]];
    self.navigationItem.title = [LLSTR(@"201201") llReplaceWithArray:@[userCount]];
    [self.tableView reloadData];
    
    //重新获取群组信息
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (success)
        {
            self.groupProperty = data;
            NSString * userCount = [NSString stringWithFormat:@"%lu",[[self.groupProperty objectForKey:@"joinedGroupUserCount"]integerValue]];
            self.navigationItem.title = [LLSTR(@"201201") llReplaceWithArray:@[userCount]];
            
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.groupProperty == nil)
        return 0;
    else
        return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) return 1;
    else if (section == 1)
    {
        if (![self isBroadcastGroup] &&
            ([[self.groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid] ||
             [[self.groupProperty objectForKey:@"payGroup"]boolValue]))
            return 3;
        else
            return 2;
    }
    else if (section == 2) {
        if ([BiChatGlobal isMeGroupOwner:self.groupProperty]) {
            return 7;
        }
        return 6;
    }
    
    else if (section == 3) return 4;
    else if (section == 4) return 2;
    else return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0 &&
        [[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
        [[[[self.groupProperty objectForKey:@"virtualGroupSubList"]firstObject]objectForKey:@"groupId"]isEqualToString:self.groupId])
    {
        NSString *str = LLSTR(@"201342");
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                        context:nil];
        
        return rect.size.height + 20;
    }
    else
        return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 &&
        [[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
        [[[[self.groupProperty objectForKey:@"virtualGroupSubList"]firstObject]objectForKey:@"groupId"]isEqualToString:self.groupId])
    {
        NSString *str = LLSTR(@"201342");
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                        context:nil];
        
        UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, rect.size.height + 20)];
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, rect.size.height + 9)];
        label4Title.text = str;
        label4Title.numberOfLines = 0;
        label4Title.font = [UIFont systemFontOfSize:14];
        label4Title.textColor = [UIColor grayColor];
        [view4Title addSubview:label4Title];
        
        return view4Title;
    }
    else
    {
        UIView *view = [UIView new];
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        NSArray *array4GroupMember = [self.groupProperty objectForKey:@"groupUserList"];
        NSInteger userPerLine = self.view.frame.size.width / 60;
        
        NSInteger buttonCount = array4GroupMember.count + 1;    //添加了+按钮
        if ([self isIGroupOwner] || [self isIAssistant])
            buttonCount ++;
        if (buttonCount > userPerLine * 3)
            buttonCount = userPerLine * 3;
        
        //实际显示用户个数
        NSInteger userCount = buttonCount - 1;
        if ([self isIGroupOwner] || [self isIAssistant])
            userCount --;
        
        if (userCount < array4GroupMember.count || [[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        {
            NSInteger lines = buttonCount / userPerLine + (buttonCount % userPerLine == 0?0:1);
            return 15 + lines * 85 + 40;
        }
        else
        {
            NSInteger lines = buttonCount / userPerLine + (buttonCount % userPerLine == 0?0:1);
            return 15 + lines * 85;
        }
    }
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"item"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        NSInteger userPerLine = self.view.frame.size.width / 60;
        CGFloat interval = (self.view.frame.size.width - userPerLine * 50) / (userPerLine + 1);
        NSArray *array4GroupMember = [self.groupProperty objectForKey:@"groupUserList"];
        
        //是否是虚拟群管理群
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
            ![[self.groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid] &&
            [[[[self.groupProperty objectForKey:@"virtualGroupSubList"]firstObject]objectForKey:@"groupId"]isEqualToString:self.groupId])
        {
            NSInteger buttonCount = array4GroupMember.count;
            if (buttonCount > userPerLine * 3)
                buttonCount = userPerLine * 3;
            
            NSInteger line = 0;
            NSInteger column = 0;
            NSInteger userCount = buttonCount;
            for (int i = 0; i < userCount; i ++)
            {
                line = i / userPerLine;
                column = i % userPerLine;
                
                NSString *str4NickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]
                                                                                     groupProperty:_groupProperty
                                                                                          nickName:[[array4GroupMember objectAtIndex:i]objectForKey:@"nickName"]];
                
                //头像
                UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]
                                                        nickName:str4NickName
                                                          avatar:[[array4GroupMember objectAtIndex:i]objectForKey:@"avatar"]
                                                           width:50 height:50];
                view4Avatar.frame = CGRectMake(interval + column * (50 + interval), 15 + line * 85, 50, 50);
                view4Avatar.userInteractionEnabled = YES;
                [cell.contentView addSubview:view4Avatar];
                
                //是否群主,管理员和嘉宾
                if ([[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
                {
                    UIImageView *image4Owner = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupowner"]];
                    image4Owner.center = CGPointMake(view4Avatar.center.x + 18, view4Avatar.center.y + 14);
                    [cell.contentView addSubview:image4Owner];
                }
                else if ([self isAssistant:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]])
                {
                    UIImageView *image4Assistant = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupassistant"]];
                    image4Assistant.center = CGPointMake(view4Avatar.center.x + 18, view4Avatar.center.y + 14);
                    [cell.contentView addSubview:image4Assistant];
                }
                else if ([self isVIP:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]])
                {
                    UIImageView *image4VIP = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupVIP"]];
                    image4VIP.center = CGPointMake(view4Avatar.center.x + 18, view4Avatar.center.y + 14);
                    [cell.contentView addSubview:image4VIP];
                }
                
                if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
                    ![[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid] &&
                    ![[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"owner"]])
                {
                    //给图片增加长按手势
                    UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGroupUser:)];
                    objc_setAssociatedObject(longPressGest, @"targetView", view4Avatar, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetData", [array4GroupMember objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
                    [view4Avatar addGestureRecognizer:longPressGest];
                }
                
                //给图片增加点击手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUserAvatar:)];
                objc_setAssociatedObject(tapGest, @"targetData", [array4GroupMember objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
                [view4Avatar addGestureRecognizer:tapGest];
                
                //昵称
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(interval + column * (50 + interval), 15 + line * 85 + 50, 50, 20)];
                label4NickName.text = str4NickName;
                label4NickName.textAlignment = NSTextAlignmentCenter;
                label4NickName.font = [UIFont systemFontOfSize:12];
                [cell.contentView addSubview:label4NickName];
            }
            
            //是否需要显示“更多”按钮
            if (userCount < array4GroupMember.count || [[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
            {
                UIButton *button4More = [[UIButton alloc]initWithFrame:CGRectMake(0, 7 + (line + 1) * 85, self.view.frame.size.width, 40)];
                button4More.titleLabel.font = [UIFont systemFontOfSize:16];
                button4More.titleLabel.numberOfLines = 0;
                button4More.titleLabel.textAlignment = NSTextAlignmentCenter;
                if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
                    [button4More setTitle:[LLSTR(@"201410") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", [[self.groupProperty objectForKey:@"joinedGroupUserCount"]integerValue]]]]  forState:UIControlStateNormal];
                else
                    [button4More setTitle:LLSTR(@"201202") forState:UIControlStateNormal];
                
                [button4More setTitleColor:THEME_GRAY forState:UIControlStateNormal];
                [button4More addTarget:self action:@selector(onButtonShowMoreUser:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:button4More];
                
                UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
                image4RightArrow.center = CGPointMake(self.view.frame.size.width - 20, 20);
                [button4More addSubview:image4RightArrow];
            }

        }
        else
        {
            NSInteger buttonCount = array4GroupMember.count + 1;    //添加了+按钮
            if ([self isIGroupOwner] || [self isIAssistant])
                buttonCount ++;
            if (buttonCount > userPerLine * 3)
                buttonCount = userPerLine * 3;
            
            //休整首页显示的用户个数
            NSInteger userCount = buttonCount - 1;
            if ([self isIGroupOwner] || [self isIAssistant])
                userCount --;

            NSInteger line = 0;
            NSInteger column = 0;
            for (int i = 0; i < userCount; i ++)
            {
                line = i / userPerLine;
                column = i % userPerLine;
                
                NSString *str4NickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]
                                                                                     groupProperty:_groupProperty
                                                                                          nickName:[[array4GroupMember objectAtIndex:i]objectForKey:@"nickName"]];
                
                //头像
                UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]
                                                        nickName:str4NickName
                                                          avatar:[[array4GroupMember objectAtIndex:i]objectForKey:@"avatar"]
                                                           width:50 height:50];
                view4Avatar.frame = CGRectMake(interval + column * (50 + interval), 15 + line * 85, 50, 50);
                view4Avatar.userInteractionEnabled = YES;
                [cell.contentView addSubview:view4Avatar];

                //是否群主,管理员和嘉宾
                if ([[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
                {
                    UIImageView *image4Owner = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupowner"]];
                    image4Owner.center = CGPointMake(view4Avatar.center.x + 18, view4Avatar.center.y + 14);
                    [cell.contentView addSubview:image4Owner];
                }
                else if ([self isAssistant:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]])
                {
                    UIImageView *image4Assistant = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupassistant"]];
                    image4Assistant.center = CGPointMake(view4Avatar.center.x + 18, view4Avatar.center.y + 14);
                    [cell.contentView addSubview:image4Assistant];
                }
                else if ([self isVIP:[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]])
                {
                    UIImageView *image4VIP = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"groupVIP"]];
                    image4VIP.center = CGPointMake(view4Avatar.center.x + 18, view4Avatar.center.y + 14);
                    [cell.contentView addSubview:image4VIP];
                }
                
                if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
                    ![[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid] &&
                    ![[[array4GroupMember objectAtIndex:i]objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"owner"]])
                {
                    //给图片增加长按手势
                    UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGroupUser:)];
                    objc_setAssociatedObject(longPressGest, @"targetView", view4Avatar, OBJC_ASSOCIATION_ASSIGN);
                    objc_setAssociatedObject(longPressGest, @"targetData", [array4GroupMember objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
                    [view4Avatar addGestureRecognizer:longPressGest];
                }
                
                //给图片增加点击手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUserAvatar:)];
                objc_setAssociatedObject(tapGest, @"targetData", [array4GroupMember objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
                [view4Avatar addGestureRecognizer:tapGest];
                
                //昵称
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(interval + column * (50 + interval), 15 + line * 85 + 50, 50, 20)];
                label4NickName.text = str4NickName;
                label4NickName.textAlignment = NSTextAlignmentCenter;
                label4NickName.font = [UIFont systemFontOfSize:12];
                [cell.contentView addSubview:label4NickName];
            }
            
            //添加按钮
            column ++;
            if (column >= userPerLine)
            {
                column = 0;
                line ++;
            }
            UIButton *button4Add = [[UIButton alloc]initWithFrame:CGRectMake(interval + column * (50 + interval), 15 + line * 85, 50, 50)];
            button4Add.layer.cornerRadius = 25;
            button4Add.clipsToBounds = YES;
            button4Add.titleLabel.font = [UIFont systemFontOfSize:30];
            [button4Add setBackgroundImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
            [button4Add addTarget:self action:@selector(onButtonAdd:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button4Add];
            
            //删除按钮
            if ([self isIGroupOwner] ||
                [self isIAssistant])
            {
                column ++;
                if (column >= userPerLine)
                {
                    column = 0;
                    line ++;
                }
                UIButton *button4Del = [[UIButton alloc]initWithFrame:CGRectMake(interval + column * (50 + interval), 15 + line * 85, 50, 50)];
                button4Del.layer.cornerRadius = 25;
                button4Del.clipsToBounds = YES;
                button4Del.titleLabel.font = [UIFont systemFontOfSize:30];
                [button4Del setBackgroundImage:[UIImage imageNamed:@"minus"] forState:UIControlStateNormal];
                [button4Del addTarget:self action:@selector(onButtonDel:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:button4Del];
            }
            
            //是否需要显示“更多”按钮
            if (userCount < array4GroupMember.count || [[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
            {
                UIButton *button4More = [[UIButton alloc]initWithFrame:CGRectMake(0, 7 + (line + 1) * 85, self.view.frame.size.width, 40)];
                button4More.titleLabel.font = [UIFont systemFontOfSize:16];
                button4More.titleLabel.numberOfLines = 0;
                button4More.titleLabel.textAlignment = NSTextAlignmentCenter;
                if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
                    [button4More setTitle:[LLSTR(@"201410") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", [[self.groupProperty objectForKey:@"joinedGroupUserCount"]integerValue]]]] forState:UIControlStateNormal];
                else
                    [button4More setTitle:LLSTR(@"201202") forState:UIControlStateNormal];
                
                 [button4More setTitleColor:THEME_GRAY forState:UIControlStateNormal];
                [button4More addTarget:self action:@selector(onButtonShowMoreUser:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:button4More];
                
                UIImageView *image4RightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
                image4RightArrow.center = CGPointMake(self.view.frame.size.width - 20, 20);
                [button4More addSubview:image4RightArrow];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
            cell.textLabel.text = LLSTR(@"201207");
        else
            cell.textLabel.text = LLSTR(@"201510");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
            cell.textLabel.text = LLSTR(@"201208");
        else
            cell.textLabel.text = LLSTR(@"201514");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
            cell.textLabel.text = LLSTR(@"204001");
        else
            cell.textLabel.text = LLSTR(@"204001");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"101417");
        
        //是否虚拟群
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
        {
            cell.textLabel.text = LLSTR(@"201512");
            NSDictionary *subGroupInfo = nil;
            for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
            {
                if ([[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                {
                    subGroupInfo = item;
                    break;
                }
            }
            
            //是管理群(本分支不会被执行到，有关处理参考VirtualGroupSetup2ViewController)
            if ([[[[self.groupProperty objectForKey:@"virtualGroupSubList"]firstObject]objectForKey:@"groupId"]isEqualToString:self.groupId])
            {
                cell.detailTextLabel.text = LLSTR(@"201503");
            }
            //是广播群
            else if ([[subGroupInfo objectForKey:@"isBroadCastGroup"]boolValue])
            {
                cell.detailTextLabel.text = LLSTR(@"201504");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else
            {
                if (![BiChatGlobal isMeGroupOperator:self.groupProperty])
                {
                    for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                    {
                        if ([self.groupId isEqualToString:[item objectForKey:@"groupId"]])
                        {
                            if ([[item objectForKey:@"groupNickName"]length] > 0)
                                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"groupNickName"]];
                            else
                                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[item objectForKey:@"virtualGroupNum"]integerValue]];
                            break;
                        }
                    }
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                else
                {
                    for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                    {
                        if ([self.groupId isEqualToString:[item objectForKey:@"groupId"]])
                        {
                            if ([[item objectForKey:@"groupNickName"]length] > 0)
                                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"groupNickName"]];
                            else
                                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[item objectForKey:@"virtualGroupNum"]integerValue]];
                            break;
                        }
                    }
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                }
            }
        }
        
        //我是否管理员或者副管理员
        else if (![BiChatGlobal isMeGroupOperator:self.groupProperty] &&
                 [[self.groupProperty objectForKey:@"changeNameRightOnly"]boolValue])
        {
            cell.detailTextLabel.text = [self.groupProperty objectForKey:@"groupName"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (![BiChatGlobal isMeGroupOperator:self.groupProperty] &&
                 [[self.groupProperty objectForKey:@"payGroup"]boolValue])
        {
            cell.detailTextLabel.text = [self.groupProperty objectForKey:@"groupName"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell.detailTextLabel.text = [self.groupProperty objectForKey:@"groupName"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"201210");
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            [[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        {
            cell.detailTextLabel.text = [self.groupProperty objectForKey:@"briefing"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            if ([[self.groupProperty objectForKey:@"briefing"]length] == 0)
            {
                cell.detailTextLabel.text = LLSTR(@"101005");
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else
            {
                cell.detailTextLabel.text = [self.groupProperty objectForKey:@"briefing"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"201211");
        
        //我是否管理员或者副管理员而且不能是虚拟群
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            [[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        {
            //当前的群头像
            NSString *str4Avatar = [BiChatGlobal getGroupAvatar:self.groupProperty];
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil nickName:[self.groupProperty objectForKey:@"groupName"] avatar:str4Avatar width:30 height:30];
            view4Avatar.center = CGPointMake(self.view.frame.size.width - 50, 22);
            [cell.contentView addSubview:view4Avatar];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            //当前的群头像
            NSString *str4Avatar = [BiChatGlobal getGroupAvatar:self.groupProperty];
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil nickName:[self.groupProperty objectForKey:@"groupName"] avatar:str4Avatar width:30 height:30];
            view4Avatar.center = CGPointMake(self.view.frame.size.width - 30, 22);
            [cell.contentView addSubview:view4Avatar];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([[self.groupProperty objectForKey:@"avatar"]length] > 0)
                image4CurrentShowedAvatar = (UIImageView *)view4Avatar;
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 3)
    {
        cell.textLabel.text = LLSTR(@"201212");
        
        UIImageView *image4VRCode = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"my_vrcode_gray"]];
        image4VRCode.center = CGPointMake(self.view.frame.size.width - 45, 22);
        [cell.contentView addSubview:image4VRCode];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 4)
    {
        if ([BiChatGlobal isMeGroupOwner:self.groupProperty]) {
            cell.textLabel.text = LLSTR(@"201241");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSString *chatId = [self.groupProperty objectForKey:@"chatId"];
            if (chatId.length > 0) {
                cell.detailTextLabel.text = [self.groupProperty objectForKey:@"chatId"];
            } else {
                cell.detailTextLabel.text = nil;
            }
        } else {
            cell.textLabel.text = LLSTR(@"201213");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    else if (indexPath.section == 2 && indexPath.row == 5)
    {
        if ([BiChatGlobal isMeGroupOwner:self.groupProperty]) {
            cell.textLabel.text = LLSTR(@"201213");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = LLSTR(@"201214");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 6)
    {
        cell.textLabel.text = LLSTR(@"201214");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if (indexPath.section == 3 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"101121");
        
        if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        {
            cell.detailTextLabel.text = LLSTR(@"201333");
        }
        else
        {
            UISwitch *switch4Mute = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4Mute addTarget:self action:@selector(onSwitchMute:) forControlEvents:UIControlEventValueChanged];
            switch4Mute.on = [[BiChatGlobal sharedManager]isFriendInMuteList:self.groupId];
            [cell.contentView addSubview:switch4Mute];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 3 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"101122");
        
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
            [BiChatGlobal isMeGroupOperator:self.groupProperty])
            cell.detailTextLabel.text = LLSTR(@"201513");
        else
        {
            UISwitch *switch4Fold = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4Fold addTarget:self action:@selector(onSwitchFold:) forControlEvents:UIControlEventValueChanged];
            switch4Fold.on = [[BiChatGlobal sharedManager]isFriendInFoldList:self.groupId];
            [cell.contentView addSubview:switch4Fold];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 3 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"101123");
        
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
            [BiChatGlobal isMeGroupOperator:self.groupProperty])
            cell.detailTextLabel.text = LLSTR(@"201513");
        else
        {
            UISwitch *switch4Stick = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4Stick addTarget:self action:@selector(onSwitchStick:) forControlEvents:UIControlEventValueChanged];
            switch4Stick.on = [[BiChatGlobal sharedManager]isFriendInStickList:self.groupId];
            [cell.contentView addSubview:switch4Stick];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 3 && indexPath.row == 3)
    {
        cell.textLabel.text = LLSTR(@"101124");
        BOOL isInContactList = [self isGroupInContactList:self.groupId];
        
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
            [BiChatGlobal isMeGroupOperator:self.groupProperty])
            cell.detailTextLabel.text = LLSTR(@"201513");
        else
        {
            UISwitch *switch4Save2Contact = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4Save2Contact addTarget:self action:@selector(onSwitchSave2Contact:) forControlEvents:UIControlEventValueChanged];
            switch4Save2Contact.on = isInContactList;
            [cell.contentView addSubview:switch4Save2Contact];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 4 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"201215");
        cell.detailTextLabel.text = [self getMyNickNameInGroup];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 4 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"201216");
        
        UISwitch *switch4ShowNickName = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
        [switch4ShowNickName addTarget:self action:@selector(onSwitchShowNickName:) forControlEvents:UIControlEventValueChanged];
        switch4ShowNickName.on = [[self.groupProperty objectForKey:@"showNickName"]boolValue];
        [cell.contentView addSubview:switch4ShowNickName];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        //隐藏删除成员按钮
        button4RemoveGroupUser.hidden = YES;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        {
            GroupSetupViewController *wnd = [[GroupSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            wnd.ownerChatWnd = self.ownerChatWnd;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else
        {
            VirtualSubGroupMemberSetupViewController *wnd = [[VirtualSubGroupMemberSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            wnd.ownerChatWnd = self.ownerChatWnd;
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        GroupContentSetupViewController *wnd = [[GroupContentSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        wnd.ownerChatWnd = self.ownerChatWnd;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        if (![[self.groupProperty objectForKey:@"payGroup"]boolValue])
        {
            UpgradeChargeGroupViewController *wnd = [[UpgradeChargeGroupViewController alloc]initWithStyle:UITableViewStyleGrouped];
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else
        {
            if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
            {
                ChargeGroupManageViewController *wnd = [[ChargeGroupManageViewController alloc]initWithStyle:UITableViewStyleGrouped];
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                [self.navigationController pushViewController:wnd animated:YES];
            }
            else
            {
                ChargeGroupInfoViewController *wnd = [[ChargeGroupInfoViewController alloc]initWithStyle:UITableViewStyleGrouped];
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                [self.navigationController pushViewController:wnd animated:YES];
            }
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        NSDictionary *subGroupInfo = nil;
        for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([[item objectForKey:@"groupId"]isEqualToString:self.groupId])
            {
                subGroupInfo = item;
                break;
            }
        }
        
        //是广播群
        if ([[subGroupInfo objectForKey:@"isBroadCastGroup"]boolValue])
            return;
        
        //我是否管理员或者副管理员
        if (![BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            ([[self.groupProperty objectForKey:@"changeNameRightOnly"]boolValue] ||
             [[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0))
        {
            ;   //什么都不做
        }
        else if (![BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            [[self.groupProperty objectForKey:@"payGroup"]boolValue])
        {
            ;   //什么都不做
        }
        else
        {
            GroupNameChangeViewController *wnd = [[GroupNameChangeViewController alloc]init];
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            wnd.ownerChatWnd = self.ownerChatWnd;
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        if (![BiChatGlobal isMeGroupOperator:self.groupProperty] ||
            [[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
        {
            if ([[self.groupProperty objectForKey:@"briefing"]length] > 0)
            {
                TextRenderViewController *wnd = [TextRenderViewController new];
                wnd.navigationItem.title = LLSTR(@"201210");
                wnd.text = [self.groupProperty objectForKey:@"briefing"];
                [self.navigationController pushViewController:wnd animated:YES];
            }
        }
        else
        {
            //设置群简介
            GroupBriefingChangeViewController *wnd = [GroupBriefingChangeViewController new];
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            wnd.ownerChatWnd = self.ownerChatWnd;
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 2)
    {
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            [[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        {
            SetGroupAvatarViewController *wnd = [SetGroupAvatarViewController new];
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else
        {
            if ([[self.groupProperty objectForKey:@"avatar"]length] > 0)
            {
                //生成头像大图片的地址
                NSString *bigAvatar = [[NSString stringWithFormat:@"%@_big", [[self.groupProperty objectForKey:@"avatar"] stringByDeletingPathExtension]]stringByAppendingPathExtension:[[self.groupProperty objectForKey:@"avatar"] pathExtension]];
                
                UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
                [image4Avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [self.groupProperty objectForKey:@"avatar"]]]];
                
                if (image4ShowAvatar == nil)
                {
                    image4ShowAvatar = [UIImageView new];
                    image4ShowAvatar.contentMode = UIViewContentModeScaleAspectFit;
                    image4ShowAvatar.userInteractionEnabled = YES;
                    
                    //添加点击事件
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBigAvatar:)];
                    [image4ShowAvatar addGestureRecognizer:tap];
                }
                image4ShowAvatar.frame = [self.navigationController.view convertRect:image4CurrentShowedAvatar.bounds fromView:image4CurrentShowedAvatar];
                image4ShowAvatar.backgroundColor = [UIColor blackColor];
                [image4ShowAvatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, bigAvatar]] placeholderImage:image4Avatar.image];
                [self.navigationController.view addSubview:image4ShowAvatar];
                
                [UIView beginAnimations:@"ani" context:nil];
                image4ShowAvatar.frame = self.navigationController.view.bounds;
                [UIView commitAnimations];
                
                //保存按钮
                if (button4LocalSave == nil)
                {
                    button4LocalSave = [[UIButton alloc]initWithFrame:CGRectMake(self.navigationController.view.frame.size.width - 60, self.navigationController.view.frame.size.height - 80, 40, 40)];
                    [button4LocalSave setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                    [button4LocalSave addTarget:self action:@selector(onButtonSave:) forControlEvents:UIControlEventTouchUpInside];
                }
                [self.navigationController.view addSubview:button4LocalSave];
            }
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 3)
    {
        //显示群二维码
        GroupVRCodeViewController *wnd = [GroupVRCodeViewController new];
        wnd.groupId = self.groupId;
        wnd.chatId = [self.groupProperty objectForKey:@"chatId"];
        wnd.groupNickName = [[BiChatGlobal sharedManager]adjustGroupNickName4Display:self.groupId nickName:[self.groupProperty objectForKey:@"groupName"]];
        wnd.groupAvatar = [self.groupProperty objectForKey:@"avatar"];
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 4)
    {
        if ([BiChatGlobal isMeGroupOwner:self.groupProperty]) {
            WPShortLinkViewController *shortVC = [[WPShortLinkViewController alloc]init];
            shortVC.type = @"g";
            shortVC.groupId = self.groupId;
            shortVC.shortLink = [self.groupProperty objectForKey:@"chatId"];
            shortVC.ChangeBlock = ^{
                [self viewWillAppear:YES];
            };
            shortVC.changeCount = [NSString stringWithFormat:@"%d",[[self.groupProperty objectForKey:@"leftChangeShortNameTimes"] intValue]];
            [self.navigationController pushViewController:shortVC animated:YES];
        } else {
            //显示群公告板
            GroupPinBoardViewController *wnd = [GroupPinBoardViewController new];
            wnd.defaultShowType = 2;
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 5)
    {
        if ([BiChatGlobal isMeGroupOwner:self.groupProperty]) {
            //显示群公告板
            GroupPinBoardViewController *wnd = [GroupPinBoardViewController new];
            wnd.defaultShowType = 2;
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            [self.navigationController pushViewController:wnd animated:YES];
        } else {
            //显示群订板
            GroupPinBoardViewController *wnd = [GroupPinBoardViewController new];
            wnd.defaultShowType = 1;
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        
    }
    else if (indexPath.section == 2 && indexPath.row == 6)
    {
        //显示群订板
        GroupPinBoardViewController *wnd = [GroupPinBoardViewController new];
        wnd.defaultShowType = 1;
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 4 && indexPath.row == 0)
    {
        NickNameInGroupChangeViewController *wnd = [[NickNameInGroupChangeViewController alloc]init];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
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
        // Create a new instance of the appropriate class, insert into the array, and add a new row to the table view
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

#pragma mark - ContactSelectDelegate function

- (void)contactSelected:(NSInteger)cookie contacts:(NSArray *)contacts
{
    //先判断一下是否所有的人都在待支付列表里面
    BOOL allInWaitingForPay = YES;
    for (NSString *uid in contacts)
    {
        if (![BiChatGlobal isUserInPayList:self.groupProperty uid:uid])
        {
            allInWaitingForPay = NO;
            break;
        }
    }

    //如果是超大群，直接发消息
    if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
    {
        [self sendInviteMessageToUsers:contacts];
    }
    
    //如果我是群管理员或者添加成员不需要管理员批准,直接添加
    else if ([BiChatGlobal isMeGroupOperator:self.groupProperty] ||
             ![[self.groupProperty objectForKey:@"addNewMemberRightOnly"]boolValue] ||
             ([[self.groupProperty objectForKey:@"payGroup"]boolValue] && allInWaitingForPay))
    {
        [self dismissViewControllerAnimated:YES completion:nil];

        //不管是虚拟群还是普通群，一律调用普通群入群
        [self groupAddMember:contacts directly:YES apply:nil];
    }
    
    //需要群管理员批准
    else
    {
        //显示发送申请界面
        UIView *view4SendApplyPrompt = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 175)];
        view4SendApplyPrompt.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
        view4SendApplyPrompt.layer.cornerRadius = 5;
        view4SendApplyPrompt.clipsToBounds = YES;
        
        //title
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 270, 20)];
        label4Title.text = LLSTR(@"203004");
        label4Title.font = [UIFont systemFontOfSize:18];
        label4Title.numberOfLines = 0;
        label4Title.textAlignment = NSTextAlignmentCenter;
        label4Title.adjustsFontSizeToFitWidth = YES;
        [view4SendApplyPrompt addSubview:label4Title];
        
        //输入框
        UIView *view4InputFrame = [[UIView alloc]initWithFrame:CGRectMake(15, 75, 270, 40)];
        view4InputFrame.backgroundColor = [UIColor whiteColor];
        view4InputFrame.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
        view4InputFrame.layer.borderWidth = 0.5;
        view4InputFrame.layer.cornerRadius = 3;
        [view4SendApplyPrompt addSubview:view4InputFrame];
        
        UITextField *input4Apply = [[UITextField alloc]initWithFrame:CGRectMake(20, 75, 250, 40)];
        input4Apply.font = [UIFont systemFontOfSize:14];
        input4Apply.placeholder = LLSTR(@"101024");
        [view4SendApplyPrompt addSubview:input4Apply];
        
        //确定取消按钮
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 125, 300, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [view4SendApplyPrompt addSubview:view4Seperator];
        view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(150, 125, 0.5, 50)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [view4SendApplyPrompt addSubview:view4Seperator];
        
        UIButton *button4Cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 125, 150, 50)];
        button4Cancel.titleLabel.font = [UIFont systemFontOfSize:16];
        [button4Cancel setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
        [button4Cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button4Cancel addTarget:self action:@selector(onButtonCancelSendApply:) forControlEvents:UIControlEventTouchUpInside];
        [view4SendApplyPrompt addSubview:button4Cancel];
        
        UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(150, 125, 150, 50)];
        button4OK.titleLabel.font = [UIFont systemFontOfSize:16];
        [button4OK setTitle:LLSTR(@"101021") forState:UIControlStateNormal];
        [button4OK setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4OK addTarget:self action:@selector(onButtonSendApply:) forControlEvents:UIControlEventTouchUpInside];
        [view4SendApplyPrompt addSubview:button4OK];
        objc_setAssociatedObject(button4OK, @"contacts", contacts, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(button4OK, @"input4Apply", input4Apply, OBJC_ASSOCIATION_RETAIN);
        
        [BiChatGlobal presentModalView:view4SendApplyPrompt clickDismiss:NO delayDismiss:0 andDismissCallback:nil];
    }
}

- (void)onButtonCancelSendApply:(id)sender
{
    //关闭提示窗口
    [BiChatGlobal dismissModalView];
}

- (void)onButtonSendApply:(id)sender
{
    //关闭提示窗口
    [BiChatGlobal dismissModalView];
    
    NSArray *contacts = objc_getAssociatedObject(sender, @"contacts");
    UITextField *input4Apply = objc_getAssociatedObject(sender, @"input4Apply");
    
    //不管是虚拟群还是普通群，一律调用普通群入群
    [self groupAddMember:contacts directly:NO apply:input4Apply.text];

    //关闭窗口
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)groupAddMember:(NSArray *)contacts directly:(BOOL)directly apply:(NSString *)apply
{
    if (contacts.count == 0)
        return;
    
    //添加朋友
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule addGroupMember:contacts groupId:self.groupId source:@{@"source":@"INVITE",@"inviterId":[BiChatGlobal sharedManager].uid} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //重新刷新group member
            [self getGroupProperty];
            
            //NSLog(@"%@", self.groupId);
            //NSLog(@"%@", data);
            
            //先生成所有朋友的列表字符串
            NSMutableArray *array4PeersSuccess = [NSMutableArray array];
            NSMutableArray *array4PeersFail = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInGroup = [NSMutableArray array];
            NSMutableArray *array4PeersNeedApprove = [NSMutableArray array];
            NSMutableArray *array4PeersBlocked = [NSMutableArray array];
            NSMutableArray *array4PeersFull = [NSMutableArray array];
            NSMutableArray *array4PeersTrail = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInWaitingPayList = [NSMutableArray array];
            for (int i = 0; i < contacts.count; i ++)
            {
                NSMutableDictionary *peer = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [contacts objectAtIndex:i], @"uid",
                                             [[BiChatGlobal sharedManager]getFriendNickName:[contacts objectAtIndex:i]], @"nickName",
                                             [BiChatGlobal sharedManager].uid, @"sender",
                                             nil];
                if ([[[BiChatGlobal sharedManager]getFriendAvatar:[contacts objectAtIndex:i]]length] > 0)
                    [peer setObject:[[BiChatGlobal sharedManager]getFriendAvatar:[contacts objectAtIndex:i]] forKey:@"avatar"];
                if ([[[BiChatGlobal sharedManager]getFriendAvatar:[contacts objectAtIndex:i]]length] > 0)
                    [peer setObject:[[BiChatGlobal sharedManager]getFriendUserName:[contacts objectAtIndex:i]] forKey:@"userName"];
                
                //这一条是否添加进群组成功
                for (NSDictionary *item in [data objectForKey:@"data"])
                {
                    if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"] &&
                        [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
                            [array4PeersTrail addObject:peer];
                        else
                            [array4PeersSuccess addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_PENDING_LIST"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersNeedApprove addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"NOT_YOUR_FRIEND"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersFail addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersAlreadyInGroup addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"NEED_APPROVE"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersNeedApprove addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersBlocked addObject:peer];
                        break;
                    }
                    else if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"] &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersFull addObject:peer];
                        break;
                    }
                    else if (([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_WAITING_PAY_LIST"] ||
                             [[item objectForKey:@"result"]isEqualToString:@"JOIN_WAITING_PAY_LIST"]) &&
                             [[item objectForKey:@"uid"]isEqualToString:[contacts objectAtIndex:i]])
                    {
                        [array4PeersAlreadyInWaitingPayList addObject:peer];
                        break;
                    }
                }
            }
            
            //NSLog(@"1-%@", array4PeersSuccess);
            //NSLog(@"2-%@", array4PeersFull);
            //NSLog(@"3-%@", array4PeersFail);
            //NSLog(@"4-%@", array4PeersNeedApprove);
            
            //处理各种状态的显示，首先全部成功
            if ((array4PeersSuccess.count > 0 || array4PeersTrail.count > 0 || array4PeersAlreadyInGroup.count > 0 || array4PeersAlreadyInWaitingPayList.count > 0) && array4PeersFail.count == 0)
                [BiChatGlobal showInfo:LLSTR(@"301712") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else if ((array4PeersSuccess.count > 0 || array4PeersTrail.count > 0 || array4PeersAlreadyInGroup.count > 0 || array4PeersAlreadyInWaitingPayList.count > 0) && array4PeersFail.count > 0)
                [BiChatGlobal showInfo:LLSTR(@"301714") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else if (array4PeersNeedApprove.count > 0)
                [BiChatGlobal showInfo:LLSTR(@"301708") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else
                [BiChatGlobal showInfo:LLSTR(@"301713") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            
            NSMutableArray *blockarray = [self.groupProperty objectForKey:@"groupBlockUserLevelTwo"];
            NSMutableArray *removeArray = [NSMutableArray array];
            if (array4PeersSuccess.count > 0) {
                for (NSDictionary *dic in array4PeersSuccess) {
                    for (NSDictionary *dic1 in blockarray) {
                        if ([[dic objectForKey:@"uid"] isEqualToString:[dic1 objectForKey:@"uid"]]) {
                            [removeArray addObject:dic1];
                        }
                    }
                }
            }
            [blockarray removeObjectsInArray:removeArray];
            
            //分别处理各种情况
            if (array4PeersSuccess.count > 0)
            {
                //同时开始发送一个邀请朋友的信息message
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUP], @"type",
                                                 [array4PeersSuccess JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                                
                //加入本地一条消息
                if (self.ownerChatWnd != nil)
                    [self.ownerChatWnd appendMessage:sendData];
                else
                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                      peerUserName:@""
                                                      peerNickName:[BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil]
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
                
                //发送到服务器
                [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
            
            //有因为对方不是好友而没有加成功的人
            if (array4PeersFail.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL], @"type",
                                                 [array4PeersFail JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                if (self.ownerChatWnd != nil)
                    [self.ownerChatWnd appendMessage:sendData];
                else
                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId peerUserName:@""
                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                        peerAvatar:[self.groupProperty objectForKey:@"avatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            
            //有需要批准的人
            if (array4PeersNeedApprove.count > 0)
            {
                //内部保存这些信息
                for (NSDictionary *item in array4PeersNeedApprove)
                {
                    NSString *key = [NSString stringWithFormat:@"%@_%@", [item objectForKey:@"uid"], self.groupId];
                    [[BiChatGlobal sharedManager].dict4ApplyList setObject:@"NEED_APPROVE" forKey:key];
                }
                [[BiChatGlobal sharedManager]saveUserAdditionInfo];
                
                //准备数据,发送给群成员
                NSDictionary *applyInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                           apply==nil?@"":apply, @"apply",
                                           array4PeersNeedApprove, @"friends", nil];
                
                //同时开始发送一个邀请朋友的信息message,本条信息所有人都可以看到
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER], @"type",
                                                 [applyInfo JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //发送到服务器
                [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    if (success)
                    {
                        //加入本地一条消息
                        if (self.ownerChatWnd != nil)
                            [self.ownerChatWnd appendMessage:sendData];
                        else
                            [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                        
                        //接下来发送一条邀请朋友的信息message，本条信息只有群主或者管理员可以看到，用于批准申请
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBER], @"type",
                                                         [applyInfo JSONString], @"content",
                                                         self.groupId, @"receiver",
                                                         [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                         [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];
                        
                        [NetworkModule sendMessageToGroupOperator:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                            if (success)
                            {
                                //接下来将向所有的需要审批个人发送一条模拟群消息，以让用户可以和群主建立虚拟聊天
                                NSString *msgId = [BiChatGlobal getUuidString];
                                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE], @"type",
                                                                 @"", @"content",
                                                                 self.groupId, @"receiver",
                                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                 @"1", @"isGroup",
                                                                 msgId, @"msgId",
                                                                 nil];
                                for (NSDictionary *item in array4PeersNeedApprove)
                                {
                                    [NetworkModule sendMessageToUser:[item objectForKey:@"uid"] message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                    }];
                                }
                            }
                        }];
                    }
                }];
            }
            
            //有因为黑名单而被拒绝的人
            if (array4PeersBlocked.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_BLOCKED], @"type",
                                                 [array4PeersBlocked JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                if (self.ownerChatWnd != nil)
                    [self.ownerChatWnd appendMessage:sendData];
                else
                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId peerUserName:@""
                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                        peerAvatar:[self.groupProperty objectForKey:@"avatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            
            //有因为群满而被拒绝的人
            if (array4PeersFull.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_FULL], @"type",
                                                 [array4PeersFull JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                if (self.ownerChatWnd != nil)
                    [self.ownerChatWnd appendMessage:sendData];
                else
                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId peerUserName:@""
                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                        peerAvatar:[self.groupProperty objectForKey:@"avatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            
            //有加入试用名单的人
            if (array4PeersTrail.count > 0)
            {
                //同时开始发送一个邀请朋友的信息message
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPTRAIL], @"type",
                                                 [array4PeersTrail JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                if (self.ownerChatWnd != nil)
                    [self.ownerChatWnd appendMessage:sendData];
                else
                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                      peerUserName:@""
                                                      peerNickName:[BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil]
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
                
                //发送到服务器
                [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
            
            //有在待付费列表中的人
            if (array4PeersAlreadyInWaitingPayList.count > 0)
            {
                //同时开始发送一个邀请朋友的信息message
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY], @"type",
                                                 [array4PeersAlreadyInWaitingPayList JSONString], @"content",
                                                 self.groupId, @"receiver",
                                                 [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                 [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                if (self.ownerChatWnd != nil)
                    [self.ownerChatWnd appendMessage:sendData];
                else
                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                      peerUserName:@""
                                                      peerNickName:[BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil]
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
                
                //这条消息发送给群管理员和所有的对方
                [MessageHelper sendGroupMessageToOperator:self.groupId
                                                     type:MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY
                                                  content:[array4PeersAlreadyInWaitingPayList mj_JSONString]
                                                 needSave:NO
                                                 needSend:YES
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                for (NSDictionary *item in array4PeersAlreadyInWaitingPayList)
                {
                    NSString *uid = [item objectForKey:@"uid"];
                    [MessageHelper sendGroupMessageToUser:uid
                                                  groupId:self.groupId
                                                     type:MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY
                                                  content:[array4PeersAlreadyInWaitingPayList mj_JSONString]
                                                 needSave:NO
                                                 needSend:YES
                                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301723") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

//把一群好友添加到虚拟群
- (void)add4VirtualGroup:(NSString *)groupId
          virtualGroupId:(NSString *)virtualGroupId
        friends_selected:(NSMutableArray *)friends_selected
    friendsInfo_selected:(NSMutableArray *)friendsInfo_selected
{
    //NSLog(@"%@", friends_selected);
    //开始添加入虚拟群
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule addVirtualGroupMember:friends_selected virtualGroupId:virtualGroupId groupId:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        //NSLog(@"%@", data);
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            NSDictionary *addVirtualGroupMemberReturn = data;
            
            //重新获取群属性
            [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                self.groupProperty = data;
                
                //先生成所有朋友的列表字符串
                NSMutableDictionary *dict4PeersSuccess = [NSMutableDictionary dictionary];
                NSMutableArray *array4PeersFail = [NSMutableArray array];
                NSMutableArray *array4PeersBlocked = [NSMutableArray array];
                NSMutableArray *array4PeersAlreadyInGroup = [NSMutableArray array];
                NSMutableDictionary *dict4PeersNeedApprove = [NSMutableDictionary dictionary];
                
                for (int i = 0; i < friendsInfo_selected.count; i ++)
                {
                    //这一条是否添加进群组成功
                    for (NSDictionary *item in [addVirtualGroupMemberReturn objectForKey:@"data"])
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[[friendsInfo_selected objectAtIndex:i]objectForKey:@"uid"]])
                        {
                            if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"])
                            {
                                NSMutableArray *array = [dict4PeersSuccess objectForKey:[item objectForKey:@"joinedGroupId"]];
                                if (array == nil)
                                {
                                    array = [NSMutableArray array];
                                    [dict4PeersSuccess setObject:array forKey:[item objectForKey:@"joinedGroupId"]];
                                }
                                [array addObject:[friendsInfo_selected objectAtIndex:i]];
                            }
                            else if ([[item objectForKey:@"result"]isEqualToString:@"NOT_YOUR_FRIEND"])
                                [array4PeersFail addObject:[friendsInfo_selected objectAtIndex:i]];
                            else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"])
                                [array4PeersBlocked addObject:[friendsInfo_selected objectAtIndex:i]];
                            else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"])
                                [array4PeersAlreadyInGroup addObject:[friendsInfo_selected objectAtIndex:i]];
                            else if ([[item objectForKey:@"result"]isEqualToString:@"NEED_APPROVE"])
                            {
                                NSMutableArray *array = [dict4PeersNeedApprove objectForKey:[item objectForKey:@"joinedGroupId"]];
                                if (array == nil)
                                {
                                    array = [NSMutableArray array];
                                    [dict4PeersNeedApprove setObject:array forKey:[item objectForKey:@"joinedGroupId"]];
                                }
                                [array addObject:[friendsInfo_selected objectAtIndex:i]];
                            }
                        }
                    }
                }
                
                //NSLog(@"2-%@", dict4PeersSuccess);
                //NSLog(@"3-%@", array4PeersFail);
                //NSLog(@"4-%@", array4PeersBlocked);
                //NSLog(@"5-%@", array4PeersAlreadyInGroup);
                //NSLog(@"6-%@", dict4PeersNeedApprove);
                
                //处理各种状态
                if (array4PeersFail.count > 0)
                {
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL], @"type",
                                                     [array4PeersFail JSONString], @"content",
                                                     self.groupId, @"receiver",
                                                     [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                     [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                     @"1", @"isGroup",
                                                     msgId, @"msgId",
                                                     nil];
                    
                    //加入本地一条消息
                    if (self.ownerChatWnd != nil)
                        [self.ownerChatWnd appendMessage:sendData];
                    else
                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                    [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                          peerUserName:@""
                                                          peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                            peerAvatar:[self.groupProperty objectForKey:@"avatar"]
                                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                }
                
                if (array4PeersAlreadyInGroup.count > 0)
                {
                    //生成一个新的消息
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [array4PeersAlreadyInGroup mj_JSONString], @"content",
                                                    [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPALREADYINGROUP], @"type",
                                                    groupId , @"receiver",
                                                    [_groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                                    [_groupProperty objectForKey:@"avatar"]==nil?@"":[_groupProperty objectForKey:@"avatar"], @"receiverAvatar",
                                                    [BiChatGlobal sharedManager].uid, @"sender",
                                                    [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                    [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                    [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                    msgId, @"msgId",
                                                    @"1", @"isGroup",
                                                    [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                    nil];
                    
                    //保存在本地
                    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:message];
                    [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                          peerUserName:@""
                                                          peerNickName:[_groupProperty objectForKey:@"groupName"]
                                                            peerAvatar:[_groupProperty objectForKey:@"avatar"]
                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                           messageTime:@""
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                }
                
                if (array4PeersBlocked.count > 0)
                {
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_BLOCKED], @"type",
                                                     [array4PeersBlocked mj_JSONString], @"content",
                                                     self.groupId, @"receiver",
                                                     [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                     [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                     @"1", @"isGroup",
                                                     msgId, @"msgId",
                                                     nil];
                    
                    //加入本地一条消息
                    if (self.ownerChatWnd != nil)
                        [self.ownerChatWnd appendMessage:sendData];
                    else
                    {
                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                        [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId peerUserName:@""
                                                              peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                peerAvatar:[self.groupProperty objectForKey:@"avatar"]
                                                                   message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                               messageTime:[BiChatGlobal getCurrentDateString]
                                                                     isNew:NO isGroup:YES isPublic:NO createNew:YES];
                    }
                }
                
                //被加入的人员列表中，如果有加入其他群的情况下，需要下面的处理
                //BOOL addToOtherGroup = NO;
                //for (NSString *key in dict4PeersSuccess)
                //{
                //    if (![key isEqualToString:self.groupId])
                //    {
                //        addToOtherGroup = YES;
                //        break;
                //    }
                //}
                if (dict4PeersSuccess.count > 0)
                {
                    for (NSString *key in dict4PeersSuccess)
                    {
                        //生成这个虚拟群的群名
                        __block NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:key];
                        if (groupProperty == nil)
                        {
                            //可能是一个新的群
                            [NetworkModule getGroupProperty:key completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                groupProperty = data;
                                //NSLog(@"通知一个新群：%@", groupProperty);
                                [self notifyVirtualGroupAssignMember:groupId groupProperty:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                            }];
                        }
                        else
                        {
                            //NSLog(@"通知一个老群：%@", groupProperty);
                            [self notifyVirtualGroupAssignMember:groupId groupProperty:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                        }
                    }
                }
                
                //有需要批准的条目
                if (dict4PeersNeedApprove.count > 0)
                {
                    for (NSString *key in dict4PeersNeedApprove)
                    {
                        //内部保存数据,为以后的取消邀请提供信息
                        for (NSDictionary *item in [dict4PeersNeedApprove objectForKey:key])
                        {
                            NSString *key1 = [NSString stringWithFormat:@"%@_%@", [item objectForKey:@"uid"], key];
                            [[BiChatGlobal sharedManager].dict4ApplyList setObject:@"NEED_APPROVE" forKey:key1];
                        }
                        [[BiChatGlobal sharedManager]saveUserAdditionInfo];
                        
                        //生成这个虚拟群的群名
                        __block NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:key];
                        if (groupProperty == nil)
                        {
                            //可能是一个新的群
                            [NetworkModule getGroupProperty:key completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                groupProperty = data;
                                //NSLog(@"通知一个新群：%@", groupProperty);
                                [self notifyVirtualGroupNeedApprove:groupId groupProperty:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersNeedApprove];
                            }];
                        }
                        else
                        {
                            //NSLog(@"通知一个老群：%@", groupProperty);
                            [self notifyVirtualGroupNeedApprove:groupId groupProperty:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersNeedApprove];
                        }
                    }
                }
                
                //修改申请列表
                for (NSString *uid in friends_selected)
                {
                    for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                    {
                        if ([uid isEqualToString:[item2 objectForKey:@"uid"]] &&
                            [[item2 objectForKey:@"groupId"]isEqualToString:self.groupId])
                        {
                            [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                            break;
                        }
                    }
                }
                [[BiChatGlobal sharedManager]saveUserAdditionInfo];
            }];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301704") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

//把一个群升级成虚拟群，然后重新批准一批入群者
- (void)upgrade2VirtualGroupAndReAdd:(NSString *)groupId
                    friends_selected:(NSMutableArray *)friends_selected
                friendsInfo_selected:(NSMutableArray *)friendsInfo_selected
{
    //获取群属性
    __block NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    
    //开始升级虚拟群
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"201316")
                                                                             message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"201317")]
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //开始设置为虚拟群
        [NetworkModule createVirtualGroup:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                [BiChatGlobal showInfo:LLSTR(@"301722") withIcon:[UIImage imageNamed:@"icon_OK"]];
                
                //重新获取群属性
                [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success)
                    {
                        groupProperty = data;
                        self.groupProperty = groupProperty;
                        //NSLog(@"%@", groupProperty);
                        
                        //同时要发送一条数据通知群中的其他成员
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CREATEVIRTUALGROUP], @"type",
                                                         @"", @"content",
                                                         groupId, @"receiver",
                                                         [groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                                         [BiChatGlobal getGroupAvatar:groupProperty], @"receiverAvatar",
                                                         [BiChatGlobal sharedManager].uid, @"sender",
                                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                         @"1", @"isGroup",
                                                         msgId, @"msgId",
                                                         nil];
                        
                        [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            if (success)
                            {
                                [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                                      peerUserName:@""
                                                                      peerNickName:[groupProperty objectForKey:@"groupName"]
                                                                        peerAvatar:[BiChatGlobal getGroupAvatar:groupProperty]
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:YES];
                                
                                //加入本地一条消息
                                if (self.ownerChatWnd)
                                    [self.ownerChatWnd appendMessage:sendData];
                                else
                                    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                            }
                        }];
                        
                        //接下来将原来需要批准的人重新加入虚拟群
                        [NetworkModule addVirtualGroupMember:friends_selected
                                              virtualGroupId:[groupProperty objectForKey:@"virtualGroupId"]
                                                     groupId:groupId
                                              completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
                         {
                             NSDictionary *addVirtualGroupMemberReturn = data;
                             
                             //重新获取群属性
                             [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                 
                                 groupProperty = data;
                                 self.groupProperty = groupProperty;
                                 
                                 //先生成所有朋友的列表字符串
                                 NSMutableDictionary *dict4PeersSuccess = [NSMutableDictionary dictionary];
                                 NSMutableArray *array4PeersFail = [NSMutableArray array];
                                 NSMutableArray *array4PeersBlocked = [NSMutableArray array];
                                 
                                 for (int i = 0; i < friendsInfo_selected.count; i ++)
                                 {
                                     //这一条是否添加进群组成功
                                     for (NSDictionary *item in [addVirtualGroupMemberReturn objectForKey:@"data"])
                                     {
                                         if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"] &&
                                             [[item objectForKey:@"uid"]isEqualToString:[[friendsInfo_selected objectAtIndex:i]objectForKey:@"uid"]])
                                         {
                                             NSMutableArray *array = [dict4PeersSuccess objectForKey:[item objectForKey:@"joinedGroupId"]];
                                             if (array == nil)
                                             {
                                                 array = [NSMutableArray array];
                                                 [dict4PeersSuccess setObject:array forKey:[item objectForKey:@"joinedGroupId"]];
                                             }
                                             [array addObject:[friendsInfo_selected objectAtIndex:i]];
                                             break;
                                         }
                                         else if ([[item objectForKey:@"result"]isEqualToString:@"NOT_YOUR_FRIEND"] &&
                                                  [[item objectForKey:@"uid"]isEqualToString:[[[BiChatGlobal sharedManager].array4ApproveList objectAtIndex:i]objectForKey:@"uid"]] &&
                                                  [groupId isEqualToString:[[[BiChatGlobal sharedManager].array4ApproveList objectAtIndex:i]objectForKey:@"groupId"]])
                                         {
                                             [array4PeersFail addObject:[friendsInfo_selected objectAtIndex:i]];
                                             break;
                                         }
                                         else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"])
                                         {
                                             [array4PeersBlocked addObject:[friendsInfo_selected objectAtIndex:i]];
                                             break;
                                         }
                                     }
                                 }
                                 
                                 //处理各种状态
                                 if (array4PeersFail.count > 0)
                                 {
                                     NSString *msgId = [BiChatGlobal getUuidString];
                                     NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL], @"type",
                                                                      [array4PeersFail JSONString], @"content",
                                                                      self.groupId, @"receiver",
                                                                      [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                                      [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                                      [BiChatGlobal sharedManager].uid, @"sender",
                                                                      [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                                      [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                                      [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                                      [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                                      @"1", @"isGroup",
                                                                      msgId, @"msgId",
                                                                      nil];
                                     
                                     //加入本地一条消息
                                     if (self.ownerChatWnd != nil)
                                         [self.ownerChatWnd appendMessage:sendData];
                                     else
                                         [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                                     [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                                           peerUserName:@""
                                                                           peerNickName:[groupProperty objectForKey:@"groupName"]
                                                                             peerAvatar:[groupProperty objectForKey:@"avatar"]
                                                                                message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                            messageTime:[BiChatGlobal getCurrentDateString]
                                                                                  isNew:NO
                                                                                isGroup:YES
                                                                               isPublic:NO
                                                                              createNew:YES];
                                 }
                                 
                                 //被加入的人员列表中，如果有加入其他群的情况下，需要下面的处理
                                 BOOL addToOtherGroup = NO;
                                 for (NSString *key in dict4PeersSuccess)
                                 {
                                     if (![key isEqualToString:self.groupId])
                                     {
                                         addToOtherGroup = YES;
                                         break;
                                     }
                                 }
                                 if (addToOtherGroup)
                                 {
                                     for (NSString *key in dict4PeersSuccess)
                                     {
                                         //生成这个虚拟群的群名
                                         __block NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:key];
                                         if (groupProperty == nil)
                                         {
                                             //可能是一个新的群
                                             [NetworkModule getGroupProperty:key completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                                 groupProperty = data;
                                                 //NSLog(@"通知一个新群：%@", groupProperty);
                                                 [self notifyVirtualGroupAssignMember:groupId groupProperty:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                                             }];
                                         }
                                         else
                                         {
                                             //NSLog(@"通知一个老群：%@", groupProperty);
                                             [self notifyVirtualGroupAssignMember:groupId groupProperty:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                                         }
                                     }
                                 }
                                 
                                 //修改申请列表
                                 for (NSString *uid in friends_selected)
                                 {
                                     for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                                     {
                                         if ([uid isEqualToString:[item2 objectForKey:@"uid"]] &&
                                             [[item2 objectForKey:@"groupId"]isEqualToString:self.groupId])
                                         {
                                             [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                                             break;
                                         }
                                     }
                                 }
                                 [[BiChatGlobal sharedManager]saveUserAdditionInfo];
                             }];
                         }];
                    }
                }];
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

//通知一个群，有人需要批准
- (void)notifyVirtualGroupNeedApprove:(NSString *)grouId
                        groupProperty:(NSMutableDictionary *)groupProperty
                           subGroupId:(NSString *)subGroupId
                    dict4PeersSuccess:(NSDictionary *)dict4PeersSuccess
{
    //准备数据,发送给群成员
    NSMutableArray *array4PeersNeedApprove = [dict4PeersSuccess objectForKey:subGroupId];
    NSDictionary *applyInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"", @"apply",
                               array4PeersNeedApprove, @"friends", nil];
    
    //同时开始发送一个邀请朋友的信息message,本条信息所有人都可以看到
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER], @"type",
                                     [applyInfo JSONString], @"content",
                                     self.groupId, @"receiver",
                                     [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                     [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     @"1", @"isGroup",
                                     msgId, @"msgId",
                                     nil];
    
    //发送到服务器
    [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            //加入本地一条消息
            if (self.ownerChatWnd != nil)
                [self.ownerChatWnd appendMessage:sendData];
            else
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
            
            //接下来发送一条邀请朋友的信息message，本条信息只有群主或者管理员可以收到（不显示），用于批准申请
            NSString *msgId = [BiChatGlobal getUuidString];
            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBER], @"type",
                                             [applyInfo JSONString], @"content",
                                             self.groupId, @"receiver",
                                             [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                             [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                             [BiChatGlobal sharedManager].uid, @"sender",
                                             [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                             [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                             [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                             [BiChatGlobal getCurrentDateString], @"timeStamp",
                                             @"1", @"isGroup",
                                             msgId, @"msgId",
                                             nil];

            [NetworkModule sendMessageToGroupOperator:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (success)
                {
                    //接下来将向所有的需要审批个人发送一条模拟群消息，以让用户可以和群主建立虚拟聊天
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE], @"type",
                                                     @"", @"content",
                                                     self.groupId, @"receiver",
                                                     [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                                     [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                     @"1", @"isGroup",
                                                     msgId, @"msgId",
                                                     nil];
                    for (NSDictionary *item in array4PeersNeedApprove)
                    {
                        [NetworkModule sendMessageToUser:[item objectForKey:@"uid"] message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        }];
                    }
                }
            }];
        }
    }];
}

//通知一个群，有人被拉入子群
- (void)notifyVirtualGroupAssignMember:(NSString *)groupId
                         groupProperty:(NSMutableDictionary *)groupProperty
                            subGroupId:(NSString *)subGroupId
                     dict4PeersSuccess:(NSDictionary *)dict4PeersSuccess
{
    //查找这个子群的序号
    NSInteger subGroupIndex = 0;
    for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
    {
        if ([[item objectForKey:@"groupId"]isEqualToString:subGroupId])
        {
            subGroupIndex = [[item objectForKey:@"virtualGroupNum"]integerValue];
            break;
        }
    }
    NSString *subGroupNickName = [NSString stringWithFormat:@"%@#%ld", [groupProperty objectForKey:@"groupName"], subGroupIndex + 1];
    NSDictionary *dict4Content = [NSDictionary dictionaryWithObjectsAndKeys:
                                  groupId, @"fromGroupId",
                                  subGroupId, @"groupId",
                                  subGroupNickName, @"groupNickName",
                                  [dict4PeersSuccess objectForKey:subGroupId], @"assignedMember",
                                  nil];
    
    //生成一条新消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP], @"type",
                                     [dict4Content JSONString], @"content",
                                     groupId, @"receiver",
                                     [groupProperty objectForKey:@"groupName"]==nil?@"":[groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                     [BiChatGlobal getGroupAvatar:groupProperty], @"receiverAvatar",
                                     [BiChatGlobal sharedManager].uid, @"sender",
                                     [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                     [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                     [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                     @"1", @"isGroup",
                                     msgId, @"msgId",
                                     nil];
    
    [NetworkModule sendMessageToGroup:groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            if (self.ownerChatWnd)
                [self.ownerChatWnd appendMessage:sendData];
            else
                [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                  peerUserName:@""
                                                  peerNickName:[groupProperty objectForKey:@"groupName"]
                                                    peerAvatar:[groupProperty objectForKey:@"avatar"]
                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:YES
                                                      isPublic:NO
                                                     createNew:YES];
        }
    }];
    
    if (subGroupId != groupId)
    {
        //生成一条新消息
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP], @"type",
                                         [dict4Content JSONString], @"content",
                                         subGroupId, @"receiver",
                                         subGroupNickName, @"receiverNickName",
                                         [BiChatGlobal getGroupAvatar:groupProperty], @"receiverAvatar",
                                         [BiChatGlobal sharedManager].uid, @"sender",
                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                         [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         @"1", @"isGroup",
                                         msgId, @"msgId",
                                         nil];
        
        //发送到相应群
        [NetworkModule sendMessageToGroup:subGroupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                //这个地方不能使用ownerChatWnd
                [[BiChatDataModule sharedDataModule]addChatContentWith:subGroupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:subGroupId
                                                      peerUserName:@""
                                                      peerNickName:subGroupNickName
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            else
                NSLog(@"send message failure");
        }];
    }
}

#pragma mark - 私有函数

- (BOOL)isIGroupOwner
{
    return [[BiChatGlobal sharedManager].uid isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]];
}

- (BOOL)isIAssistant
{
    for (NSString *str in [self.groupProperty objectForKey:@"assitantUid"])
    {
        if ([[BiChatGlobal sharedManager].uid isEqualToString:str])
            return YES;
    }
    return NO;
}

- (BOOL)isAssistant:(NSString *)uid
{
    for (NSString *str in [self.groupProperty objectForKey:@"assitantUid"])
    {
        if ([uid isEqualToString:str])
            return YES;
    }
    return NO;
}

- (BOOL)isVIP:(NSString *)uid
{
    for (NSString *str in [self.groupProperty objectForKey:@"vip"])
    {
        if ([uid isEqualToString:str])
            return YES;
    }
    return NO;
}

- (BOOL)isBroadcastGroup
{
    NSDictionary *subGroupInfo = nil;
    for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
    {
        if ([[item objectForKey:@"groupId"]isEqualToString:self.groupId])
        {
            subGroupInfo = item;
            break;
        }
    }
    
    return [[subGroupInfo objectForKey:@"isBroadCastGroup"]boolValue];
}

- (UIView *)createOperationPanel
{
    //是否群主
    if ([[self.groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        return nil;
    }
    
    //普通用户
    UIView *view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    
    UIButton *button4Quit = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    button4Quit.backgroundColor = [UIColor whiteColor];
    button4Quit.titleLabel.font = [UIFont systemFontOfSize:16];
    button4Quit.layer.cornerRadius = 5;
    button4Quit.clipsToBounds = YES;
    [button4Quit addTarget:self action:@selector(onButtonQuit:) forControlEvents:UIControlEventTouchUpInside];
    [button4Quit setTitle:LLSTR(@"201217") forState:UIControlStateNormal];
    [button4Quit setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [view4Panel addSubview:button4Quit];
    
    return view4Panel;
}

- (void)getGroupProperty
{
    [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for (id key in data)
                    [self.groupProperty setObject:[data objectForKey:key] forKey:key];
                
                NSString * userCount = [NSString stringWithFormat:@"%lu",[[self.groupProperty objectForKey:@"joinedGroupUserCount"]integerValue]];
                self.navigationItem.title = [LLSTR(@"201201") llReplaceWithArray:@[userCount]];
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)onButtonAdd:(id)sender
{
    //准备数据
    NSMutableArray *array4Selected = [NSMutableArray array];
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
        [array4Selected addObject:[item objectForKey:@"uid"]];
    
    //开始选择新人
    ContactListViewController *wnd = [ContactListViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.selectMode = SELECTMODE_MULTI;
    wnd.multiSelectMax = 30;
    wnd.multiSelectMaxError = LLSTR(@"301027");
    wnd.delegate = self;
    wnd.alreadySelected = array4Selected;
    wnd.defaultTitle = LLSTR(@"201001");
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

//删除
- (void)onButtonDel:(id)sender
{
    GroupMemberDeleteViewController *wnd = [GroupMemberDeleteViewController new];
    wnd.ownerChatWnd = self.ownerChatWnd;
    wnd.groupId = self.groupId;
    wnd.groupProperty = self.groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
}

//显示更多用户
- (void)onButtonShowMoreUser:(id)sender
{
    AllGroupMemberViewController *wnd = [AllGroupMemberViewController new];
    wnd.groupId = self.groupId;
    wnd.groupProperty = self.groupProperty;
    [self.navigationController pushViewController:wnd animated:YES];
}

//用户退出
- (void)onButtonQuit:(id)sender
{
    NSString *message;
    if ([[self.groupProperty objectForKey:@"payGroup"]boolValue] && ![BiChatGlobal isMeGroupOperator:self.groupProperty])
        message = LLSTR(@"204131");
    else
        message = LLSTR(@"201218");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //发送退出群聊消息message
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_QUITGROUP], @"type",
                                  @"", @"content",
                                  self.groupId, @"receiver",
                                  [BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:nil], @"receiverNickName",
                                  [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
                                  [BiChatGlobal sharedManager].uid, @"sender",
                                  [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                  [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                  [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                  [BiChatGlobal getCurrentDateString], @"timeStamp",
                                  @"1", @"isGroup",
                                  msgId, @"msgId",
                                  nil];
        
        [NetworkModule sendMessageToGroupOperator:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                //发送一个退群消息
                [self quitGroup];
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)quitGroup
{
    //send the message
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 8;
    HTONS(CommandType);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[self.groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送消息命令
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        if (isTimeOut)
        {
            NSLog(@"%@", LLSTR(@"301001"));
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    //删除本地记录
                    [[BiChatDataModule sharedDataModule]deleteChatItemInList:self.groupId];
                    [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:self.groupId];
                    //[[BiChatDataModule sharedDataModule]DeleteAllGroupPinMessage:self.groupId];
                    
                    //发送一个从通讯录里面删除群消息
                    [self removeGroupFromContactList];
                }
            }
        }
    }];
}

- (void)removeGroupFromContactList
{
    //send the message
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 24;
    HTONS(CommandType);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[self.groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送消息命令
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        //只要发送了这个命令，不管成功不成功，都要返回主界面了
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (void)onSwitchShowNickName:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:s.on], @"showNickName", nil];
    [NetworkModule setGroupPrivateProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            [self.groupProperty setObject:[NSNumber numberWithBool:s.on] forKey:@"showNickName"];
        }
        
    }];
}

- (void)onSwitchSave2Contact:(id)sender
{
    UISwitch *switch4Save2Contact = (UISwitch *)sender;
    
    //保存到通讯录或者从通讯录删除
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType;
    if (switch4Save2Contact.on) CommandType = 23;
    else CommandType = 24;
    HTONS(CommandType);
    
    
    //生成登录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加群id
    [data appendData:[self.groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送获取群成员命令
    //NSLog(@"%@", [data description]);
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            //没有成功
            NSLog(@"超期");
            switch4Save2Contact.on = !switch4Save2Contact.on;
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            
            //成功，需要重新加载一下通讯录
            if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
                [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {}];
        }
    }];
}

- (void)onSwitchMute:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    if (s.on)
    {
        [NetworkModule muteItem:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    else
    {
        [NetworkModule unMuteItem:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
}

- (void)onSwitchFold:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    if (s.on)
    {
        [NetworkModule foldItem:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    else
    {
        [NetworkModule unFoldItem:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
}

- (void)onSwitchStick:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    if (s.on)
    {
        [NetworkModule stickItem:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    else
    {
        [NetworkModule unStickItem:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
}

- (BOOL)isGroupInContactList:(NSString *)groupId
{
    //NSLog(@"%@", groupId);
    //NSLog(@"%@", [BiChatGlobal sharedManager].array4AllGroup);
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4AllGroup)
    {
        if ([[item objectForKey:@"uid"]isEqualToString:groupId])
            return YES;
    }
    return NO;
}

- (void)longPressGroupUser:(UILongPressGestureRecognizer *)longPressGest
{
//    UIView *view4Target = objc_getAssociatedObject(longPressGest, @"targetView");
//    NSDictionary *info4Target = objc_getAssociatedObject(longPressGest, @"targetData");
//
//    //显示删除按钮
//    button4RemoveGroupUser.hidden = NO;
//    objc_setAssociatedObject(button4RemoveGroupUser, @"targetData", info4Target, OBJC_ASSOCIATION_ASSIGN);
//    button4RemoveGroupUser.center = CGPointMake(view4Target.frame.origin.x + view4Target.frame.size.width - 5, view4Target.frame.origin.y + 5);
//
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    [cell.contentView addSubview:button4RemoveGroupUser];
//
//    //时钟控制删除按钮显示时间
//    [timer4HideRemoveGroupUserButton invalidate];
//    timer4HideRemoveGroupUserButton = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
//        button4RemoveGroupUser.hidden = YES;
//        [timer4HideRemoveGroupUserButton invalidate];
//        timer4HideRemoveGroupUserButton = nil;
//    }];
}

- (void)tapUserAvatar:(UITapGestureRecognizer *)tagGest
{
    NSDictionary *info4Target = objc_getAssociatedObject(tagGest, @"targetData");
    //NSLog(@"%@", info4Target);
    NSString *nickName = [[BiChatGlobal sharedManager]getFriendNickName:[info4Target objectForKey:@"uid"]];
    if (nickName.length == 0)
        nickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[info4Target objectForKey:@"uid"]
                                                            groupProperty:self.groupProperty
                                                                 nickName:[info4Target objectForKey:@"nickName"]];
    
    //进入用户信息界面
    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
    wnd.uid = [info4Target objectForKey:@"uid"];
    wnd.userName = [info4Target objectForKey:@"userName"];
    wnd.avatar = [info4Target objectForKey:@"avatar"];
    wnd.nickName = nickName;
    wnd.nickNameInGroup = [info4Target objectForKey:@"groupNickName"];
    wnd.enterWay = [info4Target objectForKey:@"source"];
    wnd.enterTime = [BiChatGlobal adjustDateString2:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[info4Target objectForKey:@"joinTime"]longLongValue]/1000]]];
    wnd.inviterId = [info4Target objectForKey:@"inviterId"];
    wnd.groupProperty = self.groupProperty;
    wnd.source = [[BiChatGlobal sharedManager]getFriendSource:[info4Target objectForKey:@"uid"]];
    if (wnd.source.length == 0)
        wnd.source = @"GROUP";
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonRemoveGroupUser:(id)sender
{
    button4RemoveGroupUser.hidden = YES;
    NSDictionary *info4Target = objc_getAssociatedObject(sender, @"targetData");
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[info4Target objectForKey:@"uid"], @"uid",
                          [info4Target objectForKey:@"nickName"], @"nickName", nil];
    NSArray *array = [NSArray arrayWithObject:dict];
    
    //发送一条消息通知有成员被移除群
    [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_KICKOUTGROUP content:[array mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            //发送删除用户的命令
            NSLog(LLSTR(@"301004"));
            [self removeGroupUser:[dict objectForKey:@"uid"]];
        }
        else
            NSLog(LLSTR(@"301001"));
    }];
}

- (void)removeGroupUser:(NSString *)uid
{
    //send the message
    short headerSize = 42 + 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 7;
    HTONS(CommandType);
    short userCount = 1;
    HTONS(userCount);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[self.groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    [data appendData:[uid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送消息命令
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        if (isTimeOut)
        {
            NSLog(LLSTR(@"301001"));
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];

            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    //删除成功,调整内部数据
                    NSMutableArray *array4UserList = [self.groupProperty objectForKey:@"groupUserList"];
                    for (int i = 0; i < array4UserList.count; i ++)
                    {
                        if ([uid isEqualToString:[[array4UserList objectAtIndex:i]objectForKey:@"uid"]])
                        {
                            [array4UserList removeObjectAtIndex:i];
                            
                            NSString * userCount = [NSString stringWithFormat:@"%lu",(long)[[self.groupProperty objectForKey:@"joinedGroupUserCount"]integerValue]];
                            self.navigationItem.title = [LLSTR(@"201201") llReplaceWithArray:@[userCount]];
                            
                            [self.tableView reloadData];
                            return ;
                        }
                    }
                }
            }
        }
    }];
}

//获取我在本群的昵称
- (NSString *)getMyNickNameInGroup
{
    if (![[self.groupProperty objectForKey:@"amISetGroupNickName"]boolValue])
        return @"";
    
    //已经设置
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [item objectForKey:@"groupNickName"];
    }
    return nil;
}

- (void)hideBigAvatar:(id)sender
{
    [image4ShowAvatar removeFromSuperview];
    [button4LocalSave removeFromSuperview];
}

- (void)onButtonSave:(id)sender
{
    //查一下本地文件是否存在
    if (image4ShowAvatar.image == nil)
    {
        //文件还没有下载成功
        [BiChatGlobal showInfo:LLSTR(@"301803") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //保存到本地相册
    UIImageWriteToSavedPhotosAlbum(image4ShowAvatar.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    WEAKSELF;

    NSString *message = @"";
    if (!error) {
        [BiChatGlobal showInfo:LLSTR(@"102205") withIcon:[UIImage imageNamed:@"icon_OK"]];
    }
    else if (error.code == -3310)
    {
        
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106203")
                                                                              message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"106204")]
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
            
        UIAlertAction * doneAct = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 8.0, *)){
                if (@available(iOS 10.0, *)){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                [alertVC dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
        UIAlertAction * cancelAct = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        [alertVC addAction:doneAct];
        [alertVC addAction:cancelAct];
        [weakSelf presentViewController:alertVC animated:YES completion:nil];

        }
    else
    {
        message = [error description];
        [BiChatGlobal showInfo:message withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }
}

- (void)sendInviteMessageToUsers:(NSArray *)contacts
{
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:self.groupId forKey:@"uid"];
    [contentDic setObject:[BiChatGlobal getGroupNickName:self.groupProperty defaultNickName:@""] forKey:@"nickName"];
    [contentDic setObject:[self.groupProperty objectForKey:@"avatar"] ? [self.groupProperty objectForKey:@"avatar"] : @"" forKey:@"avatar"];
    [contentDic setObject:@"groupCard" forKey:@"cardType"];
    [contentDic setObject:[NSString stringWithFormat:@"%@?groupId=%@&RefCode=%@&type=3",[BiChatGlobal sharedManager].download, self.groupId,[BiChatGlobal sharedManager].RefCode] forKey:@"url"];

    __block NSInteger count4Success = 0;
    __block NSInteger count4Failure = 0;
    [BiChatGlobal ShowActivityIndicator];
    for (NSString *uid in contacts)
    {
        NSDictionary *dict = [[BiChatGlobal sharedManager]getFriendInfoInContactByUid:uid];
        
        NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
        [sendDic setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CARD] forKey:@"type"];
        [sendDic setObject:[contentDic mj_JSONString] forKey:@"content"];
        [sendDic setObject:[dict objectForKey:@"uid"] forKey:@"receiver"];
        [sendDic setObject:[dict objectForKey:@"nickName"] forKey:@"receiverNickName"];
        [sendDic setObject:[dict objectForKey:@"avatar"]==nil?@"":[dict objectForKey:@"avatar"] forKey:@"receiverAvatar"];
        [sendDic setObject:[BiChatGlobal sharedManager].uid forKey:@"sender"];
        [sendDic setObject:[BiChatGlobal sharedManager].nickName forKey:@"senderNickName"];
        [sendDic setObject:[BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar forKey:@"senderAvatar"];
        [sendDic setObject:[BiChatGlobal getCurrentDateString] forKey:@"timeStamp"];
        [sendDic setObject:[BiChatGlobal getUuidString] forKey:@"msgId"];
        [sendDic setObject:[BiChatGlobal getUuidString] forKey:@"contentId"];
        [sendDic setObject: [BiChatGlobal getCurrentDateString] forKey:@"favTime"];
        
        //发给个人
        [NetworkModule sendMessageToUser:[dict objectForKey:@"uid"] message:sendDic completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                //消息放入本地
                [[BiChatDataModule sharedDataModule]setLastMessage:[dict objectForKey:@"uid"]
                                                      peerUserName:[dict objectForKey:@"userName"]
                                                      peerNickName:[dict objectForKey:@"nickName"]
                                                        peerAvatar:[dict objectForKey:@"avatar"]
                                                           message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO
                                                           isGroup:NO
                                                          isPublic:NO
                                                         createNew:YES];
                [[BiChatDataModule sharedDataModule]addChatContentWith:[dict objectForKey:@"uid"] content:sendDic];
                
                count4Success ++;
                if (count4Success + count4Failure == contacts.count)
                {
                    [BiChatGlobal HideActivityIndicator];
                    if (count4Success > 0)
                    {
                        [BiChatGlobal showInfo:LLSTR(@"301710") withIcon:[UIImage imageNamed:@"icon_OK"]];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                        [BiChatGlobal showInfo:LLSTR(@"301711") withIcon:[UIImage imageNamed:@"icon_alert"]];
                }
            } else {
                count4Failure ++;
                if (count4Success + count4Failure == contacts.count)
                {
                    [BiChatGlobal HideActivityIndicator];
                    if (count4Success > 0)
                    {
                        [BiChatGlobal showInfo:LLSTR(@"301710") withIcon:[UIImage imageNamed:@"icon_OK"]];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                        [BiChatGlobal showInfo:LLSTR(@"301711") withIcon:[UIImage imageNamed:@"icon_alert"]];
                }
            }
        }];
    }
}


@end
