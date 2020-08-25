//
//  WPMyForceRobResultViewController.m
//  BiChat
//
//  Created by iMac on 2018/12/25.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPMyForceRobResultViewController.h"
#import "MyWalletAccountViewController.h"
#import "WPRedPacketDetalTableViewCell.h"

@interface WPMyForceRobResultViewController ()<UITableViewDelegate,UITableViewDataSource>

//头像
@property (nonatomic,strong)UIImageView *headIV;
//人名
@property (nonatomic,strong)UILabel *nameLabel;
//红包名
@property (nonatomic,strong)UILabel *titleLabel;
//红包金额
@property (nonatomic,strong)UILabel *priceLabel;
//零钱包
@property (nonatomic,strong)UILabel *coinLabel;
//红包状况
@property (nonatomic,strong)UILabel *resultLabel;
//红包状况背景色
@property (nonatomic,strong)UIView *resultBackView;
//底部红色View
@property (nonatomic,strong)UIView *colorView;
//点击跳转到零钱包
@property (nonatomic,strong)UIButton *tapButton;

@property (nonatomic,assign)NSInteger currentPage;
@property (nonatomic,assign)NSInteger totalCount;
@property (nonatomic,strong)NSMutableArray *listArray;
@property (nonatomic,strong)UITableView *tableV;
@property (nonatomic,strong)UIView *headerV;

@end

@implementation WPMyForceRobResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.title = LLSTR(@"201013");
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = RGB(0xd85742);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB(0xffe2b3)}];
    self.navigationController.navigationBar.tintColor = RGB(0xffe2b3);
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)createUI {
    
    self.colorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.view addSubview:self.colorView];
    self.colorView.backgroundColor = RGB(0xd85742);
    
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:[self.data objectForKey:@"coinType"]];
    
    self.colorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.view addSubview:self.colorView];
    self.colorView.backgroundColor = RGB(0xd85742);
    
    self.tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) + 20) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableV];
    self.tableV.backgroundColor = [UIColor clearColor];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.rowHeight = 60;
    
    self.tableV.mj_footer.hidden = YES;
    self.headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 272)];
    self.headerV.backgroundColor = RGB(0xf1f1f1);
    self.tableV.tableHeaderView = self.headerV;
    UIImageView *topIV = [[UIImageView alloc]init];
    [self.headerV addSubview:topIV];
    [topIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.headerV);
        make.height.equalTo(@60);
    }];
    topIV.image = Image(@"redPacket_top");
    
    self.headIV = [[UIImageView alloc]init];
    [self.headerV addSubview:self.headIV];
//    [self.headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[self.data objectForKey:@"avatar"]]]];
    [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[self.data objectForKey:@"avatar"]] title:[self.data objectForKey:@"nickName"] size:CGSizeMake(60, 60) placeHolde:nil color:nil textColor:nil];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@60);
        make.centerY.equalTo(topIV.mas_bottom).offset(-4);
        make.centerX.equalTo(self.headerV);
    }];
    self.headIV.layer.masksToBounds = YES;
    self.headIV.layer.cornerRadius = 30;
    //    self.headIV.layer.borderWidth = 1;
    //    self.headIV.layer.borderColor = RGB(0xe6cea2).CGColor;
    
    self.nameLabel = [[UILabel alloc]init];
    [self.headerV addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV).offset(20);
        make.right.equalTo(self.headerV).offset(-20);
        make.top.equalTo(self.headIV.mas_bottom).offset(5);
        make.height.equalTo(@20);
    }];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = Font(16);
    self.nameLabel.text = [self.data objectForKey:@"nickName"];
    
    
    self.titleLabel = [[UILabel alloc]init];
    [self.headerV addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV).offset(20);
        make.right.equalTo(self.headerV).offset(-20);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
        make.height.equalTo(@60);
    }];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = Font(18);
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.text = LLSTR(@"101454");
    
    self.priceLabel = [[UILabel alloc]init];
    [self.headerV addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV).offset(20);
        make.right.equalTo(self.headerV).offset(-20);
        make.height.equalTo(@30);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
    }];
    self.priceLabel.textAlignment = NSTextAlignmentCenter;
    self.priceLabel.font = Font(36);
    NSString *price = [NSString stringWithFormat:@"%@",[self.data objectForKey:@"value"]];
    self.priceLabel.text = [price accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%@",[coinInfo objectForKey:@"bit"]] auotCheck:YES];
    
    self.coinLabel = [[UILabel alloc]init];
    [self.headerV addSubview:self.coinLabel];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV).offset(20);
        make.right.equalTo(self.headerV).offset(-20);
        make.height.equalTo(@20);
        make.top.equalTo(self.priceLabel.mas_bottom).offset(1);
    }];
    self.coinLabel.textAlignment = NSTextAlignmentCenter;
    self.coinLabel.font = Font(12);
    self.coinLabel.text = [coinInfo objectForKey:@"dSymbol"];
    
    self.tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.headerV addSubview:self.tapButton];
    [self.tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV).offset(20);
        make.right.equalTo(self.headerV).offset(-20);
        make.top.equalTo(self.coinLabel.mas_bottom).offset(5);
        make.height.equalTo(@25);
    }];
    self.tapButton.titleLabel.font = Font(14);
    [self.tapButton setTitleColor:LightBlue forState:UIControlStateNormal];
    [self.tapButton setTitle:LLSTR(@"101473") forState:UIControlStateNormal];
    [self.tapButton addTarget:self action:@selector(toChange) forControlEvents:UIControlEventTouchUpInside];
}

//零钱包
- (void)toChange {
    //先获取是否已经设置了支付密码
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:[self.data objectForKey:@"coinType"]];
    MyWalletAccountViewController *wnd = [MyWalletAccountViewController new];
    wnd.coinSymbol = [self.data objectForKey:@"coinType"];
    wnd.coinDSymbol = [coinInfo objectForKey:@"dSymbol"];
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPRedPacketDetalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPRedPacketDetalTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[BiChatGlobal sharedManager].avatar] title:[BiChatGlobal sharedManager].nickName size:CGSizeMake(60, 60) placeHolde:nil color:nil textColor:nil];
//    [cell.headIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[BiChatGlobal sharedManager].avatar]]];
    cell.getStatusLabel.text = LLSTR(@"101419");
    cell.titleLabel.text = [BiChatGlobal sharedManager].nickName;
    [cell.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.headIV.mas_right).offset(10);
        make.right.equalTo(cell.contentView).offset(-180);
        make.top.bottom.equalTo(cell.contentView);
    }];
    cell.priceLabel.text = self.priceLabel.text;
    [cell.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.titleLabel.mas_right).offset(10);
        make.right.equalTo(cell.contentView).offset(-10);
        make.height.equalTo(@20);
        make.bottom.equalTo(cell.headIV.mas_centerY);
    }];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        self.colorView.frame = CGRectMake(0, 0, ScreenWidth, fabs(scrollView.contentOffset.y) + 5);
    } else {
        self.colorView.frame = CGRectMake(0, 0, ScreenWidth, 0);
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
