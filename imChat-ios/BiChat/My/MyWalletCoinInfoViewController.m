//
//  MyWalletCoinInfoViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "MyWalletCoinInfoViewController.h"
#import "MyWalletAccountViewController.h"
#import "NetworkModule.h"
#import "WPDiscoverTableViewCellType4.h"
#import "WPNewsShareViewController.h"
#import "WPCoinDetailViewController.h"
#import "WithdrawCoinViewController.h"
#import "WPCoinDetailModel.h"
#import "WPNewsDetailViewController.h"
#import "DFLanguageManager.h"

@interface MyWalletCoinInfoViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *listArray;
@property (nonatomic,assign)NSInteger currentPage;
@property (nonatomic,strong)WPCoinDetailModel *model;
//用于标记两个请求
@property (nonatomic,assign)NSInteger requestNum;

@end

@implementation MyWalletCoinInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    self.navigationItem.titleView = [self createCoinNameTitle];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:Image(@"more") style:UIBarButtonItemStyleDone target:self action:@selector(functionSelect)];
    
    self.navigationController.navigationBar.translucent = NO;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 140;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_footer = [MJRefreshBackGifFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
    [self refresh];
    [self.view addSubview:self.tableView];
    
    //调整数据
    if ([[self.coinInfo objectForKey:@"multiplier"]integerValue] == 0)
        [self.coinInfo setObject:[NSNumber numberWithInteger:1] forKey:@"multiplier"];
    if ([[self.coinInfo objectForKey:@"symbol"]isEqualToString:@"TOKEN"])
        internalQuotationDataOK = NO;
    else
        internalQuotationDataOK = YES;
    showCurrentQuotation = YES;
    currentSelect = 1;
    [self createGUI];
    view4CoinQuotation.showTime = YES;
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
    
    //获取最新的行情
    [self fleshQuotation];
    
    //建立一个时钟刷新当前价格
    timer4FreshCurrentQuotation = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {

        NSString *str = [NSString stringWithFormat:@"%@:7", self.coinCode];
        [NetworkModule getCoinHistory:str completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success && [data count] >= 1)
            {
                self->currentQuotation = [[data firstObject]objectForKey:@"end"];
                if (self->showCurrentQuotation)
                {
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
                    formatter.numberStyle = NSNumberFormatterDecimalStyle;
                    formatter.minimumFractionDigits = 4;
                    formatter.maximumFractionDigits = 4;

                    self->label4CoinValue.text = [NSString stringWithFormat:@"$%@", [formatter stringFromNumber:[NSNumber numberWithDouble:self->currentQuotation.doubleValue * self.coinCount]]];

                    self->label4CurrentQuotation.text = [NSString stringWithFormat:@"$%.2f", self->currentQuotation.doubleValue * [[_coinInfo objectForKey:@"multiplier"]integerValue]];
                    [self adjustCurrentQuotaitonDisplay];
                    
                    //计算涨跌幅
                    if (self->beginQuotation != nil)
                    {
                        double chg = (self->currentQuotation.doubleValue - self->beginQuotation.doubleValue) / self->beginQuotation.doubleValue * 100;
                        if (chg > 0)
                        {
                            self->label4CurrentChg.text = [NSString stringWithFormat:@"+%.2f [%.2f%%]", (self->currentQuotation.doubleValue - self->beginQuotation.doubleValue) * [[self.coinInfo objectForKey:@"multiplier"]integerValue], chg];
                            self->label4CurrentQuotation.textColor = THEME_GREEN;
                            self->label4CurrentChg.textColor = THEME_GREEN;
                        }
                        else
                        {
                            self->label4CurrentChg.text = [NSString stringWithFormat:@"-%.2f [-%.2f%%]", (self->beginQuotation.doubleValue - self->currentQuotation.doubleValue) * [[self.coinInfo objectForKey:@"multiplier"]integerValue], -chg];
                            self->label4CurrentQuotation.textColor = THEME_RED;
                            self->label4CurrentChg.textColor = THEME_RED;
                        }
                    }
                }
            }
        }];

    }];
    [timer4FreshCurrentQuotation fire];
}

//两个请求结束后调用方法
- (void)requestFinish {
    self.requestNum ++;
    if (self.requestNum < 2) {
        return;
    }
    if (!internalQuotationDataOK && self.listArray.count == 0) {
        [self getCoinInfo];
    }
}

- (void)getCoinInfo {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getCoinBaseInfo.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"coinType":self.symbol} success:^(id response) {
        self.model = [WPCoinDetailModel mj_objectWithKeyValues:response];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 5;
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        [attributes setObject:Font(14) forKey:NSFontAttributeName];
        [attributes setObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
        
        CGRect rect  = [self.model.desc boundingRectWithSize:CGSizeMake(ScreenWidth - 40, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14),NSParagraphStyleAttributeName : paragraphStyle} context:nil];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 100, ScreenWidth, rect.size.height + 120)];
        self.tableView.tableFooterView = view;
        
        UILabel *officLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 50, 40)];
        [view addSubview:officLabel];
        officLabel.font = Font(14);
        officLabel.textColor = THEME_GRAY;
        officLabel.text = @"官    网";
        
        UILabel *officContentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(officLabel.frame) + 10, 20, ScreenWidth - 30 - 50 - 10, 40)];
        [view addSubview:officContentLabel];
        officContentLabel.text = self.model.sites[0];
        officContentLabel.font = Font(14);
        officContentLabel.userInteractionEnabled = YES;
        officContentLabel.textColor = LightBlue;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOffic)];
        [officContentLabel addGestureRecognizer:tapGes];
        
        
        UILabel *whiteLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 60, 50, 40)];
        [view addSubview:whiteLabel];
        whiteLabel.font = Font(14);
        whiteLabel.textColor = THEME_GRAY;
        whiteLabel.text = @"白皮书";
        
        UILabel *whiteContentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(officLabel.frame) + 10, 60, ScreenWidth - 30 - 50 - 10, 40)];
        [view addSubview:whiteContentLabel];
        whiteContentLabel.text = self.model.whitePaper;
        whiteContentLabel.textColor = LightBlue;
        whiteContentLabel.font = Font(14);
        whiteContentLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showWihte)];
        [whiteContentLabel addGestureRecognizer:tapGes1];
        
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 120, ScreenWidth - 40, rect.size.height)];
        label.numberOfLines = 0;
        label.font = Font(14);
        label.textColor = [UIColor grayColor];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:self.model.desc.length > 0 ? self.model.desc : @"" attributes:attributes];
        label.attributedText = attStr;
        [view addSubview:label];
    } failure:^(NSError *error) {
    }];
}
//显示官网
- (void)showOffic {
    if (self.model.sites.count == 0) {
        return;
    }
    NSString *str = self.model.sites[0];
    if (str.length == 0) {
        return;
    }
    WPNewsDetailViewController *detailVC = [[WPNewsDetailViewController alloc]init];
    detailVC.url = self.model.sites[0];
    if (![self.model.sites[0] containsString:@"http://"] && ![self.model.sites[0] containsString:@"https://"]) {
        detailVC.url = [NSString stringWithFormat:@"http://%@",self.model.sites[0]];
    }
    [self.navigationController pushViewController:detailVC animated:YES];
}
//显示白皮书
- (void)showWihte {
    if (self.model.whitePaper.length == 0) {
        return;
    }
    WPNewsDetailViewController *detailVC = [[WPNewsDetailViewController alloc]init];
    detailVC.url = self.model.whitePaper;
    if (![self.model.whitePaper containsString:@"http://"] && ![self.model.whitePaper containsString:@"https://"]) {
        detailVC.url = [NSString stringWithFormat:@"http://%@",self.model.whitePaper];
    }
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer4FreshCurrentQuotation invalidate];
    timer4FreshCurrentQuotation = nil;
}

- (void)functionSelect {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"103107") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self onButtonRechargeCoin:nil];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"103108") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self onButtonWithdrawCoin:nil];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:LLSTR(@"103109") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self onButtonAccount];
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:LLSTR(@"103110") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WPCoinDetailViewController *detailVC = [[WPCoinDetailViewController alloc] init];
        detailVC.symbol = self.symbol;
        detailVC.dSymbol = self.coinName;
        [self.navigationController pushViewController:detailVC animated:YES];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [action1 setValue:THEME_COLOR forKey:@"_titleTextColor"];
    [action2 setValue:THEME_COLOR forKey:@"_titleTextColor"];
    [action3 setValue:THEME_COLOR forKey:@"_titleTextColor"];
    [action4 setValue:THEME_COLOR forKey:@"_titleTextColor"];
    [alertC addAction:action1];
    [alertC addAction:action2];
    [alertC addAction:action3];
    [alertC addAction:action4];
    [alertC addAction:actionCancel];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - QuotationOperationDelegate

- (void)enterShowQuotationSelectionMode:(NSNumber *)quotation atTime:(NSDate *)time
{
    self.tableView.scrollEnabled = NO;
    showCurrentQuotation = NO;
    selectedQuotation = quotation;
    label4CurrentQuotation.text = [NSString stringWithFormat:@"$%.2f", self->selectedQuotation.doubleValue * [[_coinInfo objectForKey:@"multiplier"]integerValue]];
    [self adjustCurrentQuotaitonDisplay];
    
    //计算涨跌幅
    if (self->beginQuotation != nil)
    {
        double chg = (self->selectedQuotation.doubleValue - self->beginQuotation.doubleValue) / self->beginQuotation.doubleValue * 100;
        if (chg > 0)
        {
            self->label4CurrentChg.text = [NSString stringWithFormat:@"+%.2f [%.2f%%]", (self->selectedQuotation.doubleValue - self->beginQuotation.doubleValue) * [[self.coinInfo objectForKey:@"multiplier"]integerValue], chg];
            self->label4CurrentChg.textColor = THEME_GREEN;
        }
        else
        {
            self->label4CurrentChg.text = [NSString stringWithFormat:@"-%.2f [-%.2f%%]", (self->beginQuotation.doubleValue - self->selectedQuotation.doubleValue) * [[self.coinInfo objectForKey:@"multiplier"]integerValue], -chg];
            self->label4CurrentChg.textColor = THEME_RED;
        }
    }
}

- (void)exitShowQuotationSelectionMode
{
    self.tableView.scrollEnabled = YES;
    showCurrentQuotation = YES;
    label4CurrentQuotation.text = [NSString stringWithFormat:@"$%.2f", self->currentQuotation.doubleValue * [[_coinInfo objectForKey:@"multiplier"]integerValue]];
    [self adjustCurrentQuotaitonDisplay];
    
    //计算涨跌幅
    if (self->beginQuotation != nil)
    {
        //NSLog(@"%f, %f, %f", self->currentQuotation.doubleValue, self->beginQuotation.doubleValue, (self->currentQuotation.doubleValue - self->beginQuotation.doubleValue) / self->beginQuotation.doubleValue);
        double chg = (self->currentQuotation.doubleValue - self->beginQuotation.doubleValue) / self->beginQuotation.doubleValue * 100;
        if (chg > 0)
        {
            self->label4CurrentChg.text = [NSString stringWithFormat:@"+%.2f [%.2f%%]", (self->currentQuotation.doubleValue - self->beginQuotation.doubleValue) * [[self.coinInfo objectForKey:@"multiplier"]integerValue], chg];
            self->label4CurrentChg.textColor = THEME_GREEN;
        }
        else
        {
            self->label4CurrentChg.text = [NSString stringWithFormat:@"-%.2f [-%.2f%%]", (self->beginQuotation.doubleValue - self->currentQuotation.doubleValue) * [[self.coinInfo objectForKey:@"multiplier"]integerValue], -chg];
            self->label4CurrentChg.textColor = THEME_RED;
        }
    }
}

- (void)quotationSelected:(NSNumber *)quotaion atTime:(NSDate *)time
{
    if (showCurrentQuotation)
        return;
    
    selectedQuotation = quotaion;
    label4CurrentQuotation.text = [NSString stringWithFormat:@"$%.2f", self->selectedQuotation.doubleValue * [[_coinInfo objectForKey:@"multiplier"]integerValue]];
    [self adjustCurrentQuotaitonDisplay];
    
    //计算涨跌幅
    if (self->beginQuotation != nil)
    {
        double chg = (self->selectedQuotation.doubleValue - self->beginQuotation.doubleValue) / self->beginQuotation.doubleValue * 100;
        if (chg > 0)
        {
            self->label4CurrentChg.text = [NSString stringWithFormat:@"+%.2f [%.2f%%]", (self->selectedQuotation.doubleValue - self->beginQuotation.doubleValue) * [[self.coinInfo objectForKey:@"multiplier"]integerValue], chg];
            self->label4CurrentChg.textColor = THEME_GREEN;
        }
        else
        {
            self->label4CurrentChg.text = [NSString stringWithFormat:@"-%.2f [-%.2f%%]", (self->beginQuotation.doubleValue - self->selectedQuotation.doubleValue) * [[self.coinInfo objectForKey:@"multiplier"]integerValue], -chg];
            self->label4CurrentChg.textColor = THEME_RED;
        }
    }
}

#pragma mark - 私有函数

- (UIView *)createCoinNameTitle
{
    UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, 40)];
    
    //群名
    UILabel *label4GroupName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, 20)];
    label4GroupName.text = self.coinName;
    label4GroupName.font = [UIFont systemFontOfSize:16];
    label4GroupName.textAlignment = NSTextAlignmentCenter;
    [view4Title addSubview:label4GroupName];
    
    NSString *str4Name = @"-";
    if ([[DFLanguageManager getLanguageName] isEqualToString:@"zh-CN"] && [[_coinInfo objectForKey:@"name"]count]>0)
        str4Name = [[_coinInfo objectForKey:@"name"]firstObject];
    else if ([[_coinInfo objectForKey:@"name"]count] > 1)
        str4Name = [[_coinInfo objectForKey:@"name"]objectAtIndex:1];
    else if ([[_coinInfo objectForKey:@"name"]count] > 0)
        str4Name = [[_coinInfo objectForKey:@"name"]firstObject];
    
    //人数
    UILabel *label4SubGroupName = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width - 100, 20)];
    label4SubGroupName.text = str4Name;
    label4SubGroupName.font = [UIFont systemFontOfSize:13];
    label4SubGroupName.textAlignment = NSTextAlignmentCenter;
    label4SubGroupName.textColor = [UIColor grayColor];
    [view4Title addSubview:label4SubGroupName];
    
    return view4Title;
}

- (void)createGUI
{
    if (internalQuotationDataOK)
    {
        UIView *view4Bk = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 500)];
        view4Bk.backgroundColor = [UIColor whiteColor];
        self.tableView.tableHeaderView = view4Bk;
        
        label4CurrentQuotation = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 50)];
        label4CurrentQuotation.font = [UIFont systemFontOfSize:40];
        label4CurrentQuotation.textColor = THEME_GREEN;
        label4CurrentQuotation.textAlignment = NSTextAlignmentCenter;
        [view4Bk addSubview:label4CurrentQuotation];
        
        label4CurrentChg = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 20)];
        label4CurrentChg.font = [UIFont systemFontOfSize:16];
        label4CurrentChg.textColor = THEME_GREEN;
        label4CurrentChg.textAlignment = NSTextAlignmentCenter;
        [view4Bk addSubview:label4CurrentChg];
        
        view4CoinQuotation = [[QuotationView alloc]initWithFrame:CGRectMake(0, 90, self.view.frame.size.width, 200)];
        view4CoinQuotation.userInteractionEnabled = YES;
        view4CoinQuotation.backgroundColor = [UIColor whiteColor];
        view4CoinQuotation.delegate = self;
        [view4Bk addSubview:view4CoinQuotation];
        
        //项目选择按钮
        CGFloat interval = (self.view.frame.size.width - 30 - 55 * 5) / 4;
        button4OneDay = [[UIButton alloc]initWithFrame:CGRectMake(15, 310, 55, 25)];
        button4OneDay.titleLabel.font = [UIFont systemFontOfSize:12];
        button4OneDay.clipsToBounds = YES;
        button4OneDay.layer.cornerRadius = 3;
        [button4OneDay setTitle:LLSTR(@"103101") forState:UIControlStateNormal];
        [button4OneDay addTarget:self action:@selector(onButton4OneDay:) forControlEvents:UIControlEventTouchUpInside];
        [view4Bk addSubview:button4OneDay];
        
        button4OneWeek = [[UIButton alloc]initWithFrame:CGRectMake(70 + interval, 310, 55, 25)];
        button4OneWeek.titleLabel.font = [UIFont systemFontOfSize:12];
        button4OneWeek.clipsToBounds = YES;
        button4OneWeek.layer.cornerRadius = 3;
        [button4OneWeek setTitle:LLSTR(@"103102") forState:UIControlStateNormal];
        [button4OneWeek addTarget:self action:@selector(onButton4OneWeek:) forControlEvents:UIControlEventTouchUpInside];
        [view4Bk addSubview:button4OneWeek];
        
        button4OneMonth = [[UIButton alloc]initWithFrame:CGRectMake(125 + interval * 2, 310, 55, 25)];
        button4OneMonth.titleLabel.font = [UIFont systemFontOfSize:12];
        button4OneMonth.clipsToBounds = YES;
        button4OneMonth.layer.cornerRadius = 3;
        [button4OneMonth setTitle:LLSTR(@"103103") forState:UIControlStateNormal];
        [button4OneMonth addTarget:self action:@selector(onButton4OneMonth:) forControlEvents:UIControlEventTouchUpInside];
        [view4Bk addSubview:button4OneMonth];
        
        button4SixMonth = [[UIButton alloc]initWithFrame:CGRectMake(180 + interval * 3, 310, 55, 25)];
        button4SixMonth.titleLabel.font = [UIFont systemFontOfSize:12];
        button4SixMonth.clipsToBounds = YES;
        button4SixMonth.layer.cornerRadius = 3;
        [button4SixMonth setTitle:LLSTR(@"103104") forState:UIControlStateNormal];
        [button4SixMonth addTarget:self action:@selector(onButton4SixMonth:) forControlEvents:UIControlEventTouchUpInside];
        [view4Bk addSubview:button4SixMonth];
        
        button4All = [[UIButton alloc]initWithFrame:CGRectMake(235 + interval * 4, 310, 55, 25)];
        button4All.titleLabel.font = [UIFont systemFontOfSize:12];
        button4All.clipsToBounds = YES;
        button4All.layer.cornerRadius = 3;
        [button4All setTitle:LLSTR(@"103105") forState:UIControlStateNormal];
        [button4All addTarget:self action:@selector(onButton4All:) forControlEvents:UIControlEventTouchUpInside];
        [view4Bk addSubview:button4All];
        
        //来源
        UILabel *label4Source = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, self.view.frame.size.width - 30, 30)];
        label4Source.text = [LLSTR(@"103106") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[self.coinInfo objectForKey:@"Source"]==nil?@"":[self.coinInfo objectForKey:@"Source"]]]];
        label4Source.textColor = [UIColor grayColor];
        label4Source.font = [UIFont systemFontOfSize:10];
        label4Source.numberOfLines = 0;
        [view4Bk addSubview:label4Source];
        
        [self fleshSelect];
        
        //获取有效精度
        NSDictionary *CoinInfo;
        for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
        {
            if ([[item objectForKey:@"symbol"]isEqualToString:self.symbol])
            {
                CoinInfo = item;
                break;
            }
        }

        //数量
        NSNumber *count = [NSNumber numberWithDouble:[[BiChatGlobal decimalNumberWithDouble:self.coinCount]doubleValue]];
        UILabel *label4CoinCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 370, self.view.frame.size.width, 30)];
        if (count.doubleValue < 0.0000000000001)
            label4CoinCount.text = @"0";
        else
            label4CoinCount.text = [[NSString stringWithFormat:@"%.12lf", count.doubleValue]accuracyCheckWithFormatterString:[CoinInfo objectForKey:@"bit"] auotCheck:NO];
        label4CoinCount.textAlignment = NSTextAlignmentCenter;
        label4CoinCount.font = [UIFont systemFontOfSize:30];
        [view4Bk addSubview:label4CoinCount];
        
        //等值
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.minimumFractionDigits = 4;
        formatter.maximumFractionDigits = 4;

        label4CoinValue = [[UILabel alloc]initWithFrame:CGRectMake(0, 400, self.view.frame.size.width, 20)];
        label4CoinValue.text = [NSString stringWithFormat:@"$%@", [formatter stringFromNumber:[NSNumber numberWithDouble:self.price * self.coinCount]]];
        label4CoinValue.textColor = [UIColor grayColor];
        label4CoinValue.font = [UIFont systemFontOfSize:14];
        label4CoinValue.textAlignment = NSTextAlignmentCenter;
        [view4Bk addSubview:label4CoinValue];
        
        //充值按钮
        UIButton *button4Recharge = [[UIButton alloc]initWithFrame:CGRectMake(20, 440, self.view.frame.size.width / 2 - 30, 40)];
        button4Recharge.titleLabel.font = [UIFont systemFontOfSize:16];
        button4Recharge.backgroundColor = [UIColor whiteColor];
        button4Recharge.layer.borderColor = THEME_COLOR.CGColor;
        button4Recharge.layer.borderWidth = 0.5;
        button4Recharge.layer.cornerRadius = 5;
        [button4Recharge setTitle:LLSTR(@"103107") forState:UIControlStateNormal];
        [button4Recharge setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4Recharge addTarget:self action:@selector(onButtonRechargeCoin:) forControlEvents:UIControlEventTouchUpInside];
        [view4Bk addSubview:button4Recharge];

        //提币按钮
        UIButton *button4Withdraw = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 10, 440, self.view.frame.size.width / 2 - 30, 40)];
        button4Withdraw.titleLabel.font = [UIFont systemFontOfSize:16];
        button4Withdraw.backgroundColor = [UIColor whiteColor];
        button4Withdraw.layer.borderColor = THEME_COLOR.CGColor;
        button4Withdraw.layer.borderWidth = 0.5;
        button4Withdraw.layer.cornerRadius = 5;
        [button4Withdraw setTitle:LLSTR(@"103108") forState:UIControlStateNormal];
        [button4Withdraw setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4Withdraw addTarget:self action:@selector(onButtonWithdrawCoin:) forControlEvents:UIControlEventTouchUpInside];
        [view4Bk addSubview:button4Withdraw];
    }
    else
    {
        UIView *view4Bk = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180)];
        view4Bk.backgroundColor = [UIColor whiteColor];
        self.tableView.tableHeaderView = view4Bk;
        
        //获取有效精度
        NSDictionary *CoinInfo;
        for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
        {
            if ([[item objectForKey:@"symbol"]isEqualToString:self.symbol])
            {
                CoinInfo = item;
                break;
            }
        }
        
        //数量
        double count = [[BiChatGlobal decimalNumberWithDouble:self.coinCount]doubleValue];
        UILabel *label4CoinCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 30)];
        if (count < 0.0000000000001)
            label4CoinCount.text = @"0";
        else
            label4CoinCount.text = [[NSString stringWithFormat:@"%.12lf", count]accuracyCheckWithFormatterString:[CoinInfo objectForKey:@"bit"] auotCheck:NO];
        label4CoinCount.textAlignment = NSTextAlignmentCenter;
        label4CoinCount.font = [UIFont systemFontOfSize:30];
        [view4Bk addSubview:label4CoinCount];
        
        //等值
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.minimumFractionDigits = 4;
        formatter.maximumFractionDigits = 4;
        
        label4CoinValue = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 20)];
        label4CoinValue.text = LLSTR(@"103123");
        label4CoinValue.textColor = [UIColor grayColor];
        label4CoinValue.font = [UIFont systemFontOfSize:14];
        label4CoinValue.textAlignment = NSTextAlignmentCenter;
        [view4Bk addSubview:label4CoinValue];
        
        //充值按钮
        UIButton *button4Recharge = [[UIButton alloc]initWithFrame:CGRectMake(20, 120, self.view.frame.size.width / 2 - 30, 40)];
        button4Recharge.titleLabel.font = [UIFont systemFontOfSize:16];
        button4Recharge.backgroundColor = [UIColor whiteColor];
        button4Recharge.layer.borderColor = THEME_COLOR.CGColor;
        button4Recharge.layer.borderWidth = 0.5;
        button4Recharge.layer.cornerRadius = 5;
        [button4Recharge setTitle:LLSTR(@"103107") forState:UIControlStateNormal];
        [button4Recharge setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4Recharge addTarget:self action:@selector(onButtonRechargeCoin:) forControlEvents:UIControlEventTouchUpInside];
        [view4Bk addSubview:button4Recharge];
        
        //提币按钮
        UIButton *button4Withdraw = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 10, 120, self.view.frame.size.width / 2 - 30, 40)];
        button4Withdraw.titleLabel.font = [UIFont systemFontOfSize:16];
        button4Withdraw.backgroundColor = [UIColor whiteColor];
        button4Withdraw.layer.borderColor = THEME_COLOR.CGColor;
        button4Withdraw.layer.borderWidth = 0.5;
        button4Withdraw.layer.cornerRadius = 5;
        [button4Withdraw setTitle:LLSTR(@"103108") forState:UIControlStateNormal];
        [button4Withdraw setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4Withdraw addTarget:self action:@selector(onButtonWithdrawCoin:) forControlEvents:UIControlEventTouchUpInside];
        [view4Bk addSubview:button4Withdraw];
    }
}

- (void)onButtonAccount
{
    //NSLog(@"%@", self.coinInfo);
    MyWalletAccountViewController *wnd = [MyWalletAccountViewController new];
    wnd.coinSymbol = self.symbol;
    wnd.coinDSymbol = [self.coinInfo objectForKey:@"dSymbol"];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)fleshQuotation
{
    NSString *str = [NSString stringWithFormat:@"%@:%ld", self.coinCode, (long)currentSelect];
    if (internalQuotationData == nil)[BiChatGlobal ShowActivityIndicator];
    [NetworkModule getCoinHistory:str completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        if (internalQuotationData == nil) [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            internalQuotationDataOK = YES;
            [self createGUI];
            internalQuotationData = data;
            self->view4CoinQuotation.quotationData = data;
            if (self->currentSelect == 1 ||
                self->currentSelect == 2)
                self->view4CoinQuotation.showTime = YES;
            else
                self->view4CoinQuotation.showTime = NO;
            if ([data count] > 0)
                self->beginQuotation = [[data objectAtIndex:0]objectForKey:@"end"];
        }
        else
        {
            internalQuotationDataOK = NO;
            [self createGUI];
        }
        [self requestFinish];
    }];
}

- (void)onButton4OneDay:(id)sender
{
    currentSelect = 1;
    internalQuotationData = nil;
    [self fleshQuotation];
    [self fleshSelect];
}

- (void)onButton4OneWeek:(id)sender
{
    currentSelect = 2;
    internalQuotationData = nil;
    [self fleshQuotation];
    [self fleshSelect];
}

- (void)onButton4OneMonth:(id)sender
{
    currentSelect = 3;
    internalQuotationData = nil;
    [self fleshQuotation];
    [self fleshSelect];
}

- (void)onButton4SixMonth:(id)sender
{
    currentSelect = 4;
    internalQuotationData = nil;
    [self fleshQuotation];
    [self fleshSelect];
}

- (void)onButton4All:(id)sender
{
    currentSelect = 5;
    internalQuotationData = nil;
    [self fleshQuotation];
    [self fleshSelect];
}
     
- (void)fleshSelect
{
    [button4OneDay setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4OneDay setBackgroundColor:[UIColor clearColor]];
    [button4OneWeek setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4OneWeek setBackgroundColor:[UIColor clearColor]];
    [button4OneMonth setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4OneMonth setBackgroundColor:[UIColor clearColor]];
    [button4SixMonth setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4SixMonth setBackgroundColor:[UIColor clearColor]];
    [button4All setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4All setBackgroundColor:[UIColor clearColor]];
    
    switch (currentSelect) {
        case 1:
            [button4OneDay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button4OneDay setBackgroundColor:THEME_COLOR];
            break;
            
        case 2:
            [button4OneWeek setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button4OneWeek setBackgroundColor:THEME_COLOR];
            break;
            
        case 3:
            [button4OneMonth setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button4OneMonth setBackgroundColor:THEME_COLOR];
            break;
            
        case 4:
            [button4SixMonth setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button4SixMonth setBackgroundColor:THEME_COLOR];
            break;
            
        case 5:
            [button4All setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button4All setBackgroundColor:THEME_COLOR];
            break;
            
        default:
            break;
    }
}

//调整当前价格的显示
- (void)adjustCurrentQuotaitonDisplay
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4CurrentQuotation.text];
    
    if (str.length <= 2) return;
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 1)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(str.length - 3, 3)];
    
    label4CurrentQuotation.attributedText = str;
    
    //是否有货币乘数
    if ([[self.coinInfo objectForKey:@"multiplier"]integerValue] > 1)
    {
        NSString *string = [NSString stringWithFormat:@" / %@%@", [self.coinInfo objectForKey:@"multiplier"], self.coinName];
        NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc]initWithString:string];
        [str2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, string.length)];
        [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, string.length)];
        
        [str appendAttributedString:str2];
        label4CurrentQuotation.attributedText = str;
    }
}

- (void)refresh {
    self.currentPage = 1;
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getNewsByCoinType.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"coinType":self.symbol,@"currPage":@"1"} success:^(id response) {
        NSArray *array = [WPDiscoverModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        if (!self.listArray) {
            self.listArray = [NSMutableArray array];
        }
        [self.listArray addObjectsFromArray:array];
        if (self.listArray.count < [[response objectForKey:@"total"] integerValue]) {
            [self.tableView.mj_footer endRefreshing];
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
        [self requestFinish];
    } failure:^(NSError *error) {
        [self requestFinish];
    }];
}

- (void)loadMore {
    self.currentPage++;
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getNewsByCoinType.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"coinType":self.symbol,@"currPage":[NSString stringWithFormat:@"%ld",self.currentPage]} success:^(id response) {
        NSArray *array = [WPDiscoverModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"list"]];
        if (!self.listArray) {
            self.listArray = [NSMutableArray array];
        }
        [self.listArray addObjectsFromArray:array];
        if (self.listArray.count < [[response objectForKey:@"total"] integerValue]) {
            [self.tableView.mj_footer endRefreshing];
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        self.currentPage--;
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    }];
}
//分享
- (void)shareVC:(WPDiscoverModel *)model {
    WPNewsShareViewController *shareVC = [[WPNewsShareViewController alloc]init];
    shareVC.model = model;
    UINavigationController *naVC = [[UINavigationController alloc]initWithRootViewController:shareVC];
    naVC.navigationBar.translucent = NO;
    [self presentViewController:naVC animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPDiscoverTableViewCellType4 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPDiscoverTableViewCellType4 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell fillData:self.listArray[indexPath.row]];
    cell.lineV.hidden = YES;
    cell.ShareBlock = ^(WPDiscoverModel *model) {
        [self shareVC:model];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//提币
- (void)onButtonWithdrawCoin:(id)sender
{
    //判断是否允许提币
    if (![[self.coinInfo objectForKey:@"allowWithdraw"]boolValue])
    {
        [BiChatGlobal showInfo:LLSTR(@"301118") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //如果是imc token，还要检查kyc
    if ([[self.coinInfo objectForKey:@"symbol"]isEqualToString:@"TOKEN"] &&
        [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"kycLevel"]integerValue] == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301620") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //是否余额为0
    if (fabs(self.coinCount) < 0.000000001)
    {
        [BiChatGlobal showInfo:LLSTR(@"301121") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }

    WithdrawCoinViewController *wnd = [WithdrawCoinViewController new];
    wnd.coinInfo = self.coinInfo;
    wnd.coinCount = self.coinCount;
    [self.navigationController pushViewController:wnd animated:YES];
}

//充币
- (void)onButtonRechargeCoin:(id)sender
{
    //判断是否允许充币
    if (![[self.coinInfo objectForKey:@"allowDeposit"]boolValue])
    {
        [BiChatGlobal showInfo:LLSTR(@"301119") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    if (walletAddress == nil)
    {
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getRechargeAddress:[self.coinInfo objectForKey:@"symbol"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                //显示窗口
                walletAddress = [data objectForKey:@"address"];
                [self showAddressWnd:walletAddress];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301123") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    else
    {
        //显示窗口
        [self showAddressWnd:walletAddress];
    }
}

//显示充币地址的窗口
- (void)showAddressWnd:(NSString *)address
{
    //窗口是否已经创建
    if (!view4WalletAddress)
    {
        view4WalletAddress = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 320)];
        view4WalletAddress.backgroundColor = [UIColor whiteColor];
        view4WalletAddress.layer.cornerRadius = 3;
    }
    
    //先删除上面的窗口
    for (UIView *subView in [view4WalletAddress subviews])
        [subView removeFromSuperview];
    
    //生成界面元素
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
    label4Title.text = [LLSTR(@"103111") llReplaceWithArray:@[self.coinName]];
    label4Title.textAlignment = NSTextAlignmentCenter;
    label4Title.font = [UIFont systemFontOfSize:14];
    [view4WalletAddress addSubview:label4Title];
    
    //关闭按钮
    UIButton *button4Close = [[UIButton alloc]initWithFrame:CGRectMake(260, 0, 40, 40)];
    [button4Close setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
    [button4Close addTarget:self action:@selector(onButton4CloseWalletAddress:) forControlEvents:UIControlEventTouchUpInside];
    [view4WalletAddress addSubview:button4Close];
    
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 40, 300, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [view4WalletAddress addSubview:view4Seperator];
    
    //是否有地址
    if (address.length > 0)
    {
        //创建一个二维码滤镜实例(CIFilter)
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        // 滤镜恢复默认设置
        [filter setDefaults];
        
        //给滤镜添加数据
        NSString *string = address;
        if ([_coinInfo objectForKey:@"addrPrefix"])
            string = [[_coinInfo objectForKey:@"addrPrefix"]stringByAppendingString:string];
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        [filter setValue:data forKeyPath:@"inputMessage"];
        
        //生成二维码
        CIImage *image = [filter outputImage];

        UIImageView *image4VRCode = [[UIImageView alloc]initWithFrame:CGRectMake(60, 60, 180, 180)];
        image4VRCode.image = [self createNonInterpolatedUIImageFormCIImage:image withSize:400];
        [view4WalletAddress addSubview:image4VRCode];
        
        //地址
        UILabel *label4Address = [[UILabel alloc]initWithFrame:CGRectMake(15, 255, 270, 20)];
        label4Address.text = address;
        label4Address.textColor = [UIColor grayColor];
        label4Address.font = [UIFont systemFontOfSize:10];
        label4Address.layer.cornerRadius = 10;
        label4Address.clipsToBounds = YES;
        label4Address.adjustsFontSizeToFitWidth = YES;
        label4Address.textAlignment = NSTextAlignmentCenter;
        [view4WalletAddress addSubview:label4Address];
        
        //copy按钮
        UIButton *button4CopyWalletAddress = [[UIButton alloc]initWithFrame:CGRectMake(15, 280, 270, 30)];
        button4CopyWalletAddress.titleLabel.font = [UIFont systemFontOfSize:14];
        [button4CopyWalletAddress setTitle:LLSTR(@"103112") forState:UIControlStateNormal];
        [button4CopyWalletAddress setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4CopyWalletAddress addTarget:self action:@selector(onButtonCopyWalletAddress:) forControlEvents:UIControlEventTouchUpInside];
        [view4WalletAddress addSubview:button4CopyWalletAddress];
    }
    else
    {
        UIButton *button4CreateAddress = [[UIButton alloc]initWithFrame:CGRectMake(0, 40, 300, 260)];
        button4CreateAddress.titleLabel.font = [UIFont systemFontOfSize:14];
        [button4CreateAddress setTitle:LLSTR(@"103113") forState:UIControlStateNormal];
        [button4CreateAddress setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [button4CreateAddress addTarget:self action:@selector(onButton4CreateWalletAddress:) forControlEvents:UIControlEventTouchUpInside];
        [view4WalletAddress addSubview:button4CreateAddress];
    }

    //窗口是否已经显示
    if (!([BiChatGlobal presentedModalView] == view4WalletAddress))
        [BiChatGlobal presentModalView:view4WalletAddress clickDismiss:YES delayDismiss:0 andDismissCallback:nil];
}

- (void)onButton4CloseWalletAddress:(id)sender
{
    [BiChatGlobal dismissModalView];
}

- (void)onButton4CreateWalletAddress:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.userInteractionEnabled = NO;
    
    //开始生成
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule createRechargeAddress:[self.coinInfo objectForKey:@"symbol"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        button.userInteractionEnabled = YES;
        //NSLog(@"%@", data);
        
        if (success &&
            [[data objectForKey:@"address"]isKindOfClass:[NSString class]] &&
            [[data objectForKey:@"address"]length] > 0)
        {
            walletAddress = [data objectForKey:@"address"];
            [self showAddressWnd:walletAddress];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301123") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        
    }];
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

- (void)onButtonCopyWalletAddress:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = walletAddress;
    [BiChatGlobal showInfo:LLSTR(@"301010") withIcon:[UIImage imageNamed:@"icon_OK"]];
}

@end
