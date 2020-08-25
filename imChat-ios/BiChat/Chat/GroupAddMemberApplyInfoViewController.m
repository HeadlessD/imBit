//
//  GroupAddMemberApplyInfoViewController.m
//  BiChat
//
//  Created by Admin on 2018/4/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "GroupAddMemberApplyInfoViewController.h"
#import "UserDetailViewController.h"
#import "JSONKit.h"
#import "NSArray+Category.h"
#import "MessageHelper.h"

@interface GroupAddMemberApplyInfoViewController ()

@end

@implementation GroupAddMemberApplyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    friends_selected = [NSMutableArray array];
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *targetInfo = [dec objectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    friends = [targetInfo objectForKey:@"friends"];
    
    if ([[self.message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GR_APPLYADDGROUPMEMBER)
        self.navigationItem.title = LLSTR(@"101032");
    else
    {
        if ([[self.message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GA_APPLYGROUP)
            self.navigationItem.title = LLSTR(@"101032");
        else
            self.navigationItem.title = LLSTR(@"101032");
        
        //table头
        UIView *view4TableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 0)];
        
        //申请人头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[self.message objectForKey:@"sender"] nickName:[self.message objectForKey:@"senderNickName"] avatar:[self.message objectForKey:@"senderAvatar"] frame:CGRectMake(0, 0, 60, 60)];
        view4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 50);
        [view4TableHeader addSubview:view4Avatar];
        
        //申请人姓名
        UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(0, 87, self.view.frame.size.width, 20)];
        label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[self.message objectForKey:@"sender"] groupProperty:self.groupProperty nickName:[self.message objectForKey:@"senderNickName"]];
        label4NickName.font = [UIFont systemFontOfSize:16];
        label4NickName.textAlignment = NSTextAlignmentCenter;
        [view4TableHeader addSubview:label4NickName];
        
        //hint
        UILabel *label4ApplyInfo = [[UILabel alloc]initWithFrame:CGRectMake(0, 110, self.view.frame.size.width, 20)];
        if ([[targetInfo objectForKey:@"source"]length] == 0)
            label4ApplyInfo.text = [LLSTR(@"203007") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)friends.count]]];
        else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"CODE"])
            label4ApplyInfo.text = LLSTR(@"203008");
        else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"LINK"])
            label4ApplyInfo.text = LLSTR(@"203009");
        else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"WECHAT"])
            label4ApplyInfo.text = LLSTR(@"203010");
        else
            label4ApplyInfo.text = [LLSTR(@"203011") llReplaceWithArray:@[[BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]]]];
        label4ApplyInfo.font = [UIFont systemFontOfSize:16];
        label4ApplyInfo.textAlignment = NSTextAlignmentCenter;
        [view4TableHeader addSubview:label4ApplyInfo];
        
        CGRect rect = CGRectZero;
        if ([[targetInfo objectForKey:@"apply"]isKindOfClass:[NSString class]])
        {
            rect = [[targetInfo objectForKey:@"apply"] boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 100, MAXFLOAT)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                                                           context:nil];
            
            UILabel *label4ApplyHint = [[UILabel alloc]initWithFrame:CGRectMake(50, 140, self.view.frame.size.width - 100, rect.size.height)];
            label4ApplyHint.text = [targetInfo objectForKey:@"apply"];
            label4ApplyHint.textAlignment = NSTextAlignmentCenter;
            label4ApplyHint.font = [UIFont systemFontOfSize:14];
            label4ApplyHint.textColor = [UIColor grayColor];
            [view4TableHeader addSubview:label4ApplyHint];
        }
        
        //seperator
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 159.5 + rect.size.height, self.view.frame.size.width, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [view4TableHeader addSubview:view4Seperator];
        view4TableHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, 160 + rect.size.height);
        self.tableView.tableHeaderView = view4TableHeader;
    }
    
    //检查一下有几个有效人员
    NSInteger count = 0;
    for (NSDictionary *item in friends)
    {
        if ([[item objectForKey:@"status"]isEqualToString:@"APPROVED"] ||
            [[item objectForKey:@"status"]isEqualToString:@"REJECTED"] ||
            [self isUserInGroup:[item objectForKey:@"uid"]] ||
            [self isUserInBlackList:[item objectForKey:@"uid"]])
            continue;
        count ++;
    }
    if (count > 0)
    {
        //footer
        UIView *view4TableFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
        self.tableView.tableFooterView = view4TableFooter;
        
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        [view4TableFooter addSubview:view4Seperator];
        
        button4Reject = [[UIButton alloc]initWithFrame:CGRectMake(15, 40, self.view.frame.size.width / 2 - 22.5, 40)];
        button4Reject.titleLabel.font = [UIFont systemFontOfSize:16];
        button4Reject.backgroundColor = THEME_RED;
        button4Reject.layer.cornerRadius = 5;
        button4Reject.clipsToBounds = YES;
        [button4Reject addTarget:self action:@selector(onButtonReject:) forControlEvents:UIControlEventTouchUpInside];
        [button4Reject setBackgroundImage:[UIImage imageNamed:@"gray"] forState:UIControlStateDisabled];
        [button4Reject setTitle:LLSTR(@"201068") forState:UIControlStateNormal];
        button4Reject.enabled = NO;
        [view4TableFooter addSubview:button4Reject];
        
        button4Agree = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 7.5, 40, self.view.frame.size.width / 2 - 22.5, 40)];
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
        self.tableView.tableFooterView = [UIView new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *item = [dec objectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    friends = [item objectForKey:@"friends"];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return friends.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]
                                            nickName:[[friends objectAtIndex:indexPath.row]objectForKey:@"nickName"]
                                              avatar:[[friends objectAtIndex:indexPath.row]objectForKey:@"avatar"]
                                               frame:CGRectMake(15, 5, 40, 40)];
    [cell.contentView addSubview:view4Avatar];
    
    UIButton *button4UserDetail = [[UIButton alloc]initWithFrame:view4Avatar.frame];
    button4UserDetail.tag = indexPath.row;
    [button4UserDetail addTarget:self action:@selector(onButtonUserDetail:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button4UserDetail];
    
    NSString *str = [[friends objectAtIndex:indexPath.row]objectForKey:@"nickName"];
    CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                    context:nil];
    if (rect.size.width > self.view.frame.size.width - 100)
        rect.size.width = self.view.frame.size.width - 100;
    
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, rect.size.width, 50)];
    label4NickName.text = str;
    label4NickName.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label4NickName];
    
    UILabel *label4Status = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 0, 85, 50)];
    label4Status.textAlignment = NSTextAlignmentRight;
    label4Status.font = [UIFont systemFontOfSize:14];
    label4Status.clipsToBounds = YES;
    label4Status.adjustsFontSizeToFitWidth = YES;
    label4Status.numberOfLines = 0;
    [cell.contentView addSubview:label4Status];
    
    UIImageView *image4Check = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];
    if (![self isSelected:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]])
        image4Check.image = [UIImage imageNamed:@"CellNotSelected"];
    image4Check.center = CGPointMake(self.view.frame.size.width - 30, 25);
    [cell.contentView addSubview:image4Check];

    //处理状态
    if ([[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"APPROVED"])
    {
        label4Status.text = LLSTR(@"201071");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    else if ([[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"REJECTED"])
    {
        label4Status.text = LLSTR(@"201070");
        label4Status.textColor = THEME_RED;
        image4Check.image = nil;
    }
    else if ([[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"FAILED"])
    {
        label4Status.text = LLSTR(@"101718");
        label4Status.textColor = THEME_RED;
        image4Check.image = nil;
    }
    else if ([[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"EXPIRED"])
    {
        label4Status.text = LLSTR(@"101421");
        label4Status.textColor = THEME_RED;
        image4Check.image = nil;
    }
    else if ([self isUserInGroup:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]])
    {
        label4Status.text = LLSTR(@"201071");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    else if ([self isUserInBlackList:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]])
    {
        label4Status.text = LLSTR(@"201072");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    else if ([[self getUserStatusInApproveList:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]]isEqualToString:@"EXPIRED"])
    {
        label4Status.text = LLSTR(@"101421");
        label4Status.textColor = THEME_RED;
        image4Check.image = nil;
    }
    else if (![self isUserInApproveList:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]])
    {
        label4Status.text = LLSTR(@"201073");
        label4Status.textColor = [UIColor grayColor];
        image4Check.image = nil;
    }
    else if ([self checkBlockStatus:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]])
    {
        label4Status.text = LLSTR(@"201067");
        label4Status.textColor = [UIColor redColor];
        image4Check.image = nil;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *uid = [[friends objectAtIndex:indexPath.row]objectForKey:@"uid"];
    
    //是否不可选择
    if ([[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"APPROVED"] ||
        [[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"REJECTED"] ||
        [[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"FAILED"] ||
        [[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"EXPIRED"] ||
        [self isUserInGroup:uid] ||
        [self isUserInBlackList:uid] ||
        [[self getUserStatusInApproveList:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]]isEqualToString:@"EXPIRED"] ||
        ![self isUserInApproveList:uid])
        return;
    
    if ([self isSelected:uid])
        [self unSelect:uid];
    else
        [self select:uid];
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

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 设置置顶按钮
    UITableViewRowAction *rejectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLSTR(@"201068") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule rejectGroupApplication:self.groupId userList:[NSArray arrayWithObject:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data){
            
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                //生成可以显示的拒绝列表
                NSMutableArray *array4Display = [NSMutableArray array];
                [array4Display addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [[friends objectAtIndex:indexPath.row]objectForKey:@"uid"], @"uid",
                                          [[friends objectAtIndex:indexPath.row]objectForKey:@"nickName"], @"nickName",
                                          [[friends objectAtIndex:indexPath.row]objectForKey:@"avatar"]==nil?@"":[[friends objectAtIndex:indexPath.row]objectForKey:@"avatar"], @"avatar",
                                          nil]];
                
                //生成一个新的消息
                NSString *msgId = [BiChatGlobal getUuidString];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [dict mj_JSONString], @"content",
                                                [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER], @"type",
                                                self.groupId , @"receiver",
                                                [_groupProperty objectForKey:@"groupName"], @"receiverNickName",
                                                [_groupProperty objectForKey:@"avatar"]==nil?@"":[_groupProperty objectForKey:@"avatar"], @"receiverAvatar",
                                                [BiChatGlobal sharedManager].uid, @"sender",
                                                [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                msgId, @"msgId",
                                                [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                nil];
                
                //将本消息发送到群里面
                [NetworkModule sendMessageToGroup:self.groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
                
                //最后添加到本会话里面
                if (self.ownerChatWnd)
                    [self.ownerChatWnd appendMessage:message];
                
                //修改本条消息内容
                JSONDecoder *dec = [JSONDecoder new];
                NSMutableDictionary *dict4Target = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                NSMutableArray *array4Friends = [dict4Target objectForKey:@"friends"];
                
                for (NSMutableDictionary *friend in array4Friends)
                {
                    if ([[friend objectForKey:@"uid"]isEqualToString:[[friends objectAtIndex:indexPath.row]objectForKey:@"uid"]])
                    {
                        [friend setObject:@"REJECTED" forKey:@"status"];
                        break;
                    }
                }
                
                [self.message setObject:[dict4Target mj_JSONString] forKey:@"content"];
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.groupId index:[[self.message objectForKey:@"index"]integerValue] message:self.message];
                
                //刷新本界面
                dec = [JSONDecoder new];
                NSDictionary *item = [dec objectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                friends = [item objectForKey:@"friends"];
                [self.tableView reloadData];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }];
    
    rejectAction.backgroundColor = [UIColor redColor];
    NSString *uid = [[friends objectAtIndex:indexPath.row]objectForKey:@"uid"];
    
    //是否不可选择
    if ([[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"APPROVED"] ||
        [[[friends objectAtIndex:indexPath.row]objectForKey:@"status"]isEqualToString:@"REJECTED"] ||
        [self isUserInGroup:uid] ||
        [self isUserInBlackList:uid])
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

#pragma mark - 私有函数

- (void)createAdditionalView
{
    
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

- (void)onButtonUserDetail:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag;
    
    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
    wnd.uid = [[friends objectAtIndex:index]objectForKey:@"uid"];
    wnd.nickName = [[friends objectAtIndex:index]objectForKey:@"nickName"];
    wnd.avatar = [[friends objectAtIndex:index]objectForKey:@"avatar"];
    wnd.userName = [[friends objectAtIndex:index]objectForKey:@"userName"];
    wnd.source = [[BiChatGlobal sharedManager]getFriendSource:[[friends objectAtIndex:index] objectForKey:@"uid"]];
    [self.navigationController pushViewController:wnd animated:YES];
}

//群主从聊天界面，进入邀请详情，审批本群的本条记录的邀请列表
- (void)onButtonAgree:(id)sender
{
    NSMutableArray *friendsInfo_selected = [NSMutableArray array];
    
    for (int i = 0; i < friends_selected.count; i ++)
    {
        for (NSDictionary *item in friends)
        {
            if ([[friends_selected objectAtIndex:i]isEqualToString:[item objectForKey:@"uid"]])
            {
                [friendsInfo_selected addObject:item];
                break;
            }
        }
    }
    
    //无论是不是虚拟群，这个时候都调用小接口
    [self approveNormalGroupApplication:self.groupId
                          groupNickName:[self.groupProperty objectForKey:@"groupName"]
                            groupAvatar:[self.groupProperty objectForKey:@"avatar"]
                 group_friends_selected:friends_selected
             group_friendsInfo_selected:friendsInfo_selected];
}

- (void)approveNormalGroupApplication:(NSString *)groupId
                        groupNickName:(NSString *)groupNickName
                          groupAvatar:(NSString *)groupAvatar
               group_friends_selected:(NSMutableArray *)group_friends_selected
           group_friendsInfo_selected:(NSMutableArray *)group_friendsInfo_selected
{
    //开始批准
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule approveGroupApplication:self.groupId userList:friends_selected completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            self.navigationItem.rightBarButtonItem = nil;
            
            //这次成功的全部列表
            NSMutableArray *array4PeersSuccess = [NSMutableArray array];
            NSMutableDictionary *dict4PeersSuccess = [NSMutableDictionary dictionary];
            NSMutableArray *array4PeersFail = [NSMutableArray array];
            NSMutableArray *array4PeersBlocked = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInGroup = [NSMutableArray array];
            NSMutableArray *array4PeersFull = [NSMutableArray array];
            NSMutableArray *array4PeersTrail = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInWaitingPayList = [NSMutableArray array];

            for (NSDictionary *item in [data objectForKey:@"data"])
            {
                //找出这个人的信息
                for (int i = 0; i < friends.count; i ++)
                {
                    if ([[item objectForKey:@"uid"]isEqualToString:[[friends objectAtIndex:i]objectForKey:@"uid"]])
                    {
                        NSMutableDictionary *peer = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [[friends objectAtIndex:i]objectForKey:@"uid"], @"uid",
                                              [[friends objectAtIndex:i]objectForKey:@"nickName"], @"nickName",
                                              [[friends objectAtIndex:i]objectForKey:@"avatar"]==nil?@"":[[friends objectAtIndex:i]objectForKey:@"avatar"], @"avatar",
                                              nil];
                        
                        if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"])
                        {
                            //加入到成功列表
                            if ([[_groupProperty objectForKey:@"payGroup"]boolValue])
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
                        else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"])
                            [array4PeersAlreadyInGroup addObject:peer];
                        else if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"])
                        {
                            [array4PeersFail addObject:peer];
                            [array4PeersFull addObject:peer];
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"])
                        {
                            [array4PeersFail addObject:peer];
                            [array4PeersBlocked addObject:peer];
                        }
                        else
                            [array4PeersFail addObject:peer];
                        
                        break;
                    }
                }
            }
            
            //处理各种状态的显示，首先全部成功
            if ((array4PeersSuccess.count > 0 || array4PeersTrail.count > 0 || array4PeersAlreadyInGroup.count > 0 || array4PeersAlreadyInWaitingPayList.count > 0) && array4PeersFail.count == 0)
                [BiChatGlobal showInfo:LLSTR(@"301718") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else if ((array4PeersSuccess.count > 0 || array4PeersTrail.count > 0 || array4PeersAlreadyInGroup.count > 0 || array4PeersAlreadyInWaitingPayList.count > 0) && array4PeersFail.count > 0)
                [BiChatGlobal showInfo:LLSTR(@"301720") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else
                [BiChatGlobal showInfo:LLSTR(@"301719") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            
            if (array4PeersSuccess.count > 0)
            {
                [self processApproveResultSuccess:array4PeersSuccess dict4PeersSuccess:dict4PeersSuccess];
                
                //修改本条消息内容
                JSONDecoder *dec = [JSONDecoder new];
                NSMutableDictionary *dict4Target = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                NSMutableArray *array4Friends = [dict4Target objectForKey:@"friends"];
                
                for (NSMutableDictionary *friend in array4Friends)
                {
                    for (NSDictionary *item in array4PeersSuccess)
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[friend objectForKey:@"uid"]])
                        {
                            [friend setObject:@"APPROVED" forKey:@"status"];
                            break;
                        }
                    }
                }
                
                [self.message setObject:[dict4Target mj_JSONString] forKey:@"content"];
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.groupId index:[[self.message objectForKey:@"index"]integerValue] message:self.message];
                
                //修改全局待批准列表
                for (NSDictionary *peer in array4PeersSuccess)
                {
                    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[peer objectForKey:@"uid"]] &&
                            [[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                        {
                            [[BiChatGlobal sharedManager].array4ApproveList removeObject:item];
                            break;
                        }
                    }
                }
                [[BiChatGlobal sharedManager]saveUserAdditionInfo];
            }
            if (array4PeersAlreadyInGroup.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPALREADYINGROUP], @"type",
                                                 [array4PeersAlreadyInGroup JSONString], @"content",
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
                
                //修改本条消息内容
                JSONDecoder *dec = [JSONDecoder new];
                NSMutableDictionary *dict4Target = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                NSMutableArray *array4Friends = [dict4Target objectForKey:@"friends"];
                
                for (NSMutableDictionary *friend in array4Friends)
                {
                    for (NSDictionary *item in array4PeersAlreadyInGroup)
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[friend objectForKey:@"uid"]])
                        {
                            [friend setObject:@"APPROVED" forKey:@"status"];
                            break;
                        }
                    }
                }
                
                [self.message setObject:[dict4Target mj_JSONString] forKey:@"content"];
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.groupId index:[[self.message objectForKey:@"index"]integerValue] message:self.message];
                
                //修改全局待批准列表
                for (NSDictionary *peer in array4PeersAlreadyInGroup)
                {
                    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[peer objectForKey:@"uid"]] &&
                            [[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                        {
                            [[BiChatGlobal sharedManager].array4ApproveList removeObject:item];
                            break;
                        }
                    }
                }
                [[BiChatGlobal sharedManager]saveUserAdditionInfo];
            }
            if (array4PeersFull.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_AGREEAPPLYFAIL_FULL], @"type",
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
            //有被加入黑名单的人
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
            
            
            //有加入试用名单的人
            if (array4PeersTrail.count > 0)
            {
                [self processApproveResultTrail:array4PeersTrail];
                
                //修改本条消息内容
                JSONDecoder *dec = [JSONDecoder new];
                NSMutableDictionary *dict4Target = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                NSMutableArray *array4Friends = [dict4Target objectForKey:@"friends"];
                
                for (NSMutableDictionary *friend in array4Friends)
                {
                    for (NSDictionary *item in array4PeersTrail)
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[friend objectForKey:@"uid"]])
                        {
                            [friend setObject:@"APPROVED" forKey:@"status"];
                            break;
                        }
                    }
                }
                
                [self.message setObject:[dict4Target mj_JSONString] forKey:@"content"];
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.groupId index:[[self.message objectForKey:@"index"]integerValue] message:self.message];
                
                //修改全局待批准列表
                for (NSDictionary *peer in array4PeersTrail)
                {
                    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[peer objectForKey:@"uid"]] &&
                            [[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                        {
                            [[BiChatGlobal sharedManager].array4ApproveList removeObject:item];
                            break;
                        }
                    }
                }
                [[BiChatGlobal sharedManager]saveUserAdditionInfo];

            }
            
            //有在待付费列表中的人
            if (array4PeersAlreadyInWaitingPayList.count > 0)
            {
                [self processApproveResultAlreadyInWaitingPayList:array4PeersAlreadyInWaitingPayList];
                
                //修改本条消息内容
                JSONDecoder *dec = [JSONDecoder new];
                NSMutableDictionary *dict4Target = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                NSMutableArray *array4Friends = [dict4Target objectForKey:@"friends"];
                
                for (NSMutableDictionary *friend in array4Friends)
                {
                    for (NSDictionary *item in array4PeersAlreadyInWaitingPayList)
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[friend objectForKey:@"uid"]])
                        {
                            [friend setObject:@"APPROVED" forKey:@"status"];
                            break;
                        }
                    }
                }
                
                [self.message setObject:[dict4Target mj_JSONString] forKey:@"content"];
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.groupId index:[[self.message objectForKey:@"index"]integerValue] message:self.message];
                
                //修改全局待批准列表
                for (NSDictionary *peer in array4PeersAlreadyInWaitingPayList)
                {
                    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[peer objectForKey:@"uid"]] &&
                            [[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                        {
                            [[BiChatGlobal sharedManager].array4ApproveList removeObject:item];
                            break;
                        }
                    }
                }
                [[BiChatGlobal sharedManager]saveUserAdditionInfo];
            }
            
            //刷新本界面
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *item = [dec objectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            friends = [item objectForKey:@"friends"];
            [self.tableView reloadData];
            [friends_selected removeAllObjects];
            button4Reject.enabled = NO;
            button4Agree.enabled = NO;
            
            [friends_selected removeAllObjects];
            [self.tableView reloadData];
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

- (void)processApproveResultSuccess:(NSArray *)array4PeersSuccess
                  dict4PeersSuccess:(NSDictionary *)dict4PeersSuccess
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

    /*
    //生成一个新的消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4PeersSuccess, @"friends", nil];
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [dict mj_JSONString], @"content",
                                    [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER], @"type",
                                    self.groupId , @"receiver",
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
    
    //将本消息发送到群里面
    [NetworkModule sendMessageToGroup:self.groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            //最后添加到本会话里面
            if (self.ownerChatWnd)
                [self.ownerChatWnd appendMessage:message];
            else
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:message];
            [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                  peerUserName:[self.groupProperty objectForKey:@"groupName"]
                                                  peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                    peerAvatar:[self.groupProperty objectForKey:@"avatar"]
                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:self.groupProperty]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO isGroup:YES isPublic:NO createNew:YES];
            
            //还要看看需不需要发送分群入群消息(应对虚拟群)
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
                    __block NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:key];
                    if (groupProperty == nil)
                    {
                        //可能是一个新的群
                        [NetworkModule getGroupProperty:key completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            groupProperty = data;
                            //NSLog(@"通知一个新群：%@", groupProperty);
                            [self notifyVirtualGroupAssignMember:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                        }];
                    }
                    else
                    {
                        //NSLog(@"通知一个老群：%@", groupProperty);
                        [self notifyVirtualGroupAssignMember:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                    }
                }
            }
        }
    }];
     */
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
        [MessageHelper sendGroupMessageTo:self.groupId
                                     type:MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY
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
        [MessageHelper sendGroupMessageTo:self.groupId
                                     type:MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY
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

- (void)notifyVirtualGroupAssignMember:(NSDictionary *)groupProperty subGroupId:(NSString *)subGroupId dict4PeersSuccess:(NSDictionary *)dict4PeersSuccess
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
    NSString *subGroupNickName = [NSString stringWithFormat:@"%@#%ld", [groupProperty objectForKey:@"groupName"], (long)(subGroupIndex + 1)];
    NSDictionary *dict4Content = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.groupId, @"fromGroupId",
                                  subGroupId, @"groupId",
                                  subGroupNickName, @"groupNickName",
                                  [dict4PeersSuccess objectForKey:subGroupId], @"assignedMember",
                                  nil];
    
    //生成一条新消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP], @"type",
                                     [dict4Content JSONString], @"content",
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
    
    [NetworkModule sendMessageToGroup:self.groupId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            if (self.ownerChatWnd)
                [self.ownerChatWnd appendMessage:sendData];
            else
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
        }
    }];
    
    if (subGroupId != self.groupId)
    {
        //生成一条新消息
        NSString *msgId = [BiChatGlobal getUuidString];
        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP], @"type",
                                         [dict4Content JSONString], @"content",
                                         subGroupId, @"receiver",
                                         subGroupNickName, @"receiverNickName",
                                         [BiChatGlobal getGroupAvatar:self.groupProperty], @"receiverAvatar",
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
                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                             isNew:NO isGroup:YES isPublic:NO createNew:YES];
            }
            else
                NSLog(@"send message failure");
        }];
    }
}

- (void)onButtonReject:(id)sender
{
    [self rejectGroupApplication:_groupId
                   groupNickName:[_groupProperty objectForKey:@"groupName"]
                     groupAvatar:[_groupProperty objectForKey:@"avatar"]
          group_friends_selected:friends_selected];
}

- (BOOL)isUserInGroup:(NSString *)uid
{
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:uid])
            return YES;
    }
    return NO;
}

- (BOOL)isUserInBlackList:(NSString *)uid
{
    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupBlackList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:uid])
            return YES;
    }
    return NO;
}
              
- (NSString *)getUserStatusInApproveList:(NSString *)uid
{
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        if ([[item objectForKey:@"uid"]isEqualToString:uid] &&
            [[item objectForKey:@"groupId"]isEqualToString:self.groupId])
            return [item objectForKey:@"status"];
    }
    return @"";
}
              
- (BOOL)isUserInApproveList:(NSString *)uid
{
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        if ([[item objectForKey:@"uid"]isEqualToString:uid] &&
            [[item objectForKey:@"groupId"]isEqualToString:self.groupId])
            return YES;
    }
    return NO;
}

- (void)select:(NSString *)uid
{
    for (NSString *item in friends_selected)
    {
        if ([item isEqualToString:uid])
            return;
    }
    [friends_selected addObject:uid];
}

- (void)unSelect:(NSString *)uid
{
    for (NSString *item in friends_selected)
    {
        if ([item isEqualToString:uid])
        {
            [friends_selected removeObject:uid];
            return;
        }
    }
}

- (BOOL)isSelected:(NSString *)uid
{
    for (NSString *item in friends_selected)
    {
        if ([uid isEqualToString:item])
            return YES;
    }
    return NO;
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
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule createVirtualGroup:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
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

- (void)rejectGroupApplication:(NSString *)groupId
                 groupNickName:(NSString *)groupNickName
                   groupAvatar:(NSString *)groupAvatar
        group_friends_selected:(NSMutableArray *)group_friends_selected
{
    //开始拒绝
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule rejectGroupApplication:self.groupId userList:group_friends_selected completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            self.navigationItem.rightBarButtonItem = nil;
            
            //生成可以显示的批准列表
            NSMutableArray *array4Display = [NSMutableArray array];
            for (int i = 0; i < friends.count; i ++)
            {
                if ([group_friends_selected containsString:[[friends objectAtIndex:i]objectForKey:@"uid"]])
                {
                    [array4Display addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [[friends objectAtIndex:i]objectForKey:@"uid"], @"uid",
                                              [[friends objectAtIndex:i]objectForKey:@"nickName"], @"nickName",
                                              [[friends objectAtIndex:i]objectForKey:@"avatar"]==nil?@"":[[friends objectAtIndex:i]objectForKey:@"avatar"], @"avatar",
                                              nil]];
                }
            }
            
            //生成一个新的消息
            NSString *msgId = [BiChatGlobal getUuidString];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
            NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [dict mj_JSONString], @"content",
                                            [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER], @"type",
                                            self.groupId , @"receiver",
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
            
            //将本消息发送到群里面
            [NetworkModule sendMessageToGroup:self.groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
            
            //最后添加到本会话里面
            if (self.ownerChatWnd)
                [self.ownerChatWnd appendMessage:message];
            else
                [[BiChatDataModule sharedDataModule]addChatContentWith:groupId content:message];
            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                  peerUserName:@""
                                                  peerNickName:groupNickName
                                                    peerAvatar:groupAvatar
                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:_groupProperty]
                                                   messageTime:[BiChatGlobal getCurrentDateString] isNew:YES
                                                       isGroup:YES isPublic:NO createNew:YES];
            
            //修改本条消息内容
            JSONDecoder *dec = [JSONDecoder new];
            NSMutableDictionary *dict4Target = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            NSMutableArray *array4Friends = [dict4Target objectForKey:@"friends"];
            for (NSMutableDictionary *friend in array4Friends)
            {
                if ([group_friends_selected containsString:[friend objectForKey:@"uid"]])
                {
                    [friend setObject:@"REJECTED" forKey:@"status"];
                }
            }
            [self.message setObject:[dict4Target mj_JSONString] forKey:@"content"];
            [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.groupId index:[[self.message objectForKey:@"index"]integerValue] message:self.message];
            
            //循环向每一个被拒绝的用户模拟发出一条消息
            for (NSString *uid in group_friends_selected)
            {
                NSString *nickName = @"";
                for (NSDictionary *item in array4Friends)
                {
                    if ([uid isEqualToString:[item objectForKey:@"uid"]])
                    {
                        nickName = [item objectForKey:@"nickName"];
                        break;
                    }
                }
                NSArray *array4Display = @[@{@"uid":uid,@"nickName":nickName}];
                NSString *msgId = [BiChatGlobal getUuidString];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array4Display, @"friends", nil];
                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [dict mj_JSONString], @"content",
                                                [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER], @"type",
                                                self.groupId , @"receiver",
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
                
                //将本消息发送到群里面
                [NetworkModule sendMessageToUser:uid message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
            }
            
            //修改全局待批准列表
            NSMutableArray *array4Delete = [NSMutableArray array];
            for (NSString *str in group_friends_selected)
            {
                for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
                {
                    if ([[item objectForKey:@"uid"]isEqualToString:str] &&
                        [[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                    {
                        [array4Delete addObject:item];
                        break;
                    }
                }
            }
            [[BiChatGlobal sharedManager].array4ApproveList removeObjectsInArray:array4Delete];
            [[BiChatGlobal sharedManager]saveUserAdditionInfo];
            
            //刷新本界面
            dec = [JSONDecoder new];
            NSDictionary *item = [dec objectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            friends = [item objectForKey:@"friends"];
            [self.tableView reloadData];
            [friends_selected removeAllObjects];
            button4Reject.enabled = NO;
            button4Agree.enabled = NO;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
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
                                        [self notifyVirtualGroupAssignMember:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                                    }];
                                }
                                else
                                {
                                    //NSLog(@"通知一个老群：%@", groupProperty);
                                    [self notifyVirtualGroupAssignMember:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                                }
                            }
                        }
                    }
                }];
                
                //修改本条消息内容
                JSONDecoder *dec = [JSONDecoder new];
                NSMutableDictionary *dict4Target = [dec mutableObjectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                NSMutableArray *array4Friends = [dict4Target objectForKey:@"friends"];
                
                for (NSMutableDictionary *friend in array4Friends)
                {
                    for (NSDictionary *item in array4PeersAll)
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[friend objectForKey:@"uid"]])
                        {
                            [friend setObject:@"APPROVED" forKey:@"status"];
                            break;
                        }
                    }
                }
                
                [self.message setObject:[dict4Target mj_JSONString] forKey:@"content"];
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:self.groupId index:[[self.message objectForKey:@"index"]integerValue] message:self.message];
                
                //修改全局待批准列表
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
            
            //刷新本界面
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *item = [dec objectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            friends = [item objectForKey:@"friends"];
            [self.tableView reloadData];
            [friends_selected removeAllObjects];
            button4Reject.enabled = NO;
            button4Agree.enabled = NO;
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301703") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

@end
