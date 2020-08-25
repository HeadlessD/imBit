//
//  MyWalletViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/3/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "MyWalletViewController.h"
#import "NetworkModule.h"
#import "UIImageView+WebCache.h"
#import "MyWalletCoinInfoViewController.h"
#import "MyWalletAccountViewController.h"
#import "PaymentPasswordSetupStep1ViewController.h"
#import "CoinSelectViewController.h"
#import "MyWalletSetupViewController.h"
#import "QuotationViewLit.h"
#import "MyForceViewController.h"

@interface MyWalletViewController ()

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if (!self.delegate)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"group_setup"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonSetup:)];
        
        //扩展背景
        UIImageView *view4ExtentBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, -500, self.view.frame.size.width, 500)];
        view4ExtentBk.image = [UIImage imageNamed:@"nav_token"];
        [self.tableView addSubview:view4ExtentBk];
    }
    else
    {
//        self.navigationItem.title = LLSTR(@"103000");
        
        //先用本地数据填充
        myWalletDetail = [NSMutableDictionary dictionaryWithDictionary:[BiChatGlobal sharedManager].dict4WalletInfo];
        [self processMyWalletDetail];
        [self.tableView reloadData];
    }
    self.tableView.tableFooterView = [UIView new];
    
    //初始化
    coinQuotation = [NSMutableDictionary dictionary];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //恢复标题栏
    if (self.delegate == nil)
    {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_token"] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_transparent"];
    }
    else
    {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.titleTextAttributes = nil;
        self.navigationController.navigationBar.tintColor = THEME_COLOR;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = nil;
    }

    [self.tableView reloadData];
    timer4Refresh = [NSTimer scheduledTimerWithTimeInterval:4 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        //获取我的钱包信息
        //if (myWalletDetail == nil) [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getWallet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            //if (myWalletDetail == nil) [BiChatGlobal HideActivityIndicator];
            //NSLog(@"获取零钱包返回：%@", data);
            if (success)
            {
                [BiChatGlobal sharedManager].dict4WalletInfo = data;
                self->myWalletDetail = data;
                self->totalAssetValue = 0;
                [self processMyWalletDetail];

                [self.tableView reloadData];
                if (!self.delegate)
                {
                    //self.tableView.tableFooterView = [self createTableFooter];
                    self.tableView.tableHeaderView = [self createTableHeader];
                }
                else
                    self.tableView.tableFooterView = [UIView new];
            }
        }];
    }];
    [timer4Refresh fire];
}

- (void)processMyWalletDetail
{
    //排序
    [[self->myWalletDetail objectForKey:@"bitcoinDetail"]sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        if ([[obj1 objectForKey:@"sort"]integerValue] > [[obj2 objectForKey:@"sort"]integerValue])
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
        
    }];
    
    //NSLog(@"wallet = %@", myWalletDetail);
    
    //计算资产总量
    for (id key in [self->myWalletDetail objectForKey:@"asset"])
    {
        NSNumber *count = [[self->myWalletDetail objectForKey:@"asset"]objectForKey:key];
        NSNumber *price = [[[self->myWalletDetail objectForKey:@"assetIndex"]objectForKey:key]objectForKey:@"price"];
        
        self->totalAssetValue += count.doubleValue * price.doubleValue;
    }
    
    //整理我持有的币列表
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [[self->myWalletDetail objectForKey:@"bitcoinDetail"]count]; i ++)
    {
        //强制加入置顶项目
        if (i < [[[self->myWalletDetail objectForKey:@"bitcoinConfig"]objectForKey:@"top"]integerValue])
            [array addObject:[[[self->myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:i]objectForKey:@"symbol"]];
        
        else
        {
            //本来就存在于列表中
            for (NSString *str in [self->myWalletDetail objectForKey:@"myCoinList"])
            {
                if ([str isEqualToString:[[[self->myWalletDetail objectForKey:@"bitcoinDetail"]objectAtIndex:i]objectForKey:@"symbol"]])
                    [array addObject:str];
            }
        }
    }
    [self->myWalletDetail setObject:array forKey:@"myCoinList"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[BiChatGlobal sharedManager]saveUserInfo];
    [timer4Refresh invalidate];
    timer4Refresh = nil;
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
    return [[myWalletDetail objectForKey:@"myCoinList"]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取这个币的详细信息
    NSDictionary *CoinInfo = nil;
    for (NSDictionary *item in [myWalletDetail objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:[[myWalletDetail objectForKey:@"myCoinList"]objectAtIndex:indexPath.row]])
        {
            CoinInfo = item;
            break;
        }
    }

    //获取这个币的数量
    NSNumber *count = [[myWalletDetail objectForKey:@"asset"]objectForKey:[CoinInfo objectForKey:@"symbol"]];
    if (count == nil) count = [NSNumber numberWithInteger:0];
    
    //数量为0
    if (fabs(count.doubleValue) < 0.00000000000001 && self.delegate && !self.showZeroCoin)
        return 0;

    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    //获取这个币的详细信息
    NSDictionary *CoinInfo = nil;
    for (NSDictionary *item in [myWalletDetail objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:[[myWalletDetail objectForKey:@"myCoinList"]objectAtIndex:indexPath.row]])
        {
            CoinInfo = item;
            break;
        }
    }
    
    //获取这个币的数量
    NSNumber *count = [[myWalletDetail objectForKey:@"asset"]objectForKey:[CoinInfo objectForKey:@"symbol"]];
    if (count == nil) count = [NSNumber numberWithInteger:0];
    
    //数量为0
    if (fabs(count.doubleValue) < 0.00000000000001 && self.delegate && !self.showZeroCoin)
        return cell;
    
    // Configure the cell...
    UIImageView *image4Logo = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 36, 36)];
    image4Logo.clipsToBounds = YES;
    [image4Logo sd_setImageWithURL:[NSURL URLWithString:[[BiChatGlobal sharedManager].StaticUrl stringByAppendingPathComponent:[CoinInfo objectForKey:@"imgColor"]]] placeholderImage:[UIImage imageNamed:@"defaultavatar"]];
    [cell.contentView addSubview:image4Logo];
    
    //符号
    UILabel *label4Symbol = [[UILabel alloc]initWithFrame:CGRectMake(55, 10, self.view.frame.size.width - 260, 20)];
    label4Symbol.text = [CoinInfo objectForKey:@"dSymbol"];
    label4Symbol.font = [UIFont systemFontOfSize:17];
    [cell.contentView addSubview:label4Symbol];
    
    //名称
    NSString *str4Name = @"-";
    if ([[DFLanguageManager getLanguageName] isEqualToString:@"zh-CN"] && [[CoinInfo objectForKey:@"name"]count]>0)
        str4Name = [[CoinInfo objectForKey:@"name"]firstObject];
    else if ([[CoinInfo objectForKey:@"name"]count] > 1)
        str4Name = [[CoinInfo objectForKey:@"name"]objectAtIndex:1];
    else if ([[CoinInfo objectForKey:@"name"]count] > 0)
        str4Name = [[CoinInfo objectForKey:@"name"]firstObject];
    UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(55, 30, self.view.frame.size.width - 260, 20)];
    label4CoinName.text = str4Name;
    label4CoinName.font = [UIFont systemFontOfSize:13];
    label4CoinName.textColor = [UIColor grayColor];
    [cell.contentView addSubview:label4CoinName];
    
    if (!self.delegate)
    {
        //走势图
        QuotationViewLit *quotationView = [[QuotationViewLit alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 190, 10, 85, 40)];
        quotationView.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:quotationView];
        
        //查找数据
        if ([coinQuotation objectForKey:[CoinInfo objectForKey:@"symbol"]] == nil)
        {
            [NetworkModule getCoinHistory:[NSString stringWithFormat:@"%@:6", [CoinInfo objectForKey:@"code"]] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (success)
                {
                    //NSLog(@"%@ - count=%zd", [NSString stringWithFormat:@"%@:6", [CoinInfo objectForKey:@"code"]], [data count]);
                    [self->coinQuotation setObject:data forKey:[CoinInfo objectForKey:@"symbol"]];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                else
                    NSLog(@"数据出错(%@)", [NSString stringWithFormat:@"%@:6", [CoinInfo objectForKey:@"code"]]);
            }];
        }
        else
            quotationView.quotationData = [coinQuotation objectForKey:[CoinInfo objectForKey:@"symbol"]];
    }
    
    //balance
    UILabel *label4CoinBanlance = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 10, 90, 20)];
    if (count.doubleValue < 0.00000000000000001)
        label4CoinBanlance.text = @"0";
    else
        label4CoinBanlance.text = [[NSString stringWithFormat:@"%.12lf", count.doubleValue]accuracyCheckWithFormatterString:[CoinInfo objectForKey:@"bit"] auotCheck:NO];
    label4CoinBanlance.font = [UIFont systemFontOfSize:16];
    label4CoinBanlance.textColor = [UIColor blackColor];
    label4CoinBanlance.textAlignment = NSTextAlignmentRight;
    label4CoinBanlance.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label4CoinBanlance];
    
    //change
    UILabel *label4CoinChange = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 30, 90, 20)];
    if (fabs([count doubleValue] * [[[[myWalletDetail objectForKey:@"assetIndex"]objectForKey:[CoinInfo objectForKey:@"symbol"]]objectForKey:@"price"]doubleValue])<0.00000001)
        label4CoinChange.text = @"--";
    else
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.minimumFractionDigits = 4;
        formatter.maximumFractionDigits = 4;
        NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[count doubleValue] * [[[[myWalletDetail objectForKey:@"assetIndex"]objectForKey:[CoinInfo objectForKey:@"symbol"]]objectForKey:@"price"]doubleValue]]];
        label4CoinChange.text = [NSString stringWithFormat:@"≈$%@", str];
    }
    label4CoinChange.font = [UIFont systemFontOfSize:14];
    label4CoinChange.textColor = [UIColor grayColor];
    label4CoinChange.textAlignment = NSTextAlignmentRight;
    label4CoinChange.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label4CoinChange];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //获取这个币的详细信息
    NSDictionary *CoinInfo = nil;
    for (NSDictionary *item in [myWalletDetail objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:[[myWalletDetail objectForKey:@"myCoinList"]objectAtIndex:indexPath.row]])
        {
            CoinInfo = item;
            break;
        }
    }
    
    //获取这个币的数量
    NSNumber *count = [[myWalletDetail objectForKey:@"asset"]objectForKey:[CoinInfo objectForKey:@"symbol"]];
    if (count == nil) count = [NSNumber numberWithInteger:0];
    
    if (self.delegate)
    {        
        //是否有余额
        if (fabs([count doubleValue])<0.000000001 && !self.showZeroCoin)
        {
            [BiChatGlobal showInfo:LLSTR(@"301114") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            return;
        }

        //通知
        if ([self.delegate respondsToSelector:@selector(coinSelected:coinDisplayName:coinIcon:coinIconWhite:coinIconGold:balance:bit:)])
            [self.delegate coinSelected:[CoinInfo objectForKey:@"symbol"]
                        coinDisplayName:[CoinInfo objectForKey:@"dSymbol"]
                               coinIcon:[CoinInfo objectForKey:@"imgColor"]
                          coinIconWhite:[CoinInfo objectForKey:@"imgWhite"]
                           coinIconGold:[CoinInfo objectForKey:@"imgGold"]
                                balance:count.doubleValue
                                    bit:[[CoinInfo objectForKey:@"bit"]integerValue]];
    }
    else
    {
        if ([[CoinInfo objectForKey:@"symbol"]isEqualToString:@"POINT"])
        {
            MyForceViewController *wnd = [MyForceViewController new];
            wnd.pushNAVC = self.navigationController;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else
        {
            //进入详情页
            MyWalletCoinInfoViewController *wnd = [MyWalletCoinInfoViewController new];
            wnd.coinInfo = CoinInfo;
            wnd.coinName = [CoinInfo objectForKey:@"dSymbol"];
            wnd.symbol = [CoinInfo objectForKey:@"symbol"];
            wnd.coinCode = [CoinInfo objectForKey:@"code"];
            wnd.coinCount = count.doubleValue;
            wnd.price = [[[[myWalletDetail objectForKey:@"assetIndex"]objectForKey:[CoinInfo objectForKey:@"symbol"]]objectForKey:@"price"]doubleValue];
            wnd.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:wnd animated:YES];
        }
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //是不是特殊的条目
    NSString *symbol = [[myWalletDetail objectForKey:@"myCoinList"] objectAtIndex:indexPath.row];
    
    //删除按钮
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:LLSTR(@"101018") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //事件处理
        [[self->myWalletDetail objectForKey:@"myCoinList"]removeObjectAtIndex:indexPath.row];
        
        //通知服务器
        [NetworkModule setMyWalletAsset:[self->myWalletDetail objectForKey:@"myCoinList"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }];
    
    if (indexPath.row < [[[myWalletDetail objectForKey:@"bitcoinConfig"]objectForKey:@"top"]integerValue] ||
        [[[myWalletDetail objectForKey:@"asset"]objectForKey:symbol]doubleValue] > 0.0000000001)
        return @[];
    else
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

- (UIView *)createTableFooter
{
    UIView *view4Footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 110)];
    
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    [view4Footer addSubview:view4Seperator];
    
    UIButton *button4Add = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 50)];
    button4Add.titleLabel.font = [UIFont systemFontOfSize:32];
    button4Add.backgroundColor = THEME_COLOR;
    button4Add.layer.cornerRadius = 5;
    button4Add.clipsToBounds = YES;
    button4Add.tag = 999;
    [button4Add setTitle:@"+" forState:UIControlStateNormal];
    [button4Add addTarget:self action:@selector(onButtonAdd:) forControlEvents:UIControlEventTouchUpInside];
    [view4Footer addSubview:button4Add];
    
    return view4Footer;
}

- (UIView *)createTableHeader
{
    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180)];
    view4Header.backgroundColor = [UIColor whiteColor];
    
    UIImageView *image4Bk = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
    image4Bk.image = [UIImage imageNamed:@"myTokenBk"];
    [view4Header addSubview:image4Bk];
    
    //总资产
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    formatter.usesGroupingSeparator = YES;
    UILabel *label4MyWealth = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, self.view.frame.size.width, 40)];
    label4MyWealth.text = [NSString stringWithFormat:@"$%@", [formatter stringFromNumber:[NSNumber numberWithDouble:totalAssetValue]]];
    label4MyWealth.font = [UIFont systemFontOfSize:40];
    label4MyWealth.textAlignment = NSTextAlignmentCenter;
    label4MyWealth.textColor = [UIColor whiteColor];
    [view4Header addSubview:label4MyWealth];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4MyWealth.text];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 1)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(str.length - 3, 3)];
    label4MyWealth.attributedText = str;
    
    //说明
    UILabel *label4MyWealthDescription = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 20)];
    label4MyWealthDescription.text = LLSTR(@"103001");
    label4MyWealthDescription.font = [UIFont systemFontOfSize:12];
    label4MyWealthDescription.textColor = [UIColor colorWithWhite:.9 alpha:1];
    label4MyWealthDescription.textAlignment = NSTextAlignmentCenter;
    label4MyWealthDescription.numberOfLines = 0;
    [view4Header addSubview:label4MyWealthDescription];
    
    UIButton *button4Add = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 65, 115, 50, 50)];
    [button4Add setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [button4Add addTarget:self action:@selector(onButtonAdd:) forControlEvents:UIControlEventTouchUpInside];
    [view4Header addSubview:button4Add];
    
    return view4Header;
}

- (void)onButtonSetup:(id)sender
{
    MyWalletSetupViewController *wnd = [[MyWalletSetupViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonAdd:(id)sender
{
    CoinSelectViewController *wnd = [CoinSelectViewController new];
    wnd.myWalletDetail = myWalletDetail;
    [self.navigationController pushViewController:wnd animated:YES];
}

@end
