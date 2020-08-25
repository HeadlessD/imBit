//
//  UnlockHistoryViewController.m
//  BiChat
//
//  Created by imac2 on 2018/9/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "UnlockHistoryViewController.h"

@interface UnlockHistoryViewController ()

@end

@implementation UnlockHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = nil;
    self.tableView.tableHeaderView = [self createSummaryPanel];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    
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

    [self freshData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BiChatGlobal HideActivityIndicator];
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
    return [array4MonthUnlock count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger year = [[[array4MonthUnlock objectAtIndex:indexPath.row]objectForKey:@"year"]integerValue];
    NSInteger month = [[[array4MonthUnlock objectAtIndex:indexPath.row]objectForKey:@"month"]integerValue];
    return [self GetCalenderLineForMonth:year month:month] * 36 + 55 + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    NSInteger year = [[[array4MonthUnlock objectAtIndex:indexPath.row]objectForKey:@"year"]integerValue];
    NSInteger month = [[[array4MonthUnlock objectAtIndex:indexPath.row]objectForKey:@"month"]integerValue];
    
    // Configure the cell...
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger line = [self GetCalenderLineForMonth:year month:month];
    UIView *calenderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, line * 36 + 55 + 1)];
    calenderView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    
    //下面代码为生成日历
    //获取本月1号的时间，以及是星期几
    NSInteger intval = self.view.frame.size.width / 7;
    CGFloat calenderPositionOffset = 55;
    NSDateComponents *comp = [NSDateComponents new];
    comp.year = year;
    comp.month = month;
    
    //第一天的时间
    NSDate *mondayDate = [calendar dateFromComponents:comp];
    
    //下个月的第一天的时间
    NSDateComponents *compInteval = [NSDateComponents new];
    compInteval.month = 1;
    NSDate *date4NextMonthFirstDay = [calendar dateByAddingComponents:compInteval toDate:mondayDate options:0];
    
    //几个关键点的日期（开始时间和结束时间）
    NSDate *beginDate = [NSDate date];
    NSDate *endDate = [NSDate date];
    
    // Configure the cell...
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(0, 7, self.view.frame.size.width, 25)];
   
    NSString * monthNum = [NSString stringWithFormat:@"%ld",101070+(long)month];
    NSString * yearStr = [NSString stringWithFormat:@"%ld",(long)year];

    label4Title.text = [NSString stringWithFormatWithIM:LLSTR(monthNum),yearStr,nil];
//    label4Title.text = [NSString stringWithFormat:@"%ld年%ld月", (long)year, (long)month];
    label4Title.font = [UIFont systemFontOfSize:15];
    label4Title.textAlignment = NSTextAlignmentCenter;
    label4Title.textColor = [UIColor lightGrayColor];
    [calenderView addSubview:label4Title];

    //week title
    UILabel *label4SundayTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 35, intval, 14)];
    label4SundayTitle.text = LLSTR(@"101097");
    label4SundayTitle.font = [UIFont systemFontOfSize:11];
    label4SundayTitle.textAlignment = NSTextAlignmentCenter;
    label4SundayTitle.textColor = [UIColor lightGrayColor];
    [calenderView addSubview:label4SundayTitle];
    
    UILabel *label4MondayTitle = [[UILabel alloc]initWithFrame:CGRectMake(intval, 35, intval, 14)];
    label4MondayTitle.text = LLSTR(@"101091");
    label4MondayTitle.font = [UIFont systemFontOfSize:11];
    label4MondayTitle.textAlignment = NSTextAlignmentCenter;
    label4MondayTitle.textColor = [UIColor lightGrayColor];
    [calenderView addSubview:label4MondayTitle];
    
    UILabel *label4TuesdayTitle = [[UILabel alloc]initWithFrame:CGRectMake(intval * 2, 35, intval, 14)];
    label4TuesdayTitle.text = LLSTR(@"101092");
    label4TuesdayTitle.font = [UIFont systemFontOfSize:11];
    label4TuesdayTitle.textAlignment = NSTextAlignmentCenter;
    label4TuesdayTitle.textColor = [UIColor lightGrayColor];
    [calenderView addSubview:label4TuesdayTitle];
    
    UILabel *label4WednesdayTitle = [[UILabel alloc]initWithFrame:CGRectMake(intval * 3, 35, intval, 14)];
    label4WednesdayTitle.text = LLSTR(@"101093");
    label4WednesdayTitle.font = [UIFont systemFontOfSize:11];
    label4WednesdayTitle.textAlignment = NSTextAlignmentCenter;
    label4WednesdayTitle.textColor = [UIColor lightGrayColor];
    [calenderView addSubview:label4WednesdayTitle];
    
    UILabel *label4ThursdayTitle = [[UILabel alloc]initWithFrame:CGRectMake(intval * 4, 35, intval, 14)];
    label4ThursdayTitle.text = LLSTR(@"101094");
    label4ThursdayTitle.font = [UIFont systemFontOfSize:11];
    label4ThursdayTitle.textAlignment = NSTextAlignmentCenter;
    label4ThursdayTitle.textColor = [UIColor lightGrayColor];
    [calenderView addSubview:label4ThursdayTitle];
    
    UILabel *label4FridayTitle = [[UILabel alloc]initWithFrame:CGRectMake(intval * 5, 35, intval, 14)];
    label4FridayTitle.text = LLSTR(@"101095");
    label4FridayTitle.font = [UIFont systemFontOfSize:11];
    label4FridayTitle.textAlignment = NSTextAlignmentCenter;
    label4FridayTitle.textColor = [UIColor lightGrayColor];
    [calenderView addSubview:label4FridayTitle];
    
    UILabel *label4SaturdayTitle = [[UILabel alloc]initWithFrame:CGRectMake(intval * 6, 35, intval, 14)];
    label4SaturdayTitle.text = LLSTR(@"101096");
    label4SaturdayTitle.font = [UIFont systemFontOfSize:11];
    label4SaturdayTitle.textAlignment = NSTextAlignmentCenter;
    label4SaturdayTitle.textColor = [UIColor lightGrayColor];
    [calenderView addSubview:label4SaturdayTitle];
    
    //calender background
    UIView *view4CalenderBk = [[UIView alloc]initWithFrame:CGRectMake(0, 54, self.view.frame.size.width, [self GetCalenderLineForMonth:year month:month] * 36 + 1)];
    view4CalenderBk.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    [calenderView addSubview:view4CalenderBk];
    
    //本月
    NSInteger lastOffset = 0;
    NSInteger lastLine = 0;
    for (int i = 1; i < 32; i ++)
    {
        comp.day = i;
        NSDate *date = [calendar dateFromComponents:comp];
        
        //如果到了下一个月,退出
        if ([date compare:date4NextMonthFirstDay] != NSOrderedAscending)
            break;
        
        NSInteger offset = [calendar component:NSCalendarUnitWeekday fromDate:date];
        NSInteger line = [calendar component:NSCalendarUnitWeekOfMonth fromDate:date];
        
        UIButton *button4Day = [[UIButton alloc]initWithFrame:CGRectMake((offset - 1) * intval,
                                                                         (line - 1) * 36+ calenderPositionOffset,
                                                                         intval,
                                                                         35)];
        button4Day.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
        
        //本日比较点
        NSDate *dateToday = [NSDate date];
        NSInteger yearTmp = [calendar component:NSCalendarUnitYear fromDate:dateToday];
        NSInteger monthTmp = [calendar component:NSCalendarUnitMonth fromDate:dateToday];
        NSInteger dayTmp = [calendar component:NSCalendarUnitDay fromDate:dateToday];
        
        //开始点比较点
        NSInteger yearBegin = [calendar component:NSCalendarUnitYear fromDate:beginDate];
        NSInteger monthBegin = [calendar component:NSCalendarUnitMonth fromDate:beginDate];
        NSInteger dayBegin = [calendar component:NSCalendarUnitDay fromDate:beginDate];
        
        //结束点比较点
        NSInteger yearEnd = [calendar component:NSCalendarUnitYear fromDate:endDate];
        NSInteger monthEnd = [calendar component:NSCalendarUnitMonth fromDate:endDate];
        NSInteger dayEnd = [calendar component:NSCalendarUnitDay fromDate:endDate];
        
        //是否开始以前的日子
        if (year < yearBegin ||
            (year == yearBegin && month < monthBegin) ||
            (year == yearBegin && month == monthBegin && i < dayBegin))
        {
            button4Day.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
            [button4Day setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        
        //是否是结束以后的日子
        else if (year > yearEnd ||
                 (year == yearEnd && month > monthEnd) ||
                 (year == yearEnd && month == monthEnd && i > dayEnd))
        {
            button4Day.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
            [button4Day setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        
        //是否还没有到
        else if (year > yearTmp ||
                 (year == yearTmp && month > monthTmp) ||
                 (year == yearTmp && month == monthTmp && i > dayTmp))
        {
            button4Day.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
            [button4Day setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        
        //可以操作的日子
        else
        {
            button4Day.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
            [button4Day setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button4Day addTarget:self action:@selector(onButtonDay:) forControlEvents:UIControlEventTouchUpInside];
        }
        [button4Day setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        
        //是否本日
        if (year == yearTmp && monthTmp == month && dayTmp == i)
        {
            button4Day.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
            [button4Day setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            UILabel *label4Day = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            label4Day.layer.cornerRadius = 15;
            label4Day.clipsToBounds = year;
            label4Day.backgroundColor = THEME_COLOR;
            //label4Day.textColor = THEME_COLOR;
            label4Day.center = CGPointMake(button4Day.bounds.size.width / 2, 12);
            [button4Day addSubview:label4Day];
        }
        
        //本日是否有解锁
        NSString *str = [NSString stringWithFormat:@"%04ld%02ld%02d", (long)year, month, i];
        for (NSDictionary *item in array4DayUnlock)
        {
            if (str.integerValue == [[item objectForKey:@"date"]integerValue])
            {
                if ([[item objectForKey:@"unLock"]boolValue])
                {
                    UILabel *label4CheckYes = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
                    label4CheckYes.text = @"✓";
                    label4CheckYes.font = [UIFont systemFontOfSize:12];
                    label4CheckYes.textColor = THEME_COLOR;
                    [label4CheckYes sizeToFit];
                    label4CheckYes.center = CGPointMake(button4Day.bounds.size.width / 2 + 2, 26);
                    [button4Day addSubview:label4CheckYes];
                }
                else
                {
                    UIView *view4CheckNo = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 6, 6)];
                    view4CheckNo.backgroundColor = THEME_GRAY;
                    view4CheckNo.layer.cornerRadius = 3;
                    view4CheckNo.center = CGPointMake(button4Day.bounds.size.width / 2, 26);
                    [button4Day addSubview:view4CheckNo];
                }
            }
        }
        
        [calenderView addSubview:button4Day];
        
        //设置本日button性质
        button4Day.tag = i;
        
        //纪录一下
        lastOffset = offset;
        lastLine = line;
    }
    
    [cell.contentView addSubview:calenderView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)onButtonDay:(id)sender
{
    
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
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getMyUnlockHistory:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        //NSLog(@"%@", data);
        if (success)
        {
            dict4UnlockHistory = data;
            array4DayUnlock = [data objectForKey:@"list"];
            [self calcArray4MonthUnlock];
            [self.tableView reloadData];
            self.tableView.tableHeaderView = [self createSummaryPanel];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301657") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
}

//把所有的按天列表统计成按月列表
- (void)calcArray4MonthUnlock
{
    array4MonthUnlock = [NSMutableArray array];
    
    for (int i = 0; i < array4DayUnlock.count; i ++)
    {
        //看看这一天是那一年
        NSDictionary *item = [array4DayUnlock objectAtIndex:i];
        NSString *str = [NSString stringWithFormat:@"%@", [item objectForKey:@"date"]];
        if ([str length] != 8)
            continue;
        
        NSInteger year = [[str substringToIndex:4]integerValue];
        NSInteger month = [[str substringWithRange:NSMakeRange(4, 2)]integerValue];
        
        //查一下这一个月是否已经收录
        BOOL found = NO;
        for (NSDictionary *item2 in array4MonthUnlock)
        {
            if ([[item2 objectForKey:@"year"]integerValue] == year &&
                [[item2 objectForKey:@"month"]integerValue] == month)
            {
                found = YES;
                break;
            }
        }
        if (!found)
            [array4MonthUnlock addObject:@{@"year":[NSNumber numberWithInteger:year], @"month": [NSNumber numberWithInteger:month]}];
    }
}

- (UIView *)createSummaryPanel
{
    if (dict4UnlockHistory == nil)
        return [UIView new];
    
    UIView *view4Summary = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 290)];
    view4Summary.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    
    UIView *view4Summary1 = [[UIView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 80)];
    view4Summary1.layer.cornerRadius = 5;
    view4Summary1.clipsToBounds = YES;
    view4Summary1.backgroundColor = [UIColor whiteColor];
    [view4Summary addSubview:view4Summary1];
    [self createSummaryPanel1:view4Summary1];
    
    UIImageView *image4Arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_up_white"]];
    image4Arrow.center = CGPointMake(40 + (self.view.frame.size.width - 40) / 100 * 24, 99);
    [view4Summary addSubview:image4Arrow];
    
    UIView *view4Summary4 = [[UIView alloc]initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 80)];
    view4Summary4.layer.cornerRadius = 5;
    view4Summary4.clipsToBounds = YES;
    view4Summary4.backgroundColor = [UIColor whiteColor];
    [view4Summary addSubview:view4Summary4];
    [self createSummaryPanel4:view4Summary4];
    
    UIView *view4Summary2 = [[UIView alloc]initWithFrame:CGRectMake(10, 190, 120, 80)];
    view4Summary2.layer.cornerRadius = 5;
    view4Summary2.clipsToBounds = YES;
    view4Summary2.backgroundColor = [UIColor whiteColor];
    [view4Summary addSubview:view4Summary2];
    [self createSummaryPanel2:view4Summary2];
    
    UIView *view4Summary3 = [[UIView alloc]initWithFrame:CGRectMake(140, 190, self.view.frame.size.width - 150, 80)];
    view4Summary3.layer.cornerRadius = 5;
    view4Summary3.clipsToBounds = YES;
    view4Summary3.backgroundColor = [UIColor whiteColor];
    [view4Summary addSubview:view4Summary3];
    [self createSummaryPanel3:view4Summary3];
    
    return view4Summary;
}

- (void)createSummaryPanel1:(UIView *)subPanel
{
    CGFloat width = (subPanel.frame.size.width - 20) / 100;

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

    //已分配
    UILabel *label4Value1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, width * 13, 20)];
    label4Value1.text = [NSString stringWithFormat:@"%ld", [[dict4UnlockHistory objectForKey:@"allotToken"]integerValue]];
    label4Value1.font = [UIFont boldSystemFontOfSize:16];
    label4Value1.textAlignment = NSTextAlignmentCenter;
    label4Value1.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value1];
    
    UILabel *label4Name1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 45, width * 13, 20)];
    if ([[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"tokenStatus"]integerValue] == 0)
        label4Name1.text = LLSTR(@"101706");
    else if ([[[BiChatGlobal sharedManager].dict4MyTokenInfo objectForKey:@"tokenStatus"]integerValue] == 1)
        label4Name1.text = LLSTR(@"101707");
    else
        label4Name1.text = LLSTR(@"101708");
    label4Name1.font = [UIFont systemFontOfSize:12];
    label4Name1.textColor = [UIColor grayColor];
    label4Name1.textAlignment = NSTextAlignmentCenter;
    label4Name1.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name1];
    
    UILabel *label4Equal = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 13, 15, width * 5, 20)];
    label4Equal.text = @"=";
    label4Equal.textColor = [UIColor grayColor];
    label4Equal.font = [UIFont systemFontOfSize:16];
    label4Equal.textAlignment = NSTextAlignmentCenter;
    label4Equal.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Equal];
    
    //已解锁
    UILabel *label4Value2 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 18, 15, width * 24, 20)];
    label4Value2.text = [NSString stringWithFormat:format, [[dict4UnlockHistory objectForKey:@"unlockToken"]floatValue]];
    label4Value2.font = [UIFont boldSystemFontOfSize:16];
    label4Value2.textAlignment = NSTextAlignmentCenter;
    label4Value2.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value2];
    
    UILabel *label4Name2 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 18, 45, width * 24, 20)];
    label4Name2.text = LLSTR(@"101709");
    label4Name2.font = [UIFont systemFontOfSize:12];
    label4Name2.textColor = [UIColor grayColor];
    label4Name2.textAlignment = NSTextAlignmentCenter;
    label4Name2.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name2];
    
    UILabel *label4Plus1 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 42, 15, width * 5, 20)];
    label4Plus1.text = @"+";
    label4Plus1.textColor = [UIColor grayColor];
    label4Plus1.font = [UIFont systemFontOfSize:16];
    label4Plus1.textAlignment = NSTextAlignmentCenter;
    label4Plus1.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Plus1];
    
    //解锁失败
    UILabel *label4Value3 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 47, 15, width * 24, 20)];
    label4Value3.text = [NSString stringWithFormat:format, [[dict4UnlockHistory objectForKey:@"failedToken"]floatValue]];
    label4Value3.font = [UIFont boldSystemFontOfSize:16];
    label4Value3.textAlignment = NSTextAlignmentCenter;
    label4Value3.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value3];
    
    UILabel *label4Name3 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 47, 45, width * 24, 20)];
    label4Name3.text = LLSTR(@"101808");
    label4Name3.font = [UIFont systemFontOfSize:12];
    label4Name3.textColor = [UIColor grayColor];
    label4Name3.textAlignment = NSTextAlignmentCenter;
    label4Name3.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name3];
    
    UILabel *label4Plus2 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 71, 15, width * 5, 20)];
    label4Plus2.text = @"+";
    label4Plus2.textColor = [UIColor grayColor];
    label4Plus2.font = [UIFont systemFontOfSize:16];
    label4Plus2.textAlignment = NSTextAlignmentCenter;
    label4Plus2.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Plus2];
    
    //待解锁
    UILabel *label4Value4 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 76, 15, width * 24, 20)];
    label4Value4.text = [NSString stringWithFormat:format, [[dict4UnlockHistory objectForKey:@"lockToken"]floatValue]];
    label4Value4.font = [UIFont boldSystemFontOfSize:16];
    label4Value4.textAlignment = NSTextAlignmentCenter;
    label4Value4.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value4];
    
    UILabel *label4Name4 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 76, 45, width * 24, 20)];
    label4Name4.text = LLSTR(@"101809");
    label4Name4.font = [UIFont systemFontOfSize:12];
    label4Name4.textColor = [UIColor grayColor];
    label4Name4.textAlignment = NSTextAlignmentCenter;
    label4Name4.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name4];
}

- (void)createSummaryPanel2:(UIView *)subPanel
{
    CGFloat rate;
    if ([[dict4UnlockHistory objectForKey:@"unLockCount"]floatValue] == 0)
        rate = 0;
    else
        rate = [[dict4UnlockHistory objectForKey:@"successCount"]floatValue] / [[dict4UnlockHistory objectForKey:@"unLockCount"]floatValue];
    
    UILabel *label4Value = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, subPanel.frame.size.width - 20, 20)];
    label4Value.text = [NSString stringWithFormat:@"%ld%%", (long)(rate * 100)];
    label4Value.font = [UIFont boldSystemFontOfSize:16];
    label4Value.textAlignment = NSTextAlignmentCenter;
    [subPanel addSubview:label4Value];
    
    UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(10, 45, subPanel.frame.size.width - 20, 20)];
    label4Name.text = LLSTR(@"101715");
    label4Name.font = [UIFont systemFontOfSize:12];
    label4Name.textColor = [UIColor grayColor];
    label4Name.textAlignment = NSTextAlignmentCenter;
    [subPanel addSubview:label4Name];
}

- (void)createSummaryPanel3:(UIView *)subPanel
{
    CGFloat width = (subPanel.frame.size.width - 20) / 100;
    
    //已解锁天数
    UILabel *label4Value1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, width * 35, 20)];
    label4Value1.text = [NSString stringWithFormat:@"%@", [dict4UnlockHistory objectForKey:@"unLockCount"]];
    label4Value1.font = [UIFont boldSystemFontOfSize:16];
    label4Value1.textAlignment = NSTextAlignmentCenter;
    [subPanel addSubview:label4Value1];
    
    UILabel *label4Name1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 45, width * 35, 20)];
    label4Name1.text = LLSTR(@"101716");
    label4Name1.font = [UIFont systemFontOfSize:12];
    label4Name1.textColor = [UIColor grayColor];
    label4Name1.textAlignment = NSTextAlignmentCenter;
    label4Name1.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name1];
    
    UILabel *label4Equal = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 35, 15, width * 5, 20)];
    label4Equal.text = @"=";
    label4Equal.textColor = [UIColor grayColor];
    label4Equal.font = [UIFont systemFontOfSize:16];
    label4Equal.textAlignment = NSTextAlignmentCenter;
    label4Equal.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Equal];
    
    //成功
    UILabel *label4Value2 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 40, 15, width * 27, 20)];
    label4Value2.text = [NSString stringWithFormat:@"%@", [dict4UnlockHistory objectForKey:@"successCount"]];
    label4Value2.font = [UIFont boldSystemFontOfSize:16];
    label4Value2.textAlignment = NSTextAlignmentCenter;
    [subPanel addSubview:label4Value2];
    
    UILabel *label4Name2 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 40, 45, width * 27, 20)];
    label4Name2.text = LLSTR(@"101717");
    label4Name2.font = [UIFont systemFontOfSize:12];
    label4Name2.textColor = [UIColor grayColor];
    label4Name2.textAlignment = NSTextAlignmentCenter;
    label4Name2.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name2];
    
    UILabel *label4Plus = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 67, 15, width * 5, 20)];
    label4Plus.text = @"+";
    label4Plus.textColor = [UIColor grayColor];
    label4Plus.font = [UIFont systemFontOfSize:16];
    label4Plus.textAlignment = NSTextAlignmentCenter;
    label4Plus.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Plus];
    
    //失败
    UILabel *label4Value3 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 72, 15, width * 27, 20)];
    label4Value3.text = [NSString stringWithFormat:@"%@", [dict4UnlockHistory objectForKey:@"failCount"]];
    label4Value3.font = [UIFont boldSystemFontOfSize:16];
    label4Value3.textAlignment = NSTextAlignmentCenter;
    label4Value3.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value3];
    
    UILabel *label4Name3 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 72, 45, width * 27, 20)];
    label4Name3.text = LLSTR(@"101718");
    label4Name3.font = [UIFont systemFontOfSize:12];
    label4Name3.textColor = [UIColor grayColor];
    label4Name3.textAlignment = NSTextAlignmentCenter;
    label4Name3.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name3];
}

- (void)createSummaryPanel4:(UIView *)subPanel
{
    CGFloat width = (subPanel.frame.size.width - 20) / 100;
    
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
    
    UILabel *label4Equal = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, width * 5, 20)];
    label4Equal.text = @"=";
    label4Equal.textColor = [UIColor grayColor];
    label4Equal.font = [UIFont systemFontOfSize:16];
    label4Equal.textAlignment = NSTextAlignmentCenter;
    label4Equal.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Equal];
    
    //已解锁
    UILabel *label4Value2 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 5, 15, width * 15, 20)];
    label4Value2.text = [NSString stringWithFormat:format, [[dict4UnlockHistory objectForKey:@"myUnlockToken"]floatValue]];
    label4Value2.font = [UIFont boldSystemFontOfSize:16];
    label4Value2.textAlignment = NSTextAlignmentCenter;
    label4Value2.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value2];
    
    UILabel *label4Name2 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 5, 45, width * 15, 20)];
    label4Name2.text = LLSTR(@"101711");
    label4Name2.font = [UIFont systemFontOfSize:12];
    label4Name2.textColor = [UIColor grayColor];
    label4Name2.textAlignment = NSTextAlignmentCenter;
    label4Name2.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name2];
    
    UILabel *label4Plus1 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 20, 15, width * 5, 20)];
    label4Plus1.text = @"+";
    label4Plus1.textColor = [UIColor grayColor];
    label4Plus1.font = [UIFont systemFontOfSize:16];
    label4Plus1.textAlignment = NSTextAlignmentCenter;
    label4Plus1.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Plus1];
    
    //解锁失败
    UILabel *label4Value3 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 25, 15, width * 15, 20)];
    label4Value3.text = [NSString stringWithFormat:format, [[dict4UnlockHistory objectForKey:@"refUnlockToken"]floatValue]];
    label4Value3.font = [UIFont boldSystemFontOfSize:16];
    label4Value3.textAlignment = NSTextAlignmentCenter;
    label4Value3.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value3];
    
    UILabel *label4Name3 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 25, 45, width * 15, 20)];
    label4Name3.text = LLSTR(@"101712");
    label4Name3.font = [UIFont systemFontOfSize:12];
    label4Name3.textColor = [UIColor grayColor];
    label4Name3.textAlignment = NSTextAlignmentCenter;
    label4Name3.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name3];
    
    UILabel *label4Plus2 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 40, 15, width * 5, 20)];
    label4Plus2.text = @"+";
    label4Plus2.textColor = [UIColor grayColor];
    label4Plus2.font = [UIFont systemFontOfSize:16];
    label4Plus2.textAlignment = NSTextAlignmentCenter;
    label4Plus2.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Plus2];
    
    //待解锁
    UILabel *label4Value4 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 45, 15, width * 15, 20)];
    label4Value4.text = [NSString stringWithFormat:format, [[dict4UnlockHistory objectForKey:@"nodeUnlockToken"]floatValue]];
    label4Value4.font = [UIFont boldSystemFontOfSize:16];
    label4Value4.textAlignment = NSTextAlignmentCenter;
    label4Value4.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value4];
    
    UILabel *label4Name4 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 45, 45, width * 15, 20)];
    label4Name4.text = LLSTR(@"101713");
    label4Name4.font = [UIFont systemFontOfSize:12];
    label4Name4.textColor = [UIColor grayColor];
    label4Name4.textAlignment = NSTextAlignmentCenter;
    label4Name4.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name4];
    
    UILabel *label4Plus3 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 60, 15, width * 5, 20)];
    label4Plus3.text = @"+";
    label4Plus3.textColor = [UIColor grayColor];
    label4Plus3.font = [UIFont systemFontOfSize:16];
    label4Plus3.textAlignment = NSTextAlignmentCenter;
    label4Plus3.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Plus3];
    
    //待解锁
    UILabel *label4Value5 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 65, 15, width * 15, 20)];
    label4Value5.text = [NSString stringWithFormat:format, [[dict4UnlockHistory objectForKey:@"teamUnlockToken"]floatValue]];
    label4Value5.font = [UIFont boldSystemFontOfSize:16];
    label4Value5.textAlignment = NSTextAlignmentCenter;
    label4Value5.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value5];
    
    UILabel *label4Name5 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 65, 45, width * 15, 20)];
    label4Name5.text = LLSTR(@"101714");
    label4Name5.font = [UIFont systemFontOfSize:12];
    label4Name5.textColor = [UIColor grayColor];
    label4Name5.textAlignment = NSTextAlignmentCenter;
    label4Name5.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name5];
    
    UILabel *label4Plus4 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 80, 15, width * 5, 20)];
    label4Plus4.text = @"+";
    label4Plus4.textColor = [UIColor grayColor];
    label4Plus4.font = [UIFont systemFontOfSize:16];
    label4Plus4.textAlignment = NSTextAlignmentCenter;
    label4Plus4.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Plus4];
    
    //待解锁
    UILabel *label4Value6 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 85, 15, width * 15, 20)];
    label4Value6.text = [NSString stringWithFormat:format, [[dict4UnlockHistory objectForKey:@"fundUnlockToken"]floatValue]];
    label4Value6.font = [UIFont boldSystemFontOfSize:16];
    label4Value6.textAlignment = NSTextAlignmentCenter;
    label4Value6.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Value6];
    
    UILabel *label4Name6 = [[UILabel alloc]initWithFrame:CGRectMake(10 + width * 85, 45, width * 15, 20)];
    label4Name6.text = LLSTR(@"101719");
    label4Name6.font = [UIFont systemFontOfSize:12];
    label4Name6.textColor = [UIColor grayColor];
    label4Name6.textAlignment = NSTextAlignmentCenter;
    label4Name6.adjustsFontSizeToFitWidth = YES;
    [subPanel addSubview:label4Name6];
}

- (NSInteger)GetCalenderLineForMonth:(NSInteger)yearVar month:(NSInteger)monthVar
{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comp = [NSDateComponents new];
    comp.year = yearVar;
    comp.month = monthVar;
    
    //第一天的时间
    NSDate *mondayDate = [calender dateFromComponents:comp];
    
    //下个月的第一天的时间
    NSDateComponents *compInteval = [NSDateComponents new];
    compInteval.month = 1;
    compInteval.day = -1;
    NSDate *date4NextMonthFirstDay = [calender dateByAddingComponents:compInteval toDate:mondayDate options:0];
    
    NSInteger line = [calender component:NSCalendarUnitWeekOfMonth fromDate:date4NextMonthFirstDay];
    return line;
}


@end
