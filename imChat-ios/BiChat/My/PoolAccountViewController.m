//
//  PoolAccountViewController.m
//  BiChat
//
//  Created by imac2 on 2018/9/21.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "PoolAccountViewController.h"
#import "WPNewsDetailViewController.h"

@interface PoolAccountViewController ()

@end

@implementation PoolAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"108005");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"细则" style:UIBarButtonItemStylePlain target:self action:@selector(onButtonRule:)];
    self.navigationItem.rightBarButtonItem = nil;

    self.tableView.tableFooterView = [UIView new];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return array4PoolAccount.count + (hasMore?1:0);
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
    label4TimeTitle.text = LLSTR(@"101815");
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
    
    // Configure the cell...
    if (hasMore && indexPath.row >= array4PoolAccount.count)
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
    NSString *str = [NSString stringWithFormat:@"%@", [[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"date"]];
    if (str.length == 8)
        str = [NSString stringWithFormat:@"%@-%@-%@", [str substringToIndex:4], [str substringWithRange:NSMakeRange(4, 2)], [str substringFromIndex:6]];
    UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 80, 44)];
    label4Time.text = str;
    label4Time.font = [UIFont fontWithName:@"Monaco" size:11];
    label4Time.textColor = [UIColor grayColor];
    label4Time.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label4Time];
    
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
    
    //方式
    UILabel *label4Type = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 250, 44)];
    label4Type.font = [UIFont fontWithName:@"Monaco" size:11];
    label4Type.textColor = [UIColor grayColor];
    [cell.contentView addSubview:label4Type];
    if ([[[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == 1)
        label4Type.text = LLSTR(@"108081"); //解锁
    else if ([[[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == 2)
        label4Type.text = LLSTR(@"108082"); //分配
    else if ([[[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue] == 3)
        label4Type.text = LLSTR(@"108083"); //转入
    
    //数量
    UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 180, 0, 80, 44)];
    label4Count.font = [UIFont fontWithName:@"Monaco" size:11];
    label4Count.textAlignment = NSTextAlignmentRight;
    label4Count.adjustsFontSizeToFitWidth = YES;
    label4Count.textColor = [UIColor grayColor];
    label4Count.text = [[BiChatGlobal decimalNumberWithDouble:[[[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"volume"]doubleValue]]accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%ld", [[CoinInfo objectForKey:@"bit"]integerValue]] auotCheck:YES];
    [cell.contentView addSubview:label4Count];
    
    //结果
    UILabel *labelResult = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 95, 0, 80 , 44)];
    labelResult.textAlignment = NSTextAlignmentRight;
    labelResult.font = [UIFont fontWithName:@"Monaco" size:11];
    labelResult.adjustsFontSizeToFitWidth = YES;
    labelResult.textColor = [UIColor grayColor];
    labelResult.text = [NSString stringWithFormat:@"%lld", [[[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"balance"]longLongValue]];
    [cell.contentView addSubview:labelResult];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger type = [[[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"type"]integerValue];
    
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
    
    if (type == 1)
    {
        //显示详情
        UIView *view4InfoPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 370)];
        view4InfoPanel.backgroundColor = [UIColor whiteColor];
        view4InfoPanel.layer.cornerRadius = 5;
        view4InfoPanel.clipsToBounds = YES;
        
        UIButton *button4Close = [[UIButton alloc]initWithFrame:CGRectMake(260, 0, 40, 40)];
        [button4Close setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
        [button4Close addTarget:self action:@selector(onButtonClosePresentedWnd:) forControlEvents:UIControlEventTouchUpInside];
        [view4InfoPanel addSubview:button4Close];
        
        NSDictionary *item = [[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"jsonRemark"];
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
        UILabel *label4Line1Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 70, view4InfoPanel.frame.size.width - 30, 20)];
        label4Line1Title.text = LLSTR(@"101808");
        label4Line1Title.font = [UIFont systemFontOfSize:14];
        label4Line1Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line1Title];
        
        //第一子行
        UILabel *label4Line11Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 95, 100, 20)];
        label4Line11Title.text = LLSTR(@"101818");
        label4Line11Title.font = [UIFont systemFontOfSize:14];
        label4Line11Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line11Title];

        UILabel *label4Line11Value = [[UILabel alloc]initWithFrame:CGRectMake(120, 95, 165, 20)];
        label4Line11Value.text = [NSString stringWithFormat:@"%ld", [[item objectForKey:@"unlockFailCount"]integerValue]];
        label4Line11Value.font = [UIFont systemFontOfSize:14];
        label4Line11Value.textAlignment = NSTextAlignmentRight;
        label4Line11Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line11Value];
        
        //第二子行
        UILabel *label4Line12Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 120, 100, 20)];
        label4Line12Title.text = LLSTR(@"101819");
        label4Line12Title.font = [UIFont systemFontOfSize:14];
        label4Line12Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line12Title];
        
        UILabel *label4Line12Value = [[UILabel alloc]initWithFrame:CGRectMake(120, 120, 165, 20)];
        label4Line12Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"unlockFailToken"]doubleValue]];
        label4Line12Value.font = [UIFont systemFontOfSize:14];
        label4Line12Value.textAlignment = NSTextAlignmentRight;
        label4Line12Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line12Value];
        
        //第二行
        UILabel *label4Line2Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 160, view4InfoPanel.frame.size.width - 30, 20)];
        label4Line2Title.text = LLSTR(@"101820");
        label4Line2Title.font = [UIFont systemFontOfSize:14];
        label4Line2Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line2Title];
        
        //第一子行
        UILabel *label4Line21Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 185, 100, 20)];
        label4Line21Title.text = LLSTR(@"101818");
        label4Line21Title.font = [UIFont systemFontOfSize:14];
        label4Line21Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line21Title];

        UILabel *label4Line2Value = [[UILabel alloc]initWithFrame:CGRectMake(120, 185, 165, 20)];
        label4Line2Value.text = [NSString stringWithFormat:@"%ld", [[item objectForKey:@"refUnlockFailCount"]integerValue] + [[item objectForKey:@"refVIPUnlockCount"]integerValue]];
        label4Line2Value.font = [UIFont systemFontOfSize:14];
        label4Line2Value.textAlignment = NSTextAlignmentRight;
        label4Line2Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line2Value];
        
        //第三行
        UILabel *label4Line22Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 210, 100, 20)];
        label4Line22Title.text = LLSTR(@"101819");
        label4Line22Title.font = [UIFont systemFontOfSize:14];
        label4Line22Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line22Title];

        UILabel *label4Line3Value = [[UILabel alloc]initWithFrame:CGRectMake(120, 210, 165, 20)];
        label4Line3Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"refUnlockFailToken"]doubleValue] + [[item objectForKey:@"refVIPUnlockToken"]doubleValue]];
        label4Line3Value.font = [UIFont systemFontOfSize:14];
        label4Line3Value.textAlignment = NSTextAlignmentRight;
        label4Line3Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line3Value];
        
        //第六行
        UILabel *label4Line6Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 250, 100, 20)];
        label4Line6Title.text = LLSTR(@"108003");
        label4Line6Title.font = [UIFont systemFontOfSize:14];
        label4Line6Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line6Title];
        
        UILabel *label4Line6Value = [[UILabel alloc]initWithFrame:CGRectMake(120, 250, 165, 20)];
        label4Line6Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"balance"]doubleValue]];
        label4Line6Value.font = [UIFont systemFontOfSize:14];
        label4Line6Value.textAlignment = NSTextAlignmentRight;
        label4Line6Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line6Value];
        
        [BiChatGlobal presentModalView:view4InfoPanel clickDismiss:YES delayDismiss:0 andDismissCallback:nil];
    }
    else if (type == 2)
    {
        //显示详情
        UIView *view4InfoPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 370)];
        view4InfoPanel.backgroundColor = [UIColor whiteColor];
        view4InfoPanel.layer.cornerRadius = 5;
        view4InfoPanel.clipsToBounds = YES;
        
        UIButton *button4Close = [[UIButton alloc]initWithFrame:CGRectMake(260, 0, 40, 40)];
        [button4Close setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
        [button4Close addTarget:self action:@selector(onButtonClosePresentedWnd:) forControlEvents:UIControlEventTouchUpInside];
        [view4InfoPanel addSubview:button4Close];
        
        NSDictionary *item = [[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"jsonRemark"];
        NSString *str = [NSString stringWithFormat:@"%@", [[array4PoolAccount objectAtIndex:indexPath.row]objectForKey:@"date"]];
        if (str.length == 8)
        {
            UILabel *label4Date = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 280, 40)];
            label4Date.text = [NSString stringWithFormat:@"%@-%@-%@", [str substringToIndex:4], [str substringWithRange:NSMakeRange(4, 2)], [str substringWithRange:NSMakeRange(6, 2)]];;
            label4Date.font = [UIFont systemFontOfSize:20];
            label4Date.textAlignment = NSTextAlignmentCenter;
            [view4InfoPanel addSubview:label4Date];
        }
        
        //第一行
        UILabel *label4Line1Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 70, view4InfoPanel.frame.size.width - 30, 20)];
        label4Line1Title.text = LLSTR(@"108201");
        label4Line1Title.font = [UIFont systemFontOfSize:14];
        label4Line1Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line1Title];
        
        //第一子行
        UILabel *label4Line11Value = [[UILabel alloc]initWithFrame:CGRectMake(20, 95, 265, 20)];
        label4Line11Value.text = [LLSTR(@"108202")llReplaceWithArray:@[[NSString stringWithFormat:@"%@", [item objectForKey:@"userCount"]==nil?@"0":[item objectForKey:@"userCount"]],
                                                                       [NSString stringWithFormat:@"%@", [item objectForKey:@"orderCount"]==nil?@"0":[item objectForKey:@"orderCount"]],
                                                                       [NSString stringWithFormat:@"%@", [item objectForKey:@"userAmount"]==nil?@"0":[item objectForKey:@"userAmount"]]]];
        label4Line11Value.font = [UIFont systemFontOfSize:14];
        label4Line11Value.textAlignment = NSTextAlignmentRight;
        label4Line11Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line11Value];
        
        //第二子行
        UILabel *label4Line12Value = [[UILabel alloc]initWithFrame:CGRectMake(20, 120, 265, 20)];
        label4Line12Value.text = [LLSTR(@"108203")llReplaceWithArray:@[[NSString stringWithFormat:@"%@", [item objectForKey:@"confirmUser"]==nil?@"0":[item objectForKey:@"confirmUser"]],
                                                                       [NSString stringWithFormat:@"%@", [item objectForKey:@"confirmCount"]==nil?@"0":[item objectForKey:@"confirmCount"]],
                                                                       [NSString stringWithFormat:@"%@", [item objectForKey:@"confirmAmount"]==nil?@"0":[item objectForKey:@"confirmAmount"]]]];
        label4Line12Value.font = [UIFont systemFontOfSize:14];
        label4Line12Value.textAlignment = NSTextAlignmentRight;
        label4Line12Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line12Value];
        
        //第三子行
        UILabel *label4Line13Value = [[UILabel alloc]initWithFrame:CGRectMake(20, 145, 265, 20)];
        label4Line13Value.text = [LLSTR(@"108204")llReplaceWithArray:@[[NSString stringWithFormat:@"%@", [item objectForKey:@"winningUser"]==nil?@"0":[item objectForKey:@"winningUser"]],
                                                                       [NSString stringWithFormat:@"%@", [item objectForKey:@"winningOrder"]==nil?@"0":[item objectForKey:@"winningOrder"]],
                                                                       [NSString stringWithFormat:@"%@", [item objectForKey:@"winningAmount"]==nil?@"0":[item objectForKey:@"winningAmount"]]]];
        label4Line13Value.font = [UIFont systemFontOfSize:14];
        label4Line13Value.textAlignment = NSTextAlignmentRight;
        label4Line13Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line13Value];
        
        //第二行
        UILabel *label4Line2Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 185, view4InfoPanel.frame.size.width - 30, 20)];
        label4Line2Title.text = LLSTR(@"108205");
        label4Line2Title.font = [UIFont systemFontOfSize:14];
        label4Line2Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line2Title];
        
        //第一子行
        UILabel *label4Line21Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 210, 100, 20)];
        label4Line21Title.text = LLSTR(@"108206");
        label4Line21Title.font = [UIFont systemFontOfSize:14];
        label4Line21Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line21Title];
        
        UILabel *label4Line21Value = [[UILabel alloc]initWithFrame:CGRectMake(120, 210, 165, 20)];
        label4Line21Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"userAllotVolume"]doubleValue]];
        label4Line21Value.font = [UIFont systemFontOfSize:14];
        label4Line21Value.textAlignment = NSTextAlignmentRight;
        label4Line21Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line21Value];
        
        //第二子行
        UILabel *label4Line22Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 235, 100, 20)];
        label4Line22Title.text = LLSTR(@"108207");
        label4Line22Title.font = [UIFont systemFontOfSize:14];
        label4Line22Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line22Title];
        
        UILabel *label4Line22Value = [[UILabel alloc]initWithFrame:CGRectMake(120, 235, 165, 20)];
        label4Line22Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"groupAllotVolume"]doubleValue]];
        label4Line22Value.font = [UIFont systemFontOfSize:14];
        label4Line22Value.textAlignment = NSTextAlignmentRight;
        label4Line22Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line22Value];
        
        //第三子行
        UILabel *label4Line23Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 260, 100, 20)];
        label4Line23Title.text = LLSTR(@"108208");
        label4Line23Title.font = [UIFont systemFontOfSize:14];
        label4Line23Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line23Title];
        
        UILabel *label4Line23Value = [[UILabel alloc]initWithFrame:CGRectMake(120, 260, 165, 20)];
        label4Line23Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"nodeAllotVolume"]doubleValue]];
        label4Line23Value.font = [UIFont systemFontOfSize:14];
        label4Line23Value.textAlignment = NSTextAlignmentRight;
        label4Line23Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line23Value];
        
        //第四子行
        UILabel *label4Line24Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 285, 100, 20)];
        label4Line24Title.text = LLSTR(@"108209");
        label4Line24Title.font = [UIFont systemFontOfSize:14];
        label4Line24Title.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line24Title];
        
        UILabel *label4Line24Value = [[UILabel alloc]initWithFrame:CGRectMake(120, 285, 165, 20)];
        label4Line24Value.text = [NSString stringWithFormat:format, [[item objectForKey:@"developerAllotVolume"]doubleValue]];
        label4Line24Value.font = [UIFont systemFontOfSize:14];
        label4Line24Value.textAlignment = NSTextAlignmentRight;
        label4Line24Value.textColor = [UIColor grayColor];
        [view4InfoPanel addSubview:label4Line24Value];
        
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 300, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
        [view4InfoPanel addSubview:view4Seperator];
        
        [BiChatGlobal presentModalView:view4InfoPanel clickDismiss:YES delayDismiss:0 andDismissCallback:nil];
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

- (void)initData
{
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getPoolHistory:1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            array4PoolAccount = [NSMutableArray arrayWithArray:[data objectForKey:@"list"]];
            hasMore = (array4PoolAccount.count == 20);
            [self.tableView reloadData];
            //NSLog(@"%@", array4PoolAccount);
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301289") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

- (void)moreData
{
    if (moreLoading)
        return;
    moreLoading = YES;
    
    NSInteger page = array4PoolAccount.count / 20 + 1;
    [NetworkModule getPoolHistory:page completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        moreLoading = NO;
        if (success)
        {
            [array4PoolAccount addObjectsFromArray:[data objectForKey:@"list"]];
            hasMore = ([[data objectForKey:@"list"]count] == 20);
            [self.tableView reloadData];
        }
        
    }];
}

- (void)onButtonClosePresentedWnd:(id)sender
{
    [BiChatGlobal dismissModalView];
}

- (void)onButtonRule:(id)sender
{
    //生成链接窗口
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
    wnd.cannotShare = YES;
//    wnd.url = @"http://www.imchat.com/pool.html";
    wnd.url = [NSString stringWithFormat:@"http://www.imchat.com/pool/pool_%@_%@.html",DIFAPPID,[DFLanguageManager getLanguageName]];
    [self.navigationController pushViewController:wnd animated:YES];
}

@end
