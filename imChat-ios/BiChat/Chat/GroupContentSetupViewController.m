//
//  GroupContentSetupViewController.m
//  BiChat Dev
//
//  Created by imac2 on 2018/11/13.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "GroupContentSetupViewController.h"
#import "MessageHelper.h"

@interface GroupContentSetupViewController ()

@end

@implementation GroupContentSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"201208");
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    
    //当前context是否可以设置
    canSetup = YES;
    if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([self.groupId isEqualToString:[item objectForKey:@"groupId"]])
            {
                if ([[item objectForKey:@"virtualGroupNum"]integerValue] != 0)
                {
                    canSetup = NO;
                    break;
                }
            }
        }
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
        return 3;
    else
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else if (section == 1)
        return 3;
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSString *str;
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]integerValue] > 0)
            str = [NSString stringWithFormat:@"%@",LLSTR(@"201403")];
        else
            str = [NSString stringWithFormat:@"%@",LLSTR(@"201403")];
        
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
        return rect.size.height + 20;
    }
    else if (section == 1)
    {
        NSString *str;
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]integerValue] > 0)
            str = LLSTR(@"201402");
        else
            str = LLSTR(@"201402");
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
        return rect.size.height + 70;
    }
    else
        return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSString *str;
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]integerValue] > 0)
            str = [NSString stringWithFormat:@"%@",LLSTR(@"201403")];
        else
            str = [NSString stringWithFormat:@"%@",LLSTR(@"201403")];
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
        
        UIView *view4BroadcastSectionFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, rect.size.height + 15)];
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, rect.size.width, rect.size.height)];
        label4Title.text = str;
        label4Title.numberOfLines = 0;
        label4Title.font = [UIFont systemFontOfSize:14];
        label4Title.textColor = [UIColor grayColor];
        [view4BroadcastSectionFooter addSubview:label4Title];
        
        return view4BroadcastSectionFooter;
    }
    else if (section == 1)
    {
        NSString *str;
        if ([[self.groupProperty objectForKey:@"virtualGroupId"]integerValue] > 0)
            str = LLSTR(@"201402");
        else
            str = LLSTR(@"201402");
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
        
        UIView *view4BroadcastSectionFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, rect.size.height + 15)];
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, rect.size.height)];
        label4Title.text = str;
        label4Title.numberOfLines = 0;
        label4Title.font = [UIFont systemFontOfSize:14];
        label4Title.textColor = [UIColor grayColor];
        label4Title.textAlignment = NSTextAlignmentCenter;
        [view4BroadcastSectionFooter addSubview:label4Title];
        
        return view4BroadcastSectionFooter;
    }
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"201401");
        
        if (canSetup && [BiChatGlobal isMeGroupOperator:self.groupProperty])
        {
            UISwitch *switch4Broadcase = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4Broadcase addTarget:self action:@selector(onSwitchBroadcast:) forControlEvents:UIControlEventValueChanged];
            switch4Broadcase.on = [[_groupProperty objectForKey:@"mute"]boolValue];
            cell.accessoryView = switch4Broadcase;
        }
        else
        {
            cell.detailTextLabel.text = [[self.groupProperty objectForKey:@"mute"]boolValue]?LLSTR(@"201333"):LLSTR(@"201334");
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"201404");
        BOOL on = YES;
        if ([[_groupProperty objectForKey:@"forbidOperations"]count] > 0)
            on = ![[[_groupProperty objectForKey:@"forbidOperations"]objectAtIndex:0]boolValue];
        
        if (canSetup && [BiChatGlobal isMeGroupOperator:self.groupProperty])
        {
            UISwitch *switch4TextWithLink = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4TextWithLink addTarget:self action:@selector(onSwitchTextWithLink:) forControlEvents:UIControlEventValueChanged];
            switch4TextWithLink.on = on;
            cell.accessoryView = switch4TextWithLink;
        }
        else
        {
            cell.detailTextLabel.text = on?LLSTR(@"201336"):LLSTR(@"201335");
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"201405");
        BOOL on = YES;
        if ([[_groupProperty objectForKey:@"forbidOperations"]count] > 1)
            on = ![[[_groupProperty objectForKey:@"forbidOperations"]objectAtIndex:1]boolValue];
        
        if (canSetup && [BiChatGlobal isMeGroupOperator:self.groupProperty])
        {
            UISwitch *switch4ImageWithVRCode = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4ImageWithVRCode addTarget:self action:@selector(onSwitchImageWithVRCode:) forControlEvents:UIControlEventValueChanged];
            switch4ImageWithVRCode.on = on;
            cell.accessoryView = switch4ImageWithVRCode;
        }
        else
        {
            cell.detailTextLabel.text = on?LLSTR(@"201336"):LLSTR(@"201335");
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"201406");
        BOOL on = YES;
        if ([[_groupProperty objectForKey:@"forbidOperations"]count] > 2)
            on = ![[[_groupProperty objectForKey:@"forbidOperations"]objectAtIndex:2]boolValue];
        
        if (canSetup && [BiChatGlobal isMeGroupOperator:self.groupProperty])
        {
            UISwitch *switch4RedPacketFromOtherGroup = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
            [switch4RedPacketFromOtherGroup addTarget:self action:@selector(onSwitchRedPacketFromOtherGroup:) forControlEvents:UIControlEventValueChanged];
            switch4RedPacketFromOtherGroup.on = on;
            cell.accessoryView = switch4RedPacketFromOtherGroup;
        }
        else
        {
            cell.detailTextLabel.text = on?LLSTR(@"201336"):LLSTR(@"201335");
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"201229");
        BOOL on = YES;
        
        if ([[_groupProperty objectForKey:@"forbidOperations"]count] > 3)
            on = ![[[_groupProperty objectForKey:@"forbidOperations"]objectAtIndex:3]boolValue];

        UISwitch *switch4GroupExchange = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 66, 6, 100, 30)];
        [switch4GroupExchange addTarget:self action:@selector(onSwitchGroupExchange:) forControlEvents:UIControlEventValueChanged];
        switch4GroupExchange.on = on;
        cell.accessoryView = switch4GroupExchange;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
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

- (void)onSwitchBroadcast:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:s.on?@"true":@"false", @"mute", nil];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            [_groupProperty setObject:s.on?@"1":@"0" forKey:@"mute"];
            
            //发送消息
            if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            {
                //广播到所有虚拟子群
                for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                {
                    [MessageHelper sendGroupMessageTo:[item objectForKey:@"groupId"]
                                                 type:s.on?MESSAGE_CONTENT_TYPE_GROUPMUTE_ON:MESSAGE_CONTENT_TYPE_GROUPMUTE_OFF
                                              content:@""
                                             needSave:YES
                                             needSend:YES
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
            }
            else
            {
                [MessageHelper sendGroupMessageTo:self.groupId type:s.on?MESSAGE_CONTENT_TYPE_GROUPMUTE_ON:MESSAGE_CONTENT_TYPE_GROUPMUTE_OFF content:@"" needSave:YES needSend:YES completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    ;
                }];
            }
        }
        else
        {
            s.on = !s.on;
            [BiChatGlobal showInfo:LLSTR(@"301303") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

- (void)onSwitchTextWithLink:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[_groupProperty objectForKey:@"forbidOperations"]];
    if (array.count < 1)
        array = [NSMutableArray arrayWithObject:@"0"];
    [array setObject:(s.on?@"0":@"1") atIndexedSubscript:0];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array, @"forbidOperations", nil];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            [_groupProperty setObject:array forKey:@"forbidOperations"];
            
            //发送消息
            if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            {
                //广播到所有虚拟子群
                for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                {
                    [MessageHelper sendGroupMessageTo:[item objectForKey:@"groupId"]
                                                 type:!s.on?MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_ON:MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_OFF
                                              content:@""
                                             needSave:YES
                                             needSend:YES
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
            }
            else
            {
                [MessageHelper sendGroupMessageTo:self.groupId type:!s.on?MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_ON:MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_OFF
                                          content:@""
                                         needSave:YES
                                         needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    ;
                }];
            }
        }
        else
        {
            s.on = !s.on;
            [BiChatGlobal showInfo:LLSTR(@"301702") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

- (void)onSwitchImageWithVRCode:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[_groupProperty objectForKey:@"forbidOperations"]];
    for (int i = (int)array.count; i < 2; i ++)
        [array addObject:@"0"];
    [array setObject:(s.on?@"0":@"1") atIndexedSubscript:1];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array, @"forbidOperations", nil];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            [_groupProperty setObject:array forKey:@"forbidOperations"];
            
            //发送消息
            if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            {
                //广播到所有虚拟子群
                for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                {
                    [MessageHelper sendGroupMessageTo:[item objectForKey:@"groupId"]
                                                 type:!s.on?MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_ON:MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_OFF
                                              content:@""
                                             needSave:YES
                                             needSend:YES
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
            }
            else
            {
                [MessageHelper sendGroupMessageTo:self.groupId type:!s.on?MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_ON:MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_OFF
                                          content:@""
                                         needSave:YES
                                         needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                       ;
                                   }];
            }
        }
        else
        {
            s.on = !s.on;
            [BiChatGlobal showInfo:LLSTR(@"301702") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

- (void)onSwitchRedPacketFromOtherGroup:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[_groupProperty objectForKey:@"forbidOperations"]];
    for (int i = (int)array.count; i < 3; i ++)
        [array addObject:@"0"];
    [array setObject:(s.on?@"0":@"1") atIndexedSubscript:2];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array, @"forbidOperations", nil];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            [_groupProperty setObject:array forKey:@"forbidOperations"];
            
            //发送消息
            if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            {
                //广播到所有虚拟子群
                for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                {
                    [MessageHelper sendGroupMessageTo:[item objectForKey:@"groupId"]
                                                 type:!s.on?MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_ON:MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_OFF
                                              content:@""
                                             needSave:YES
                                             needSend:YES
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
            }
            else
            {
                [MessageHelper sendGroupMessageTo:self.groupId type:!s.on?MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_ON:MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_OFF
                                          content:@""
                                         needSave:YES
                                         needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                       ;
                                   }];
            }
        }
        else
        {
            s.on = !s.on;
            [BiChatGlobal showInfo:LLSTR(@"301702") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

- (void)onSwitchGroupExchange:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[_groupProperty objectForKey:@"forbidOperations"]];
    for (int i = (int)array.count; i < 4; i ++)
        [array addObject:@"0"];
    [array setObject:(s.on?@"1":@"0") atIndexedSubscript:3];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array, @"forbidOperations", nil];
    [NetworkModule setGroupPublicProfile:self.groupId profile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            [_groupProperty setObject:array forKey:@"forbidOperations"];
            
            //发送消息
            if ([[self.groupProperty objectForKey:@"virtualGroupId"]length] > 0)
            {
                //广播到所有虚拟子群
                for (NSDictionary *item in [self.groupProperty objectForKey:@"virtualGroupSubList"])
                {
                    [MessageHelper sendGroupMessageTo:[item objectForKey:@"groupId"]
                                                 type:s.on?MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_ON:MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_OFF
                                              content:@""
                                             needSave:YES
                                             needSend:YES
                                       completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                }
            }
            else
            {
                [MessageHelper sendGroupMessageTo:self.groupId type:s.on?MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_ON:MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_OFF
                                          content:@""
                                         needSave:YES
                                         needSend:YES
                                   completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                                       ;
                                   }];
            }
        }
        else
        {
            s.on = !s.on;
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 22", nil];
        }
    }];
}

@end
