//
//  VirtualGroupListViewController.m
//  BiChat
//
//  Created by Admin on 2018/5/16.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatDataModule.h"
#import "VirtualGroupListViewController.h"
#import "VirtualGroupSetupViewController.h"
#import "NetworkModule.h"
#import "ChatViewController.h"

@interface VirtualGroupListViewController ()

@end

@implementation VirtualGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [self.groupProperty objectForKey:@"groupName"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    
    //虚拟群的groupProperty需要转化一下
    NSMutableDictionary *gp = [[BiChatDataModule sharedDataModule]getGroupProperty:[[[self.groupProperty objectForKey:@"virtualGroupSubList"]firstObject]objectForKey:@"groupId"]];
    if (gp)
        self.groupProperty = gp;

    //刷新界面
    [self refreshGUI];
    if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"201505") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSetup:)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BiChatGlobal sharedManager].VIRTUALGroupChatList = self;
    
    //需要获取一下0群的groupId
    NSString *groupId = [[[self.groupProperty objectForKey:@"virtualGroupSubList"]objectAtIndex:0]objectForKey:@"groupId"];
    
    //错误处理
    if (groupId.length == 0)
        groupId = self.groupId;
    
    //需要获取一下群属性
    [self.tableView reloadData];
    [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            self.groupProperty = data;
            self.navigationItem.title = [self.groupProperty objectForKey:@"groupName"];
            [self refreshGUI];
            if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"201505") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSetup:)];
        }
        else if (array4VirtualGroupList.count == 0)
            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal sharedManager].VIRTUALGroupChatList = nil;
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
    if (self.vituralList.count > 0) {
        return self.vituralList.count;
    }
    return array4VirtualGroupList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.vituralList.count > 0) {
        return 50;
    }
    
    //如果我是管理员或群主并且是管理群
    if ([BiChatGlobal isMeGroupOperator:self.groupProperty] && indexPath.row == 0)
        return 64;
    
    //如果我是管理员或群主并且是广播群,并且广播群是打开的
    BOOL broadcastIsOn = YES;
    if (![[self.groupProperty objectForKey:@"enableBroadCastGroup"]boolValue])
        broadcastIsOn = NO;
    for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
    {
        if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
            broadcastIsOn = [[item objectForKey:@"enableBroadCast"]boolValue];
    }

    if ([BiChatGlobal isMeGroupOperator:self.groupProperty] && indexPath.row == 1 && broadcastIsOn)
        return 64;
    
    //找出这个聊天的具体信息
    NSMutableArray *array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    NSMutableDictionary *dict4ChatItem = nil;
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        //处理不同的版本
        if ([[array4VirtualGroupList objectAtIndex:indexPath.row]isKindOfClass:[NSDictionary class]])
        {
            if ([[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]])
            {
                dict4ChatItem = [array4ChatList objectAtIndex:i];
                break;
            }
        }
    }
    if (dict4ChatItem == nil)
        return 0;
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    //外部指定虚拟子群列表
    if (self.vituralList.count > 0) {
        
        //虚拟群标志
        NSDictionary *dic = self.vituralList[indexPath.row];
        NSString *subGroupName;
        if ([[dic objectForKey:@"groupNickName"]length] > 0)
            subGroupName = [dic objectForKey:@"groupNickName"];
        else
            subGroupName = [NSString stringWithFormat:@"%zd", [[dic objectForKey:@"virtualGroupNum"]integerValue]];
        NSInteger groupUserCount = [[dic objectForKey:@"groupUserCount"]integerValue];

        //昵称
        UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
        label4Name.text = [NSString stringWithFormat:@"#%@",[dic objectForKey:@"virtualGroupNum"]];
        if ([[dic objectForKey:@"virtualGroupNum"] integerValue] == 0) {
            label4Name.text = LLSTR(@"201503");
            UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7, 36, 36)];
            image4Avatar.image = [UIImage imageNamed:@"vgroup_manage"];
        }
        else
        {
            UIView *view4Avatar = [BiChatGlobal getVirtualGroupAvatarWnd:self.groupId
                                                                nickName:subGroupName
                                                          groupUserCount:groupUserCount
                                                                   frame:CGRectMake(15, 7, 36, 36)];
            [cell.contentView addSubview:view4Avatar];
        }
        NSString *groupName = [dic objectForKey:@"groupNickName"];
        if (groupName.length > 0) {
            label4Name.text = groupName;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.contentView addSubview:label4Name];
        
        return cell;
    }
    
    //如果我是管理员或群主并且是广播群,并且广播群是打开的
    BOOL broadcastIsOn = YES;
    if (![[self.groupProperty objectForKey:@"enableBroadCastGroup"]boolValue])
        broadcastIsOn = NO;
    for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
    {
        if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
            broadcastIsOn = [[item objectForKey:@"enableBroadCast"]boolValue];
    }
    
    //找出这个聊天的具体信息
    NSMutableArray *array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    NSMutableDictionary *dict4ChatItem = nil;
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        //处理不同的版本
        if ([[array4VirtualGroupList objectAtIndex:indexPath.row]isKindOfClass:[NSDictionary class]])
        {
            if ([[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]])
            {
                dict4ChatItem = [array4ChatList objectAtIndex:i];
                break;
            }
        }
    }
    
    if (indexPath.row == 1 &&!([BiChatGlobal isMeGroupOperator:self.groupProperty] && broadcastIsOn) && dict4ChatItem == nil)
        return cell;
    
    //有没有消息在里面
    if (dict4ChatItem == nil && (![BiChatGlobal isMeGroupOperator:self.groupProperty] || indexPath.row > 1))
        return cell;
    
    // Configure the cell...
    //最后消息日期
    CGRect rect4LastMessageTime = CGRectZero;
    if ([[dict4ChatItem objectForKey:@"lastMessageTime"]length] > 0)
    {
        NSString *str = [BiChatGlobal adjustDateString:[dict4ChatItem objectForKey:@"lastMessageTime"]];
        rect4LastMessageTime = [str boundingRectWithSize:CGSizeMake(90, MAXFLOAT)
                                                 options:0
                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}
                                                 context:nil];
        
        UILabel *label4LastMessageTime = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - rect4LastMessageTime.size.width, 12.5, rect4LastMessageTime.size.width, 12)];
        label4LastMessageTime.text = str;
        label4LastMessageTime.font = [UIFont systemFontOfSize:11];
        label4LastMessageTime.textAlignment = NSTextAlignmentRight;
        label4LastMessageTime.textColor = THEME_GRAY;
        label4LastMessageTime.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4LastMessageTime];
    }

    //昵称
    UILabel *label4UserName = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, self.view.frame.size.width - rect4LastMessageTime.size.width, 20)];
    if (indexPath.row == 0)
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(13, 7, 50, 50)];
        image4Avatar.image = [UIImage imageNamed:@"vgroup_manage"];
        [cell.contentView addSubview:image4Avatar];
        label4UserName.text = LLSTR(@"201503");
    }
    else if ([[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"isBroadCastGroup"]boolValue])
    {
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(13, 7, 50, 50)];
        image4Avatar.image = [UIImage imageNamed:@"vgroup_broadcast"];
        [cell.contentView addSubview:image4Avatar];
        label4UserName.text = LLSTR(@"201504");
    }
    else
    {
        NSString *subGroupName;
        if ([[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"]length] > 0)
            subGroupName = [[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"];
        else
            subGroupName = [NSString stringWithFormat:@"%zd", [[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"virtualGroupNum"]integerValue]];

        NSInteger groupUserCount = [[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupUserCount"]integerValue];
        UIView *view4Avatar = [BiChatGlobal getVirtualGroupAvatarWnd:self.groupId
                                                            nickName:subGroupName
                                                      groupUserCount:groupUserCount
                                                               width:50 height:50];
        view4Avatar.center = CGPointMake(38, 32);
        [cell.contentView addSubview:view4Avatar];
        label4UserName.text = [NSString stringWithFormat:@"#%@", subGroupName];
        
        //看看这个群有几个图标
        NSArray *array4GroupFlag = [[BiChatGlobal sharedManager]getGroupFlag:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]];
        
        //计算群昵称的空间大小
        CGRect rect4NickName = [label4UserName.text  boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 72 - 5 - array4GroupFlag.count * 28 - rect4LastMessageTime.size.width, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                 context:nil];
        label4UserName.frame = CGRectMake(72, 11, rect4NickName.size.width, 20);
        
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
    label4UserName.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4UserName];
    
    if ([[BiChatGlobal sharedManager]isFriendInMuteList:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]])
    {
        UIImageView *image4Silence = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"silent_gray"]];
        image4Silence.center = CGPointMake(self.view.frame.size.width - 18, 43);
        [cell.contentView addSubview:image4Silence];
        
        if ([[dict4ChatItem objectForKey:@"newMessageCount"]integerValue] > 0)
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
    else
    {
        //消息条数
        if ([[dict4ChatItem objectForKey:@"newMessageCount"]integerValue] > 0)
        {
            NSString *str4NewMessageCount = [NSString stringWithFormat:@"%@", [dict4ChatItem objectForKey:@"newMessageCount"]];
            CGRect rect = [str4NewMessageCount boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                                            context:nil];
            if (rect.size.width < rect.size.height) rect.size.width = rect.size.height;
            
            UIImageView *image4RedBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 4, rect.size.height + 4)];
            image4RedBk.image = [UIImage imageNamed:@"red"];
            image4RedBk.center = CGPointMake(58, 15.5);
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
            label4NewMessageCount.center = CGPointMake(58, 15);
            [cell.contentView addSubview:label4NewMessageCount];
        }
    }
    
    //最后消息
    UILabel *label4LastMessage = [[UILabel alloc]initWithFrame:CGRectMake(72, 36, self.view.frame.size.width - 100, 15)];
    if (![[BiChatGlobal sharedManager]isFriendInMuteList:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]] ||
        [[dict4ChatItem objectForKey:@"newMessageCount"]integerValue] == 0)
        label4LastMessage.text = [dict4ChatItem objectForKey:@"lastMessage"];
    else
        label4LastMessage.text = [LLSTR(@"101146") llReplaceWithArray:@[
                                  [NSString stringWithFormat:@"%@",[dict4ChatItem objectForKey:@"newMessageCount"]],
                                  [dict4ChatItem objectForKey:@"lastMessage"]]];
    
    label4LastMessage.font = [UIFont systemFontOfSize:13];
    label4LastMessage.textColor = THEME_GRAY;
    [cell.contentView addSubview:label4LastMessage];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //找出这个聊天的具体信息
    NSMutableArray *array4ChatList = [[BiChatDataModule sharedDataModule]getChatListInfo];
    NSMutableDictionary *dict4ChatItem = nil;
    for (int i = 0; i < array4ChatList.count; i ++)
    {
        //处理不同的版本
        if ([[array4VirtualGroupList objectAtIndex:indexPath.row]isKindOfClass:[NSDictionary class]])
        {
            if ([[[array4ChatList objectAtIndex:i]objectForKey:@"peerUid"]isEqualToString:[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"]])
            {
                dict4ChatItem = [array4ChatList objectAtIndex:i];
                break;
            }
        }
    }
    
    if (self.vituralList.count > 0) {
        NSDictionary *vitralDic = self.vituralList[indexPath.row];
        for (NSMutableDictionary *dic in array4ChatList) {
            if ([dic isKindOfClass:[NSDictionary class]] && [[dic objectForKey:@"peerUid"] isEqualToString:[vitralDic objectForKey:@"virtualGroupId"]]) {
                dict4ChatItem = dic;
            }
        }
        //进入子群聊天界面
        ChatViewController *wnd = [ChatViewController new];
        wnd.peerUid = [vitralDic objectForKey:@"groupId"];
        wnd.peerAvatar = [vitralDic objectForKey:@"avatar"];
        NSString *groupName = [NSString stringWithFormat:@"#%@",[vitralDic objectForKey:@"virtualGroupNum"]];
        if ([[vitralDic objectForKey:@"virtualGroupNum"] integerValue] == 0) {
            groupName = LLSTR(@"201503");
        }
        NSString *vitName = [vitralDic objectForKey:@"groupNickName"];
        if (vitName.length > 0) {
            groupName = [vitralDic objectForKey:@"groupNickName"];
        }
        wnd.peerNickName = groupName;
        wnd.peerUserName = @"";
        wnd.isGroup = YES;
        wnd.newMessageCount = [[dict4ChatItem objectForKey:@"newMessageCount"]integerValue];
        [self.navigationController pushViewController:wnd animated:YES];
        
        //清楚这个聊天的新消息条数
        [[BiChatDataModule sharedDataModule]clearNewMessageCountWith:[dict4ChatItem objectForKey:@"peerUid"]];
        return;
    }
    
    if ([[array4VirtualGroupList objectAtIndex:indexPath.row]isKindOfClass:[NSDictionary class]])
    {
        //进入子群聊天界面
        ChatViewController *wnd = [ChatViewController new];
        wnd.peerUid = [[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupId"];
        wnd.peerAvatar = [self.groupProperty objectForKey:@"avatar"];
        if (indexPath.row == 0)
            wnd.peerNickName = [NSString stringWithFormat:@"%@%@", [self.groupProperty objectForKey:@"groupName"],LLSTR(@"201503")];
        else if ([[[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"]length] > 0)
            wnd.peerNickName = [NSString stringWithFormat:@"%@#%@", [self.groupProperty objectForKey:@"groupName"], [[array4VirtualGroupList objectAtIndex:indexPath.row]objectForKey:@"groupNickName"]];
        else
            wnd.peerNickName = [NSString stringWithFormat:@"%@#%ld", [self.groupProperty objectForKey:@"groupName"], indexPath.row];
        wnd.peerUserName = @"";
        wnd.isGroup = YES;
        wnd.newMessageCount = [[dict4ChatItem objectForKey:@"newMessageCount"]integerValue];
        [self.navigationController pushViewController:wnd animated:YES];
        //清楚这个聊天的新消息条数
        [[BiChatDataModule sharedDataModule]clearNewMessageCountWith:[dict4ChatItem objectForKey:@"peerUid"]];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *item = [array4VirtualGroupList objectAtIndex:indexPath.row];
    
    //设置静音按钮
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101114") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //事件
        [NetworkModule muteItem:[item objectForKey:@"groupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                [self.tableView reloadData];
            }
            
        }];
        
    }];
    
    //取消设置静音按钮
    UITableViewRowAction *unMuteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"101118") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //事件
        [NetworkModule unMuteItem:[item objectForKey:@"groupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            if (success)
            {
                [self.tableView reloadData];
            }
            
        }];
    }];
    
    //删除按钮
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"101018") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //删除后台数据
        [[BiChatDataModule sharedDataModule]deleteChatItemInList:[item objectForKey:@"groupId"]];
        [[BiChatDataModule sharedDataModule]deleteAllChatContentWith:[item objectForKey:@"groupId"]];
        [tableView reloadData];
    }];
    
    muteAction.backgroundColor = THEME_GREEN;
    unMuteAction.backgroundColor = THEME_GREEN;
    
    if (indexPath.row == 0)
        return @[[[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"groupId"]]?unMuteAction:muteAction];
    else if (indexPath.row == 1)
    {
        //如果我是管理员或群主并且是广播群,并且广播群是打开的
        BOOL broadcastIsOn = YES;
        if (![[self.groupProperty objectForKey:@"enableBroadCastGroup"]boolValue])
            broadcastIsOn = NO;
        for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
                broadcastIsOn = [[item objectForKey:@"enableBroadCast"]boolValue];
        }
        if (broadcastIsOn)
            return @[[[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"groupId"]]?unMuteAction:muteAction];
        else
            return @[[[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"groupId"]]?unMuteAction:muteAction, deleteAction];
    }
    else
        return @[[[BiChatGlobal sharedManager]isFriendInMuteList:[item objectForKey:@"groupId"]]?unMuteAction:muteAction, deleteAction];
}


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

- (void)onButtonSetup:(id)sender
{
    if ([[self.groupProperty objectForKey:@"isMainGroup"]boolValue] == YES)
    {
        VirtualGroupSetupViewController *wnd = [[VirtualGroupSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else
    {
        //获取主群id
        [BiChatGlobal ShowActivityIndicator];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [NetworkModule getMainGroupIdByVirtualGroup:[self.groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            if (success)
            {
                NSString *mainGroupId = [data objectForKey:@"mainGroupId"];
                NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:mainGroupId];
                if (groupProperty == nil)
                {
                    [NetworkModule getGroupProperty:mainGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        self.groupProperty = data;
                        self.groupId = mainGroupId;
                        VirtualGroupSetupViewController *wnd = [[VirtualGroupSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
                        wnd.groupId = self.groupId;
                        wnd.groupProperty = self.groupProperty;
                        [self.navigationController pushViewController:wnd animated:YES];
                    }];
                }
                else
                {
                    self.groupProperty = groupProperty;
                    self.groupId = mainGroupId;
                    VirtualGroupSetupViewController *wnd = [[VirtualGroupSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
                    wnd.groupId = self.groupId;
                    wnd.groupProperty = self.groupProperty;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION  enableClick:YES];
        }];
    }
}

- (void)refreshGUI
{
    [self performSelectorOnMainThread:@selector(refreshGUIInternal) withObject:nil waitUntilDone:NO];
}

- (void)refreshGUIInternal
{
    array4VirtualGroupList = [self.groupProperty objectForKey:@"virtualGroupSubList"];
    [array4VirtualGroupList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        if ([[obj1 objectForKey:@"virtualGroupNum"]integerValue] == 0)
            return NSOrderedAscending;
        else if ([[obj2 objectForKey:@"virtualGroupNum"]integerValue] == 0)
            return NSOrderedDescending;
        else if ([[obj1 objectForKey:@"isBroadCastGroup"]boolValue])
            return NSOrderedAscending;
        else if ([[obj2 objectForKey:@"isBroadCastGroup"]boolValue])
            return NSOrderedDescending;
        else if ([[obj1 objectForKey:@"virtualGroupNum"]integerValue] > [[obj2 objectForKey:@"virtualGroupNum"]integerValue])
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    [self.tableView reloadData];
}

@end
