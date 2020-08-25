//
//  MyWalletAccountViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "MyWalletAccountViewController.h"
#import "NetworkModule.h"
#import "NSString+Categroy.h"

@interface MyWalletAccountViewController ()

@end

@implementation MyWalletAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [LLSTR(@"103120") llReplaceWithArray:@[self.coinDSymbol]];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.tableFooterView = [UIView new];
    
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
        
    //每次显示都要获取一下当前的流水
    [self initData];
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
    return array4Account.count + (hasMore?1:0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view4Header.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
    
    //标题
    UILabel *label4TimeTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 80, 40)];
    label4TimeTitle.text = LLSTR(@"103121");
    label4TimeTitle.font = [UIFont systemFontOfSize:14];
    [view4Header addSubview:label4TimeTitle];
    
    UILabel *label4ActionTitle = [[UILabel alloc]initWithFrame:CGRectMake(95, 0, self.view.frame.size.width - 270, 40)];
    label4ActionTitle.text = LLSTR(@"103122");
    label4ActionTitle.font = [UIFont systemFontOfSize:14];
    [view4Header addSubview:label4ActionTitle];

    UILabel *label4AcountTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 180, 0, 80, 40)];
    label4AcountTitle.text = LLSTR(@"103116");
    label4AcountTitle.textAlignment = NSTextAlignmentRight;
    label4AcountTitle.font = [UIFont systemFontOfSize:14];
    [view4Header addSubview:label4AcountTitle];
    
    UILabel *label4ResultTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 95, 0, 80 , 40)];
    label4ResultTitle.text = LLSTR(@"101720");
    label4ResultTitle.font = [UIFont systemFontOfSize:14];
    label4ResultTitle.textAlignment = NSTextAlignmentRight;
    [view4Header addSubview:label4ResultTitle];
    
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, self.view.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    [view4Header addSubview:view4Seperator];
    
    return view4Header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    //有更多？
    if (hasMore && indexPath.row >= array4Account.count)
    {
        UILabel *label4More = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        label4More.text = LLSTR(@"101031");
        label4More.font = [UIFont systemFontOfSize:12];
        label4More.textColor = [UIColor lightGrayColor];
        label4More.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label4More];
        
        [self moreData];
        return cell;
    }
    
    // Configure the cell...
    UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 80, 44)];
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"MM/dd HH:mm";
    NSString *str = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"time"]doubleValue]/1000]];
    
    label4Time.text = str;
    label4Time.font = [UIFont fontWithName:@"Monaco" size:11];
    label4Time.textColor = [UIColor grayColor];
    label4Time.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label4Time];
    
    //解锁需要不同的样式I
    if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"TOKEN_UNLOCK"] &&
        [[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"jsonRemark"]objectForKey:@"uId"] != nil)
    {
        if ([self.coinSymbol isEqualToString:@"TOKEN"])
        {
            //方式
            UILabel *label4Type = [[UILabel alloc]initWithFrame:CGRectMake(100, 6, self.view.frame.size.width - 250, 17)];
            label4Type.font = [UIFont fontWithName:@"Monaco" size:11];
            label4Type.textColor = [UIColor grayColor];
            label4Type.text = LLSTR(@"103220");
            [cell.contentView addSubview:label4Type];

            //用户名
            NSString *uid = [[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"jsonRemark"]objectForKey:@"uId"];
            NSString *nickName = [[BiChatGlobal sharedManager]getFriendNickName:uid];
            nickName = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:uid groupProperty:nil nickName:nickName];
            UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(100, 23, self.view.frame.size.width - 250, 17)];
            label4NickName.font = [UIFont fontWithName:@"Monaco" size:11];
            label4NickName.text = nickName;
            label4NickName.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4NickName];
        }
        else
        {
            //方式
            UILabel *label4Type = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 250, 44)];
            label4Type.font = [UIFont fontWithName:@"Monaco" size:11];
            label4Type.textColor = [UIColor grayColor];
            label4Type.text = LLSTR(@"101702");
            [cell.contentView addSubview:label4Type];
        }
    }
    else
    {
        //方式
        UILabel *label4Type = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 250, 44)];
        label4Type.font = [UIFont fontWithName:@"Monaco" size:11];
        label4Type.textColor = [UIColor grayColor];
        [cell.contentView addSubview:label4Type];
        
        //根据不同的类型做工作
        if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"REWARD_CREATE"])
            label4Type.text = LLSTR(@"103201");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"REWARD_RECEIVE"])
            label4Type.text = LLSTR(@"103202");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"TRANSFER_CREATE"])
            label4Type.text = LLSTR(@"103203");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"TRANSFER_RECEIVE"])
            label4Type.text = LLSTR(@"103204");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"TRANSFER_CANCEL"])
            label4Type.text = LLSTR(@"103205");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"REWARD_REFUND"])
            label4Type.text = LLSTR(@"103206");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"TRANSFER_EXPIRE"])
            label4Type.text = LLSTR(@"103207");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"REWARD_RECEIVE_TRANSFER"])
            label4Type.text = LLSTR(@"103208");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"POINT_CREATE"])
            label4Type.text = LLSTR(@"103209");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"TOKEN_UNLOCK"])
        {
            if ([self.coinSymbol isEqualToString:@"TOKEN"])
                label4Type.text = LLSTR(@"103210");
            else
                label4Type.text = LLSTR(@"101702");
        }
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"DEPOSIT"])
            label4Type.text = LLSTR(@"103211");
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"WITHDRAW_REQUEST"])
        {
            if ([[[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"jsonRemark"]objectForKey:@"fee"]boolValue])
                label4Type.text = LLSTR(@"103213");
            else
                label4Type.text = LLSTR(@"103212");
        }
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"WITHDRAW_CONFIRM"])
        {
            if ([[[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"jsonRemark"]objectForKey:@"fee"]boolValue])
                label4Type.text = LLSTR(@"103213");
            else
                label4Type.text = LLSTR(@"103212");
        }
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"WITHDRAW_REFUND"])
        {
            if ([[[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"jsonRemark"]objectForKey:@"fee"]boolValue])
                label4Type.text = LLSTR(@"103214");
            else
                label4Type.text = LLSTR(@"103215");
        }
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"WITHDRAW_REQ_APPROVE"])
        {
            if ([[[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"jsonRemark"]objectForKey:@"fee"]boolValue])
                label4Type.text = LLSTR(@"103213");
            else
                label4Type.text = LLSTR(@"103212");
        }
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"WITHDRAW_REQ_DENY"])
            label4Type.text = LLSTR(@"103216");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"P2PEX_REQUEST"])
            label4Type.text = LLSTR(@"103217");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"P2PEX_DEAL"])
            label4Type.text = LLSTR(@"103218");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"P2PEX_QUIT"])
            label4Type.text = LLSTR(@"103219");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_DECLINE"])
            label4Type.text = LLSTR(@"103225");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_INSTANT"])
            label4Type.text = LLSTR(@"103221");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_POOL"])
            label4Type.text = LLSTR(@"103223");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_PEND"])
            label4Type.text = LLSTR(@"103222");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_REFUND"])
            label4Type.text = LLSTR(@"103224");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_DISPUTE_BACK"])
            label4Type.text = LLSTR(@"103226");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_ABORT"])
            label4Type.text = LLSTR(@"103227");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_REFUND_FORWARD"])
            label4Type.text = LLSTR(@"103232");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"BID_FREEZE"])
            label4Type.text = LLSTR(@"103228");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"BID_UNFREEZE"])
            label4Type.text = LLSTR(@"103229");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"POOL_DISTRIBUTE"])
            label4Type.text = LLSTR(@"103230");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_REFUND_FREEZE"])
            label4Type.text = LLSTR(@"103231");
        
        else if ([[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"]isEqualToString:@"PAY_REFUND_FORWARD"])
            label4Type.text = LLSTR(@"103232");
        
        else
            label4Type.text = [[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"transactionType"];
    }
    
    //数量
    UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 180, 0, 80, 44)];
    label4Count.font = [UIFont fontWithName:@"Monaco" size:11];
    label4Count.textAlignment = NSTextAlignmentRight;
    label4Count.adjustsFontSizeToFitWidth = YES;
    label4Count.textColor = [UIColor grayColor];
    label4Count.text = [[BiChatGlobal decimalNumberWithDouble:[[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"change"]doubleValue]]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", (long)[self getCoinBit:self.coinSymbol]] auotCheck:YES];
    [cell.contentView addSubview:label4Count];

    //结果
    UILabel *labelResult = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 95, 0, 80 , 44)];
    labelResult.textAlignment = NSTextAlignmentRight;
    labelResult.font = [UIFont fontWithName:@"Monaco" size:11];
    labelResult.adjustsFontSizeToFitWidth = YES;
    labelResult.textColor = [UIColor grayColor];
    double count = [[[[array4Account objectAtIndex:indexPath.row]objectForKey:@"balanceData"]objectForKey:@"value"]doubleValue];
    labelResult.text = [[NSString stringWithFormat:@"%.012f", count]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", (long)[self getCoinBit:self.coinSymbol]] auotCheck:NO];
    [cell.contentView addSubview:labelResult];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (NSInteger)getCoinBit:(NSString *)coinSymbol
{
    for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:coinSymbol])
            return [[item objectForKey:@"bit"]integerValue];
    }
    return 0;
}

- (void)initData
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getWalletAccount:self.coinSymbol currPage:1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            self->array4Account = [NSMutableArray arrayWithArray:[data objectForKey:@"list"]];
            hasMore = (self->array4Account.count == 20);
            [self.tableView reloadData];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301289") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)moreData
{
    if (moreLoading)
        return;
    moreLoading = YES;
    NSInteger page = array4Account.count / 20 + 1;
    [NetworkModule getWalletAccount:self.coinSymbol currPage:page completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        moreLoading = NO;
        if (success)
        {
            [self->array4Account addObjectsFromArray:[data objectForKey:@"list"]];
            hasMore = ([[data objectForKey:@"list"]count] == 20);
            [self.tableView reloadData];
        }
    }];
}

@end
