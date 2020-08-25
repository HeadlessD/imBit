//
//  GroupApproveViewController.m
//  BiChat
//
//  Created by Admin on 2018/5/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "GroupApproveViewController.h"
#import "UserDetailViewController.h"
#import "pinyin.h"
#import "JSONKit.h"
#import "MessageHelper.h"

@interface GroupApproveViewController ()

@end

@implementation GroupApproveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201311");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    friends_selected = [NSMutableArray array];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //获取群审批列表
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getGroupApproveList:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        NSLog(@"1-%@", data);
        NSLog(@"2-%@", [BiChatGlobal sharedManager].array4ApproveList);
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //要根据获取到的数据来调整系统审批列表
            NSMutableArray *array4Delete = [NSMutableArray array];
            for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
            {
                //非本群数据，不用处理
                if (![[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                    continue;
                
                //查找本群的这条入群审批
                BOOL found = NO;
                for (NSDictionary *item2 in [data objectForKey:@"data"])
                {
                    if ([[item objectForKey:@"groupId"]isEqualToString:self.groupId] &&
                        [[item objectForKey:@"uid"]isEqualToString:[item2 objectForKey:@"uid"]])
                    {
                        found = YES;
                        break;
                    }
                }
                
                //没有找到，需要删除这个条目
                if (!found)
                    [array4Delete addObject:item];
            }
            
            [[BiChatGlobal sharedManager].array4ApproveList removeObjectsInArray:array4Delete];
            [self freshData];
            
            //清除聊天界面的“新的入群申请标志”
            NSMutableArray *array = [[BiChatDataModule sharedDataModule]getChatListInfo];
            for (NSMutableDictionary *item in array)
            {
                if (self.groupId == nil ||
                    [[item objectForKey:@"peerUid"]isEqualToString:self.groupId])
                    [[BiChatDataModule sharedDataModule]clearNewApplyGroup:[item objectForKey:@"peerUid"]];
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301745") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return array4AllApply.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[array4AllApply objectAtIndex:section]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    view4Header.backgroundColor = THEME_TABLEBK;
    
    //有入群方式
    if ([[[[array4AllApply objectAtIndex:section]firstObject]objectForKey:@"source"]length] > 0)
    {
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, self.view.frame.size.width - 30, 38)];
        label4Title.text = [BiChatGlobal getSourceString:[[[array4AllApply objectAtIndex:section]firstObject]objectForKey:@"source"]];
        label4Title.font = [UIFont systemFontOfSize:16];
        [view4Header addSubview:label4Title];
    }
    else
    {
        //title
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, self.view.frame.size.width - 30, 20)];
        label4Title.text = [LLSTR(@"201065") llReplaceWithArray:@[ [[[array4AllApply objectAtIndex:section]firstObject]objectForKey:@"senderNickName"]]];
        label4Title.font = [UIFont systemFontOfSize:16];
        [view4Header addSubview:label4Title];
        
        //subTitle
        UILabel *label4SubTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 25, self.view.frame.size.width - 30, 20)];
        label4SubTitle.text = [[[array4AllApply objectAtIndex:section]firstObject]objectForKey:@"apply"];
        if (label4SubTitle.text.length == 0)
            label4SubTitle.text = LLSTR(@"201066");
        label4SubTitle.textColor = THEME_GRAY;
        label4SubTitle.font = [UIFont systemFontOfSize:13];
        [view4Header addSubview:label4SubTitle];
    }

    return view4Header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    NSDictionary *item = [[array4AllApply objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    
    // Configure the cell...
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"uid"]
                                            nickName:[item objectForKey:@"nickName"]
                                              avatar:[item objectForKey:@"avatar"]
                                               frame:CGRectMake(15, 7, 36, 36)];
    [cell.contentView addSubview:view4Avatar];
    
    UIButton *button4UserDetail = [[UIButton alloc]initWithFrame:view4Avatar.frame];
    [button4UserDetail addTarget:self action:@selector(onButtonUserDetail:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(button4UserDetail, @"applyInfo", item, OBJC_ASSOCIATION_ASSIGN);
    [cell.contentView addSubview:button4UserDetail];
    
    if ([[item objectForKey:@"source"]length] > 0 &&
        [[item objectForKey:@"apply"]isKindOfClass:[NSString class]] &&
        [[item objectForKey:@"apply"]length] > 0)
    {
        UILabel *label4Nickname = [[UILabel alloc]initWithFrame:CGRectMake(60, 7, self.view.frame.size.width - 110, 20)];
        label4Nickname.text = [item objectForKey:@"nickName"];
        label4Nickname.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Nickname];
        
        UILabel *label4Reason = [[UILabel alloc]initWithFrame:CGRectMake(60, 27, self.view.frame.size.width - 110, 16)];
        label4Reason.text = [item objectForKey:@"apply"];
        label4Reason.font = [UIFont systemFontOfSize:13];
        label4Reason.textColor = THEME_GRAY;
        [cell.contentView addSubview:label4Reason];
    }
    else
    {
        UILabel *label4Nickname = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 100, 50)];
        label4Nickname.text = [item objectForKey:@"nickName"];
        label4Nickname.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:label4Nickname];
    }
    
    //是否有效
    if ([self checkBlockStatus:[item objectForKey:@"uid"]])
    {
        UILabel *label4BlockStatus = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 0, 85, 50)];
        label4BlockStatus.text = LLSTR(@"201067");
        label4BlockStatus.textColor = [UIColor redColor];
        label4BlockStatus.textAlignment = NSTextAlignmentRight;
        label4BlockStatus.font = [UIFont systemFontOfSize:14];
        label4BlockStatus.numberOfLines = 0;
        [cell.contentView addSubview:label4BlockStatus];
    }
    else
    {
        //是否已经选择
        UIImageView *image4Check = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];
        if (![self isSelected:[[[array4AllApply objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"uid"]
                      groupId:[[[array4AllApply objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"groupId"]])
            image4Check.image = [UIImage imageNamed:@"CellNotSelected"];
        image4Check.center = CGPointMake(self.view.frame.size.width - 30, 25);
        [cell.contentView addSubview:image4Check];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *uid = [[[array4AllApply objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"uid"];
    NSString *groupId = [[[array4AllApply objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"groupId"];
    
    //检查是否已经被屏蔽
    if ([self checkBlockStatus:uid])
        return;
    
    //选择操作
    if ([self isSelected:uid groupId:groupId])
        [self unSelect:uid groupId:groupId];
    else
        [self select:uid groupId:groupId];
    [self.tableView reloadData];
    
    //是否有选择
    if (friends_selected.count > 0)
    {
        button4Reject.enabled = YES;
        button4Agree.enabled = YES;
    }
    else
    {
        button4Reject.enabled = NO;
        button4Agree.enabled = NO;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //删除按钮
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"101018") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        NSDictionary *item = [[array4AllApply objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
        [[BiChatGlobal sharedManager].array4ApproveList removeObject:item];
        [self freshData];
        [self.tableView reloadData];
        
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

#pragma mark - 私有函数

- (void)freshData
{
    array4AllApply = [NSMutableArray array];
    
    //先整理一下数据
    NSMutableArray *array4Delete = [NSMutableArray array];
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        if ([[item objectForKey:@"groupNickName"]length] == 0)
        {
            [array4Delete addObject:item];
        }
    }
    [[BiChatGlobal sharedManager].array4ApproveList removeObjectsInArray:array4Delete];
    [[BiChatGlobal sharedManager]saveUserAdditionInfo];
    
    //整理数据
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        //是否显示特定群的申请
        if (self.groupId.length > 0 && ![self.groupId isEqualToString:[item objectForKey:@"groupId"]])
            continue;
        
        //本分类是否已经存在
        //NSLog(@"%@", item);
        BOOL found = NO;
        for (int i = 0; i < array4AllApply.count; i ++)
        {
            if ([[item objectForKey:@"source"]length] > 0)
            {
                if ([[item objectForKey:@"source"]isEqualToString:[[[array4AllApply objectAtIndex:i]firstObject]objectForKey:@"source"]])
                {
                    found = YES;
                    [[array4AllApply objectAtIndex:i]addObject:[NSMutableDictionary dictionaryWithDictionary:item]];
                    break;
                }
            }
            else if ([[item objectForKey:@"apply"]isEqualToString:[[[array4AllApply objectAtIndex:i]firstObject]objectForKey:@"apply"]] &&
                [[item objectForKey:@"sender"]isEqualToString:[[[array4AllApply objectAtIndex:i]firstObject]objectForKey:@"sender"]])
            {
                found = YES;
                [[array4AllApply objectAtIndex:i]addObject:[NSMutableDictionary dictionaryWithDictionary:item]];
                break;
            }
        }
        
        if (!found)
        {
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:[NSMutableDictionary dictionaryWithDictionary:item]];
            [array4AllApply addObject:array];
        }
    }
    
    //获取本群的block列表
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:self.groupId];
    if ([[groupProperty objectForKey:@"virtualGroupId"]length] == 0)
    {
        array4Block = [groupProperty objectForKey:@"groupBlockUserLevelTwo"];
        [self.tableView reloadData];
        [self createAdditionalView];
    }
    else
    {
        [NetworkModule getMainGroupIdByVirtualGroup:[groupProperty objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            NSString *mainGroupId = [data objectForKey:@"mainGroupId"];
            NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:mainGroupId];
            if (groupProperty == nil)
            {
                [NetworkModule getGroupProperty:mainGroupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    array4Block = [data objectForKey:@"groupBlockUserLevelTwo"];
                    [self.tableView reloadData];
                    [self createAdditionalView];
                }];
            }
            else
            {
                array4Block = [groupProperty objectForKey:@"groupBlockUserLevelTwo"];
                [self.tableView reloadData];
                [self createAdditionalView];
            }
        }];
    }
}

- (void)createAdditionalView
{
    if (array4AllApply.count > 0)
    {
        self.tableView.backgroundView = nil;
        
        //footer
        UIView *view4TableFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        self.tableView.tableFooterView = view4TableFooter;
        
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [view4TableFooter addSubview:view4Seperator];
        
        button4Reject = [[UIButton alloc]initWithFrame:CGRectMake(15, 30, self.view.frame.size.width / 2 - 22.5, 40)];
        button4Reject.titleLabel.font = [UIFont systemFontOfSize:16];
        button4Reject.backgroundColor = THEME_RED;
        button4Reject.layer.cornerRadius = 5;
        button4Reject.clipsToBounds = YES;
        [button4Reject addTarget:self action:@selector(onButtonReject:) forControlEvents:UIControlEventTouchUpInside];
        [button4Reject setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateDisabled];
        [button4Reject setTitle:LLSTR(@"201068") forState:UIControlStateNormal];
        button4Reject.enabled = NO;
        [view4TableFooter addSubview:button4Reject];
        
        button4Agree = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 7.5, 30, self.view.frame.size.width / 2 - 22.5, 40)];
        button4Agree.titleLabel.font = [UIFont systemFontOfSize:16];
        button4Agree.backgroundColor = THEME_COLOR;
        button4Agree.layer.cornerRadius = 5;
        button4Agree.clipsToBounds = YES;
        [button4Agree addTarget:self action:@selector(onButtonAgree:) forControlEvents:UIControlEventTouchUpInside];
        [button4Agree setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateDisabled];
        [button4Agree setTitle:LLSTR(@"201069") forState:UIControlStateNormal];
        button4Agree.enabled = NO;
        [view4TableFooter addSubview:button4Agree];
    }
    else
    {
        UIView *view4Bk = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        UILabel *label4EmptyHint = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
        label4EmptyHint.text = LLSTR(@"203005");
        label4EmptyHint.textColor = THEME_GRAY;
        label4EmptyHint.textAlignment = NSTextAlignmentCenter;
        label4EmptyHint.font = [UIFont systemFontOfSize:16];
        [view4Bk addSubview:label4EmptyHint];
        self.tableView.backgroundView = view4Bk;
        self.tableView.tableFooterView = [UIView new];
    }
}

- (BOOL)checkBlockStatus:(NSString *)uid
{
    for (NSDictionary *item in array4Block)
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]])
            return YES;
    }
    return NO;
}

- (void)select:(NSString *)uid groupId:(NSString *)groupId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", uid, groupId];
    for (NSString *item in friends_selected)
    {
        if ([item isEqualToString:key])
            return;
    }
    [friends_selected addObject:key];
}

- (void)unSelect:(NSString *)uid groupId:(NSString *)groupId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", uid, groupId];
    for (NSString *item in friends_selected)
    {
        if ([item isEqualToString:key])
        {
            [friends_selected removeObject:key];
            return;
        }
    }
}

- (BOOL)isSelected:(NSString *)uid groupId:(NSString *)groupId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", uid, groupId];
    for (NSString *item in friends_selected)
    {
        if ([item isEqualToString:key])
            return YES;
    }
    return NO;
}

- (void)onButtonReject:(id)sender
{
    for (int j = 0; j < array4AllApply.count; j ++)
    {
        //查一下本群选择了多少人
        NSString *groupId = [[[array4AllApply objectAtIndex:j]firstObject]objectForKey:@"groupId"];
        NSString *groupNickName = [[[array4AllApply objectAtIndex:j]firstObject]objectForKey:@"groupNickName"];
        NSString *groupAvatar = [[[array4AllApply objectAtIndex:j]firstObject]objectForKey:@"groupAvatar"];
        NSMutableArray *group_friends_selected = [NSMutableArray array];
        for (NSDictionary *item in [array4AllApply objectAtIndex:j])
        {
            if ([self isSelected:[item objectForKey:@"uid"] groupId:groupId])
                [group_friends_selected addObject:[item objectForKey:@"uid"]];
        }
        if (group_friends_selected.count == 0)
            continue;
        
        [self rejectGroupApplication:groupId
                       groupNickName:groupNickName
                         groupAvatar:groupAvatar
              group_friends_selected:group_friends_selected];
    }
    
    //刷新本界面
    [friends_selected removeAllObjects];
    [self freshData];
    [[BiChatGlobal sharedManager]saveUserInfo];
}

- (void)rejectGroupApplication:(NSString *)groupId
                 groupNickName:(NSString *)groupNickName
                   groupAvatar:(NSString *)groupAvatar
        group_friends_selected:(NSMutableArray *)group_friends_selected
{
    //开始拒绝
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule rejectGroupApplication:groupId userList:group_friends_selected completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            //发送消息到各个用户的客服群（模拟发送，使用sendMessageToUser）
            for (NSString * uid in group_friends_selected)
            {
                //查一下这个用户是否有审批群
                for (NSMutableDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
                {
                    if ([[item objectForKey:@"uid"]isEqualToString:uid] &&
                        [[item objectForKey:@"groupId"]isEqualToString:groupId])
                    {
                        //发一条消息给这个用户
                        NSMutableArray *array4Display = [NSMutableArray array];
                        [array4Display addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [item objectForKey:@"uid"], @"uid",
                                                  [item objectForKey:@"nickName"], @"nickName",
                                                  [item objectForKey:@"avatar"]==nil?@"":[item objectForKey:@"avatar"], @"avatar",
                                                  nil]];
                        
                        //生成一个新的消息
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
                        NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                        [dict mj_JSONString], @"content",
                                                        [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER], @"type",
                                                        groupId , @"receiver",
                                                        [item objectForKey:@"groupNickName"], @"receiverNickName",
                                                        [item objectForKey:@"groupAvatar"], @"receiverAvatar",
                                                        [BiChatGlobal sharedManager].uid, @"sender",
                                                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                        [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                        msgId, @"msgId",
                                                        @"1", @"isGroup",
                                                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                        nil];
                        [NetworkModule sendMessageToUser:[item objectForKey:@"uid"] message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                            if (success)
                            {
                                if ([[item objectForKey:@"approveGroupId"]length] > 0)
                                {
                                    [[BiChatDataModule sharedDataModule]addChatContentWith:[item objectForKey:@"approveGroupId"] content:message];
                                    [[BiChatDataModule sharedDataModule]setLastMessage:[item objectForKey:@"approveGroupId"]
                                                                          peerUserName:@""
                                                                          peerNickName:[item objectForKey:@"senderNickName"]
                                                                            peerAvatar:[item objectForKey:@"senderAvatar"]
                                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                                 isNew:NO isGroup:YES isPublic:NO createNew:YES];
                                }
                            }
                        }];
                    }
                }
            }
            
            //NSLog(@"%@", data);
            //NSLog(@"%@", [BiChatGlobal sharedManager].array4ApproveList);
            self.navigationItem.rightBarButtonItem = nil;
            
            //生成可以显示的批准列表
            NSMutableArray *array4Display = [NSMutableArray array];
            for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
            {
                for (NSDictionary *friend in [data objectForKey:@"data"])
                {
                    if ([[friend objectForKey:@"uid"]isEqualToString:[item objectForKey:@"uid"]] &&
                        [[item objectForKey:@"groupId"]isEqualToString:groupId])
                    {
                        if ([[friend objectForKey:@"result"]isEqualToString:@"SUCCESS"])
                            [array4Display addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [item objectForKey:@"uid"], @"uid",
                                                      [item objectForKey:@"nickName"]==nil?@"":[item objectForKey:@"nickName"], @"nickName",
                                                      [item objectForKey:@"avatar"]==nil?@"":[item objectForKey:@"avatar"], @"avatar",
                                                      nil]];
                    }
                }
            }
            
            //生成一个新的消息
            NSString *msgId = [BiChatGlobal getUuidString];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
            NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [dict mj_JSONString], @"content",
                                            [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER], @"type",
                                            groupId , @"receiver",
                                            groupNickName, @"receiverNickName",
                                            groupAvatar, @"receiverAvatar",
                                            [BiChatGlobal sharedManager].uid, @"sender",
                                            [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                            [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                            [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                            msgId, @"msgId",
                                            @"1", @"isGroup",
                                            [BiChatGlobal getCurrentDateString], @"timeStamp",
                                            nil];
            //将本消息发送到群里面
            [NetworkModule sendMessageToGroup:groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                [BiChatGlobal HideActivityIndicator];
                if (success)
                {
                    [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:message];
                    [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                          peerUserName:@""
                                                          peerNickName:groupNickName
                                                            peerAvatar:groupAvatar
                                                               message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                           messageTime:@""
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                }
            }];
            
            //修改全局待批准列表
            for (NSString *str in group_friends_selected)
            {
                for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
                {
                    if ([[item objectForKey:@"uid"]isEqualToString:str] &&
                        [[item objectForKey:@"groupId"]isEqualToString:groupId])
                    {
                        [[BiChatGlobal sharedManager].array4ApproveList removeObject:item];
                        break;
                    }
                }
            }
            [[BiChatGlobal sharedManager]saveUserAdditionInfo];
            [self freshData];
        }
        else
        {
            [BiChatGlobal HideActivityIndicator];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

//聊天列表里面，总的入群申请界面，同意入群申请，可跨群
- (void)onButtonAgree:(id)sender
{
    //查一下本群选择了多少人
    NSString *groupId;
    NSString *groupNickName;
    NSString *groupAvatar;
    NSMutableArray *group_friends_selected = [NSMutableArray array];
    NSMutableArray *group_friendsInfo_selected = [NSMutableArray array];
    for (int j = 0; j < array4AllApply.count; j ++)
    {
        groupId = [[[array4AllApply objectAtIndex:j]firstObject]objectForKey:@"groupId"];
        groupNickName = [[[array4AllApply objectAtIndex:j]firstObject]objectForKey:@"groupNickName"];
        groupAvatar = [[[array4AllApply objectAtIndex:j]firstObject]objectForKey:@"groupAvatar"];
        for (NSDictionary *item in [array4AllApply objectAtIndex:j])
        {
            if ([self isSelected:[item objectForKey:@"uid"] groupId:groupId])
            {
                [group_friends_selected addObject:[item objectForKey:@"uid"]];
                [group_friendsInfo_selected addObject:item];
            }
        }
        if (group_friends_selected.count == 0)
            continue;
    }
        
    //这个群是否虚拟群
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:self.groupId];
    if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
        [self approveVirtualGroupApplication:groupId
                               groupNickName:groupNickName
                                 groupAvatar:groupAvatar
                      group_friends_selected:(NSMutableArray *)group_friends_selected
                  group_friendsInfo_selected:group_friendsInfo_selected];
    else
        [self approveNormalGroupApplication:groupId
                              groupNickName:groupNickName
                                groupAvatar:groupAvatar
                     group_friends_selected:(NSMutableArray *)group_friends_selected
                 group_friendsInfo_selected:group_friendsInfo_selected];
    
    //刷新一下界面
    [friends_selected removeAllObjects];
    [self freshData];
    [[BiChatGlobal sharedManager]saveUserInfo];
}

- (void)approveVirtualGroupApplication:(NSString *)groupId
                         groupNickName:(NSString *)groupNickName
                           groupAvatar:(NSString *)groupAvatar
                group_friends_selected:(NSMutableArray *)group_friends_selected
            group_friendsInfo_selected:(NSMutableArray *)group_friendsInfo_selected
{
    //开始批准
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule approveGroupApplication:groupId userList:group_friends_selected completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //这次成功的全部列表
            NSMutableArray *array4PeersAll = [NSMutableArray array];
            NSMutableDictionary *dict4PeersSuccess = [NSMutableDictionary dictionary];
            NSMutableArray *array4PeersFull = [NSMutableArray array];
            //NSMutableArray *array4Blocked = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInGroup = [NSMutableArray array];
            NSMutableArray *array4PeersNotInPendingList = [NSMutableArray array];
            
            for (NSDictionary *item in [data objectForKey:@"data"])
            {
                //找出这个人的信息
                for (int i = 0; i < group_friendsInfo_selected.count; i ++)
                {
                    if ([[item objectForKey:@"uid"]isEqualToString:[[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"uid"]])
                    {
                        NSDictionary *peer = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"uid"], @"uid",
                                              [[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"nickName"], @"nickName",
                                              [[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"avatar"]==nil?@"":[[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"avatar"], @"avatar",
                                              nil];
                        
                        //加入到分群列表
                        if ([[item objectForKey:@"joinedGroupId"]length] > 0)
                        {
                            //加入到成功列表
                            [array4PeersAll addObject:peer];
                            
                            //分群列表
                            if ([dict4PeersSuccess objectForKey:[item objectForKey:@"joinedGroupId"]] == nil)
                                [dict4PeersSuccess setObject:[NSMutableArray array] forKey:[item objectForKey:@"joinedGroupId"]];
                            [[dict4PeersSuccess objectForKey:[item objectForKey:@"joinedGroupId"]]addObject:peer];
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"])
                            [array4PeersFull addObject:peer];
                        else if ([[item objectForKey:@"result"]isEqualToString:@"NOT_IN_PENDING_LIST"])
                        {
                            [array4PeersAll addObject:peer];
                            [array4PeersNotInPendingList addObject:peer];
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"])
                        {
                            [array4PeersAll addObject:peer];
                            [array4PeersAlreadyInGroup addObject:peer];
                        }
                        break;
                    }
                }
            }
            
            //有成功的条目
            if (array4PeersAll.count > 0)
            {
                //生成一个新的消息
                NSString *msgId = [BiChatGlobal getUuidString];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4PeersAll, @"friends", nil];
                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [dict mj_JSONString], @"content",
                                                [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER], @"type",
                                                groupId , @"receiver",
                                                groupNickName, @"receiverNickName",
                                                groupAvatar, @"receiverAvatar",
                                                [BiChatGlobal sharedManager].uid, @"sender",
                                                [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                msgId, @"msgId",
                                                @"1", @"isGroup",
                                                [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                nil];
                
                //将本消息发送到群里面
                [NetworkModule sendMessageToGroup:groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    if (success)
                    {
                        [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:message];
                        [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                              peerUserName:@""
                                                              peerNickName:groupNickName
                                                                peerAvatar:groupAvatar
                                                                   message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                               messageTime:@""
                                                                     isNew:NO
                                                                   isGroup:YES
                                                                  isPublic:NO
                                                                 createNew:YES];
                        
                        //还要看看需不需要发送分群入群消息(应对虚拟群)
                        //被加入的人员列表中，如果有加入其他群的情况下，需要下面的处理
                        BOOL addToOtherGroup = NO;
                        for (NSString *key in dict4PeersSuccess)
                        {
                            if (![key isEqualToString:groupId])
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
                    }
                }];
                
                //修改全局数据
                NSMutableArray *array4Delete = [NSMutableArray array];
                for (NSDictionary *item1 in [BiChatGlobal sharedManager].array4ApproveList)
                {
                    for (NSDictionary *item2 in array4PeersAll)
                    {
                        if ([[item1 objectForKey:@"uid"]isEqualToString:[item2 objectForKey:@"uid"]] &&
                            [[item1 objectForKey:@"groupId"]isEqualToString:groupId])
                        {
                            [array4Delete addObject:item1];
                            break;
                        }
                    }
                }
                [[BiChatGlobal sharedManager].array4ApproveList removeObjectsInArray:array4Delete];
                [[BiChatGlobal sharedManager]saveUserAdditionInfo];
            }
            
            //有已经不在pending list的条目
            if (array4PeersNotInPendingList.count > 0)
            {
                //生成一个新的消息
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [array4PeersNotInPendingList JSONString], @"content",
                                                [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_NOTINPENDINGLIST], @"type",
                                                groupId , @"receiver",
                                                groupNickName, @"receiverNickName",
                                                groupAvatar, @"receiverAvatar",
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
                                                      peerNickName:groupNickName
                                                        peerAvatar:groupAvatar
                                                           message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                       messageTime:@""
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
            }
            
            //有已经在群里的条目
            if (array4PeersAlreadyInGroup.count > 0)
            {
                //生成一个新的消息
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [array4PeersAlreadyInGroup JSONString], @"content",
                                                [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPALREADYINGROUP], @"type",
                                                groupId , @"receiver",
                                                groupNickName, @"receiverNickName",
                                                groupAvatar, @"receiverAvatar",
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
                                                      peerNickName:groupNickName
                                                        peerAvatar:groupAvatar
                                                           message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                       messageTime:@""
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
            }
            
            //是不是有群已经满了，而被拒绝的人
            if (array4PeersFull.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_AGREEAPPLYFAIL_FULL], @"type",
                                                 [array4PeersFull JSONString], @"content",
                                                 groupId, @"receiver",
                                                 groupNickName, @"receiverNickName",
                                                 groupAvatar, @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:groupId peerUserName:@""
                                                      peerNickName:groupNickName
                                                        peerAvatar:groupAvatar
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];

            }
            
            //刷新一下界面
            //[friends_selected removeAllObjects];
            [self freshData];
            [[BiChatGlobal sharedManager]saveUserInfo];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (NSMutableDictionary *)getApproveFriendInfoById:(NSString *)uid groupId:(NSString *)groupId
{
    for (NSMutableDictionary * item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        if ([[item objectForKey:@"uid"]isEqualToString:uid] &&
            [[item objectForKey:@"groupId"]isEqualToString:groupId])
            return item;
    }
    return nil;
}

- (void)approveNormalGroupApplication:(NSString *)groupId
                        groupNickName:(NSString *)groupNickName
                          groupAvatar:(NSString *)groupAvatar
               group_friends_selected:(NSMutableArray *)group_friends_selected
           group_friendsInfo_selected:(NSMutableArray *)group_friendsInfo_selected
{
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:self.groupId];
    
    //开始批准
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule approveGroupApplication:groupId userList:group_friends_selected completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        //NSLog(@"%@", data);
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //这次成功的全部列表
            NSMutableArray *array4PeersSuccess = [NSMutableArray array];
            NSMutableArray *array4PeersFull = [NSMutableArray array];
            NSMutableArray *array4PeersFail = [NSMutableArray array];
            NSMutableArray *array4PeersNotInPendingList = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInGroup = [NSMutableArray array];
            NSMutableArray *array4PeersTrail = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInWaitingPayList = [NSMutableArray array];

            for (NSDictionary *item in [data objectForKey:@"data"])
            {
                //找出这个人的信息
                for (int i = 0; i < group_friendsInfo_selected.count; i ++)
                {
                    if ([[item objectForKey:@"uid"]isEqualToString:[[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"uid"]])
                    {
                        NSMutableDictionary *peer = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"uid"], @"uid",
                                                     [[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"nickName"], @"nickName",
                                                     [[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"avatar"]==nil?@"":[[group_friendsInfo_selected objectAtIndex:i]objectForKey:@"avatar"], @"avatar",
                                                     nil];
                        
                        //加入到成功列表
                        if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"])
                        {
                            //加入到成功列表
                            if ([[groupProperty objectForKey:@"payGroup"]boolValue])
                                [array4PeersTrail addObject:peer];
                            else
                                [array4PeersSuccess addObject:peer];

                            //修改全局待批准列表
                            for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                            {
                                if ([[item2 objectForKey:@"uid"]isEqualToString:[item objectForKey:@"uid"]] &&
                                    [[item2 objectForKey:@"groupId"]isEqualToString:groupId])
                                {
                                    [peer setObject:item2 forKey:@"approveInfo"];
                                    [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                                    break;
                                }
                            }
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_WAITING_PAY_LIST"] ||
                                 [[item objectForKey:@"result"]isEqualToString:@"JOIN_WAITING_PAY_LIST"])
                        {
                            [array4PeersAlreadyInWaitingPayList addObject:peer];
                            
                            //修改全局待批准列表
                            for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                            {
                                if ([[item2 objectForKey:@"uid"]isEqualToString:[item objectForKey:@"uid"]] &&
                                    [[item2 objectForKey:@"groupId"]isEqualToString:groupId])
                                {
                                    [peer setObject:item2 forKey:@"approveInfo"];
                                    [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                                    break;
                                }
                            }
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"])
                        {
                            [array4PeersFail addObject:peer];
                            [array4PeersFull addObject:peer];
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"NOT_IN_PENDING_LIST"])
                        {
                            [array4PeersFail addObject:peer];
                            [array4PeersNotInPendingList addObject:peer];
                            
                            //修改全局待批准列表
                            for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                            {
                                if ([[item2 objectForKey:@"uid"]isEqualToString:[item objectForKey:@"uid"]] &&
                                    [[item2 objectForKey:@"groupId"]isEqualToString:groupId])
                                {
                                    [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                                    break;
                                }
                            }
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"])
                        {
                            [array4PeersAlreadyInGroup addObject:peer];
                            
                            //修改全局待批准列表
                            for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                            {
                                if ([[item2 objectForKey:@"uid"]isEqualToString:[item objectForKey:@"uid"]] &&
                                    [[item2 objectForKey:@"groupId"]isEqualToString:groupId])
                                {
                                    [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                                    break;
                                }
                            }
                        }

                        break;
                    }
                }
            }
            [[BiChatGlobal sharedManager]saveUserInfo];
            [self freshData];
            
            //处理各种状态的显示，首先全部成功
            if ((array4PeersSuccess.count > 0 || array4PeersTrail.count > 0 || array4PeersAlreadyInGroup.count > 0 || array4PeersAlreadyInWaitingPayList.count > 0) && array4PeersFail.count == 0)
                [BiChatGlobal showInfo:LLSTR(@"301718") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else if ((array4PeersSuccess.count > 0 || array4PeersTrail.count > 0 || array4PeersAlreadyInGroup.count > 0 || array4PeersAlreadyInWaitingPayList.count > 0) && array4PeersFail.count > 0)
                [BiChatGlobal showInfo:LLSTR(@"301720") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else
                [BiChatGlobal showInfo:LLSTR(@"301719") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            
            //有成功的条目
            if (array4PeersSuccess.count > 0)
            {
                [self processApproveResultSuccess:array4PeersSuccess];
            }
            
            //有已经不在pending list的条目
            if (array4PeersNotInPendingList.count > 0)
            {
                //生成一个新的消息
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [array4PeersNotInPendingList mj_JSONString], @"content",
                                                [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_NOTINPENDINGLIST], @"type",
                                                groupId , @"receiver",
                                                groupNickName, @"receiverNickName",
                                                groupAvatar, @"receiverAvatar",
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
                                                      peerNickName:groupNickName
                                                        peerAvatar:groupAvatar
                                                           message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                       messageTime:@""
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
            }
            
            //有已经在群里的条目
            if (array4PeersAlreadyInGroup.count > 0)
            {
                //生成一个新的消息
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [array4PeersAlreadyInGroup mj_JSONString], @"content",
                                                [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPALREADYINGROUP], @"type",
                                                groupId , @"receiver",
                                                groupNickName, @"receiverNickName",
                                                groupAvatar, @"receiverAvatar",
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
                                                      peerNickName:groupNickName
                                                        peerAvatar:groupAvatar
                                                           message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                       messageTime:@""
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
            }
            
            //是不是有群已经满了，而被拒绝的人
            if (array4PeersFull.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_AGREEAPPLYFAIL_FULL], @"type",
                                                 [array4PeersFull mj_JSONString], @"content",
                                                 groupId, @"receiver",
                                                 groupNickName, @"receiverNickName",
                                                 groupAvatar, @"receiverAvatar",
                                                 [BiChatGlobal sharedManager].uid, @"sender",
                                                 [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                 [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                 [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                 [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                 @"1", @"isGroup",
                                                 msgId, @"msgId",
                                                 nil];
                
                //加入本地一条消息
                [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                [[BiChatDataModule sharedDataModule]setLastMessage:groupId peerUserName:@""
                                                      peerNickName:groupNickName
                                                        peerAvatar:groupAvatar
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            
            //有加入试用名单的人
            if (array4PeersTrail.count > 0)
                [self processApproveResultTrail:array4PeersTrail];
            
            //有在待付费列表中的人
            if (array4PeersAlreadyInWaitingPayList.count > 0)
                [self processApproveResultAlreadyInWaitingPayList:array4PeersAlreadyInWaitingPayList];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)processApproveResultSuccess:(NSArray *)array4PeersSuccess
{
    //将入群试用的分门别类
    NSMutableArray *array4AddGroup = [NSMutableArray array];            //拉人进群
    NSMutableArray *array4JoinGroup = [NSMutableArray array];           //申请入群
    for (NSDictionary *item in array4PeersSuccess)
    {
        if ([[[item objectForKey:@"approveInfo"]objectForKey:@"source"]length] > 0)
        {
            NSString *source = [[item objectForKey:@"approveInfo"]objectForKey:@"source"];
            
            //先找一下这个source是否已经存在
            BOOL found = NO;
            for (NSMutableDictionary *item2 in array4JoinGroup)
            {
                if ([[item2 objectForKey:@"source"]isEqualToString:source])
                {
                    [[item2 objectForKey:@"userList"]addObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}];
                    found = YES;
                    break;
                }
            }
            
            //没发现，增加一个新的
            if (!found)
            {
                NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:source, @"source", nil];
                [item2 setObject:[NSMutableArray arrayWithObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}] forKey:@"userList"];
                [array4JoinGroup addObject:item2];
            }
        }
        else
        {
            NSString *inviter = [[item objectForKey:@"approveInfo"]objectForKey:@"sender"];
            NSString *inviterNickName = [[item objectForKey:@"approveInfo"]objectForKey:@"senderNickName"];
            NSString *inviterAvatar = [[item objectForKey:@"approveInfo"]objectForKey:@"senderAvatar"];
            
            //先找一下这个inviter是否存在
            BOOL found = NO;
            for (NSMutableDictionary *item2 in array4AddGroup)
            {
                if ([[item2 objectForKey:@"inviter"]isEqualToString:inviter])
                {
                    [[item2 objectForKey:@"userList"]addObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}];
                    found = YES;
                    break;
                }
            }
            
            //没发现，增加一个新的
            if (!found)
            {
                NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:inviter, @"inviter", inviterNickName, @"inviterNickName", inviterAvatar, @"inviterAvatar", nil];
                [item2 setObject:[NSMutableArray arrayWithObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}] forKey:@"userList"];
                [array4AddGroup addObject:item2];
            }
        }
    }
    
    //发送消息
    for (NSDictionary *item in array4AddGroup)
        [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_APPROVEADDGROUP content:[item mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
    for (NSDictionary *item in array4JoinGroup)
        [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_APPROVEJOINGROUP content:[item mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
}

- (void)processApproveResultTrail:(NSArray *)array4PeersTrail
{
    //将入群试用的分门别类
    NSMutableArray *array4AddGroup = [NSMutableArray array];            //拉人进群
    NSMutableArray *array4JoinGroup = [NSMutableArray array];           //申请入群
    for (NSDictionary *item in array4PeersTrail)
    {
        if ([[[item objectForKey:@"approveInfo"]objectForKey:@"source"]length] > 0)
        {
            NSString *source = [[item objectForKey:@"approveInfo"]objectForKey:@"source"];
            
            //先找一下这个source是否已经存在
            BOOL found = NO;
            for (NSMutableDictionary *item2 in array4JoinGroup)
            {
                if ([[item2 objectForKey:@"source"]isEqualToString:source])
                {
                    [[item2 objectForKey:@"userList"]addObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}];
                    found = YES;
                    break;
                }
            }
            
            //没发现，增加一个新的
            if (!found)
            {
                NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:source, @"source", nil];
                [item2 setObject:[NSMutableArray arrayWithObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}] forKey:@"userList"];
                [array4JoinGroup addObject:item2];
            }
        }
        else
        {
            NSString *inviter = [[item objectForKey:@"approveInfo"]objectForKey:@"sender"];
            NSString *inviterNickName = [[item objectForKey:@"approveInfo"]objectForKey:@"senderNickName"];
            NSString *inviterAvatar = [[item objectForKey:@"approveInfo"]objectForKey:@"senderAvatar"];
            
            //先找一下这个inviter是否存在
            BOOL found = NO;
            for (NSMutableDictionary *item2 in array4AddGroup)
            {
                if ([[item2 objectForKey:@"inviter"]isEqualToString:inviter])
                {
                    [[item2 objectForKey:@"userList"]addObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}];
                    found = YES;
                    break;
                }
            }
            
            //没发现，增加一个新的
            if (!found)
            {
                NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:inviter, @"inviter", inviterNickName, @"inviterNickName", inviterAvatar, @"inviterAvatar", nil];
                [item2 setObject:[NSMutableArray arrayWithObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}] forKey:@"userList"];
                [array4AddGroup addObject:item2];
            }
        }
    }
    
    //开始发送消息
    for (NSDictionary *item in array4AddGroup)
        [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPTRAIL
                                  content:[item mj_JSONString]
                                 needSave:YES needSend:YES
                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
    for (NSDictionary *item in array4JoinGroup)
        [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_AGREEJOINGROUPTRAIL
                                  content:[item mj_JSONString]
                                 needSave:YES needSend:YES
                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
}

- (void)processApproveResultAlreadyInWaitingPayList:(NSArray *)array4PeersAlreadyInWaitingPayList
{
    //将入群试用的分门别类
    NSMutableArray *array4AddGroup = [NSMutableArray array];            //拉人进群
    NSMutableArray *array4JoinGroup = [NSMutableArray array];           //申请入群
    for (NSDictionary *item in array4PeersAlreadyInWaitingPayList)
    {
        if ([[[item objectForKey:@"approveInfo"]objectForKey:@"source"]length] > 0)
        {
            NSString *source = [[item objectForKey:@"approveInfo"]objectForKey:@"source"];
            
            //先找一下这个source是否已经存在
            BOOL found = NO;
            for (NSMutableDictionary *item2 in array4JoinGroup)
            {
                if ([[item2 objectForKey:@"source"]isEqualToString:source])
                {
                    [[item2 objectForKey:@"userList"]addObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}];
                    found = YES;
                    break;
                }
            }
            
            //没发现，增加一个新的
            if (!found)
            {
                NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:source, @"source", nil];
                [item2 setObject:[NSMutableArray arrayWithObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}] forKey:@"userList"];
                [array4JoinGroup addObject:item2];
            }
        }
        else
        {
            NSString *inviter = [[item objectForKey:@"approveInfo"]objectForKey:@"sender"];
            NSString *inviterNickName = [[item objectForKey:@"approveInfo"]objectForKey:@"senderNickName"];
            NSString *inviterAvatar = [[item objectForKey:@"approveInfo"]objectForKey:@"senderAvatar"];
            
            //先找一下这个inviter是否存在
            BOOL found = NO;
            for (NSMutableDictionary *item2 in array4AddGroup)
            {
                if ([[item2 objectForKey:@"inviter"]isEqualToString:inviter])
                {
                    [[item2 objectForKey:@"userList"]addObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}];
                    found = YES;
                    break;
                }
            }
            
            //没发现，增加一个新的
            if (!found)
            {
                NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:inviter, @"inviter", inviterNickName, @"inviterNickName", inviterAvatar, @"inviterAvatar", nil];
                [item2 setObject:[NSMutableArray arrayWithObject:@{@"uid": [item objectForKey:@"uid"], @"nickName": [item objectForKey:@"nickName"], @"avatar": [item objectForKey:@"avatar"]}] forKey:@"userList"];
                [array4AddGroup addObject:item2];
            }
        }
    }
    
    //发送消息
    for (NSDictionary *item in array4AddGroup)
    {
        [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY
                                  content:[item mj_JSONString]
                                 needSave:YES needSend:NO
                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        [MessageHelper sendGroupMessageToUser:[item objectForKey:@"inviter"]
                                      groupId:self.groupId
                                         type:MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY
                                      content:[item mj_JSONString]
                                     needSave:NO needSend:YES
                               completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        [MessageHelper sendGroupMessageToOperator:self.groupId type:MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY
                                          content:[item mj_JSONString]
                                         needSave:NO needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        for (NSDictionary *user in [item objectForKey:@"userList"])
        {
            [MessageHelper sendGroupMessageToUser:[user objectForKey:@"uid"] groupId:self.groupId
                                             type:MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY
                                          content:[item mj_JSONString]
                                         needSave:NO needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        }
    }
    for (NSDictionary *item in array4JoinGroup)
    {
        [MessageHelper sendGroupMessageTo:self.groupId type:MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY
                                  content:[item mj_JSONString]
                                 needSave:YES needSend:NO
                           completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        [MessageHelper sendGroupMessageToOperator:self.groupId type:MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY
                                          content:[item mj_JSONString]
                                         needSave:NO needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        for (NSDictionary *user in [item objectForKey:@"userList"])
        {
            [MessageHelper sendGroupMessageToUser:[user objectForKey:@"uid"] groupId:self.groupId
                                             type:MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY
                                          content:[item mj_JSONString]
                                         needSave:NO needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        }
    }
}

//把一个群升级成虚拟群，然后重新批准一批入群者
- (void)upgrade2VirtualGroupAndReApprove:(NSString *)groupId
                  group_friends_selected:(NSMutableArray *)group_friends_selected
              group_friendsInfo_selected:(NSMutableArray *)group_friendsInfo_selected
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
                                [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:sendData];
                            }
                        }];
                        
                        //接下来继续同意入群
                        [self approveVirtualGroupApplication:groupId
                                               groupNickName:[groupProperty objectForKey:@"groupName"]
                                                 groupAvatar:[groupProperty objectForKey:@"avatar"]
                                      group_friends_selected:group_friends_selected
                                  group_friendsInfo_selected:group_friendsInfo_selected];
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

//通知一个群，有人被拉入群
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
    NSString *subGroupNickName = [NSString stringWithFormat:@"%@#%ld", [groupProperty objectForKey:@"groupName"], (long)subGroupIndex];
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

- (void)onButtonUserDetail:(id)sender
{
    NSDictionary *applyInfo = objc_getAssociatedObject(sender, @"applyInfo");
    UserDetailViewController *wnd = [UserDetailViewController new];
    wnd.uid = [applyInfo objectForKey:@"uid"];
    wnd.nickName = [applyInfo objectForKey:@"nickName"];
    wnd.avatar = [applyInfo objectForKey:@"avatar"];
    [self.navigationController pushViewController:wnd animated:YES];
}

@end
