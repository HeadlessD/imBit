//
//  WPBiddingViewController.m
//  BiChat
//
//  Created by iMac on 2019/2/15.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPBiddingViewController.h"
#import "WPBiddingActivityDetailModel.h"
#import "WPBiddingView.h"
//#import "WPBiddingOrderView.h"
#import "WPEncryptionObject.h"
#import "WPProductInputView.h"
#import "WPBiddingDetailViewController.h"
#import "PoolAccountViewController.h"
#import "WPNewsDetailViewController.h"
#import "WPBiddingHistoryViewController.h"
#import "WPTipsView.h"
#import "DFLanguageManager.h"

@interface WPBiddingViewController ()

{
    NSDictionary *myTokenInfo;
}

@property (nonatomic,strong)UIScrollView *sv;
@property (nonatomic,strong)UILabel *countDownLabel;
@property (nonatomic,strong)WPBiddingActivityDetailModel *biddingModel;
@property (nonatomic,strong)NSArray *activityList;
//@property (nonatomic,strong)WPBiddingOrderView *biddingOrderView;
@property (nonatomic,strong)WPProductInputView *passView;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)UIButton *biddingButton;

@end

@implementation WPBiddingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self freshData];

    self.view.backgroundColor = RGB(0xf2f2f2);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:Image(@"more") style:UIBarButtonItemStyleDone target:self action:@selector(showAction)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//
//}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //修改标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_token2"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav_transparent"];
}

- (void)freshData {
    [self.timer invalidate];
    [NetworkModule getTokenInfo:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            myTokenInfo = data;
            [self getActivityDetail];
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301656") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        
    }];
}

- (void)getActivityDetail {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getBidAcitveDetail.do" parameters:nil success:^(id response) {
        self.biddingModel = [WPBiddingActivityDetailModel mj_objectWithKeyValues:response];
        if (self.biddingModel.batchNo.length > 0) {
            [self getBiddingList];
        } else {
            [self createUI];
        }
    } failure:^(NSError *error) {
//        [BiChatGlobal showFailWithString:@""];
    }];
}

- (void)getBiddingList {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getUserBidList.do" parameters:@{@"batchNo":self.biddingModel.batchNo} success:^(id response) {
        self.activityList = [response objectForKey:@"list"];
        [self createUI];
    } failure:^(NSError *error) {
//        [BiChatGlobal showFailWithString:@""];
    }];
}
- (void)getBiddingList1 {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getUserBidList.do" parameters:@{@"batchNo":self.biddingModel.batchNo} success:^(id response) {
        [BiChatGlobal HideActivityIndicator];
        self.activityList = [response objectForKey:@"list"];
        [self createUI];
    } failure:^(NSError *error) {
        [BiChatGlobal HideActivityIndicator];
    }];
}

- (void)createUI {
    if (!self.sv) {
        self.sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64))];
        [self.view addSubview:self.sv];
    }
    UIView *view = [self.sv viewWithTag:123];
    if (view) {
        [view removeFromSuperview];
    }
    UIView *contentV = [[UIView alloc]init];
    contentV.tag = 123;
    [self.sv addSubview:contentV];
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sv);
        make.width.equalTo(self.sv);
    }];
    contentV.backgroundColor = RGB(0xf2f2f2);
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 240)];
    [contentV addSubview:topView];
    topView.backgroundColor = RGB(0xfffffc);
    
    //扩展背景
    UIImageView *view4ExtentBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, -300, ScreenWidth, 300)];
    view4ExtentBk.image = [UIImage imageNamed:@"nav_token"];
    [contentV addSubview:view4ExtentBk];
    
    //背景
    UIImageView *image4Bk = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"myInfoBk"]];
    image4Bk.frame = CGRectMake(0, -64, self.view.frame.size.width, 232);
    [contentV addSubview:image4Bk];
    
    
    //获取币信息
    NSDictionary *coinInfo1 = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.biddingModel.coinType];
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.biddingModel.castCoinType];
    //积累奖池
    UILabel *totalCountLabel = [[UILabel alloc]init];
    [contentV addSubview:totalCountLabel];
    [totalCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentV).offset(10);
        make.right.equalTo(contentV.mas_centerX).offset(-10);
        make.top.equalTo(contentV).offset(50);
        make.height.equalTo(@80);
    }];
    totalCountLabel.textColor = [UIColor whiteColor];
    totalCountLabel.textAlignment = NSTextAlignmentCenter;
    totalCountLabel.numberOfLines = 3;
    totalCountLabel.font = Font(14);
    
    NSString *totalCountString = [NSString stringWithFormat:@"%@\n%@\n%@",[NSString stringWithFormat:@"%lld", [[myTokenInfo objectForKey:@"rewardPool"]longLongValue]],@"IMC",LLSTR(@"108003")];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:totalCountString];
    [attStr addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(0, totalCountString.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1 alpha:0.9] range:NSMakeRange(0, totalCountString.length)];
    [attStr addAttribute:NSFontAttributeName value:Font(20) range:[totalCountString rangeOfString:[NSString stringWithFormat:@"%lld", [[myTokenInfo objectForKey:@"rewardPool"]longLongValue]]]];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[totalCountString rangeOfString:[NSString stringWithFormat:@"%lld", [[myTokenInfo objectForKey:@"rewardPool"]longLongValue]]]];
    totalCountLabel.attributedText = attStr;
    //中奖系数
    UILabel *coefficientLabel = [[UILabel alloc]init];
    [contentV addSubview:coefficientLabel];
    [coefficientLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentV.mas_centerX).offset(10);
        make.right.equalTo(contentV).offset(-10);
        make.top.equalTo(contentV).offset(50);
        make.height.equalTo(@80);
    }];
    coefficientLabel.textColor = [UIColor whiteColor];
    coefficientLabel.textAlignment = NSTextAlignmentCenter;
    coefficientLabel.numberOfLines = 3;
    coefficientLabel.font = Font(14);
    NSString *coefficientString = [NSString stringWithFormat:@"%@\n\n%@",[NSString stringWithFormat:@"%.02f", [[myTokenInfo objectForKey:@"rewardRate"]floatValue]],LLSTR(@"108004")];
    NSMutableAttributedString *attStr1 = [[NSMutableAttributedString alloc] initWithString:coefficientString];
    [attStr1 addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(0, coefficientString.length)];
    [attStr1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1 alpha:0.9] range:NSMakeRange(0, coefficientString.length)];
    [attStr1 addAttribute:NSFontAttributeName value:Font(20) range:[coefficientString rangeOfString:[NSString stringWithFormat:@"%.02f", [[myTokenInfo objectForKey:@"rewardRate"]floatValue]]]];
    [attStr1 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[coefficientString rangeOfString:[NSString stringWithFormat:@"%.02f", [[myTokenInfo objectForKey:@"rewardRate"]floatValue]]]];
    coefficientLabel.attributedText = attStr1;
    
    UIButton *coefficientButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [contentV addSubview:coefficientButton];
    [coefficientButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(coefficientLabel);
        make.top.equalTo(coefficientLabel).offset(8);
    }];
    [coefficientButton setImage:Image(@"question_mark") forState:UIControlStateNormal];
    [coefficientButton addTarget:self action:@selector(showCoefficient) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *array = @[@"FORCE / BTC",@"FORCE / ETH",@"FORCE / IMC"];
    CGFloat unitWidth = (ScreenWidth - 60) / 3.0;
    UILabel *rateMiddleLabel = [[UILabel alloc]init];
    [topView addSubview:rateMiddleLabel];
    [rateMiddleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(topView.mas_bottom).offset(-5);
        make.height.equalTo(@(60));
        make.width.equalTo(@(unitWidth));
        make.centerX.equalTo(topView);
    }];
    rateMiddleLabel.numberOfLines = 2;
    rateMiddleLabel.textAlignment = NSTextAlignmentCenter;
//    rateMiddleLabel.text = @"aaa\nbbb";
    if (array.count > 1) {
//        rateMiddleLabel.text = [NSString stringWithFormat:@"%@\n%@",[self.biddingModel.exchange objectForKey:array[1]],array[1]];
        NSString *middleStr = [NSString stringWithFormat:@"%@\n%@",[[self.biddingModel.exchange objectForKey:@"ETH"] floatValue] > 0 ? [self.biddingModel.exchange objectForKey:@"ETH"] : @" -- ",array[1]];
        NSMutableAttributedString *middleAttstr = [[NSMutableAttributedString alloc] initWithString:middleStr];
        [middleAttstr addAttribute:NSForegroundColorAttributeName value:RGB(0x808080) range:NSMakeRange(0, middleStr.length)];
        [middleAttstr addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(0, middleStr.length)];
        [middleAttstr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:[middleStr rangeOfString:[[self.biddingModel.exchange objectForKey:@"ETH"] floatValue] > 0 ? [self.biddingModel.exchange objectForKey:@"ETH"] : @" -- "]];
        [middleAttstr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[middleStr rangeOfString:[[self.biddingModel.exchange objectForKey:@"ETH"] floatValue] > 0 ? [self.biddingModel.exchange objectForKey:@"ETH"] : @" -- "]];
        rateMiddleLabel.attributedText = middleAttstr;
    }
    
    UILabel *rateLeftLabel = [[UILabel alloc]init];
    [topView addSubview:rateLeftLabel];
    [rateLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(rateMiddleLabel);
        make.width.equalTo(@(unitWidth));
        make.right.equalTo(rateMiddleLabel.mas_left).offset(-10);
    }];
    rateLeftLabel.numberOfLines = 2;
    rateLeftLabel.textAlignment = NSTextAlignmentCenter;
    if (array.count > 0) {
        NSString *middleStr = [NSString stringWithFormat:@"%@\n%@",[[self.biddingModel.exchange objectForKey:@"BTC"] floatValue] > 0 ? [self.biddingModel.exchange objectForKey:@"BTC"] : @" -- ",array[0]];
        NSMutableAttributedString *middleAttstr = [[NSMutableAttributedString alloc] initWithString:middleStr];
        [middleAttstr addAttribute:NSForegroundColorAttributeName value:RGB(0x808080) range:NSMakeRange(0, middleStr.length)];
        [middleAttstr addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(0, middleStr.length)];
        [middleAttstr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:[middleStr rangeOfString:[NSString stringWithFormat:@"%@",[[self.biddingModel.exchange objectForKey:@"BTC"] floatValue] > 0 ? [self.biddingModel.exchange objectForKey:@"BTC"] : @" -- "]]];
        [middleAttstr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[middleStr rangeOfString:[NSString stringWithFormat:@"%@",[[self.biddingModel.exchange objectForKey:@"BTC"] floatValue] > 0 ? [self.biddingModel.exchange objectForKey:@"BTC"] : @" -- "]]];
        rateLeftLabel.attributedText = middleAttstr;
    }
    
    UILabel *rateRightLabel = [[UILabel alloc]init];
    [topView addSubview:rateRightLabel];
    [rateRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(rateMiddleLabel);
        make.width.equalTo(@(unitWidth));
        make.left.equalTo(rateMiddleLabel.mas_right).offset(10);
    }];
    rateRightLabel.numberOfLines = 2;
    rateRightLabel.textAlignment = NSTextAlignmentCenter;
//    rateRightLabel.text = @"aaa\nbbb";
    if (array.count > 2) {
//        rateRightLabel.text = [NSString stringWithFormat:@"%@\n%@",[self.biddingModel.exchange objectForKey:array[2]],array[2]];
        NSString *middleStr = [NSString stringWithFormat:@"%@\n%@",[[self.biddingModel.exchange objectForKey:@"BTC"] floatValue] > 0 ? [self.biddingModel.exchange objectForKey:@"BTC"] : @" -- ",array[2]];
        NSMutableAttributedString *middleAttstr = [[NSMutableAttributedString alloc] initWithString:middleStr];
        [middleAttstr addAttribute:NSForegroundColorAttributeName value:RGB(0x808080) range:NSMakeRange(0, middleStr.length)];
        [middleAttstr addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(0, middleStr.length)];
        [middleAttstr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:[middleStr rangeOfString:[NSString stringWithFormat:@"%@",[[self.biddingModel.exchange objectForKey:@"IMC"] floatValue] > 0 ? [self.biddingModel.exchange objectForKey:@"IMC"] : @" -- "]]];
        [middleAttstr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[middleStr rangeOfString:[NSString stringWithFormat:@"%@",[[self.biddingModel.exchange objectForKey:@"IMC"] floatValue] > 0 ? [self.biddingModel.exchange objectForKey:@"IMC"] : @" -- "]]];
        rateRightLabel.attributedText = middleAttstr;
    }
    
    if (self.biddingModel.batchNo.length == 0) {
        UIView *allocationView = [[UIView alloc]init];
        [contentV addSubview:allocationView];
        [allocationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topView.mas_bottom).offset(15);
            make.left.equalTo(contentV).offset(15);
            make.right.equalTo(contentV).offset(-15);
            make.height.equalTo(@140);
        }];
        allocationView.backgroundColor = [UIColor whiteColor];
        allocationView.layer.cornerRadius = 5;
        allocationView.clipsToBounds = YES;
        
        UILabel *emptyLabel = [[UILabel alloc]init];
        [allocationView addSubview:emptyLabel];
        [emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(allocationView);
        }];
        emptyLabel.numberOfLines = 2;
        emptyLabel.font = Font(20);
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.text = LLSTR(@"108051");
        [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(emptyLabel.mas_bottom).offset(10);
        }];
        return;
    }
    
    UIView *allocationView = [[UIView alloc]init];
    [contentV addSubview:allocationView];
    [allocationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_bottom).offset(15);
        make.left.equalTo(contentV).offset(15);
        make.right.equalTo(contentV).offset(-15);
        if ([self.biddingModel.status integerValue] == 17) {
            make.height.equalTo(@160);
        } else {
            make.height.equalTo(@70);
        }
    }];
    allocationView.backgroundColor = [UIColor whiteColor];
    allocationView.layer.cornerRadius = 5;
    allocationView.clipsToBounds = YES;
    
    //分配总份数
    UILabel *allocationpPieceLabel = [[UILabel alloc]init];
    [allocationView addSubview:allocationpPieceLabel];
    [allocationpPieceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(allocationView);
        make.right.equalTo(allocationView.mas_centerX);
        make.top.equalTo(allocationView);
        make.height.equalTo(@(70));
    }];
    allocationpPieceLabel.numberOfLines = 2;
    allocationpPieceLabel.font = Font(14);
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5;
    NSString *imcString = [[NSString stringWithFormat:@"%@",self.biddingModel.userVolume] accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%d",[[coinInfo1 objectForKey:@"bit"] intValue]] auotCheck:YES];
    NSString *leftStr = [NSString stringWithFormat:@"%@ %@\n%@",imcString,[coinInfo1 objectForKey:@"dSymbol"],[LLSTR(@"108008") llReplaceWithArray:@[self.biddingModel.amount]]];
    NSMutableAttributedString *leftAttStr = [[NSMutableAttributedString alloc] initWithString:leftStr];
    [leftAttStr addAttribute:NSForegroundColorAttributeName value:RGB(0x808080) range:NSMakeRange(0, leftStr.length)];
    [leftAttStr addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(0, leftStr.length)];
    [leftAttStr addAttribute:NSFontAttributeName value:Font(20) range:NSMakeRange(0, [imcString length])];
    [leftAttStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [imcString length])];
    [leftAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, leftStr.length)];
    allocationpPieceLabel.attributedText = leftAttStr;
    allocationpPieceLabel.textAlignment = NSTextAlignmentCenter;
    //总量
    UILabel *coinCount = [[UILabel alloc]init];
    [allocationView addSubview:coinCount];
    [coinCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(allocationView.mas_centerX);
        make.right.equalTo(allocationView);
        make.top.equalTo(allocationView);
        make.height.equalTo(@(70));
    }];
    coinCount.numberOfLines = 2;
    
    NSString *forceString = [[NSString stringWithFormat:@"%@",self.biddingModel.totalAmount] accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%d",[[coinInfo objectForKey:@"bit"] intValue]] auotCheck:YES];
    NSString *rightStr = [NSString stringWithFormat:@"%@ %@\n%@",forceString,@"FORCE",[LLSTR(@"108009") llReplaceWithArray:@[self.biddingModel.userCount,self.biddingModel.orderCount]]];
    NSMutableAttributedString *rightAttStr = [[NSMutableAttributedString alloc] initWithString:rightStr];
    [rightAttStr addAttribute:NSForegroundColorAttributeName value:RGB(0x808080) range:NSMakeRange(0, rightStr.length)];
    [rightAttStr addAttribute:NSFontAttributeName value:Font(12) range:NSMakeRange(0, rightStr.length)];
    [rightAttStr addAttribute:NSFontAttributeName value:Font(20) range:NSMakeRange(0, [forceString length])];
    [rightAttStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [forceString length])];
    [rightAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, rightAttStr.length)];
    coinCount.attributedText = rightAttStr;
    coinCount.textAlignment = NSTextAlignmentCenter;
    if ([self.biddingModel.status integerValue] == 17) {
        UIView *lineV = [[UIView alloc]init];
        [allocationView addSubview:lineV];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(allocationView).offset(10);
            make.right.equalTo(allocationView).offset(-10);
            make.top.equalTo(allocationView).offset(70);
            make.height.equalTo(@(0.5));
        }];
        lineV.backgroundColor = RGB(0xcccccc);
        lineV.alpha = .8;
        
        UILabel *resultLabel1 = [[UILabel alloc]init];
        [allocationView addSubview:resultLabel1];
        [resultLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(allocationView).offset(10);
            make.right.equalTo(allocationView).offset(-10);
            make.top.equalTo(lineV.mas_bottom).offset(15);
            make.height.equalTo(@(16));
        }];
        resultLabel1.text = [LLSTR(@"108031") llReplaceWithArray:@[[[NSString stringWithFormat:@"%@",self.biddingModel.bidPrice] accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%d",[[coinInfo objectForKey:@"bit"] intValue]] auotCheck:NO]]];
        resultLabel1.font = Font(14);
        resultLabel1.textAlignment = NSTextAlignmentCenter;
        
        UILabel *resultLabel2 = [[UILabel alloc]init];
        [allocationView addSubview:resultLabel2];
        [resultLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(allocationView).offset(10);
            make.right.equalTo(allocationView).offset(-10);
            make.top.equalTo(resultLabel1.mas_bottom).offset(6);
            make.height.equalTo(@(16));
        }];
        resultLabel2.text = [LLSTR(@"108032") llReplaceWithArray:@[self.biddingModel.allotVolumeStr,self.biddingModel.winningAmount]];
        resultLabel2.font = Font(14);
        resultLabel2.textAlignment = NSTextAlignmentCenter;
        
        UILabel *resultLabel3 = [[UILabel alloc]init];
        [allocationView addSubview:resultLabel3];
        [resultLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(allocationView).offset(10);
            make.right.equalTo(allocationView).offset(-10);
            make.top.equalTo(resultLabel2.mas_bottom).offset(6);
            make.height.equalTo(@(16));
        }];
        resultLabel3.text = [LLSTR(@"108033") llReplaceWithArray:@[self.biddingModel.confirmUser ,self.biddingModel.confirmCount,self.biddingModel.winningUser,self.biddingModel.winningOrder]];
        resultLabel3.font = Font(14);
        resultLabel3.textAlignment = NSTextAlignmentCenter;
    }
    
    //倒计时View
    UIView *countDownView = [[UIView alloc]init];
    [contentV addSubview:countDownView];
    [countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(allocationView);
        make.top.equalTo(allocationView.mas_bottom).offset(15);
        make.height.equalTo(@270);
    }];
    countDownView.backgroundColor = [UIColor whiteColor];
    
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"bidding.db"];
    NSString * storeStr =[store getStringById:self.biddingModel.batchNo fromTable:[NSString stringWithFormat:@"b%@",[BiChatGlobal sharedManager].uid]];
    
    
    self.biddingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [countDownView addSubview:self.biddingButton];
    [self.biddingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@120);
        make.height.equalTo(@40);
        make.centerX.equalTo(countDownView);
        make.top.equalTo(countDownView).offset(90);
    }];
    self.biddingButton.layer.cornerRadius = 3;
    self.biddingButton.layer.masksToBounds = YES;
    self.biddingButton.backgroundColor = RGB(0x2f93fa);
    [self.biddingButton addTarget:self action:@selector(doBidding) forControlEvents:UIControlEventTouchUpInside];
    self.biddingButton.titleLabel.font = Font(16);
    
    self.countDownLabel = [[UILabel alloc]init];
    [countDownView addSubview:self.countDownLabel];
    
    
    if (self.biddingModel.batchNo.length == 0) {
        self.biddingButton.hidden = YES;
        self.countDownLabel.text = LLSTR(@"108051");
    } else if ([self.biddingModel.status integerValue] < 3 && self.biddingModel.batchNo.length > 0) {
        [self.biddingButton setTitle:LLSTR(@"108013") forState:UIControlStateNormal];
        self.biddingButton.backgroundColor = [UIColor lightGrayColor];
        self.countDownLabel.text = LLSTR(@"108052");
    } else if ([self.biddingModel.status integerValue] == 3) {
        [self.biddingButton setTitle:LLSTR(@"108013") forState:UIControlStateNormal];
        [self countDown];
    } else if ([self.biddingModel.status integerValue] > 3 && [self.biddingModel.status integerValue] < 9) {
        if (self.activityList.count > 0) {
            self.biddingButton.backgroundColor = [UIColor lightGrayColor];
            [self.biddingButton setTitle:LLSTR(@"108014") forState:UIControlStateNormal];
            self.biddingButton.userInteractionEnabled = NO;
            self.countDownLabel.text = LLSTR(@"108053");
        } else {
            self.biddingButton.hidden = YES;
            self.countDownLabel.text = LLSTR(@"108059");
        }
    } else if ([self.biddingModel.status integerValue] == 9) {
        if (self.activityList.count > 0) {
            if ([storeStr boolValue]) {
                self.countDownLabel.text = LLSTR(@"108054");
                self.biddingButton.hidden = YES;
            } else {
                [self.biddingButton setTitle:LLSTR(@"108014") forState:UIControlStateNormal];
                self.biddingButton.backgroundColor = RGB(0xfa8f2f);
                [self countDown];
            }
        } else {
            self.biddingButton.hidden = YES;
            self.countDownLabel.text = LLSTR(@"108059");
        }
    } else if ([self.biddingModel.status integerValue] > 9 && [self.biddingModel.status integerValue] < 17) {
        if (self.activityList.count == 0) {
            self.countDownLabel.text = LLSTR(@"108059");
            self.biddingButton.hidden = YES;
        } else {
            if ([storeStr boolValue]) {
                self.countDownLabel.text = LLSTR(@"108055");
                self.biddingButton.hidden = YES;
            } else {
                self.countDownLabel.text = LLSTR(@"108062");
                self.biddingButton.hidden = YES;
            }
        }
    } else if ([self.biddingModel.status integerValue] == 17) {
        if (self.activityList.count == 0) {
            self.countDownLabel.text = LLSTR(@"108059");
            self.biddingButton.hidden = YES;
        } else {
            if (self.biddingModel.userSummary.isSubmitKey) {
                self.countDownLabel.text = [LLSTR(@"108060") llReplaceWithArray:@[self.biddingModel.userSummary.successAmount,self.biddingModel.userSummary.successOrder]];
                self.biddingButton.hidden = YES;
            } else {
                self.countDownLabel.text = LLSTR(@"108062");
                self.biddingButton.hidden = YES;
            }
        }
    } else if ([self.biddingModel.status integerValue] == 18) {
        self.countDownLabel.text = LLSTR(@"108057");
        self.biddingButton.hidden = YES;
    } else if ([self.biddingModel.status integerValue] == 19) {
        self.countDownLabel.text = LLSTR(@"108058");
        self.biddingButton.hidden = YES;
    }
    
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(countDownView);
        if (self.biddingButton.hidden) {
            make.top.equalTo(countDownView).offset(10);
            make.bottom.equalTo(countDownView.mas_top).offset(160);
        } else {
            make.top.equalTo(countDownView);
            make.bottom.equalTo(self.biddingButton.mas_top);
        }
    }];
    self.countDownLabel.textAlignment = NSTextAlignmentCenter;
    self.countDownLabel.numberOfLines = 2;
    self.countDownLabel.font = Font(20);
    if (self.biddingModel.batchNo.length == 0) {
        return;
    }
    UILabel *biddingLabel = [[UILabel alloc]init];
    [countDownView addSubview:biddingLabel];
    [biddingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countDownView).offset(15);
        make.right.equalTo(countDownView).offset(-15);
        make.top.equalTo(countDownView).offset(150);
        make.height.equalTo(@22);
    }];
    biddingLabel.font = Font(14);
    biddingLabel.textColor = RGB(0x808080);
    biddingLabel.numberOfLines = 2;
    biddingLabel.text = [NSString stringWithFormat:@"%@%@ - %@",LLSTR(@"108015"),[self.biddingModel.bidStartTime getTimeWithTimestamp:@"yyyy/MM/dd HH:mm"],[self.biddingModel.bidEndTime getTimeWithTimestamp:@"MM/dd HH:mm"]];
    
    UILabel *biddingConfirmLabel = [[UILabel alloc]init];
    [countDownView addSubview:biddingConfirmLabel];
    [biddingConfirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countDownView).offset(15);
        make.right.equalTo(countDownView).offset(-15);
        make.top.equalTo(biddingLabel.mas_bottom);
        make.height.equalTo(@22);
    }];
    biddingConfirmLabel.font = Font(14);
    biddingConfirmLabel.textColor = RGB(0x808080);
    biddingConfirmLabel.text = [NSString stringWithFormat:@"%@%@ - %@",LLSTR(@"108016"),[self.biddingModel.submitStartTime getTimeWithTimestamp:@"yyyy/MM/dd HH:mm"],[self.biddingModel.submitEndTime getTimeWithTimestamp:@"MM/dd HH:mm"]];
    
    UILabel *biddingResultLabel = [[UILabel alloc]init];
    [countDownView addSubview:biddingResultLabel];
    [biddingResultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countDownView).offset(15);
        make.right.equalTo(countDownView).offset(-15);
        make.top.equalTo(biddingConfirmLabel.mas_bottom);
        make.height.equalTo(@22);
    }];
    biddingResultLabel.font = Font(14);
    biddingResultLabel.textColor = RGB(0x808080);
    biddingResultLabel.text = [NSString stringWithFormat:@"%@%@",LLSTR(@"108017"),[self.biddingModel.resultTime getTimeWithTimestamp:@"yyyy/MM/dd HH:mm"]];
//    [self.biddingModel.bidEndTime getTimeWithTimestamp:@"yyyyMMdd HH:mm"];
    
    UILabel *biddingRuleLabel = [[UILabel alloc]init];
    [countDownView addSubview:biddingRuleLabel];
    [biddingRuleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countDownView).offset(15);
        make.right.equalTo(countDownView).offset(-15);
        make.top.equalTo(biddingResultLabel.mas_bottom);
        make.height.equalTo(@22);
    }];
    biddingRuleLabel.text = LLSTR(@"108018");
    biddingRuleLabel.font = Font(14);
    biddingRuleLabel.textColor = RGB(0x808080);
    
    CGRect rect = [biddingRuleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil];
    
    UIButton *biddingRuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [countDownView addSubview:biddingRuleButton];
    [biddingRuleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(biddingRuleLabel);
        make.left.equalTo(biddingRuleLabel).offset(rect.size.width);
        make.width.equalTo(@(25));
    }];
    [biddingRuleButton setImage:Image(@"question_mark_blue") forState:UIControlStateNormal];
    [biddingRuleButton addTarget:self action:@selector(showRule) forControlEvents:UIControlEventTouchUpInside];
    
    [countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(allocationView);
        make.top.equalTo(allocationView.mas_bottom).offset(15);
        make.bottom.equalTo(biddingRuleLabel.mas_bottom).offset(10);
    }];

    
    //我的竞价
    UIView *myBiddingView = [[UIView alloc]init];
    [contentV addSubview:myBiddingView];
    [myBiddingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentV).offset(15);
        make.right.equalTo(contentV).offset(-15);
        make.top.equalTo(countDownView.mas_bottom).offset(15);
        make.height.equalTo(@(self.activityList.count * 25 + 80));
    }];
    myBiddingView.backgroundColor = [UIColor whiteColor];
    myBiddingView.layer.cornerRadius = 5;
    myBiddingView.layer.masksToBounds = YES;
    
    UILabel *myBiddingTitleLabel = [[UILabel alloc]init];
    [myBiddingView addSubview:myBiddingTitleLabel];
    [myBiddingTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(myBiddingView).offset(15);
        make.right.equalTo(myBiddingView).offset(-15);
        make.top.equalTo(myBiddingView).offset(10);
        make.height.equalTo(@40);
    }];
    myBiddingTitleLabel.text = LLSTR(@"108019");
    UIView *lastView = nil;
    for (int i = 0; i < self.activityList.count; i++) {
        WPBiddingView *biddingV = [[WPBiddingView alloc]init];
        [myBiddingView addSubview:biddingV];
        [biddingV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(myBiddingView);
            make.right.equalTo(myBiddingView);
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom);
            } else {
                make.top.equalTo(myBiddingView).offset(60);
            }
            make.height.equalTo(@25);
        }];
        lastView = biddingV;
        biddingV.model = self.biddingModel;
        [biddingV fillData:self.activityList[i]];
        WEAKSELF;
        biddingV.CheckBlock = ^(NSDictionary * _Nonnull dict) {
            WPBiddingDetailViewController *biddingVC = [[WPBiddingDetailViewController alloc]init];
            biddingVC.model = self.biddingModel;
            biddingVC.coefficient = [myTokenInfo objectForKey:@"rewardRate"];
            biddingVC.biddingDic = dict;
            [self.navigationController pushViewController:biddingVC animated:YES];
            biddingVC.RefreshBlock = ^{
                [BiChatGlobal ShowActivityIndicator];
                [weakSelf performSelector:@selector(getBiddingList1) withObject:nil afterDelay:3];
            };
            
        };
    }
    if (self.activityList.count > 0) {
        UIView *lineV = [[UIView alloc]init];
        [myBiddingView addSubview:lineV];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(allocationView).offset(10);
            make.right.equalTo(allocationView).offset(-10);
            make.top.equalTo(myBiddingView).offset(50);
            make.height.equalTo(@(0.5));
        }];
        lineV.backgroundColor = RGB(0xcccccc);
        lineV.alpha = .8;
    }
    
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(myBiddingView.mas_bottom).offset(10);
    }];
}
//显示拍卖规则
- (void)showRule {
//    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:[LLSTR(@"108034") llReplaceWithArray:@[self.biddingModel.amount]] preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *act = [UIAlertAction actionWithTitle:[LLSTR(@"101023") llReplaceWithArray:@[@"9"]] style:UIAlertActionStyleDefault handler:nil];
//    [alertC addAction:act];
//    [self presentViewController:alertC animated:YES completion:nil];
    [WPTipsView showTipWithContent:[LLSTR(@"108034") llReplaceWithArray:@[self.biddingModel.amount,self.biddingModel.volume]]];
    
}
//显示系数
- (void)showCoefficient {
    [WPTipsView showTipWithContent:LLSTR(@"301660")];
//    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:[LLSTR(@"301660") llReplaceWithArray:@[self.biddingModel.amount]] preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *act = [UIAlertAction actionWithTitle:[LLSTR(@"101023") llReplaceWithArray:@[@"9"]] style:UIAlertActionStyleDefault handler:nil];
//    [alertC addAction:act];
//    [self presentViewController:alertC animated:YES completion:nil];
}

//竞价
- (void)doBidding {
    //"status":
    //1,活动状态，0未开始，1开始公示，2等待投标，3开始投标，4等待加密数据上链，5加密数据开始上链，6加密数据正在上链，7加密数据完成上链, 8等待提交密钥，9开始提交密钥，10开始分配，11正在分配，12分配完成，13开始结果上链，14正在结果链，15结果链完成，16等待结果公布，17结果开始公布
//    if ([self.biddingModel.status intValue] == 3) {
//        [self showOrder];
//    }
    
    WEAKSELF;
    if ([self.biddingModel.status integerValue] == 9) {
        [self uploadKey];
    } else {
        if ([self.activityList count] >= [self.biddingModel.maxBidOrderCount integerValue]) {
            [BiChatGlobal showFailWithString:[LLSTR(@"108105") llReplaceWithArray:@[self.biddingModel.maxBidOrderCount]]];
            return;
        }
        WPBiddingDetailViewController *biddingVC = [[WPBiddingDetailViewController alloc]init];
        biddingVC.coefficient = [myTokenInfo objectForKey:@"rewardRate"];
        biddingVC.model = self.biddingModel;
        biddingVC.RefreshBlock = ^{
            [BiChatGlobal ShowActivityIndicator];
            [weakSelf performSelector:@selector(getBiddingList1) withObject:nil afterDelay:3];
        };
        [self.navigationController pushViewController:biddingVC animated:YES];
    }
}
//上传密钥
- (void)uploadKey {
    WPEncryptModel *model = [WPEncryptionObject getEncryptModelByNo:self.biddingModel.batchNo];
    if (model.batchNo.length == 0) {
        [BiChatGlobal showSuccessWithString:LLSTR(@"108102")];
        return;
    }
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:[LLSTR(@"108044") llReplaceWithArray:@[self.biddingModel.amount]] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *act = [UIAlertAction actionWithTitle:LLSTR(@"108014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[WPBaseManager baseManager] getInterface:@"/Chat/Api/submitEncryptKey.do" parameters:@{@"batchNo":self.biddingModel.batchNo,@"encryptKey":model.aesKey,@"encryptId":model.encryptId} success:^(id response) {
            YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"bidding.db"];
            [store createTableWithName:[NSString stringWithFormat:@"b%@",[BiChatGlobal sharedManager].uid]];
            [store putString:@"1" withId:model.batchNo intoTable:[NSString stringWithFormat:@"b%@",[BiChatGlobal sharedManager].uid]];
            [self freshData];
            [BiChatGlobal showSuccessWithString:LLSTR(@"108109")];
        } failure:^(NSError *error) {
            [BiChatGlobal showFailWithString:LLSTR(@"108102")];
        }];
    }];
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:act];
    [alertC addAction:act1];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void) countDown{
    WEAKSELF;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf doDown];
    }];

}

- (void)doDown {
    self.countDownLabel.font = [UIFont fontWithName:@"Monaco" size:30];
    NSTimeInterval interval = [self.biddingModel.bidEndTime doubleValue] / 1000.0;
    if ([self.biddingModel.status intValue] == 9) {
        interval = [self.biddingModel.submitEndTime doubleValue] / 1000.0;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSTimeInterval teimInt = [date timeIntervalSinceDate:[BiChatGlobal getCurrentDate]];
    if (teimInt <= 0) {
        [self freshData];
        self.biddingButton.userInteractionEnabled = NO;
        [self.biddingButton setBackgroundColor:[UIColor lightGrayColor]];
        return;
    }
    long long marginInterval = teimInt;
    long hour = marginInterval / 3600;
    long minute = (marginInterval  % 3600) / 60;
    long second = (marginInterval % 60);
    self.countDownLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
    if (marginInterval == 0) {
        [self.timer invalidate];
        [self freshData];
    }
}

- (void)showAction {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:LLSTR(@"108005") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showSerial];
    }];
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:LLSTR(@"108006") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showHistory];
    }];
    UIAlertAction *act3 = [UIAlertAction actionWithTitle:LLSTR(@"108007") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showSerialRule];
    }];
    UIAlertAction *act4 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertC addAction:act1];
    [alertC addAction:act2];
    [alertC addAction:act3];
    [alertC addAction:act4];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (BOOL)navigationShouldPopOnBackButton {
    [self.timer invalidate];
    return YES;
}

- (void)showSerial {
    PoolAccountViewController *wnd = [PoolAccountViewController new];
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)showHistory {
    WPBiddingHistoryViewController *historyVC = [[WPBiddingHistoryViewController alloc] init];
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (void)showSerialRule {
    //生成链接窗口
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
    wnd.cannotShare = YES;
    wnd.url = [NSString stringWithFormat:@"http://www.imchat.com/pool/pool_%@_%@.html",DIFAPPID,[DFLanguageManager getLanguageName]] ;
    [self.navigationController pushViewController:wnd animated:YES];
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

