//
//  ChargeGroupManageViewController.m
//  BiChat
//
//  Created by imac2 on 2019/3/20.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "ChargeGroupManageViewController.h"
#import "ModifyChargeGroupViewController.h"
#import "ChargeGroupTrailUserViewController.h"
#import "ChargeGroupOfficialUserViewController.h"
#import "ChargeGroupInvalideUserViewController.h"

@interface ChargeGroupManageViewController ()

@end

@implementation ChargeGroupManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"204001");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.backgroundColor = THEME_TABLEBK_LIGHT;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.00001)];
        
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else if (section == 1)
        return 3;
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 90;
    else
        return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0.00001;
    else
        return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        CGFloat width;
        if ([[self.groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            width = (self.view.frame.size.width - 30) / 3;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
            width = self.view.frame.size.width / 3;
        
        //币种
        NSDictionary *coinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:[self.groupProperty objectForKey:@"coinType"]];
        UILabel *label4CoinType = [[UILabel alloc]initWithFrame:CGRectMake(0, 24, width, 20)];
        label4CoinType.text = [coinInfo objectForKey:@"dSymbol"];
        label4CoinType.textAlignment = NSTextAlignmentCenter;
        label4CoinType.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:label4CoinType];
        
        UILabel *label4CoinTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 46, width, 20)];
        label4CoinTypeTitle.text = LLSTR(@"204101");
        label4CoinTypeTitle.textAlignment = NSTextAlignmentCenter;
        label4CoinTypeTitle.font = [UIFont systemFontOfSize:12];
        label4CoinTypeTitle.textColor = [UIColor grayColor];
        label4CoinTypeTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CoinTypeTitle];
        
        //数量
        UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(width, 24, width, 20)];
        label4Count.text = [[NSString stringWithFormat:@"%.12lf", [[self.groupProperty objectForKey:@"payValue"]doubleValue]]accuracyCheckWithFormatterString:[coinInfo objectForKey:@"bit"] auotCheck:YES];
        label4Count.textAlignment = NSTextAlignmentCenter;
        label4Count.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:label4Count];
        
        UILabel *label4CountTitle = [[UILabel alloc]initWithFrame:CGRectMake(width, 46, width, 20)];
        label4CountTitle.text = LLSTR(@"204102");
        label4CountTitle.textAlignment = NSTextAlignmentCenter;
        label4CountTitle.font = [UIFont systemFontOfSize:12];
        label4CountTitle.textColor = [UIColor grayColor];
        label4CountTitle.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4CountTitle];
        
        //使用时间
        UILabel *label4TrailTime = [[UILabel alloc]initWithFrame:CGRectMake(width * 2, 24, width, 20)];
        if ([[self.groupProperty objectForKey:@"trailTime"]longLongValue]/1000 == 3600)
            label4TrailTime.text = LLSTR(@"204105");
        else if ([[self.groupProperty objectForKey:@"trailTime"]longLongValue]/1000 == 3600 * 24)
            label4TrailTime.text = LLSTR(@"204106");
        else if ([[self.groupProperty objectForKey:@"trailTime"]longLongValue]/1000 == 3600 * 24 * 7)
            label4TrailTime.text = LLSTR(@"204107");
        label4TrailTime.textAlignment = NSTextAlignmentCenter;
        label4TrailTime.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:label4TrailTime];
        
        UILabel *label4TrailTimeTitle = [[UILabel alloc]initWithFrame:CGRectMake(width * 2, 46, width, 20)];
        label4TrailTimeTitle.text = LLSTR(@"204104");
        label4TrailTimeTitle.textAlignment = NSTextAlignmentCenter;
        label4TrailTimeTitle.font = [UIFont systemFontOfSize:12];
        label4TrailTimeTitle.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4TrailTimeTitle];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"204003");
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)([[self.groupProperty objectForKey:@"groupTrailUids"]count])];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"204004");
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)([[self.groupProperty objectForKey:@"joinedGroupUserCount"]integerValue] - [[self.groupProperty objectForKey:@"groupTrailUids"]count] - 1)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"204005");
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[[self.groupProperty objectForKey:@"waitingPayList"]count]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        cell.textLabel.text = LLSTR(@"204128");
        
        //我是群主
        if ([[self.groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            cell.detailTextLabel.text = LLSTR(@"204015");
        else if ([BiChatGlobal isMeGroupOperator:self.groupProperty])
            cell.detailTextLabel.text = LLSTR(@"204016");
        else if ([BiChatGlobal isMeGroupVIP:self.groupProperty])
            cell.detailTextLabel.text = LLSTR(@"204017");
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if ([[self.groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            ModifyChargeGroupViewController *wnd = [[ModifyChargeGroupViewController alloc]initWithStyle:UITableViewStyleGrouped];
            wnd.groupId = self.groupId;
            wnd.groupProperty = self.groupProperty;
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        ChargeGroupTrailUserViewController *wnd = [ChargeGroupTrailUserViewController new];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        ChargeGroupOfficialUserViewController *wnd = [ChargeGroupOfficialUserViewController new];
        wnd.groupId = self.groupId;
        wnd.groupProperty = self.groupProperty;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        ChargeGroupInvalideUserViewController *wnd = [ChargeGroupInvalideUserViewController new];
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

@end
