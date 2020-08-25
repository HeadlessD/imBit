//
//  WPRedPacketRobViewController.m
//  BiChat
//
//  Created by 张迅 on 2018/5/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketRobViewController.h"
#import "WPRedPacketGetRedPacketPeopleModel.h"
#import "WPRedPacketDetalTableViewCell.h"
#import "MyWalletViewController.h"
#import "WXApi.h"
#import <YYText.h>
#import "PaymentPasswordSetupStep1ViewController.h"
#import "MyWalletAccountViewController.h"

@interface WPRedPacketRobViewController () <UITableViewDelegate,UITableViewDataSource,PaymentPasswordSetDelegate>

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

@implementation WPRedPacketRobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLSTR(@"201013");
    [self getRedpacketInfo];
    self.currentPage = 0;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)popSelf {
    [self.navigationController popViewControllerAnimated:YES];
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
    NSInteger height = 0;
    if ((self.redModel.rewardType == 103 && [self.redModel.subType isEqualToString:@"1"]) ||
        (self.redModel.rewardType == 106 && [self.redModel.subType isEqualToString:@"1"])) {
        height = 20;
    }
    
    self.tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) + 20) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableV];
    self.tableV.backgroundColor = [UIColor clearColor];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.rowHeight = 60;
    self.tableV.mj_footer = [MJRefreshBackGifFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
    self.tableV.mj_footer.hidden = YES;
    BOOL hasGet = NO;
    if ([self.redModel.drawAmount floatValue] > 0) {
        hasGet = YES;
    }
    self.headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, hasGet ? 312 : 232)];
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
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@60);
        make.centerY.equalTo(topIV.mas_bottom).offset(-4);
        make.centerX.equalTo(self.headerV);
    }];
    self.headIV.layer.masksToBounds = YES;
    self.headIV.layer.cornerRadius = 30;
    
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
    
    if (hasGet) {
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
    self.resultBackView = [[UIView alloc]init];
    [self.headerV addSubview:self.resultBackView];
    self.resultBackView.backgroundColor = [UIColor whiteColor];
    [self.resultBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV);
        make.right.equalTo(self.headerV);
        make.bottom.equalTo(self.headerV);
        make.height.equalTo(@(25 + height));
    }];
    self.resultLabel = [[UILabel alloc]init];
    self.resultLabel.numberOfLines = 2;
    [self.headerV addSubview:self.resultLabel];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV).offset(9);
        make.right.equalTo(self.headerV).offset(-9);
        make.bottom.equalTo(self.headerV);
        make.height.equalTo(@(25 + height));
    }];
    self.resultLabel.font = Font(14);
    self.resultLabel.textColor = THEME_GRAY;
    
    UIView *lineV = [[UIView alloc]init];
    [self.headerV addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.headerV);
        make.height.equalTo(@1);
    }];
    lineV.backgroundColor = RGB(0xf4f4f4);
}
//分享
- (void)doShare {
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.description = [NSString stringWithFormat:@"快来抢%@红包喽～",self.redModel.dSymbol];
        message.title = self.redModel.name;
        UIImage *newImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.redModel.imgWechat]]];
        [message setThumbImage:newImage];
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
        WXWebpageObject *ext2 = [WXWebpageObject object];
        ext2.webpageUrl = self.shareUrl;
        message.mediaObject = ext2;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.scene = WXSceneSession;
        req.message = message;
        [WXApi sendReq:req];
    }
}
//零钱包
- (void)toChange {
    //先获取是否已经设置了支付密码
    MyWalletAccountViewController *wnd = [MyWalletAccountViewController new];
    wnd.coinSymbol = self.redModel.symbol;
    wnd.coinDSymbol = self.redModel.dSymbol;
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (UIViewController *)paymentPasswordSetSuccess:(NSInteger)cookie; {
    MyWalletViewController *wnd = [MyWalletViewController new];
    [self.navigationController pushViewController:wnd animated:YES];
    return nil;
}


//获取红包信息
- (void)getRedpacketInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [dict setObject:self.rewardId forKey:@"rewardid"];
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/getRewardDetail.do" parameters:dict success:^(id response) {
        self.redModel = [WPRedpacketRobRedPacketDetailModel mj_objectWithKeyValues:[response objectForKey:@"model"]];
        long hour = [self.redModel.receiveTime integerValue] / 1000 / 3600;
        long minute = ([self.redModel.receiveTime integerValue] / 1000 % 3600) / 60;
        long second = ([self.redModel.receiveTime integerValue] / 1000 % 60);
        
        if ([self.redModel.receiveTime integerValue] / 1000 < 60) {
            self.redModel.receiveTime = [NSString stringWithFormat:@"%ld%@",second,LLSTR(@"101070")];
        } else if ([self.redModel.receiveTime integerValue] / 1000 < 3600) {
            self.redModel.receiveTime = [NSString stringWithFormat:@"%ld%@",(second == 0 ? minute : minute + 1),LLSTR(@"101069")];
        } else {
            if (minute > 0) {
                self.redModel.receiveTime = [NSString stringWithFormat:@"%ld%@%ld%@",hour,LLSTR(@"101068"),minute,LLSTR(@"101069")];
            } else {
                self.redModel.receiveTime = [NSString stringWithFormat:@"%ld%@",hour,LLSTR(@"101068")];
            }
        }
        if (!self.redModel.receiveTime) {
            self.redModel.receiveTime = self.redModel.diffTime;
        }
        [self createUI];
        [self resetWithModel:self.redModel];
        [self loadMore];
        if ([self.redModel.rewardStatus isEqualToString:@"4"]) {
            [self showOverTimeLabel];
        } else if (self.redModel.isOwner) {
            [self showTipLabel];
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showToastWithError:error];
    }];
}
//显示超时label
- (void)showOverTimeLabel {
    YYLabel *label = [[YYLabel alloc]init];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.view).offset(-15);
    }];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:LLSTR(@"101456")];
    [attStr addAttribute:NSFontAttributeName value:Font(14) range:NSMakeRange(0, LLSTR(@"101456").length)];
    attStr.yy_alignment = NSTextAlignmentCenter;
//    [attStr addAttribute:NSForegroundColorAttributeName value:THEME_GRAY range:NSMakeRange(0, 12)];
//    [attStr yy_setTextHighlightRange:NSMakeRange(11, 3) color:LightBlue backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//        [self toChange];
//    }];
    
    label.attributedText = attStr;
    self.tableV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) - 45);
//    if (self.redModel.rewardType == 101 || self.redModel.rewardType == 104) {
//        if (self.redModel.isOwner) {
//            self.resultLabel.text = [NSString stringWithFormat:@"1 份红包 %@ %@，该红包已过期",self.redModel.amount,self.redModel.dSymbol];
//        } else {
//
//        }
//    }
    
    NSString *showTitle = nil;
    if (self.redModel.rewardType == 101 || self.redModel.rewardType == 104) {
        showTitle = [LLSTR(@"101541") llReplaceWithArray:@[[self.redModel.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],self.redModel.dSymbol]];
    } else if (self.redModel.rewardType == 103 && [self.redModel.subType isEqualToString:@"1"]) {
        showTitle = [LLSTR(@"101550") llReplaceWithArray:@[[self.redModel.residueCount toPrise],[self.redModel.count toPrise],[self.redModel.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[self.redModel.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],self.redModel.dSymbol,[NSString stringWithFormat:@"%d",(int)([self.redModel.rate floatValue] * 100)]]];
    } else if (self.redModel.rewardType == 106 && [self.redModel.subType isEqualToString:@"1"]) {
        showTitle = [LLSTR(@"101550") llReplaceWithArray:@[[self.redModel.residueCount toPrise],[self.redModel.count toPrise],[self.redModel.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[self.redModel.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],self.redModel.dSymbol,[NSString stringWithFormat:@"%d",(int)([self.redModel.rate floatValue] * 100)]]];
    } else {
        if (self.redModel.isOwner) {
            showTitle = [LLSTR(@"101547") llReplaceWithArray:@[[self.redModel.residueCount toPrise],[self.redModel.count toPrise],[self.redModel.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[self.redModel.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],self.redModel.dSymbol]];
        } else {
            showTitle = [LLSTR(@"101547") llReplaceWithArray:@[[self.redModel.residueCount toPrise],[self.redModel.count toPrise],[self.redModel.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[self.redModel.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],self.redModel.dSymbol]];
        }
    }
    CGFloat height = [showTitle boundingRectWithSize:CGSizeMake(ScreenWidth - 30, 40) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.resultLabel.font} context:nil].size.height;
    self.resultLabel.text = showTitle;
    
    [self.resultBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV);
        make.right.equalTo(self.headerV);
        make.bottom.equalTo(self.headerV);
        make.height.equalTo(@(15 + height));
    }];
    [self.resultLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV).offset(9);
        make.right.equalTo(self.headerV).offset(-9);
        make.bottom.equalTo(self.headerV);
        make.height.equalTo(@(15 + height));
    }];
    
}

- (void)showTipLabel {
    YYLabel *label = [[YYLabel alloc]init];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.view).offset(-15);
    }];
    NSString *string = LLSTR(@"101456");
    if (self.redModel.rewardType != 102 && self.redModel.rewardType != 101) {
        string = LLSTR(@"101456");
    }
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:string];
    [attStr addAttribute:NSFontAttributeName value:Font(14) range:NSMakeRange(0, string.length)];
    attStr.yy_alignment = NSTextAlignmentCenter;
    [attStr addAttribute:NSForegroundColorAttributeName value:THEME_GRAY range:NSMakeRange(0, string.length - LLSTR(@"101456").length)];
//    [attStr yy_setTextHighlightRange:NSMakeRange(string.length - LLSTR(@"101456").length, LLSTR(@"101456").length) color:LightBlue backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//        [self toChange];
//    }];
    label.attributedText = attStr;
    self.tableV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) - 45);
    
}

//根据返回的数据重置UI
- (void)resetWithModel:(WPRedpacketRobRedPacketDetailModel *)model {
    if (self.redModel.rewardType != 102 || self.redModel.rewardType != 101) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        if ((self.redModel.isOwner || model.isShare) && [model.rewardStatus isEqualToString:@"0"]) {
            if (self.shareUrl.length == 0) {
                self.navigationItem.rightBarButtonItem = nil;
            } else {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(doShare)];
            }
        }
    }
    [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,model.avatar] title:model.nickname size:CGSizeMake(60, 60) placeHolde:nil color:RGB(0xddbc87) textColor:[UIColor blackColor]];
    self.nameLabel.text = model.nickname;
    self.titleLabel.text = model.name;
    self.priceLabel.text = [model.drawAmount accuracyCheckWithFormatterString:model.bit auotCheck:YES];
    if (model.coinName.count > 1) {
        self.coinLabel.text = model.dSymbol;
    }
    NSString *showTitle = nil;
    if (model.rewardType == 101 || model.rewardType == 104) {
        if (model.isOwner) {
            showTitle = [LLSTR(@"101542") llReplaceWithArray:@[[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol]];
            if ([model.rewardStatus isEqualToString:@"3"]) {
                showTitle = [LLSTR(@"101544") llReplaceWithArray:@[[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol]];
            }
        } else {
            showTitle = [LLSTR(@"101543") llReplaceWithArray:@[[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol]];
            if ([model.rewardStatus isEqualToString:@"3"]) {
                showTitle = [LLSTR(@"101545") llReplaceWithArray:@[[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol]];
            }
        }
    } else if (self.redModel.rewardType == 103 && [self.redModel.subType isEqualToString:@"1"]) {
        showTitle = [LLSTR(@"101549") llReplaceWithArray:@[[model.residueCount toPrise],[model.count toPrise],[model.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol,[NSString stringWithFormat:@"%d",(int)([self.redModel.rate floatValue] * 100)]]];
        if ([model.rewardStatus isEqualToString:@"3"] || [model.rewardStatus isEqualToString:@"2"]) {
            showTitle = [LLSTR(@"101551") llReplaceWithArray:@[
                         [model.residueCount toPrise],
                         [model.count toPrise],
                         [model.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],
                         [model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],
                         model.dSymbol,
                         [NSString stringWithFormat:@"%d",(int)([self.redModel.rate floatValue] * 100)],
                         model.receiveTime]];
        }
    } else if (self.redModel.rewardType == 106 && [self.redModel.subType isEqualToString:@"1"]) {
        showTitle = [LLSTR(@"101549") llReplaceWithArray:@[[model.residueCount toPrise],[model.count toPrise],[model.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol,[NSString stringWithFormat:@"%d",(int)([self.redModel.rate floatValue] * 100)]]];
        if ([model.rewardStatus isEqualToString:@"3"] || [model.rewardStatus isEqualToString:@"2"]) {
            showTitle = [LLSTR(@"101551") llReplaceWithArray:@[
                         [model.residueCount toPrise],
                         [model.count toPrise],
                         [model.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],
                         [model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],
                         model.dSymbol,
                         [NSString stringWithFormat:@"%d",(int)([self.redModel.rate floatValue] * 100)],
                         model.receiveTime]];
        }
    }
    else {
        if (model.isOwner) {
            showTitle = [LLSTR(@"101546") llReplaceWithArray:@[[model.residueCount toPrise],[model.count toPrise],[model.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol]];
            if ([model.rewardStatus isEqualToString:@"3"] || [model.rewardStatus isEqualToString:@"2"]) {
                showTitle = [LLSTR(@"101548") llReplaceWithArray:@[[model.residueCount toPrise],[model.count toPrise],[model.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol,model.receiveTime]];
            }
        } else {
            showTitle = [LLSTR(@"101546") llReplaceWithArray:@[[model.residueCount toPrise],[model.count toPrise],[model.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol]];
            if ([model.rewardStatus isEqualToString:@"3"] || [model.rewardStatus isEqualToString:@"2"]) {
                showTitle = [LLSTR(@"101548") llReplaceWithArray:@[[model.residueCount toPrise],[model.count toPrise],[model.residueAmount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],[model.amount accuracyCheckWithFormatterString:self.redModel.bit auotCheck:YES],model.dSymbol,model.receiveTime]];
            }
        }
    }
    CGFloat height = [showTitle boundingRectWithSize:CGSizeMake(ScreenWidth - 30, 40) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.resultLabel.font} context:nil].size.height;
    self.resultLabel.text = showTitle;
    
    [self.resultBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV);
        make.right.equalTo(self.headerV);
        make.bottom.equalTo(self.headerV);
        make.height.equalTo(@(15 + height));
    }];
    [self.resultLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerV).offset(9);
        make.right.equalTo(self.headerV).offset(-9);
        make.bottom.equalTo(self.headerV);
        make.height.equalTo(@(15 + height));
    }];
}

- (void)loadMore {
    self.currentPage ++;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
    [dict setObject:[NSString stringWithFormat:@"%@",self.redModel.rewardid ? self.redModel.rewardid : self.rewardId] forKey:@"rewardid"];
    [dict setObject:[NSString stringWithFormat:@"%ld",self.currentPage] forKey:@"currPage"];
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/getReceiveList.do" parameters:dict success:^(id response) {
        if (!self.listArray) {
            self.listArray = [NSMutableArray array];
        }
        [self.listArray addObjectsFromArray:[WPRedPacketGetRedPacketPeopleModel mj_objectArrayWithKeyValuesArray:[response objectForKey:@"data"]]];
        [self.tableV reloadData];
        if ([[response objectForKey:@"total"] integerValue] > self.listArray.count) {
            [self.tableV.mj_footer endRefreshing];
            self.tableV.mj_footer.hidden = NO;
        } else {
            [self.tableV.mj_footer endRefreshingWithNoMoreData];
            self.tableV.mj_footer.hidden = YES;
        }
        [self.tableV reloadData];
        
    } failure:^(NSError *error) {
        self.currentPage --;
        self.tableV.mj_footer.hidden = NO;
        [BiChatGlobal showToastWithError:error];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WPRedPacketDetalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WPRedPacketDetalTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell fillData:self.listArray[indexPath.row] withBit:self.redModel.bit];
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

@end
