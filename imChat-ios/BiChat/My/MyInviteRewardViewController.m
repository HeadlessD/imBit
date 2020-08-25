//
//  MyInviteRewardViewController.m
//  BiChat
//
//  Created by imac2 on 2018/11/28.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "MyInviteRewardViewController.h"
#import "InviteHistoryViewController.h"
#import "InviteRewardRankViewController.h"
#import "MyVRCodeViewController.h"

@interface MyInviteRewardViewController ()

@end

@implementation MyInviteRewardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101802") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonInvite:)];
    self.tableView.tableFooterView = [UIView new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //修改标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_token2"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_transparent"];
    
    //初始化数据
    myTokenInfo = [BiChatGlobal sharedManager].dict4MyTokenInfo;
    self.tableView.tableHeaderView = [self createInviteInfoPanel];
    [self.tableView reloadData];
    [self freshData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (myTokenInfo == nil)
        return 0;
    else
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 4;
    else
        return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //获取bit信息
    NSDictionary *CoinInfo;
    for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:@"TOKEN"])
        {
            CoinInfo = item;
            break;
        }
    }
    NSString *format = [NSString stringWithFormat:@"%%.0%ldf", [[CoinInfo objectForKey:@"bit"]integerValue]];

    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.backgroundColor = THEME_TABLEBK;
        cell.contentView.backgroundColor = THEME_TABLEBK;
        cell.textLabel.text = LLSTR(@"101806");
        cell.textLabel.textColor = [UIColor blackColor];
        
        NSString * refu = [NSString stringWithFormat:@"%@",[myTokenInfo objectForKey:@"refUserCount"]];
        cell.detailTextLabel.text = [LLSTR(@"201002") llReplaceWithArray:@[refu]];
        
        if ([[myTokenInfo objectForKey:@"refUserCount"]integerValue] > 0)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"101709");
        cell.detailTextLabel.text = [NSString stringWithFormat:format, [[myTokenInfo objectForKey:@"refUnlockToken"]floatValue]];
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"101710");
        cell.detailTextLabel.text = [NSString stringWithFormat:format, [[myTokenInfo objectForKey:@"refFailedToken"]floatValue]];
    }
    else if (indexPath.section == 0 && indexPath.row == 3)
    {
        cell.textLabel.text = LLSTR(@"101809");
        cell.detailTextLabel.text = [NSString stringWithFormat:format, [[myTokenInfo objectForKey:@"refLockToken"]floatValue]];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.backgroundColor = THEME_TABLEBK;
        cell.contentView.backgroundColor = THEME_TABLEBK;
        cell.textLabel.text = LLSTR(@"101810");
        cell.textLabel.textColor = [UIColor blackColor];
        if ([[myTokenInfo objectForKey:@"refTodayUnlockUser"]integerValue] > 0)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;

            UIImageView *view4RankIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ranking"]];
            view4RankIcon.center = CGPointMake(self.view.frame.size.width - 45, 20);
            [cell.contentView addSubview:view4RankIcon];
        }
        else
        {
            UIImageView *view4RankIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ranking"]];
            view4RankIcon.center = CGPointMake(self.view.frame.size.width - 25, 20);
            [cell.contentView addSubview:view4RankIcon];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        cell.textLabel.text = LLSTR(@"101811");
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@／%@",
                                     [myTokenInfo objectForKey:@"refTodayUnlockFinishedUser"],
                                     [myTokenInfo objectForKey:@"refTodayUnlockUser"]];
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        cell.textLabel.text = LLSTR(@"101812");
        cell.detailTextLabel.text = [NSString stringWithFormat:[NSString stringWithFormat:@"%@／%@", format, format],
                                     [[myTokenInfo objectForKey:@"refTodayUnlockFinishedToken"]floatValue],
                                     [[myTokenInfo objectForKey:@"refTodayUnlockToken"]floatValue]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if ([[myTokenInfo objectForKey:@"refUserCount"]integerValue] > 0)
        {
            InviteHistoryViewController *wnd = [InviteHistoryViewController new];
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        if ([[myTokenInfo objectForKey:@"refTodayUnlockUser"]integerValue] > 0)
        {
            //进入排行榜
            InviteRewardRankViewController *wnd = [InviteRewardRankViewController new];
            [self.navigationController pushViewController:wnd animated:YES];
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

- (void)freshData
{
    [NetworkModule getTokenInfo:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (success)
        {
            //NSLog(@"%@", data);
            myTokenInfo = data;
            self.tableView.tableHeaderView = [self createInviteInfoPanel];
            [self.tableView reloadData];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301656") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (UIView *)createInviteInfoPanel
{
    UIView *view4Panel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, isIphonex?210:230)];
    view4Panel.backgroundColor = [UIColor whiteColor];
    
    //背景
    UIImageView *image4Bk = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"myInfoBk"]];
    image4Bk.frame = CGRectMake(0, isIphonex?-107:-87, self.view.frame.size.width, 232);
    [view4Panel addSubview:image4Bk];
    
    if (myTokenInfo == nil)
        return view4Panel;
    
    //NSLog(@"%@", myTokenInfo);
    
    //获取bit信息
    NSDictionary *CoinInfo;
    for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:@"TOKEN"])
        {
            CoinInfo = item;
            break;
        }
    }
    NSString *format = [NSString stringWithFormat:@"%%.0%ldf", [[CoinInfo objectForKey:@"bit"]integerValue]];
    
    UILabel *label4InviteRewardCount = [[UILabel alloc]initWithFrame:CGRectMake(30, isIphonex?30:50, self.view.frame.size.width - 60, 20)];
    label4InviteRewardCount.text = [NSString stringWithFormat:format, [[myTokenInfo objectForKey:@"refUnlockToken"]floatValue]];
    label4InviteRewardCount.textColor = [UIColor whiteColor];
    label4InviteRewardCount.font = [UIFont boldSystemFontOfSize:20];
    label4InviteRewardCount.textAlignment = NSTextAlignmentCenter;
    [view4Panel addSubview:label4InviteRewardCount];
    
    UILabel *label4IMCTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, isIphonex?50:70, self.view.frame.size.width, 20)];
    label4IMCTitle.text = @"IMC";
    label4IMCTitle.font = [UIFont systemFontOfSize:12];
    label4IMCTitle.textAlignment = NSTextAlignmentCenter;
    label4IMCTitle.textColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4Panel addSubview:label4IMCTitle];
    
    UILabel *label4InviteRewardTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, isIphonex?67:87, self.view.frame.size.width - 60, 20)];
    label4InviteRewardTitle.text = LLSTR(@"101803");
    label4InviteRewardTitle.font = [UIFont systemFontOfSize:12];
    label4InviteRewardTitle.textAlignment = NSTextAlignmentCenter;
    label4InviteRewardTitle.textColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4Panel addSubview:label4InviteRewardTitle];

    //条目宽度
    CGFloat itemWidth = (self.view.frame.size.width - 60) / 2;
    
    //全球用户
    UILabel *label4AllMyInviteCount = [[UILabel alloc]initWithFrame:CGRectMake(30, isIphonex?146:166, itemWidth, 20)];
    label4AllMyInviteCount.text = [NSString stringWithFormat:@"%ld", [[myTokenInfo objectForKey:@"refTodayUnlockUser"]integerValue] + [[myTokenInfo objectForKey:@"newUserCount"]integerValue]];
    label4AllMyInviteCount.textColor = [UIColor blackColor];
    label4AllMyInviteCount.font = [UIFont boldSystemFontOfSize:16];
    label4AllMyInviteCount.textAlignment = NSTextAlignmentCenter;
    [view4Panel addSubview:label4AllMyInviteCount];
    
    UILabel *label4AllMyInviteTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, isIphonex?166:186, itemWidth, 20)];
    label4AllMyInviteTitle.text = LLSTR(@"101804");
    label4AllMyInviteTitle.font = [UIFont systemFontOfSize:12];
    label4AllMyInviteTitle.textAlignment = NSTextAlignmentCenter;
    label4AllMyInviteTitle.textColor = [UIColor lightGrayColor];
    [view4Panel addSubview:label4AllMyInviteTitle];
    
    //中奖系数
    UILabel *label4NewMyInviteCount = [[UILabel alloc]initWithFrame:CGRectMake(30 + itemWidth, isIphonex?146:166, itemWidth, 20)];
    label4NewMyInviteCount.text = [NSString stringWithFormat:@"%ld", [[myTokenInfo objectForKey:@"newUserCount"]integerValue]];
    label4NewMyInviteCount.font = [UIFont boldSystemFontOfSize:16];
    label4NewMyInviteCount.textColor = [UIColor blackColor];
    label4NewMyInviteCount.textAlignment = NSTextAlignmentCenter;
    [view4Panel addSubview:label4NewMyInviteCount];
    
    UILabel *label4NewMyInviteTitle = [[UILabel alloc]initWithFrame:CGRectMake(30 + itemWidth, isIphonex?166:186, itemWidth, 20)];
    label4NewMyInviteTitle.text = LLSTR(@"101805");
    label4NewMyInviteTitle.font = [UIFont systemFontOfSize:12];
    label4NewMyInviteTitle.textAlignment = NSTextAlignmentCenter;
    label4NewMyInviteTitle.textColor = [UIColor lightGrayColor];
    [view4Panel addSubview:label4NewMyInviteTitle];

    return view4Panel;
}

- (void)onButtonInvite:(id)sender
{
    MyVRCodeViewController *wnd = [MyVRCodeViewController new];
    wnd.hidesBottomBarWhenPushed = YES;
    wnd.tipType = @"fromProfile";
    [self.navigationController pushViewController:wnd animated:YES];
}

@end
