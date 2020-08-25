//
//  InviteHistoryViewController.m
//  BiChat Dev
//
//  Created by imac2 on 2018/9/14.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "InviteHistoryViewController.h"

@interface InviteHistoryViewController ()

@end

@implementation InviteHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"101803");
    self.tableView.tableFooterView = [UIView new];
    showMode = SHOWMODE_BYTIME;
    [self freshShowMode];
    [self initData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view4Header.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    
    if (showMode == SHOWMODE_BYTIME)
    {
        UILabel *label4DateTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 80, 40)];
        label4DateTitle.text = LLSTR(@"101815");
        label4DateTitle.font = [UIFont systemFontOfSize:14];
        [view4Header addSubview:label4DateTitle];
        
        CGFloat width = (self.view.frame.size.width - 120) / 3;
        UILabel *label4InviteCountTitle = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, width, 40)];
        label4InviteCountTitle.text = LLSTR(@"101816");
        label4InviteCountTitle.font = [UIFont systemFontOfSize:14];
        label4InviteCountTitle.textAlignment = NSTextAlignmentRight;
        [view4Header addSubview:label4InviteCountTitle];
        
        UILabel *label4UnlockTokenTitle = [[UILabel alloc]initWithFrame:CGRectMake(100 + width + 5, 0, width, 40)];
        label4UnlockTokenTitle.text = LLSTR(@"101817");
        label4UnlockTokenTitle.font = [UIFont systemFontOfSize:14];
        label4UnlockTokenTitle.textAlignment = NSTextAlignmentRight;
        label4UnlockTokenTitle.adjustsFontSizeToFitWidth = YES;
        [view4Header addSubview:label4UnlockTokenTitle];
        
        UILabel *label4UnlockRateTitle = [[UILabel alloc]initWithFrame:CGRectMake(100 + (width + 5) * 2, 0, width, 40)];
        label4UnlockRateTitle.text = LLSTR(@"101715");
        label4UnlockRateTitle.font = [UIFont systemFontOfSize:14];
        label4UnlockRateTitle.textAlignment = NSTextAlignmentRight;
        label4UnlockRateTitle.adjustsFontSizeToFitWidth = YES;
        [view4Header addSubview:label4UnlockRateTitle];
    }
    else
    {
        //标题
        UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 120, 40)];
        label4NickName.text = LLSTR(@"102103");
        label4NickName.font = [UIFont systemFontOfSize:14];
        [view4Header addSubview:label4NickName];
        
        UILabel *label4UnlockTokenTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 185, 0, 60, 40)];
        label4UnlockTokenTitle.text = LLSTR(@"101709");
        label4UnlockTokenTitle.font = [UIFont systemFontOfSize:14];
        label4UnlockTokenTitle.textAlignment = NSTextAlignmentRight;
        label4UnlockTokenTitle.adjustsFontSizeToFitWidth = YES;
        [view4Header addSubview:label4UnlockTokenTitle];
        
        UILabel *label4UnlockRateTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 120, 0, 50, 40)];
        label4UnlockRateTitle.text = LLSTR(@"101721");
        label4UnlockRateTitle.font = [UIFont systemFontOfSize:14];
        label4UnlockRateTitle.textAlignment = NSTextAlignmentRight;
        label4UnlockRateTitle.adjustsFontSizeToFitWidth = YES;
        [view4Header addSubview:label4UnlockRateTitle];
        
        UILabel *label4LockTokenTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 65, 0, 50, 40)];
        label4LockTokenTitle.text = LLSTR(@"101809");
        label4LockTokenTitle.font = [UIFont systemFontOfSize:14];
        label4LockTokenTitle.textAlignment = NSTextAlignmentRight;
        label4LockTokenTitle.adjustsFontSizeToFitWidth = YES;
        [view4Header addSubview:label4LockTokenTitle];
    }
    
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    [view4Header addSubview:view4Seperator];
    
    return view4Header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (showMode == SHOWMODE_BYTIME)
        return array4InviteHistoryByTime.count + (hasMoreDataByTime?1:0);
    else
        return array4InviteHistoryByUser.count + (hasMoreDataByUser?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
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
    if (showMode == SHOWMODE_BYTIME)
    {
        //更多?
        if (indexPath.row >= array4InviteHistoryByTime.count)
        {
            UILabel *label4More = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
            label4More.text = LLSTR(@"101031");
            label4More.font = [UIFont systemFontOfSize:12];
            label4More.textColor = [UIColor lightGrayColor];
            label4More.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label4More];

            [self moreDataByTime];
            return cell;
        }
        
        NSDictionary *item = [array4InviteHistoryByTime objectAtIndex:indexPath.row];
        
        NSString *str = [NSString stringWithFormat:@"%@", [item objectForKey:@"date"]];
        if (str.length == 8)
        {
            UILabel *label4Date = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 80, 50)];
            label4Date.text = [NSString stringWithFormat:@"%@-%@-%@", [str substringToIndex:4], [str substringWithRange:NSMakeRange(4, 2)], [str substringWithRange:NSMakeRange(6, 2)]];
            label4Date.font = [UIFont fontWithName:@"Monaco" size:11];
            label4Date.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4Date];
        }
        
        CGFloat width = (self.view.frame.size.width - 120) / 3;
        UILabel *label4InviteCount = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, width, 50)];
        label4InviteCount.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"unlockUser"]];
        label4InviteCount.font = [UIFont fontWithName:@"Monaco" size:11];
        label4InviteCount.textAlignment = NSTextAlignmentRight;
        label4InviteCount.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4InviteCount];
        
        UILabel *label4UnlockToken = [[UILabel alloc]initWithFrame:CGRectMake(100 + width + 5, 0, width, 50)];
        label4UnlockToken.text = [NSString stringWithFormat:@"%@", [BiChatGlobal decimalNumberWithDouble:[[item objectForKey:@"unlockRefTokenSuccess"]doubleValue]]];
        label4UnlockToken.font = [UIFont fontWithName:@"Monaco" size:11];
        label4UnlockToken.textAlignment = NSTextAlignmentRight;
        label4UnlockToken.adjustsFontSizeToFitWidth = YES;
        label4UnlockToken.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4UnlockToken];
        
        UILabel *label4UnlockRate = [[UILabel alloc]initWithFrame:CGRectMake(100 + (width + 5) * 2, 0, width, 50)];
        label4UnlockRate.text = [NSString stringWithFormat:@"%d%%", (int)([[item objectForKey:@"unlockRefTokenRate"]doubleValue] * 100)];
        label4UnlockRate.font = [UIFont fontWithName:@"Monaco" size:11];
        label4UnlockRate.textAlignment = NSTextAlignmentRight;
        label4UnlockRate.adjustsFontSizeToFitWidth = YES;
        label4UnlockRate.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4UnlockRate];
    }
    else
    {
        //更多?
        if (indexPath.row >= array4InviteHistoryByUser.count)
        {
            UILabel *label4More = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
            label4More.text = LLSTR(@"101031");
            label4More.font = [UIFont systemFontOfSize:12];
            label4More.textColor = [UIColor lightGrayColor];
            label4More.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label4More];
            
            [self moreDataByUser];
            return cell;
        }
        
        NSString *nickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[[array4InviteHistoryByUser objectAtIndex:indexPath.row]objectForKey:@"uid"] groupProperty:nil nickName:[[array4InviteHistoryByUser objectAtIndex:indexPath.row]objectForKey:@"nickName"]];
        
        NSDictionary *item = [array4InviteHistoryByUser objectAtIndex:indexPath.row];
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"uid"] nickName:nickName avatar:[item objectForKey:@"avatar"] frame:CGRectMake(15, 7, 36, 36)];
        [cell.contentView addSubview:view4Avatar];
        
        if ([[[array4InviteHistoryByUser objectAtIndex:indexPath.row]objectForKey:@"status"]integerValue] != 1)
        {
            UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, self.view.frame.size.width - 255, 15)];
            label4NickName.text = nickName;
            label4NickName.font = [UIFont fontWithName:@"Monaco" size:11];
            label4NickName.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4NickName];
            
            UILabel *label4Status = [[UILabel alloc]initWithFrame:CGRectMake(60, 25, self.view.frame.size.width - 255, 15)];
            if ([[[array4InviteHistoryByUser objectAtIndex:indexPath.row]objectForKey:@"status"]integerValue] == 0)
                label4Status.text = LLSTR(@"101706");
            else
                label4Status.text = LLSTR(@"101708");
            label4Status.font = [UIFont fontWithName:@"Monaco" size:11];
            label4Status.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4Status];
        }
        else
        {
            UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width - 255, 50)];
            label4NickName.text = nickName;
            label4NickName.font = [UIFont fontWithName:@"Monaco" size:11];
            label4NickName.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4NickName];
        }
        
        //解锁奖励
        UILabel *label4UnlockToken = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 185, 0, 60, 50)];
        label4UnlockToken.text = [NSString stringWithFormat:format, [[item objectForKey:@"myRefSucceedToken"]doubleValue]];
        label4UnlockToken.textAlignment = NSTextAlignmentRight;
        label4UnlockToken.font = [UIFont fontWithName:@"Monaco" size:11];
        label4UnlockToken.adjustsFontSizeToFitWidth = YES;
        label4UnlockToken.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4UnlockToken];
        
        UILabel *label4UnlockRate = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 120, 0, 50, 50)];
        label4UnlockRate.text = [NSString stringWithFormat:@"%ld%%", (NSInteger)([[item objectForKey:@"myRefUnlockRate"]doubleValue] * 100)];
        label4UnlockRate.textAlignment = NSTextAlignmentRight;
        label4UnlockRate.font = [UIFont fontWithName:@"Monaco" size:11];
        label4UnlockRate.adjustsFontSizeToFitWidth = YES;
        label4UnlockRate.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4UnlockRate];
        
        UILabel *label4Unlock = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 65, 0, 50, 50)];
        label4Unlock.text = [NSString stringWithFormat:format, [[item objectForKey:@"myRefLockToken"]doubleValue]];
        label4Unlock.textAlignment = NSTextAlignmentRight;
        label4Unlock.font = [UIFont fontWithName:@"Monaco" size:11];
        label4Unlock.textColor = [UIColor grayColor];
        label4Unlock.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label4Unlock];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (showMode == SHOWMODE_BYTIME)
    {
        UIView *view4InfoPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 370)];
        view4InfoPanel.backgroundColor = [UIColor whiteColor];
        view4InfoPanel.layer.cornerRadius = 5;
        view4InfoPanel.clipsToBounds = YES;
        
        UIButton *button4Close = [[UIButton alloc]initWithFrame:CGRectMake(260, 0, 40, 40)];
        [button4Close setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
        [button4Close addTarget:self action:@selector(onButtonClosePresentedWnd:) forControlEvents:UIControlEventTouchUpInside];
        [view4InfoPanel addSubview:button4Close];
        
        NSDictionary *item = [array4InviteHistoryByTime objectAtIndex:indexPath.row];
        NSString *str = [NSString stringWithFormat:@"%@", [item objectForKey:@"date"]];
        if (str.length == 8)
        {
            UILabel *label4Date = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 280, 40)];
            label4Date.text = [NSString stringWithFormat:@"%@-%@-%@", [str substringToIndex:4], [str substringWithRange:NSMakeRange(4, 2)], [str substringWithRange:NSMakeRange(6, 2)]];;
            label4Date.font = [UIFont systemFontOfSize:20];
            label4Date.textAlignment = NSTextAlignmentCenter;
            [view4InfoPanel addSubview:label4Date];
        }
        
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 300, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
        [view4InfoPanel addSubview:view4Seperator];

        //第一行
        UILabel *label4Line1Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 70, 200, 20)];
        label4Line1Title.text = LLSTR(@"101821");
        label4Line1Title.font = [UIFont systemFontOfSize:14];
        label4Line1Title.textColor = [UIColor grayColor];
        label4Line1Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line1Title];
        
        UILabel *label4Line1Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 70, 65, 20)];
        label4Line1Value.text = [NSString stringWithFormat:@"%ld", (long)[[item objectForKey:@"unlockUser"]integerValue]];
        label4Line1Value.font = [UIFont systemFontOfSize:14];
        label4Line1Value.textAlignment = NSTextAlignmentRight;
        label4Line1Value.textColor = [UIColor grayColor];
        label4Line1Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line1Value];
        
        //第二行
        UILabel *label4Line11Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 95, 200, 20)];
        label4Line11Title.text = LLSTR(@"101822");
        label4Line11Title.font = [UIFont systemFontOfSize:14];
        label4Line11Title.textColor = [UIColor grayColor];
        label4Line11Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line11Title];
        
        UILabel *label4Line11Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 95, 65, 20)];
        label4Line11Value.text = [NSString stringWithFormat:@"%ld", (long)[[item objectForKey:@"unlockUserSuccess"]integerValue]];
        label4Line11Value.font = [UIFont systemFontOfSize:14];
        label4Line11Value.textAlignment = NSTextAlignmentRight;
        label4Line11Value.textColor = [UIColor grayColor];
        label4Line11Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line11Value];
        
        //第三行
        UILabel *label4Line2Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 135, 200, 20)];
        label4Line2Title.text = LLSTR(@"101823");
        label4Line2Title.font = [UIFont systemFontOfSize:14];
        label4Line2Title.textColor = [UIColor grayColor];
        label4Line2Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line2Title];
        
        UILabel *label4Line2Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 135, 65, 20)];
        label4Line2Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"unlockRefToken"]doubleValue]];
        label4Line2Value.font = [UIFont systemFontOfSize:14];
        label4Line2Value.textAlignment = NSTextAlignmentRight;
        label4Line2Value.textColor = [UIColor grayColor];
        label4Line2Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line2Value];
        
        //第四行
        UILabel *label4Line3Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 160, 200, 20)];
        label4Line3Title.text = LLSTR(@"101824");
        label4Line3Title.font = [UIFont systemFontOfSize:14];
        label4Line3Title.textColor = [UIColor grayColor];
        label4Line3Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line3Title];
        
        UILabel *label4Line3Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 160, 65, 20)];
        label4Line3Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"unlockRefTokenSuccess"]doubleValue]];
        label4Line3Value.font = [UIFont systemFontOfSize:14];
        label4Line3Value.textAlignment = NSTextAlignmentRight;
        label4Line3Value.textColor = [UIColor grayColor];
        label4Line3Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line3Value];
        
        //第五行
        UILabel *label4Line4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 185, 200, 20)];
        label4Line4Title.text = LLSTR(@"101715");
        label4Line4Title.font = [UIFont systemFontOfSize:14];
        label4Line4Title.textColor = [UIColor grayColor];
        label4Line4Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line4Title];
        
        UILabel *label4Line4Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 185, 65, 20)];
        label4Line4Value.text = [NSString stringWithFormat:@"%ld%%", (long)([[item objectForKey:@"unlockRefTokenRate"]doubleValue] * 100)];
        label4Line4Value.font = [UIFont systemFontOfSize:14];
        label4Line4Value.textAlignment = NSTextAlignmentRight;
        label4Line4Value.textColor = [UIColor grayColor];
        label4Line4Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line4Value];
        
        //第六行
        UILabel *label4Line5Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 225, 200, 20)];
        label4Line5Title.text = LLSTR(@"101826");
        label4Line5Title.font = [UIFont systemFontOfSize:14];
        label4Line5Title.textColor = [UIColor grayColor];
        label4Line5Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line5Title];
        
        UILabel *label4Line5Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 225, 65, 20)];
        label4Line5Value.text = [NSString stringWithFormat:@"%ld", (long)[[item objectForKey:@"newUsers"]integerValue]];
        label4Line5Value.font = [UIFont systemFontOfSize:14];
        label4Line5Value.textAlignment = NSTextAlignmentRight;
        label4Line5Value.textColor = [UIColor grayColor];
        label4Line5Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line5Value];
        
        //第七行
        UILabel *label4Line6Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 250, 200, 20)];
        label4Line6Title.text = LLSTR(@"101827");
        label4Line6Title.font = [UIFont systemFontOfSize:14];
        label4Line6Title.textColor = [UIColor grayColor];
        label4Line6Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line6Title];
        
        UILabel *label4Line6Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 250, 65, 20)];
        label4Line6Value.text = [NSString stringWithFormat:@"%ld", (long)[[item objectForKey:@"finishUser"]integerValue]];
        label4Line6Value.font = [UIFont systemFontOfSize:14];
        label4Line6Value.textAlignment = NSTextAlignmentRight;
        label4Line6Value.textColor = [UIColor grayColor];
        label4Line6Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line6Value];

        [BiChatGlobal presentModalView:view4InfoPanel clickDismiss:YES delayDismiss:0 andDismissCallback:nil];
    }
    else
    {
        UIView *view4InfoPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 400)];
        view4InfoPanel.backgroundColor = [UIColor whiteColor];
        view4InfoPanel.layer.cornerRadius = 5;
        view4InfoPanel.clipsToBounds = YES;
        
        UIButton *button4Close = [[UIButton alloc]initWithFrame:CGRectMake(260, 0, 40, 40)];
        [button4Close setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
        [button4Close addTarget:self action:@selector(onButtonClosePresentedWnd:) forControlEvents:UIControlEventTouchUpInside];
        [view4InfoPanel addSubview:button4Close];
        
        //查找这个用户的备注名
        NSDictionary *item = [array4InviteHistoryByUser objectAtIndex:indexPath.row];
        NSString *str4MemoName = [[BiChatGlobal sharedManager]getFriendMemoName:[item objectForKey:@"uid"]];
        CGFloat offset = 0;
        if (str4MemoName.length == 0)
        {
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"uid"] nickName:[item objectForKey:@"nickName"] avatar:[item objectForKey:@"avatar"] frame:CGRectMake(15, 7, 50, 50)];
            view4Avatar.center = CGPointMake(150, 45);
            [view4InfoPanel addSubview:view4Avatar];
            
            UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 280, 20)];
            label4NickName.text = [item objectForKey:@"nickName"];
            label4NickName.font = [UIFont systemFontOfSize:16];
            label4NickName.textAlignment = NSTextAlignmentCenter;
            [view4InfoPanel addSubview:label4NickName];
            
            UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 110, 300, 0.5)];
            view4Seperator.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
            [view4InfoPanel addSubview:view4Seperator];
        }
        else
        {
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[item objectForKey:@"uid"] nickName:str4MemoName avatar:[item objectForKey:@"avatar"] frame:CGRectMake(15, 7, 50, 50)];
            view4Avatar.center = CGPointMake(150, 45);
            [view4InfoPanel addSubview:view4Avatar];
            
            UILabel *label4MemoName = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 280, 20)];
            label4MemoName.text = str4MemoName;
            label4MemoName.font = [UIFont systemFontOfSize:16];
            label4MemoName.textAlignment = NSTextAlignmentCenter;
            [view4InfoPanel addSubview:label4MemoName];
            
            UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 280, 20)];
            label4NickName.text = [NSString stringWithFormat:@"%@: %@",LLSTR(@"102021"), [item objectForKey:@"nickName"]];
            label4NickName.font = [UIFont systemFontOfSize:12];
            label4NickName.textAlignment = NSTextAlignmentCenter;
            label4NickName.textColor = [UIColor grayColor];
            [view4InfoPanel addSubview:label4NickName];

            UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 130, 300, 0.5)];
            view4Seperator.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
            [view4InfoPanel addSubview:view4Seperator];
            offset += 20;
        }
        
        //第一行
        UILabel *label4Line1Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 120 + offset, 200, 20)];
        if ([[item objectForKey:@"status"]integerValue] == 0)
            label4Line1Title.text = LLSTR(@"101706");      //
        else if ([[item objectForKey:@"status"]integerValue] == 1)
            label4Line1Title.text = LLSTR(@"101707");
        else
            label4Line1Title.text = LLSTR(@"101708");
        
        label4Line1Title.font = [UIFont systemFontOfSize:14];
        label4Line1Title.textColor = [UIColor grayColor];
        label4Line1Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line1Title];
        
        UILabel *label4Line1Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 120 + offset, 65, 20)];
        label4Line1Value.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"token"]];
        label4Line1Value.font = [UIFont systemFontOfSize:14];
        label4Line1Value.textAlignment = NSTextAlignmentRight;
        label4Line1Value.textColor = [UIColor grayColor];
        label4Line1Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line1Value];
        
        //第四行
        UILabel *label4Line4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 160 + offset, 200, 20)];
        label4Line4Title.text = LLSTR(@"101803");
        label4Line4Title.font = [UIFont systemFontOfSize:14];
        label4Line4Title.textColor = [UIColor grayColor];
        label4Line4Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line4Title];
        
        UILabel *label4Line4Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 160 + offset, 65, 20)];
        label4Line4Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"myRefToken"]doubleValue]];
        label4Line4Value.font = [UIFont systemFontOfSize:14];
        label4Line4Value.textAlignment = NSTextAlignmentRight;
        label4Line4Value.textColor = [UIColor grayColor];
        label4Line4Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line4Value];
        
        //第五行
        UILabel *label4Line5Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 185 + offset, 200, 20)];
        label4Line5Title.text = LLSTR(@"101828");
        label4Line5Title.font = [UIFont systemFontOfSize:14];
        label4Line5Title.textColor = [UIColor grayColor];
        label4Line5Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line5Title];
        
        UILabel *label4Line5Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 185 + offset, 65, 20)];
        label4Line5Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"myRefUnlockToken"]doubleValue]];
        label4Line5Value.font = [UIFont systemFontOfSize:14];
        label4Line5Value.textAlignment = NSTextAlignmentRight;
        label4Line5Value.textColor = [UIColor grayColor];
        label4Line5Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line5Value];
        
        //第六行
        UILabel *label4Line6Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 210 + offset, 200, 20)];
//        label4Line6Title.text = @"    解锁成功";
        label4Line6Title.text = LLSTR(@"101807");
        label4Line6Title.font = [UIFont systemFontOfSize:14];
        label4Line6Title.textColor = [UIColor grayColor];
        label4Line6Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line6Title];
        
        UILabel *label4Line6Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 210 + offset, 65, 20)];
        label4Line6Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"myRefSucceedToken"]doubleValue]];
        label4Line6Value.font = [UIFont systemFontOfSize:14];
        label4Line6Value.textAlignment = NSTextAlignmentRight;
        label4Line6Value.textColor = [UIColor grayColor];
        label4Line6Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line6Value];
        
        //第七行
        UILabel *label4Line7Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 235 + offset, 200, 20)];
//        label4Line7Title.text = @"    解锁失败";
        label4Line7Title.text = LLSTR(@"101808");
        label4Line7Title.font = [UIFont systemFontOfSize:14];
        label4Line7Title.textColor = [UIColor grayColor];
        label4Line7Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line7Title];
        
        UILabel *label4Line7Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 235 + offset, 65, 20)];
        label4Line7Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"myRefFailedToken"]doubleValue]];
        label4Line7Value.font = [UIFont systemFontOfSize:14];
        label4Line7Value.textAlignment = NSTextAlignmentRight;
        label4Line7Value.textColor = [UIColor grayColor];
        label4Line7Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line7Value];
        
        //第八行
        UILabel *label4Line8Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 260 + offset, 200, 20)];
        label4Line8Title.text = LLSTR(@"101809");
        label4Line8Title.font = [UIFont systemFontOfSize:14];
        label4Line8Title.textColor = [UIColor grayColor];
        label4Line8Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line8Title];
        
        UILabel *label4Line8Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 260 + offset, 65, 20)];
        label4Line8Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"myRefLockToken"]doubleValue]];
        label4Line8Value.font = [UIFont systemFontOfSize:14];
        label4Line8Value.textAlignment = NSTextAlignmentRight;
        label4Line8Value.textColor = [UIColor grayColor];
        label4Line8Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line8Value];
        
        //第九行
        UILabel *label4Line9Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 300 + offset, 200, 20)];
        label4Line9Title.text = LLSTR(@"101716");
        label4Line9Title.font = [UIFont systemFontOfSize:14];
        label4Line9Title.textColor = [UIColor grayColor];
        label4Line9Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line9Title];
        
        UILabel *label4Line9Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 300 + offset, 65, 20)];
        label4Line9Value.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"myRefUnLockDay"]];
        label4Line9Value.font = [UIFont systemFontOfSize:14];
        label4Line9Value.textAlignment = NSTextAlignmentRight;
        label4Line9Value.textColor = [UIColor grayColor];
        label4Line9Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line9Value];
        
        //第十行
        UILabel *label4Line10Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 325 + offset, 200, 20)];
        label4Line10Title.text = LLSTR(@"101721");
        label4Line10Title.font = [UIFont systemFontOfSize:14];
        label4Line10Title.textColor = [UIColor grayColor];
        label4Line10Title.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line10Title];
        
        UILabel *label4Line10Value = [[UILabel alloc]initWithFrame:CGRectMake(220, 325 + offset, 65, 20)];
        label4Line10Value.text = [NSString stringWithFormat:@"%ld%%", (long)([[item objectForKey:@"myRefUnlockRate"]doubleValue] * 100)];
        label4Line10Value.font = [UIFont systemFontOfSize:14];
        label4Line10Value.textAlignment = NSTextAlignmentRight;
        label4Line10Value.textColor = [UIColor grayColor];
        label4Line10Value.adjustsFontSizeToFitWidth = YES;
        [view4InfoPanel addSubview:label4Line10Value];

        [BiChatGlobal presentModalView:view4InfoPanel clickDismiss:YES delayDismiss:0 andDismissCallback:nil];
    }
}

- (void)onButtonClosePresentedWnd:(id)sender
{
    [BiChatGlobal dismissModalView];
}

//日期 可解锁人数 可解锁奖励数 解锁成功奖励数 解锁成功率 新增人数 解锁结束人数
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

- (void)freshShowMode
{
    if (showMode == 1)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101814") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonShowModeByTime:)];
    else
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101813") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonShowModeByUser:)];
    
    //刷新数据
    [self.tableView reloadData];
}

- (void)onButtonShowModeByUser:(id)sender
{
    showMode = SHOWMODE_BYUSER;
    [self freshShowMode];
    [self.tableView reloadData];
    if (array4InviteHistoryByUser.count > 0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    else
        [self initData];
}

- (void)onButtonShowModeByTime:(id)sender
{
    showMode = SHOWMODE_BYTIME;
    [self freshShowMode];
    [self.tableView reloadData];
    if (array4InviteHistoryByTime.count > 0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    else
        [self initData];
}

- (void)initData
{
    if (showMode == SHOWMODE_BYTIME && array4InviteHistoryByTime == nil)
        [self initDataByTime];
    else if (showMode == SHOWMODE_BYUSER && array4InviteHistoryByUser == nil)
        [self initDataByUser];
    else
        [self.tableView reloadData];
}

- (void)initDataByTime
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getUserInviteeListByDate:1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            array4InviteHistoryByTime = [NSMutableArray arrayWithArray:[data objectForKey:@"list"]];
            hasMoreDataByTime = (array4InviteHistoryByTime.count == 20);
            [self.tableView reloadData];
        }
        
    }];
}

- (void)initDataByUser
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getUserInviteeListByUser:1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            array4InviteHistoryByUser = [NSMutableArray arrayWithArray:[data objectForKey:@"list"]];
            //NSLog(@"%@", array4InviteHistoryByUser);
            hasMoreDataByUser = (array4InviteHistoryByUser.count == 20);
            [self.tableView reloadData];
        }
        
    }];
}

- (void)moreDataByTime
{
    if (moreDataByTimeLoading)
        return;
    moreDataByTimeLoading = YES;
    
    NSInteger page = array4InviteHistoryByTime.count / 20 + 1;
    [NetworkModule getUserInviteeListByDate:page completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        moreDataByTimeLoading = NO;
        if (success)
        {
            [array4InviteHistoryByTime addObjectsFromArray:[data objectForKey:@"list"]];
            hasMoreDataByTime = ([[data objectForKey:@"list"]count] == 20);
            [self.tableView reloadData];
        }
        
    }];
}

- (void)moreDataByUser
{
    if (moreDataByUserLoading)
        return;
    moreDataByUserLoading = YES;
    
    NSInteger page = array4InviteHistoryByUser.count / 20 + 1;
    [NetworkModule getUserInviteeListByUser:page completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        moreDataByUserLoading = NO;
        if (success)
        {
            [array4InviteHistoryByUser addObjectsFromArray:[data objectForKey:@"list"]];
            hasMoreDataByUser = ([[data objectForKey:@"list"]count] == 20);
            [self.tableView reloadData];
        }
        
    }];
}

@end
