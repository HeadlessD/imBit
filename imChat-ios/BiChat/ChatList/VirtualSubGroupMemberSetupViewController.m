//
//  VirtualSubGroupMemberSetupViewController.m
//  BiChat Dev
//
//  Created by imac2 on 2018/11/27.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "VirtualSubGroupMemberSetupViewController.h"
#import "GroupApproveViewController.h"
#import "MessageHelper.h"

@interface VirtualSubGroupMemberSetupViewController ()

@end

@implementation VirtualSubGroupMemberSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201510");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 15)];
    self.tableView.separatorColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.tableFooterView = [self createOperationPanel];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        if ([[BiChatGlobal sharedManager].uid isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
            return 3;
        else if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
            return 2;
        else
            return 0;
    }
    else if (section == 1)
    {
        return 6;
    }
    else if (section == 2)
    {
        return 2;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 4)
    {
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            [[self.groupProperty objectForKey:@"addNewMemberRightOnly"]boolValue])
            return 44;
        else
            return 0;
    }
    else
        return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([[BiChatGlobal sharedManager].uid isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]] &&
            [[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
            return 15;
        else if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
            return 15;
        else
            return 0;
    }
    else if (section == 2)
    {
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            ![[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] &&
            [[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        {
            NSString *str = LLSTR(@"201315");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            return rect.size.height + 20;
        }
        else
            return 15;
    }
    else if (section == 3)
    {
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            ![[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] &&
            [[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        {
            NSString *str = LLSTR(@"201317");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            return rect.size.height + 20;
        }
        else
            return 0.0000001;
    }
    else
        return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2)
    {
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            ![[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] &&
            [[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        {
            NSString *str = LLSTR(@"201315");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, rect.size.height + 20)];
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, self.view.frame.size.width - 30, rect.size.height)];
            label4Title.text = str;
            label4Title.numberOfLines = 0;
            label4Title.font = [UIFont systemFontOfSize:14];
            label4Title.textColor = [UIColor grayColor];
            [view4Title addSubview:label4Title];
            
            return view4Title;
        }
        else
            return [UIView new];
    }
    else if (section == 3)
    {
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            ![[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue] &&
            [[self.groupProperty objectForKey:@"virtualGroupId"]length] == 0)
        {
            NSString *str = LLSTR(@"201317");
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            
            UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, rect.size.height + 20)];
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, self.view.frame.size.width - 30, rect.size.height)];
            label4Title.text = str;
            label4Title.numberOfLines = 0;
            label4Title.font = [UIFont systemFontOfSize:14];
            label4Title.textColor = [UIColor grayColor];
            [view4Title addSubview:label4Title];
            
            return view4Title;
        }
        else
            return [UIView new];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    // Configure the cell...
    if ([[BiChatGlobal sharedManager].uid isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
    {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            NSInteger count = [[self.groupProperty objectForKey:@"assitantUid"]count];
            for (NSString *uid in [self.groupProperty objectForKey:@"assitantUid"])
            {
                if ([uid isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
                    count --;
            }
            if (count < 0) count = 0;
            cell.textLabel.text = LLSTR(@"201303");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
            NSInteger count = [[self.groupProperty objectForKey:@"vip"]count];
            if (count < 0) count = 0;
            cell.textLabel.text = LLSTR(@"201305");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.section == 0 && indexPath.row == 2)
        {
            cell.textLabel.text = LLSTR(@"201306");
            if (![[self.groupProperty objectForKey:@"payGroup"]boolValue])
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    else if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
    {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            NSInteger count = [[self.groupProperty objectForKey:@"vip"]count];
            if (count < 0) count = 0;
            cell.textLabel.text = LLSTR(@"201305");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
            cell.textLabel.text = LLSTR(@"201306");
            if (![[self.groupProperty objectForKey:@"payGroup"]boolValue])
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"201329");
        cell.detailTextLabel.text = [[self.groupProperty objectForKey:@"changeNameRightOnly"]boolValue]||[[self.groupProperty objectForKey:@"virtualGroupId"]length]>0?LLSTR(@"201331"):LLSTR(@"201332");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        //当前用户是否群主或者管理员
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
        {
            cell.textLabel.text = LLSTR(@"201309");
            UISwitch *switch4CanPinMessage = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4CanPinMessage addTarget:self action:@selector(onSwitchCanPinMessage:) forControlEvents:UIControlEventValueChanged];
            switch4CanPinMessage.on = [[self.groupProperty objectForKey:@"dingRightOnly"]boolValue];
            [cell.contentView addSubview:switch4CanPinMessage];
        }
        else
        {
            cell.textLabel.text = LLSTR(@"201330");
            cell.detailTextLabel.text = [[self.groupProperty objectForKey:@"dingRightOnly"]boolValue]?LLSTR(@"201331"):LLSTR(@"201332");
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        //当前用户是否群主或者管理员
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
        {
            cell.textLabel.text = LLSTR(@"201344");
            UISwitch *switch4CanPinMessage = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4CanPinMessage addTarget:self action:@selector(onSwitchOnlyAssistantCanAddFriend:) forControlEvents:UIControlEventValueChanged];
            switch4CanPinMessage.on = [[self.groupProperty objectForKey:@"onlyAssistantCanAddFriend"]boolValue];
            [cell.contentView addSubview:switch4CanPinMessage];
        }
        else
        {
            cell.textLabel.text = LLSTR(@"201345");
            cell.detailTextLabel.text = [[self.groupProperty objectForKey:@"onlyAssistantCanAddFriend"]boolValue]?LLSTR(@"201331"):LLSTR(@"201332");
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 3)
    {
        cell.textLabel.text = LLSTR(@"201310");
        
        //当前用户是否群主或者管理员
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
        {
            UISwitch *switch4CanAddMember = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4CanAddMember addTarget:self action:@selector(onSwitchCanAddMember:) forControlEvents:UIControlEventValueChanged];
            switch4CanAddMember.on = [[self.groupProperty objectForKey:@"addNewMemberRightOnly"]boolValue];
            [cell.contentView addSubview:switch4CanAddMember];
            
            if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
            {
                switch4CanAddMember.enabled = NO;
                switch4CanAddMember.userInteractionEnabled = NO;
            }
        }
        else
            cell.detailTextLabel.text = [[self.groupProperty objectForKey:@"addNewMemberRightOnly"]boolValue]?LLSTR(@"201333"):LLSTR(@"201334");
        
        //当前是否超大群
        if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
        {
            cell.textLabel.textColor = THEME_GRAY;
            cell.detailTextLabel.textColor = THEME_GRAY;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 4)
    {
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty] &&
            [[self.groupProperty objectForKey:@"addNewMemberRightOnly"]boolValue])
        {
            cell.textLabel.text = LLSTR(@"201311");
            
            //统计一下一共有几个本群的入群申请
            NSInteger count = 0;
            for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
            {
                if ([[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                    count ++;
            }
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
            if (count > 0)
            {
                CGRect rect = [cell.textLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
                
                UIView *view4Attention = [[UIView alloc]initWithFrame:CGRectMake(18 + rect.size.width, 13, 10, 10)];
                view4Attention.layer.cornerRadius = 5;
                view4Attention.clipsToBounds = YES;
                view4Attention.backgroundColor = [UIColor redColor];
                [cell.contentView addSubview:view4Attention];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 5)
    {
        cell.textLabel.text = LLSTR(@"201346");
        
        //先设置为群主
        for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
        {
            if ([[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
            {
                cell.detailTextLabel.text = [item objectForKey:@"nickName"];
                break;
            }
        }
        
        //是否指定了审批管理员
        if ([[self.groupProperty objectForKey:@"customerServiceManager"]length] > 0)
        {
            for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
            {
                if ([[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"customerServiceManager"]])
                {
                    cell.detailTextLabel.text = [item objectForKey:@"nickName"];
                    break;
                }
            }
        }
        
        if ([BiChatGlobal isMeGroupOwner:self.groupProperty])
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        else
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"201313");
        if ([[self.groupProperty objectForKey:@"isUnlimitedGroup"]boolValue])
            cell.detailTextLabel.text = LLSTR(@"201328");
        else
            cell.detailTextLabel.text = [LLSTR(@"201005") llReplaceWithArray:@[[NSString stringWithFormat:@"%@", [self.groupProperty objectForKey:@"groupUserCount"]]]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"201511");
        
        //当前用户是否群主或者管理员
        if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
        {
            UISwitch *switch4CanAddMember = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4CanAddMember addTarget:self action:@selector(onSwitchAllowAutoJoinGroup:) forControlEvents:UIControlEventValueChanged];
            switch4CanAddMember.on = ![[self.groupProperty objectForKey:@"notAllowAutoJoinGroup"]boolValue];
            [cell.contentView addSubview:switch4CanAddMember];
        }
        else
            cell.detailTextLabel.text = [[self.groupProperty objectForKey:@"notAllowAutoJoinGroup"]boolValue]?LLSTR(@"201335"):LLSTR(@"201336");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([BiChatGlobal isMeGroupOperator:_groupProperty])
    {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            if ([[BiChatGlobal sharedManager].uid isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
            {
                GroupMemberSelectorViewController *wnd = [GroupMemberSelectorViewController new];
                wnd.defaultTitle = LLSTR(@"201303");
                wnd.canSelectOwner = NO;
                wnd.canSelectAssistant = YES;
                wnd.needConfirm = YES;
                wnd.multiSelect = YES;
                wnd.cookie = 2;
                wnd.delegate = self;
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                wnd.defaultSelected = [self.groupProperty objectForKey:@"assitantUid"];
                wnd.canSelectDefaultSelected = YES;
                wnd.showMemo = YES;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                nav.navigationBar.translucent = NO;
                nav.navigationBar.tintColor = THEME_COLOR;
                [self.navigationController presentViewController:nav animated:YES completion:nil];

            }
            else
            {
                GroupMemberSelectorViewController *wnd = [GroupMemberSelectorViewController new];
                wnd.defaultTitle = LLSTR(@"201305");
                wnd.canSelectOwner = NO;
                wnd.canSelectAssistant = NO;
                wnd.needConfirm = YES;
                wnd.multiSelect = YES;
                wnd.cookie = 3;
                wnd.delegate = self;
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                wnd.defaultSelected = [self.groupProperty objectForKey:@"vip"];
                wnd.canSelectDefaultSelected = YES;
                wnd.showMemo = YES;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                nav.navigationBar.translucent = NO;
                nav.navigationBar.tintColor = THEME_COLOR;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
            if ([[BiChatGlobal sharedManager].uid isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
            {
                GroupMemberSelectorViewController *wnd = [GroupMemberSelectorViewController new];
                wnd.defaultTitle = LLSTR(@"201305");
                wnd.canSelectOwner = NO;
                wnd.canSelectAssistant = NO;
                wnd.needConfirm = YES;
                wnd.multiSelect = YES;
                wnd.cookie = 3;
                wnd.delegate = self;
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                wnd.defaultSelected = [self.groupProperty objectForKey:@"vip"];
                wnd.canSelectDefaultSelected = YES;
                wnd.showMemo = YES;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                nav.navigationBar.translucent = NO;
                nav.navigationBar.tintColor = THEME_COLOR;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }
            else
            {
                if (![[self.groupProperty objectForKey:@"payGroup"]boolValue])
                    [self moveGroupMember];
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 2)
        {
            if (![[self.groupProperty objectForKey:@"payGroup"]boolValue])
                [self moveGroupMember];
        }
        else if (indexPath.section == 1 && indexPath.row == 4)
        {
            GroupApproveViewController *wnd = [GroupApproveViewController new];
            wnd.groupId = self.groupId;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else if (indexPath.section == 1 && indexPath.row == 5)
        {
            if ([BiChatGlobal isMeGroupOwner:self.groupProperty])
            {
                //先设置为群主
                NSString *uid;
                for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                {
                    if ([[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
                    {
                        uid = [item objectForKey:@"uid"];
                        break;
                    }
                }
                
                //是否指定了审批管理员
                if ([[self.groupProperty objectForKey:@"customerServiceManager"]length] > 0)
                {
                    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                    {
                        if ([[item objectForKey:@"uid"]isEqualToString:[self.groupProperty objectForKey:@"customerServiceManager"]])
                        {
                            uid = [item objectForKey:@"uid"];
                            break;
                        }
                    }
                }
                
                GroupMemberSelectorViewController *wnd = [GroupMemberSelectorViewController new];
                wnd.defaultTitle = LLSTR(@"201346");
                wnd.canSelectOwner = YES;
                wnd.canSelectAssistant = YES;
                wnd.canSelectOrdinary = NO;
                wnd.needConfirm = YES;
                wnd.multiSelect = NO;
                wnd.cookie = 5;
                wnd.delegate = self;
                wnd.groupId = self.groupId;
                wnd.groupProperty = self.groupProperty;
                wnd.showMemo = YES;
                wnd.defaultSelected = @[uid];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
                nav.navigationBar.translucent = NO;
                nav.navigationBar.tintColor = THEME_COLOR;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }
        }
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

- (void)memberSelected:(NSArray *)member withCookie:(NSInteger)cookie
{
    if (cookie == 1 && [member count] == 0)
        return;
    
    //关闭选择框
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //开始处理
    NSMutableArray *array4MemberUid = [NSMutableArray array];
    for (NSDictionary *item in member)
        [array4MemberUid addObject:[item objectForKey:@"uid"]];
    if (cookie == 1)        //群主转让
    {
        if (array4MemberUid.count > 0)
        {
            //设置新的群主
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule setGroupOwner:self.groupId
                                   owner:[array4MemberUid firstObject]
                          completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
             {
                 
                 [BiChatGlobal HideActivityIndicator];
                 if (success)
                 {
                     [self.groupProperty setObject:[array4MemberUid firstObject] forKey:@"ownerUid"];
                     [self.tableView reloadData];
                     
                     //获取新群主的昵称
                     NSString *str = @"";
                     for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                     {
                         if ([[array4MemberUid firstObject]isEqualToString:[item objectForKey:@"uid"]])
                         {
                             str = [item objectForKey:@"nickName"];
                             break;
                         }
                     }
                     
                     //装配一个新的通知消息
                     NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[array4MemberUid firstObject], @"uid",
                                           str, @"nickName",
                                           nil];
                     
                     //同时要发送一条数据通知群中的其他成员
                     NSString *msgId = [BiChatGlobal getUuidString];
                     NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_CHANGEGROUPOWNER], @"type",
                                                      [dict mj_JSONString], @"content",
                                                      self.groupId, @"receiver",
                                                      [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                             [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                                   peerUserName:@""
                                                                   peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                     peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                        message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                                    messageTime:[BiChatGlobal getCurrentDateString]
                                                                          isNew:NO
                                                                        isGroup:YES
                                                                       isPublic:NO
                                                                      createNew:YES];
                             
                             //加入本地一条消息
                             if (self.ownerChatWnd != nil)
                             {
                                 [self.ownerChatWnd appendMessage:sendData];
                             }
                             else
                                 [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                         }
                     }];
                 }
             }];
        }
    }
    else if (cookie == 2)           //设置群管理员
    {
        //先找出添加了谁，删除了谁
        NSMutableArray *array4Delete = [NSMutableArray arrayWithArray:[self.groupProperty objectForKey:@"assitantUid"]];
        NSMutableArray *array4DeleteDelete = [NSMutableArray array];
        for (NSString *item in array4Delete)
        {
            for (NSString *item2 in array4MemberUid)
            {
                if ([item isEqualToString:item2])
                {
                    [array4DeleteDelete addObject:item];
                    break;
                }
            }
        }
        [array4Delete removeObjectsInArray:array4DeleteDelete];
        NSMutableArray *array4Add = [NSMutableArray array];
        for (NSDictionary *item in array4MemberUid)
            [array4Add addObject:item];
        NSMutableArray *array4DeleteAdd = [NSMutableArray array];
        for (NSString *item in array4Add)
        {
            for (NSString *item2 in [self.groupProperty objectForKey:@"assitantUid"])
            {
                if ([item isEqualToString:item2])
                {
                    [array4DeleteAdd addObject:item];
                    break;
                }
            }
        }
        [array4Add removeObjectsInArray:array4DeleteAdd];
        
        //第一步，添加群管理员
        if (array4Add.count > 0)
        {
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule addGroupAssistant:self.groupId assistant:array4Add completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (success)
                {
                    //NSLog(@"%@", data);
                    NSMutableArray *array4NewAssistant = [NSMutableArray array];
                    for (NSString *str in array4Add)
                    {
                        //这个群成员是否失败
                        if ([[data objectForKey:@"failCode"]objectForKey:str] != nil)
                        {
                            for (int i = 0; i < array4MemberUid.count; i ++)
                            {
                                if ([str isEqualToString:[array4MemberUid objectAtIndex:i]])
                                {
                                    [array4MemberUid removeObjectAtIndex:i];
                                    break;
                                }
                            }
                            continue;
                        }
                        
                        //获取新群嘉宾的昵称
                        NSString *str4NickName = @"";
                        for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                        {
                            if ([str isEqualToString:[item objectForKey:@"uid"]])
                            {
                                str4NickName = [item objectForKey:@"nickName"];
                                break;
                            }
                        }
                        //没有找到，从系统里面查一下
                        if (str4NickName.length == 0)
                            str4NickName = [[BiChatGlobal sharedManager].dict4NickNameCache objectForKey:str];
                        
                        //装配一个新的通知消息
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"uid",
                                              str4NickName, @"nickName",
                                              nil];
                        
                        [array4NewAssistant addObject:dict];
                    }
                    
                    [self.groupProperty setObject:array4MemberUid forKey:@"assitantUid"];
                    [self.tableView reloadData];
                    
                    //没有人成功的设置成为群嘉宾
                    if (array4NewAssistant.count > 0)
                    {
                        //同时要发送一条数据通知群中的其他成员
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDASSISTANT], @"type",
                                                         [array4NewAssistant mj_JSONString], @"content",
                                                         self.groupId, @"receiver",
                                                         [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                                //加入本地一条消息
                                if (self.ownerChatWnd != nil)
                                    [self.ownerChatWnd appendMessage:sendData];
                                else
                                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                                      peerUserName:@""
                                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:YES];
                            }
                        }];
                    }
                    
                    //是否有第二步
                    if (array4Delete.count == 0)
                    {
                        //没有第二步
                        [BiChatGlobal HideActivityIndicator];
                        if ([[data objectForKey:@"failCode"]count] == 0)
                            [BiChatGlobal showInfo:[LLSTR(@"301765")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)array4Add.count]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                        else
                            [BiChatGlobal showInfo:[LLSTR(@"301766")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", array4Add.count - [[data objectForKey:@"failCode"]count]], [NSString stringWithFormat:@"%ld", [[data objectForKey:@"failCode"]count]]]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }
                    else
                    {
                        NSDictionary *data4Add = data;
                        [NetworkModule delGroupAssistant:self.groupId assistant:array4Delete completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                            [BiChatGlobal HideActivityIndicator];
                            if (success)
                            {
                                NSMutableArray *array4DeletedAssistant = [NSMutableArray array];
                                for (NSString *str in array4Delete)
                                {
                                    //这个群成员是否失败
                                    if ([[data objectForKey:@"failCode"]objectForKey:str] != nil)
                                    {
                                        [array4MemberUid addObject:str];
                                        continue;
                                    }
                                    
                                    //获取新群嘉宾的昵称
                                    NSString *str4NickName = @"";
                                    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                                    {
                                        if ([str isEqualToString:[item objectForKey:@"uid"]])
                                        {
                                            str4NickName = [item objectForKey:@"nickName"];
                                            break;
                                        }
                                    }
                                    //没有找到，从系统里面查一下
                                    if (str4NickName.length == 0)
                                        str4NickName = [[BiChatGlobal sharedManager].dict4NickNameCache objectForKey:str];
                                    
                                    //装配一个新的通知消息
                                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"uid",
                                                          str4NickName, @"nickName",
                                                          nil];
                                    
                                    [array4DeletedAssistant addObject:dict];
                                }
                                
                                [self.groupProperty setObject:array4MemberUid forKey:@"assitantUid"];
                                [self.tableView reloadData];
                                
                                if (array4DeletedAssistant.count > 0)
                                {
                                    //同时要发送一条数据通知群中的其他成员
                                    NSString *msgId = [BiChatGlobal getUuidString];
                                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_DELASSISTANT], @"type",
                                                                     [array4DeletedAssistant mj_JSONString], @"content",
                                                                     self.groupId, @"receiver",
                                                                     [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                                            //加入本地一条消息
                                            if (self.ownerChatWnd != nil)
                                                [self.ownerChatWnd appendMessage:sendData];
                                            else
                                                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                                            [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                                                  peerUserName:@""
                                                                                  peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                                    peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                                         isNew:NO
                                                                                       isGroup:YES
                                                                                      isPublic:NO
                                                                                     createNew:NO];
                                        }
                                    }];
                                }
                                
                                //提示用户
                                if ([[data objectForKey:@"failCode"]count] == 0 && [[data4Add objectForKey:@"failCode"]count] == 0)
                                    [BiChatGlobal showInfo:[LLSTR(@"301769")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)array4Add.count], [NSString stringWithFormat:@"%ld", (long)array4Delete.count]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                                else
                                    [BiChatGlobal showInfo:[LLSTR(@"301770")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", array4Add.count - [[data4Add objectForKey:@"failCode"]count]], [NSString stringWithFormat:@"%ld", array4Delete.count - [[data objectForKey:@"failCode"]count]], [NSString stringWithFormat:@"%ld", [[data objectForKey:@"failCode"]count] + [[data4Add objectForKey:@"failCode"]count]]]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                            }
                            else
                                [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }];
                    }
                }
            }];
        }
        
        //第二部，删除管理员
        else if (array4Delete.count > 0)
        {
            [NetworkModule delGroupAssistant:self.groupId assistant:array4Delete completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                [BiChatGlobal HideActivityIndicator];
                if (success)
                {
                    NSMutableArray *array4DeletedAssistant = [NSMutableArray array];
                    for (NSString *str in array4Delete)
                    {
                        //这个群成员是否失败
                        if ([[data objectForKey:@"failCode"]objectForKey:str] != nil)
                        {
                            [array4MemberUid addObject:str];
                            continue;
                        }
                        
                        //获取新群嘉宾的昵称
                        NSString *str4NickName = @"";
                        for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                        {
                            if ([str isEqualToString:[item objectForKey:@"uid"]])
                            {
                                str4NickName = [item objectForKey:@"nickName"];
                                break;
                            }
                        }
                        //没有找到，从系统里面查一下
                        if (str4NickName.length == 0)
                            str4NickName = [[BiChatGlobal sharedManager].dict4NickNameCache objectForKey:str];
                        
                        //装配一个新的通知消息
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"uid",
                                              str4NickName, @"nickName",
                                              nil];
                        
                        [array4DeletedAssistant addObject:dict];
                    }
                    
                    [self.groupProperty setObject:array4MemberUid forKey:@"assitantUid"];
                    [self.tableView reloadData];
                    
                    if (array4DeletedAssistant.count > 0)
                    {
                        //同时要发送一条数据通知群中的其他成员
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_DELASSISTANT], @"type",
                                                         [array4DeletedAssistant mj_JSONString], @"content",
                                                         self.groupId, @"receiver",
                                                         [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                                //加入本地一条消息
                                if (self.ownerChatWnd != nil)
                                    [self.ownerChatWnd appendMessage:sendData];
                                else
                                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                                      peerUserName:@""
                                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:NO];
                            }
                        }];
                    }
                    
                    //提示用户
                    if ([[data objectForKey:@"failCode"]count] == 0)
                        [BiChatGlobal showInfo:[LLSTR(@"301767")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)array4Delete.count]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                    else
                        [BiChatGlobal showInfo:[LLSTR(@"301768")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", array4Delete.count - [[data objectForKey:@"failCode"]count]], [NSString stringWithFormat:@"%ld", [[data objectForKey:@"failCode"]count]]]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                else
                    [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
    }
    else if (cookie == 3)           //设置群嘉宾
    {
        //先找出添加了谁，删除了谁
        NSMutableArray *array4Delete = [NSMutableArray arrayWithArray:[self.groupProperty objectForKey:@"vip"]];
        NSMutableArray *array4DeleteDelete = [NSMutableArray array];
        for (NSString *item in array4Delete)
        {
            for (NSString *item2 in array4MemberUid)
            {
                if ([item isEqualToString:item2])
                {
                    [array4DeleteDelete addObject:item];
                    break;
                }
            }
        }
        [array4Delete removeObjectsInArray:array4DeleteDelete];
        NSMutableArray *array4Add = [NSMutableArray array];
        for (NSDictionary *item in array4MemberUid)
            [array4Add addObject:item];
        NSMutableArray *array4DeleteAdd = [NSMutableArray array];
        for (NSString *item in array4Add)
        {
            for (NSString *item2 in [self.groupProperty objectForKey:@"vip"])
            {
                if ([item isEqualToString:item2])
                {
                    [array4DeleteAdd addObject:item];
                    break;
                }
            }
        }
        [array4Add removeObjectsInArray:array4DeleteAdd];
        
        //第一步，添加群嘉宾
        if (array4Add.count > 0)
        {
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule addGroupVIP:self.groupId VIP:array4Add completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                [BiChatGlobal HideActivityIndicator];
                if (success)
                {
                    //NSLog(@"%@", data);
                    NSMutableArray *array4NewVIP = [NSMutableArray array];
                    for (NSString *str in array4Add)
                    {
                        //这个群成员是否失败
                        if ([[data objectForKey:@"failCode"]objectForKey:str] != nil)
                        {
                            for (int i = 0; i < array4MemberUid.count; i ++)
                            {
                                if ([str isEqualToString:[array4MemberUid objectAtIndex:i]])
                                {
                                    [array4MemberUid removeObjectAtIndex:i];
                                    break;
                                }
                            }
                            continue;
                        }
                        
                        //获取新群嘉宾的昵称
                        NSString *str4NickName = @"";
                        for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                        {
                            if ([str isEqualToString:[item objectForKey:@"uid"]])
                            {
                                str4NickName = [item objectForKey:@"nickName"];
                                break;
                            }
                        }
                        //没有找到，从系统里面查一下
                        if (str4NickName.length == 0)
                            str4NickName = [[BiChatGlobal sharedManager].dict4NickNameCache objectForKey:str];
                        
                        //装配一个新的通知消息
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"uid",
                                              str4NickName, @"nickName",
                                              nil];
                        
                        [array4NewVIP addObject:dict];
                    }
                    
                    [self.groupProperty setObject:array4MemberUid forKey:@"vip"];
                    [self.tableView reloadData];
                    
                    //没有人成功的设置成为群嘉宾
                    if (array4NewVIP.count > 0)
                    {
                        //同时要发送一条数据通知群中的其他成员
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDVIP], @"type",
                                                         [array4NewVIP mj_JSONString], @"content",
                                                         self.groupId, @"receiver",
                                                         [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                                //加入本地一条消息
                                if (self.ownerChatWnd != nil)
                                    [self.ownerChatWnd appendMessage:sendData];
                                else
                                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                                      peerUserName:@""
                                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:YES];
                            }
                        }];
                    }
                    
                    //是否有第二步
                    if (array4Delete.count == 0)
                    {
                        //没有第二步
                        [BiChatGlobal HideActivityIndicator];
                        if ([[data objectForKey:@"failCode"]count] == 0)
                            [BiChatGlobal showInfo:[LLSTR(@"301771")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)array4Add.count]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                        else
                            [BiChatGlobal showInfo:[LLSTR(@"301772")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", array4Add.count - [[data objectForKey:@"failCode"]count]], [NSString stringWithFormat:@"%ld", [[data objectForKey:@"failCode"]count]]]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    }
                    else
                    {
                        NSDictionary *data4Add = data;
                        [NetworkModule delGroupVIP:self.groupId VIP:array4Delete completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                            [BiChatGlobal HideActivityIndicator];
                            if (success)
                            {
                                NSMutableArray *array4DeletedVIP = [NSMutableArray array];
                                for (NSString *str in array4Delete)
                                {
                                    //这个群成员是否失败
                                    if ([[data objectForKey:@"failCode"]objectForKey:str] != nil)
                                    {
                                        [array4MemberUid addObject:str];
                                        continue;
                                    }
                                    
                                    //获取新群嘉宾的昵称
                                    NSString *str4NickName = @"";
                                    for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                                    {
                                        if ([str isEqualToString:[item objectForKey:@"uid"]])
                                        {
                                            str4NickName = [item objectForKey:@"nickName"];
                                            break;
                                        }
                                    }
                                    //没有找到，从系统里面查一下
                                    if (str4NickName.length == 0)
                                        str4NickName = [[BiChatGlobal sharedManager].dict4NickNameCache objectForKey:str];
                                    
                                    //装配一个新的通知消息
                                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"uid",
                                                          str4NickName, @"nickName",
                                                          nil];
                                    
                                    [array4DeletedVIP addObject:dict];
                                }
                                
                                [self.groupProperty setObject:array4MemberUid forKey:@"vip"];
                                [self.tableView reloadData];
                                
                                if (array4DeletedVIP.count > 0)
                                {
                                    //同时要发送一条数据通知群中的其他成员
                                    NSString *msgId = [BiChatGlobal getUuidString];
                                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_DELVIP], @"type",
                                                                     [array4DeletedVIP mj_JSONString], @"content",
                                                                     self.groupId, @"receiver",
                                                                     [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                                            //加入本地一条消息
                                            if (self.ownerChatWnd != nil)
                                                [self.ownerChatWnd appendMessage:sendData];
                                            else
                                                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                                            [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                                                  peerUserName:@""
                                                                                  peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                                    peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                                         isNew:NO
                                                                                       isGroup:YES
                                                                                      isPublic:NO
                                                                                     createNew:NO];
                                        }
                                    }];
                                }
                                
                                //提示用户
                                if ([[data objectForKey:@"failCode"]count] == 0 && [[data4Add objectForKey:@"failCode"]count] == 0)
                                    [BiChatGlobal showInfo:[LLSTR(@"301775")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)array4Add.count], [NSString stringWithFormat:@"%ld", (long)array4Delete.count]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                                else
                                    [BiChatGlobal showInfo:[LLSTR(@"301776")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", array4Add.count - [[data4Add objectForKey:@"failCode"]count]], [NSString stringWithFormat:@"%ld", array4Delete.count - [[data objectForKey:@"failCode"]count]], [NSString stringWithFormat:@"%ld", [[data objectForKey:@"failCode"]count] + [[data4Add objectForKey:@"failCode"]count]]]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                            }
                            else
                                [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }];
                    }
                }
                else
                {
                    [BiChatGlobal HideActivityIndicator];
                    [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
            }];
        }
        
        //第二部，删除群嘉宾
        else if (array4Delete.count > 0)
        {
            [BiChatGlobal ShowActivityIndicator];
            [NetworkModule delGroupVIP:self.groupId VIP:array4Delete completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                [BiChatGlobal HideActivityIndicator];
                if (success)
                {
                    NSMutableArray *array4DeletedVIP = [NSMutableArray array];
                    for (NSString *str in array4Delete)
                    {
                        //这个群成员是否失败
                        if ([[data objectForKey:@"failCode"]objectForKey:str] != nil)
                        {
                            [array4MemberUid addObject:str];
                            continue;
                        }
                        
                        //获取新群嘉宾的昵称
                        NSString *str4NickName = @"";
                        for (NSDictionary *item in [self.groupProperty objectForKey:@"groupUserList"])
                        {
                            if ([str isEqualToString:[item objectForKey:@"uid"]])
                            {
                                str4NickName = [item objectForKey:@"nickName"];
                                break;
                            }
                        }
                        //没有找到，从系统里面查一下
                        if (str4NickName.length == 0)
                            str4NickName = [[BiChatGlobal sharedManager].dict4NickNameCache objectForKey:str];
                        
                        //装配一个新的通知消息
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"uid",
                                              str4NickName, @"nickName",
                                              nil];
                        
                        [array4DeletedVIP addObject:dict];
                    }
                    
                    [self.groupProperty setObject:array4MemberUid forKey:@"vip"];
                    [self.tableView reloadData];
                    
                    if (array4DeletedVIP.count > 0)
                    {
                        //同时要发送一条数据通知群中的其他成员
                        NSString *msgId = [BiChatGlobal getUuidString];
                        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_DELVIP], @"type",
                                                         [array4DeletedVIP mj_JSONString], @"content",
                                                         self.groupId, @"receiver",
                                                         [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                                //加入本地一条消息
                                if (self.ownerChatWnd != nil)
                                    [self.ownerChatWnd appendMessage:sendData];
                                else
                                    [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                                [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                                      peerUserName:@""
                                                                      peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                                        peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                                           message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                                       messageTime:[BiChatGlobal getCurrentDateString]
                                                                             isNew:NO
                                                                           isGroup:YES
                                                                          isPublic:NO
                                                                         createNew:NO];
                            }
                        }];
                    }
                    
                    //提示用户
                    if ([[data objectForKey:@"failCode"]count] == 0)
                        [BiChatGlobal showInfo:[LLSTR(@"301773")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", (long)array4Delete.count]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                    else
                        [BiChatGlobal showInfo:[LLSTR(@"301774")llReplaceWithArray:@[[NSString stringWithFormat:@"%ld", array4Delete.count - [[data objectForKey:@"failCode"]count]], [NSString stringWithFormat:@"%ld", [[data objectForKey:@"failCode"]count]]]] withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
                else
                    [BiChatGlobal showInfo:LLSTR(@"301017") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
    }
    else if (cookie == 4)       //群成员迁移第一步
    {
        //第二步，选择一个群组
        ChatSelectViewController *wnd = [ChatSelectViewController new];
        wnd.defaultTitle = LLSTR(@"102419");
        wnd.showGroupOnly = YES;
        wnd.hideVirtualManageGroup = YES;
        wnd.delegate = self;
        wnd.cookie = 1;
        wnd.target = member;
        wnd.canShowBlock = ^BOOL(NSString *groupId) {
            
            //只显示和本群有同样的群主，并且我都是管理员或群主
            //获取目标群的属性
            NSDictionary *targetGroupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
            if ([[targetGroupProperty objectForKey:@"virtualGroupId"]length] > 0)
            {
                targetGroupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[[targetGroupProperty objectForKey:@"virtualGroupSubList"]firstObject]objectForKey:@"groupId"]];
            }

            //群主是否相同
            if (![[targetGroupProperty objectForKey:@"ownerUid"] isEqualToString:[self.groupProperty objectForKey:@"ownerUid"]])
                return NO;
            
            //我是否都是管理员
            if (![BiChatGlobal isMeGroupOperator:targetGroupProperty] ||
                ![BiChatGlobal isMeGroupOperator:self.groupProperty])
                return NO;
            
            //群是否已经被解散
            if ([[targetGroupProperty objectForKey:@"disabled"]boolValue])
                return NO;
            
            return YES;
        };
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    
    //设置群入群沟通
    else if (cookie == 5)
    {
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule setGroupPublicProfile:self.groupId profile:@{@"customerServiceManager": [[member firstObject]objectForKey:@"uid"]} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                [self.groupProperty setObject:[[member firstObject]objectForKey:@"uid"] forKey:@"customerServiceManager"];
                [self.tableView reloadData];
                [BiChatGlobal showInfo:LLSTR(@"201347") withIcon:[UIImage imageNamed:@"icon_OK"]];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"201348") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
}

#pragma mark - ChatSelectDelegate

- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target
{
    if (cookie == 1)        //群成员迁移第二步
    {
        NSDictionary *targetGroupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[[chats firstObject]objectForKey:@"peerUid"]];
        //如果本群为收费群而对方不是收费群
        if ([[self.groupProperty objectForKey:@"payGroup"]boolValue] &&
            ![[targetGroupProperty objectForKey:@"payGroup"]boolValue])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                     message:LLSTR(@"204124")
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                //开始移动群成员
                NSArray *members = (NSArray *)target;
                [self moveMembersTo:[[chats firstObject]objectForKey:@"peerUid"] members:members];
                
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertController addAction:confirmAction];
            [alertController addAction:cancelAction];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentViewController:alertController animated:YES completion:^{}];
            }];
        }
        else
        {
            //开始移动群成员
            NSArray *members = (NSArray *)target;
            [self moveMembersTo:[[chats firstObject]objectForKey:@"peerUid"] members:members];
            
            //关闭选择窗口
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)moveMembersTo:(NSString *)groupId members:(NSArray *)members
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule copyGroupMemberFrom:self.groupId To:groupId members:members completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        
        //统计一下有几个人没有移动成功
        NSMutableArray *array4Success = [NSMutableArray array];
        NSInteger starveCount = 0, failCount = 0;
        for (NSString *key in [data objectForKey:@"failData"])
        {
            if ([[[data objectForKey:@"failCode"]objectForKey:key]integerValue] == 20011)
                starveCount ++;
            else
                failCount ++;
        }
        for (NSDictionary *item in [data objectForKey:@"data"])
        {
            if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"] ||
                [[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP"])
            {
                for (NSDictionary *user in members)
                {
                    if ([[user objectForKey:@"uid"]isEqualToString:[item objectForKey:@"uid"]])
                    {
                        [array4Success addObject:user];
                        break;
                    }
                }
            }
        }
        
        if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
        {
            if (array4Success.count == members.count)
                [BiChatGlobal showInfo:[LLSTR(@"204134") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",(long)members.count]]]
                              withIcon:[UIImage imageNamed:@"icon_OK"]];
            else
                [BiChatGlobal showInfo:[LLSTR(@"204135") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",(long)array4Success.count] ,[NSString stringWithFormat:@"%ld",(long)failCount], [NSString stringWithFormat:@"%ld", (long)starveCount]]]
                              withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        else
        {
            if (array4Success.count == members.count)
                [BiChatGlobal showInfo:[LLSTR(@"301763") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",(long)members.count]]]
                              withIcon:[UIImage imageNamed:@"icon_OK"]];
            else
                [BiChatGlobal showInfo:[LLSTR(@"301764") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",(long)array4Success.count] ,[NSString stringWithFormat:@"%ld",(long)(members.count - array4Success.count)]]]
                              withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
        
        //需要向两个群发消息
        if (array4Success.count > 0)
        {
            [MessageHelper sendGroupMessageTo:self.groupId
                                         type:MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBEROUT
                                      content:[array4Success mj_JSONString]
                                     needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                     }];
            
            [MessageHelper sendGroupMessageTo:groupId type:MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBERIN content:[array4Success mj_JSONString] needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
            
            //修改本地的群成员列表
            [NetworkModule getGroupProperty:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    [self.groupProperty setObject:[data objectForKey:@"groupUserList"] forKey:@"groupUserList"];
                }
            }];
        }
        
        //关闭选择窗口
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - 私有函数

- (UIView *)createOperationPanel
{
    //是否群主
    if (![[self.groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid] ||
        [[self.groupProperty objectForKey:@"disabled"]boolValue])
        return nil;
    
    //是否广播群
    if ([BiChatGlobal isBroadcastGroup:self.groupProperty groupId:self.groupId])
        return nil;
    
    //群主
    UIView *view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    
    UIButton *button4Dismiss = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    button4Dismiss.backgroundColor = [UIColor whiteColor];
    button4Dismiss.titleLabel.font = [UIFont systemFontOfSize:16];
    button4Dismiss.layer.cornerRadius = 5;
    button4Dismiss.clipsToBounds = YES;
    [button4Dismiss addTarget:self action:@selector(onButtonDismiss:) forControlEvents:UIControlEventTouchUpInside];
    [button4Dismiss setTitle:LLSTR(@"201322") forState:UIControlStateNormal];
    [button4Dismiss setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [view4Panel addSubview:button4Dismiss];
    
    return view4Panel;
}

- (void)onButtonDismiss:(id)sender
{
    if ([[_groupProperty objectForKey:@"payGroup"]boolValue])
        [self dismissChargeGroup];
    else
        [self dismissGroup];
}

- (void)dismissGroup
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:LLSTR(@"201325")
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissGroupInternal];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)dismissChargeGroup
{
    //先获取解散群需要的花费
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getDismissChargeGroupFee:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        
        //生成需要显示的消息字符串
        NSMutableArray *array1 = [NSMutableArray array];
        for (NSString *key in [data objectForKey:@"balance"])
        {
            NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:key];
            NSString *str = [NSString stringWithFormat:@"%@ %@", [[BiChatGlobal decimalNumberWithDouble: [[[data objectForKey:@"balance"]objectForKey:key]doubleValue]]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", (long)[[coinInfo objectForKey:@"bit"]integerValue]] auotCheck:YES], [coinInfo objectForKey:@"dSymbol"]];
            [array1 addObject:str];
        }
        NSMutableArray *array2 = [NSMutableArray array];
        for (NSString *key in [data objectForKey:@"requestBalance"])
        {
            NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:key];
            NSString *str = [NSString stringWithFormat:@"%@ %@", [[BiChatGlobal decimalNumberWithDouble: [[[data objectForKey:@"requestBalance"]objectForKey:key]doubleValue]]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", (long)[[coinInfo objectForKey:@"bit"]integerValue]] auotCheck:YES], [coinInfo objectForKey:@"dSymbol"]];
            [array2 addObject:str];
        }
        NSString *balance = [array1 componentsJoinedByString:@", "];
        NSString *requestBalance = [array2 componentsJoinedByString:@", "];
        NSString *number = [NSString stringWithFormat:@"%@", [data objectForKey:@"refundUserCount"]];
        NSString *message;
        if (requestBalance.length == 0)
            message = [LLSTR(@"204126")llReplaceWithArray:@[number]];
        else
            message = [LLSTR(@"204125")llReplaceWithArray:@[number, requestBalance, balance]];
        
        if (success)
        {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"204121") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //正式开始解散
                [self dismissGroupInternal];
                
            }];
            UIAlertAction *act2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:act1];
            [alertC addAction:act2];
            [self presentViewController:alertC animated:YES completion:nil];
        }
        else if (errorCode == 20011)
        {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"204121") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"204127") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *act2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [act1 setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
            [alertC addAction:act1];
            [alertC addAction:act2];
            [self presentViewController:alertC animated:YES completion:nil];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)dismissGroupInternal
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule dismissGroup:self.groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        
        if (success)
        {
            if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
            {
                NSInteger starveCount = 0, failCount = 0;
                for (NSString *key in [data objectForKey:@"failData"])
                {
                    if ([[[data objectForKey:@"failCode"]objectForKey:key]integerValue] == 20011)
                        starveCount ++;
                    else
                        failCount ++;
                }
                if (starveCount == 0 && failCount == 0)
                {
                    [BiChatGlobal showInfo:[LLSTR(@"204136")llReplaceWithArray:@[[NSString stringWithFormat:@"%@", [self.groupProperty objectForKey:@"joinedGroupUser"]]]] withIcon:[UIImage imageNamed:@"icon_OK"]];
                }
                else
                {
                    [BiChatGlobal showInfo:[LLSTR(@"204137")llReplaceWithArray:@[[NSString stringWithFormat:@"%@", [self.groupProperty objectForKey:@"joinedGroupUser"]], [NSString stringWithFormat:@"%ld", (long)failCount], [NSString stringWithFormat:@"%ld", (long)starveCount]]] withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301728") withIcon:[UIImage imageNamed:@"icon_OK"]];
            
            //连退两层
            NSArray *array = self.navigationController.viewControllers;
            if (array.count > 2)
            {
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:array];
                [viewControllers removeLastObject];
                [viewControllers removeLastObject];
                [self.navigationController setViewControllers:viewControllers animated:YES];
            }
            else
                [self.navigationController popViewControllerAnimated:YES];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301729") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}


//切换仅群主和管理员可以修改群名
- (void)onSwitchCanChangeGroupName:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    //设置高级消息
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:s.on], @"changeNameRightOnly", nil];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [self.groupProperty setObject:[NSNumber numberWithBool:s.on] forKey:@"changeNameRightOnly"];
            [self.tableView reloadData];
            
            //装配一个新的通知消息
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid",
                                  [BiChatGlobal sharedManager].nickName, @"nickName",
                                  nil];
            
            //同时要发送一条数据通知群中的其他成员
            NSString *msgId = [BiChatGlobal getUuidString];
            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", s.on?MESSAGE_CONTENT_TYPE_SETADMINCHANGENAMEONLY:MESSAGE_CONTENT_TYPE_CLEARADMINCHANGENAMEONLY], @"type",
                                             [dict mj_JSONString], @"content",
                                             self.groupId, @"receiver",
                                             [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                    [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                          peerUserName:@""
                                                          peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                            peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                    
                    //加入本地一条消息
                    if (self.ownerChatWnd != nil)
                    {
                        [self.ownerChatWnd appendMessage:sendData];
                    }
                    else
                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                }
            }];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:nil];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 47", nil];
        }
    }];
}

//切换仅群主和管理员可以添加成员
- (void)onSwitchCanAddMember:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    //是否需要查找服务器
    if (!s.on)
    {
        //统计一下有几个待审批
        NSInteger count = 0;
        for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
        {
            if ([[item objectForKey:@"groupId"]isEqualToString:self.groupId])
                count ++;
        }
        
        if (count > 0)
        {
            //询问用户是否关闭成员确认
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"201339")
                                                                                     message:[NSString stringWithFormat:@"\r\n%@", LLSTR(@"201340")]
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:LLSTR(@"101003") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self setCanAddMember:s.on];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                //重新置位
                s.on = YES;
            }];
            [alertController addAction:OKAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:^{}];
        }
        else
            [self setCanAddMember:s.on];
    }
    else
        [self setCanAddMember:s.on];
}

- (void)onSwitchOnlyAssistantCanAddFriend:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    //设置高级消息
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:s.on], @"onlyAssistantCanAddFriend", nil];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [self.groupProperty setObject:[NSNumber numberWithBool:s.on] forKey:@"onlyAssistantCanAddFriend"];
            [self.tableView reloadData];
            
            //装配一个新的通知消息
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid",
                                  [BiChatGlobal sharedManager].nickName, @"nickName",
                                  nil];
            
            //同时要发送一条数据通知群中的其他成员
            NSString *msgId = [BiChatGlobal getUuidString];
            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", s.on?MESSAGE_CONTENT_TYPE_SETADMINADDFRIENDONLY:MESSAGE_CONTENT_TYPE_CLEARADMINADDFRIENDONLY], @"type",
                                             [dict mj_JSONString], @"content",
                                             self.groupId, @"receiver",
                                             [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                    //加入本地一条消息
                    if (self.ownerChatWnd != nil)
                    {
                        [self.ownerChatWnd appendMessage:sendData];
                    }
                    else
                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                    [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                          peerUserName:@""
                                                          peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                            peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                }
            }];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:nil];
        }
    }];
}

//设置群聊邀请确认
- (void)setCanAddMember:(BOOL)canAddMember
{
    //设置高级消息
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:canAddMember], @"addNewMemberRightOnly", nil];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [self.groupProperty setObject:[NSNumber numberWithBool:canAddMember] forKey:@"addNewMemberRightOnly"];
            [self.tableView reloadData];
            
            //需要提示用户
            [BiChatGlobal showInfo:canAddMember?LLSTR(@"301751"):LLSTR(@"301709") withIcon:[UIImage imageNamed:@"icon_OK"]];
            
            //装配一个新的通知消息
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid",
                                  [BiChatGlobal sharedManager].nickName, @"nickName",
                                  nil];
            
            //同时要发送一条数据通知群中的其他成员
            NSString *msgId = [BiChatGlobal getUuidString];
            NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", canAddMember?MESSAGE_CONTENT_TYPE_SETADMINADDUSERONLY:MESSAGE_CONTENT_TYPE_CLEARADMINADDUSERONLY], @"type",
                                            [dict mj_JSONString], @"content",
                                            self.groupId, @"receiver",
                                            [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                [self.ownerChatWnd appendMessage:message];
            else
                [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:message];
            [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                  peerUserName:@""
                                                  peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                    peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:self.groupProperty]
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:YES
                                                      isPublic:NO
                                                     createNew:YES];
            [NetworkModule sendMessageToGroup:self.groupId message:message completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            }];
            
            //先生成所有朋友的列表字符串
            NSMutableArray *array4PeersProcessed = [NSMutableArray array];
            NSMutableArray *array4PeersSuccess = [NSMutableArray array];
            NSMutableDictionary *dict4PeersSuccess = [NSMutableDictionary dictionary];
            NSMutableArray *array4PeersFail = [NSMutableArray array];
            NSMutableArray *array4PeersBlocked = [NSMutableArray array];
            NSMutableArray *array4PeersFull = [NSMutableArray array];
            NSMutableArray *array4PeersTrail = [NSMutableArray array];
            NSMutableArray *array4PeersAlreadyInWaitingPayList = [NSMutableArray array];

            for (int i = 0; i < [BiChatGlobal sharedManager].array4ApproveList.count; i ++)
            {
                NSMutableDictionary *peer = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [[[BiChatGlobal sharedManager].array4ApproveList objectAtIndex:i]objectForKey:@"uid"], @"uid",
                                             [[[BiChatGlobal sharedManager].array4ApproveList objectAtIndex:i]objectForKey:@"nickName"], @"nickName",
                                             [[[BiChatGlobal sharedManager].array4ApproveList objectAtIndex:i]objectForKey:@"avatar"]==nil?@"":[[[BiChatGlobal sharedManager].array4ApproveList objectAtIndex:i]objectForKey:@"avatar"], @"avatar",
                                             nil];
                
                //这一条是否添加进群组成功
                for (NSDictionary *item in [data objectForKey:@"data"])
                {
                    if ([[item objectForKey:@"uid"]isEqualToString:[[[BiChatGlobal sharedManager].array4ApproveList objectAtIndex:i]objectForKey:@"uid"]] &&
                        [self.groupId isEqualToString:[[[BiChatGlobal sharedManager].array4ApproveList objectAtIndex:i]objectForKey:@"groupId"]])
                    {
                        if ([[item objectForKey:@"result"]isEqualToString:@"SUCCESS"])
                        {
                            if ([item objectForKey:@"joinedGroupId"] == nil ||
                                [[item objectForKey:@"joinedGroupId"]isEqualToString:self.groupId])
                            {
                                if ([[self.groupProperty objectForKey:@"payGroup"]boolValue])
                                    [array4PeersTrail addObject:peer];
                                else
                                    [array4PeersSuccess addObject:peer];
                                [array4PeersProcessed addObject:peer];
                            }
                            else
                            {
                                NSMutableArray *array = [dict4PeersSuccess objectForKey:[item objectForKey:@"joinedGroupId"]];
                                if (array == nil)
                                {
                                    array = [NSMutableArray array];
                                    [dict4PeersSuccess setObject:array forKey:[item objectForKey:@"joinedGroupId"]];
                                }
                                [array addObject:peer];
                                [array4PeersProcessed addObject:peer];
                            }
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"NOT_YOUR_FRIEND"])
                        {
                            [array4PeersFail addObject:peer];
                            [array4PeersProcessed addObject:peer];
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"BLOCKED"])
                        {
                            [array4PeersBlocked addObject:peer];
                            [array4PeersProcessed addObject:peer];
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"GROUP_IS_FULL"])
                        {
                            [array4PeersFull addObject:peer];
                            [array4PeersProcessed addObject:peer];
                        }
                        else if ([[item objectForKey:@"result"]isEqualToString:@"ALREADY_IN_GROUP_WAITING_PAY_LIST"] ||
                                 [[item objectForKey:@"result"]isEqualToString:@"JOIN_WAITING_PAY_LIST"])
                        {
                            [array4PeersAlreadyInWaitingPayList addObject:peer];
                            [array4PeersProcessed addObject:peer];
                            break;
                        }
                    }
                }
            }
            
            //NSLog(@"2-%@", dict4PeersSuccess);
            //NSLog(@"3-%@", array4PeersFail);
            //NSLog(@"4-%@", array4PeersBlocked);
            //NSLog(@"5-%@", array4PeersFull);
            //NSLog(@"6-%@", array4PeersSuccess);
            
            //分别处理几种情况，有人被加入到了本群
            if (array4PeersSuccess.count > 0 || array4PeersTrail.count > 0 || array4PeersAlreadyInWaitingPayList.count > 0)
            {
                [self notifyGroupAssignMember:array4PeersSuccess];
            }
            
            //有人被加入到了其他子群
            if (dict4PeersSuccess.count > 0 && [[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
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
                            [self notifyVirtualGroupAssignMember:self.groupId groupProperty:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                        }];
                    }
                    else
                    {
                        //NSLog(@"通知一个老群：%@", groupProperty);
                        [self notifyVirtualGroupAssignMember:self.groupId groupProperty:groupProperty subGroupId:key dict4PeersSuccess:dict4PeersSuccess];
                    }
                }
            }
            
            //是不是有群已经满了，而被拒绝的人
            if (array4PeersFull.count > 0)
            {
                NSString *msgId = [BiChatGlobal getUuidString];
                NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_FULL], @"type",
                                                 [array4PeersFull mj_JSONString], @"content",
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
            
            //修改申请列表
            for (NSDictionary *item1 in array4PeersProcessed)
            {
                for (NSDictionary *item2 in [BiChatGlobal sharedManager].array4ApproveList)
                {
                    if ([[item1 objectForKey:@"uid"] isEqualToString:[item2 objectForKey:@"uid"]] &&
                        [[item2 objectForKey:@"groupId"]isEqualToString:self.groupId])
                    {
                        [[BiChatGlobal sharedManager].array4ApproveList removeObject:item2];
                        break;
                    }
                }
            }
            [[BiChatGlobal sharedManager]saveUserAdditionInfo];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:nil];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 48", nil];
        }
    }];
}


//通知本群，有人进入
- (void)notifyGroupAssignMember:(NSArray *)array4PeersSuccess
{
    NSDictionary *dict4Content = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.groupId, @"fromGroupId",
                                  self.groupId, @"groupId",
                                  array4PeersSuccess, @"assignedMember",
                                  nil];
    
    //生成一条新消息
    NSString *msgId = [BiChatGlobal getUuidString];
    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP], @"type",
                                     [dict4Content mj_JSONString], @"content",
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
                                     [dict4Content mj_JSONString], @"content",
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
                                         [dict4Content mj_JSONString], @"content",
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

//切换仅群主和管理员可以加入精选
- (void)onSwitchCanPinMessage:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    //设置高级消息
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:s.on], @"dingRightOnly", nil];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [self.groupProperty setObject:[NSNumber numberWithBool:s.on] forKey:@"dingRightOnly"];
            [self.tableView reloadData];
            
            //装配一个新的通知消息
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid",
                                  [BiChatGlobal sharedManager].nickName, @"nickName",
                                  nil];
            
            //同时要发送一条数据通知群中的其他成员
            NSString *msgId = [BiChatGlobal getUuidString];
            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", s.on?MESSAGE_CONTENT_TYPE_SETADMINPINONLY:MESSAGE_CONTENT_TYPE_CLEARADMINPINONLY], @"type",
                                             [dict mj_JSONString], @"content",
                                             self.groupId, @"receiver",
                                             [self.groupProperty objectForKey:@"groupName"], @"receiverNickName",
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
                    //加入本地一条消息
                    if (self.ownerChatWnd != nil)
                    {
                        [self.ownerChatWnd appendMessage:sendData];
                    }
                    else
                        [[BiChatDataModule sharedDataModule]addChatContentWith:self.groupId content:sendData];
                    [[BiChatDataModule sharedDataModule]setLastMessage:self.groupId
                                                          peerUserName:@""
                                                          peerNickName:[self.groupProperty objectForKey:@"groupName"]
                                                            peerAvatar:[BiChatGlobal getGroupAvatar:self.groupProperty]
                                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:self.groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO
                                                               isGroup:YES
                                                              isPublic:NO
                                                             createNew:YES];
                }
            }];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:nil];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 49", nil];
        }
    }];
}

//切换是否允许自动分配
- (void)onSwitchAllowAutoJoinGroup:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    //设置高级消息
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:!s.on], @"notAllowAutoJoinGroup", nil];
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            [self.groupProperty setObject:[NSNumber numberWithBool:!s.on] forKey:@"notAllowAutoJoinGroup"];
            [self.tableView reloadData];
        }
        else
            s.on = !s.on;
    }];
}

//移动群成员
- (void)moveGroupMember
{
    GroupMemberSelectorViewController *wnd = [GroupMemberSelectorViewController new];
    wnd.defaultTitle = LLSTR(@"201306");
    wnd.defaultDoneTitle = LLSTR(@"201326");
    wnd.canSelectOwner = NO;
    wnd.canSelectAssistant = NO;
    wnd.needConfirm = YES;
    wnd.multiSelect = YES;
    wnd.multiSelectTitle = LLSTR(@"201307");
    wnd.cookie = 4;
    wnd.delegate = self;
    wnd.groupId = self.groupId;
    wnd.groupProperty = self.groupProperty;
    wnd.showMemo = YES;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

@end
