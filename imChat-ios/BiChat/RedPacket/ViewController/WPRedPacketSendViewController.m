//
//  WPRedPacketSendViewController.m
//  BiChat
//
//  Created by 张迅 on 2018/5/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketSendViewController.h"
#import "WPRedPacketSendView.h"
#import <YYText.h>
#import <IQKeyboardManager.h>
#import "WPRedPacketSendCoinSelectView.h"
#import "WPRedPacketSendReceiveModel.h"
#import "WPRedPacketSendCoinModel.h"
#import "WPRedPacketPayWorkdInputView.h"
#import "PaymentPasswordSetupStep1ViewController.h"
#import <IQKeyboardManager.h>
#import "WXApi.h"
#import "BiChatDataModule.h"
#import "MyWalletViewController.h"
#import "GroupMemberSelectorViewController.h"
#import "MessageHelper.h"
#import "ChatViewController.h"
#import "WPProductInputView.h"
@interface WPRedPacketSendViewController ()<UITextViewDelegate,UITextFieldDelegate,PaymentPasswordSetDelegate,CoinSelectDelegate,GroupMemberSelectDelegate>
//币种
@property (nonatomic,strong)WPRedPacketSendView *kindView;
//所选择的币的名称
@property (nonatomic,strong)UILabel *coinTL;
//所选择的币的图标
@property (nonatomic,strong)UIImageView *coinIV;
//币总数、单个数量
@property (nonatomic,strong)WPRedPacketSendView *priceView;
//发红包针对的人的View
@property (nonatomic,strong)WPRedPacketSendView *peopleView;
//个数
@property (nonatomic,strong)WPRedPacketSendView *countView;
@property (nonatomic,strong)UITextView *contentTV;
//总币数
@property (nonatomic,strong)UILabel *priceLabel;
//币类型
@property (nonatomic,strong)UILabel *coinLabel;
@property (nonatomic,strong)YYLabel *typeLabel;
@property (nonatomic,strong)UIButton *confirmBtn;
@property (nonatomic,strong)UILabel *peopleCountLabel;
//币选择view
@property (nonatomic,strong)WPRedPacketSendCoinSelectView *sendV;
//是否普通红包
@property (nonatomic,assign)BOOL isNormal;
//是否编辑
@property (nonatomic,assign)BOOL hasEdit;
//后台获取的发红包model
@property (nonatomic,strong)WPRedPacketSendReceiveModel *receiveModel;
//选择的币的model
@property (nonatomic,strong)WPRedPacketSendCoinModel *selModel;
//创建的红包信息
@property (nonatomic,strong)WPRedPacketSendReceiveModel *createModel;
//输入密码view
@property (nonatomic,strong)WPProductInputView *passView;
//提示label
@property (nonatomic,strong)UILabel *watchTipLabel;
//提示label
@property (nonatomic,strong)UILabel *tipLabel;
//是否允许转发，默认允许
@property (nonatomic,assign)BOOL allowShare;
//是否允许到红包流
@property (nonatomic,assign)BOOL allowFeed;
//分享红包类型，0:定向、1:群友、2:红包流
@property (nonatomic, assign) NSInteger subType;
//群友转发子类型
@property (nonatomic,strong)UIView *transmitView;
//奖励个数view
@property (nonatomic,strong)WPRedPacketSendView *awardView;
//滚动条
@property (nonatomic,strong)UISlider *slider;
//邀请者
@property (nonatomic,strong)UILabel *inviteLabel;
//被邀请者
@property (nonatomic,strong)UILabel *invitedLabel;
//比例
@property (nonatomic,strong)NSString *rate;
//剩余币个数
@property (nonatomic,strong)UILabel *totalPricelabel;

@property (nonatomic,strong)UIView *containerV;
//选择的人
@property (nonatomic,strong)NSDictionary *selectedPeople;
@end

#define kMaxLength 60
#define kBtnTag 99
#define kTransmitTag 999

@implementation WPRedPacketSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dict = [[BiChatDataModule sharedDataModule]getGroupProperty:self.peerId];
    if ([[dict objectForKey:@"privateGroup"] boolValue]) {
        self.isPrivate = YES;
    } else {
        self.isPrivate = NO;
    }
    self.rate = @"0.5";
    if (self.isInvite) {
        self.allowShare = YES;
        self.allowFeed = YES;
    } else {
        self.allowShare = NO;
        self.allowFeed = NO;
    }
    if (!self.canPop) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101002") style:UIBarButtonItemStylePlain target:self action:@selector(doCancel)];
    }
    self.title = LLSTR(@"101451");
    if (self.isInvite) {
        self.title = LLSTR(@"201014");
    }
    
    self.view.backgroundColor = RGB(0xf5f5f5);
    [self createUI];
    [self resetButtonStatus];
    [self getRedpacketInfo];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].toolbarBarTintColor = RGB(0xd2d5db);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)keyboardWillShow:(NSNotification *)noti{
    if (!self.passView) {
        return;
    }
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.16 animations:^{
        [self.passView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-keyboardHeight);
        }];
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti{
    if (self.passView) {
        [self.passView removeFromSuperview];
        self.passView = nil;
    }
}

//获取发红包信息
- (void)getRedpacketInfo {
    if (self.peerId.length > 0 && self.isGroup) {
        [NetworkModule getGroupProperty:self.peerId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success) {
                if (!self.receiveModel) {
                    self.receiveModel = [[WPRedPacketSendReceiveModel alloc]init];
                }
                self.receiveModel.total = [NSString stringWithFormat:@"%ld",[[data objectForKey:@"joinedGroupUserCount"] integerValue]];
                if (self.isGroup || (self.peerId.length == 0 && !self.isGroup)) {
                    if (self.isInvite) {
                        self.peopleCountLabel.text = [NSString stringWithFormat:@"%@ %@",[LLSTR(@"101468") llReplaceWithArray:@[self.receiveModel.total]],LLSTR(@"101470")];
                    } else {
                        self.peopleCountLabel.text = [LLSTR(@"101468") llReplaceWithArray:@[self.receiveModel.total]];
                    }
                }
            }
        }];
    }
}
//    self.receiveModel = [[WPRedPacketSendReceiveModel alloc] init];
//    if ([[[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"asset"] allKeys].count == 0) {
//        [NetworkModule getWallet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//            [BiChatGlobal sharedManager].dict4WalletInfo = data;
//            NSMutableArray *listArray = [NSMutableArray array];
//            NSDictionary *keyDic = [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"asset"];
//            NSArray *assetArray = [keyDic allKeys];
//            for (int i = 0; i < assetArray.count; i++) {
//                NSString *key = assetArray[i];
//                WPRedPacketSendCoinModel *model = [[WPRedPacketSendCoinModel alloc]init];
//                for (NSDictionary *dict in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"]) {
//                    if ([[dict objectForKey:@"symbol"] isEqualToString:key]) {
//                        model.symbol = [dict objectForKey:@"symbol"];
//                        model.bit = [dict objectForKey:@"bit"];
//                        model.amount = [[NSString stringWithFormat:@"%@",[keyDic objectForKey:key]] accuracyCheckWithFormatterString:model.bit];
//                        model.code = [dict objectForKey:@"code"];
//                        model.imgWhite = [dict objectForKey:@"imgWhite"];
//                        model.imgWechat = [dict objectForKey:@"imgWechat"];
//                        model.imgGold = [dict objectForKey:@"imgGold"];
//                        model.sort = [dict objectForKey:@"sort"];
//                        model.dSymbol = [dict objectForKey:@"dSymbol"];
//                        model.imgColor = [dict objectForKey:@"imgColor"];
//                        model.name = [dict objectForKey:@"name"];
//                    }
//                }
//                if (model.symbol.length > 0 && [model.amount doubleValue] > 0.0) {
//                    [listArray addObject:model];
//                }
//            }
//            [listArray sortUsingComparator:^NSComparisonResult(WPRedPacketSendCoinModel *obj1, WPRedPacketSendCoinModel *obj2) {
//                if ([obj1.sort integerValue] < [obj2.sort integerValue]) {
//                    return NSOrderedAscending;
//                }
//                return NSOrderedDescending;
//            }];
//            self.receiveModel.list = listArray;
//        }];
//    } else {
//        NSMutableArray *listArray = [NSMutableArray array];
//        NSDictionary *keyDic = [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"asset"];
//        NSArray *assetArray = [keyDic allKeys];
//        for (int i = 0; i < assetArray.count; i++) {
//            NSString *key = assetArray[i];
//            WPRedPacketSendCoinModel *model = [[WPRedPacketSendCoinModel alloc]init];
//            for (NSDictionary *dict in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"]) {
//                if ([[dict objectForKey:@"symbol"] isEqualToString:key]) {
//                    model.symbol = [dict objectForKey:@"symbol"];
//                    model.bit = [dict objectForKey:@"bit"];
//                    model.amount = [[NSString stringWithFormat:@"%@",[keyDic objectForKey:key]] accuracyCheckWithFormatterString:model.bit];
//                    model.code = [dict objectForKey:@"code"];
//                    model.imgWhite = [dict objectForKey:@"imgWhite"];
//                    model.imgWechat = [dict objectForKey:@"imgWechat"];
//                    model.imgGold = [dict objectForKey:@"imgGold"];
//                    model.sort = [dict objectForKey:@"sort"];
//                    model.dSymbol = [dict objectForKey:@"dSymbol"];
//                    model.imgColor = [dict objectForKey:@"imgColor"];
//                    model.name = [dict objectForKey:@"name"];
//                }
//            }
//            if (model.symbol.length > 0 && [model.amount doubleValue] > 0.0) {
//                [listArray addObject:model];
//            }
//        }
//        [listArray sortUsingComparator:^NSComparisonResult(WPRedPacketSendCoinModel *obj1, WPRedPacketSendCoinModel *obj2) {
//            if ([obj1.sort integerValue] < [obj2.sort integerValue]) {
//                return NSOrderedAscending;
//            }
//            return NSOrderedDescending;
//        }];
//        self.receiveModel.list = listArray;
//    }
//
//
//
//
//}
//取消
- (void)doCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createUI {
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64))];
    [self.view addSubview:sv];
    
    self.containerV = [[UIView alloc]init];
    [sv addSubview:self.containerV];
    
    [self.containerV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sv);
        make.width.equalTo(sv);
    }];
    
    if (self.isInvite) {
        NSArray *titleArray = @[LLSTR(@"101481"),LLSTR(@"101482"),LLSTR(@"101483")];
        for (int i = 0; i < titleArray.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.containerV addSubview:button];
            button.titleLabel.numberOfLines = 2;
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@((ScreenWidth - 16) / 3 - 5));
                make.height.equalTo(@50);
                make.top.equalTo(self.containerV).offset(5);
                if (i == 0) {
                    make.left.equalTo(self.containerV).offset(8);
                } else if (i == 1) {
                    make.centerX.equalTo(self.containerV);
                } else {
                    make.right.equalTo(self.containerV).offset(-8);
                }
            }];
            
            if (isIPhone5) {
                button.titleLabel.font = Font(12);
            } else {
                button.titleLabel.font = Font(14);
            }
            [button setTitle:titleArray[i] forState:UIControlStateNormal];
            [button setImage:Image(@"CellNotSelected") forState:UIControlStateNormal];
            [button setImage:Image(@"CellBlueSelected") forState:UIControlStateSelected];
            [button setTitleColor:THEME_GRAY forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            button.tag = kBtnTag + i;
            if (i == 0) {
                button.selected = YES;
            }
            [button addTarget:self action:@selector(typeChange:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if (!self.isInvite && self.isGroup) {
        self.peopleView = [[WPRedPacketSendView alloc]init];
        [self.containerV addSubview:self.peopleView];
        [self.peopleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerV).offset(15);
            make.right.equalTo(self.containerV).offset(-15);
            if (self.isInvite) {
                make.top.equalTo(self.containerV).offset(60);
            } else {
                make.top.equalTo(self.containerV).offset(20);
            }
            make.height.equalTo(@50);
        }];
        self.peopleView.subTF.text = LLSTR(@"101458");
        self.peopleView.subTF.textAlignment = NSTextAlignmentLeft;
        UIImageView *arrowIV = [[UIImageView alloc]init];
        [self.peopleView addSubview:arrowIV];
        [arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.peopleView);
            make.right.equalTo(self.peopleView).offset(-15);
            make.width.equalTo(@15);
        }];
        arrowIV.image = Image(@"arrow_right");
        arrowIV.contentMode = UIViewContentModeCenter;
        [self.peopleView.subTF mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.peopleView).offset(-30);
            make.left.equalTo(self.peopleView).offset(10);
        }];
        [self.peopleView addTarget:self selector:@selector(peopleChoose)];
    }
    
    self.kindView = [[WPRedPacketSendView alloc]init];
    [self.containerV addSubview:self.kindView];
    [self.kindView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerV).offset(15);
        make.right.equalTo(self.containerV).offset(-15);
        if (self.isInvite) {
            make.top.equalTo(self.containerV).offset(60);
        } else {
            if (self.peopleView) {
                make.top.equalTo(self.peopleView.mas_bottom).offset(20);
            } else {
                make.top.equalTo(self.containerV).offset(20);
            }
        }
        make.height.equalTo(@50);
    }];
    self.kindView.titleTF.text = LLSTR(@"101452");
    [self.kindView addTarget:self selector:@selector(coinChoose)];
    
    UIImageView *arrowIV = [[UIImageView alloc]init];
    [self.kindView addSubview:arrowIV];
    [arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.kindView);
        make.right.equalTo(self.kindView).offset(-15);
        make.width.equalTo(@15);
    }];
    arrowIV.image = Image(@"arrow_right");
    arrowIV.contentMode = UIViewContentModeCenter;
    
    self.coinTL = [[UILabel alloc]init];
    [self.kindView addSubview:self.coinTL];
    [self.coinTL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(arrowIV.mas_left);
        make.width.equalTo(@1);
        make.top.bottom.equalTo(self.kindView);
    }];
    self.coinTL.textAlignment = NSTextAlignmentCenter;
    self.coinTL.font = Font(16);
    self.coinTL.hidden = YES;
    
    self.coinIV = [[UIImageView alloc]init];
    [self.kindView addSubview:self.coinIV];
    [self.coinIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.centerY.equalTo(self.kindView);
        make.right.equalTo(self.coinTL.mas_left);
    }];
    self.coinIV.layer.cornerRadius = 20;
    self.coinIV.layer.masksToBounds = YES;
    self.coinIV.contentMode = UIViewContentModeScaleAspectFit;
    self.coinIV.hidden = YES;
    
    self.priceView = [[WPRedPacketSendView alloc]init];
    [self.containerV addSubview:self.priceView];
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerV).offset(15);
        make.right.equalTo(self.containerV).offset(-15);
        make.top.equalTo(self.kindView.mas_bottom).offset(10);
        make.height.equalTo(@50);
    }];
    self.priceView.titleTF.text = LLSTR(@"101461");
    self.priceView.subTF.placeholder = @"0.00";
    self.priceView.subTF.delegate = self;
    self.priceView.subTF.userInteractionEnabled = YES;
    [self.priceView.subTF mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.priceView).offset(-10);
    }];
    if (!self.isGroup && self.peerId.length > 0) {
        self.priceView.titleTF.text = LLSTR(@"103116");
    }
    self.priceView.subTF.keyboardType = UIKeyboardTypeDecimalPad;
    if (self.isGroup || (!self.isGroup && self.peerId.length == 0)) {
        
        //配置“拼”
        UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 22)];
        leftView.backgroundColor = [UIColor clearColor];
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 20, 20)];
        leftLabel.backgroundColor = RGB(0xf9bc51);
        leftLabel.layer.cornerRadius = 3;
        leftLabel.layer.masksToBounds = YES;
        leftLabel.textColor = [UIColor whiteColor];
        leftLabel.font = Font(12);
        leftLabel.text = @"拼";
        leftLabel.textAlignment = NSTextAlignmentCenter;
        [leftView addSubview:leftLabel];
        self.priceView.titleTF.leftView = leftView;
        self.priceView.titleTF.leftViewMode = UITextFieldViewModeAlways;
        
        self.typeLabel = [[YYLabel alloc]init];
        [self.containerV addSubview:self.typeLabel];
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerV).offset(25);
            make.top.equalTo(self.priceView.mas_bottom);
            make.height.equalTo(@25);
            make.right.equalTo(self.containerV).offset(-30);
        }];
        NSString *redString = [NSString stringWithFormat:@"%@，%@",LLSTR(@"101462"),LLSTR(@"101465")];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:redString];
        [attStr addAttribute:NSForegroundColorAttributeName value:THEME_GRAY range:NSMakeRange(0, redString.length)];
        [attStr addAttribute:NSFontAttributeName value:Font(14) range:NSMakeRange(0, redString.length)];
        [attStr yy_setColor:RGB(0x2f93fa) range:NSMakeRange(LLSTR(@"101462").length+1, LLSTR(@"101465").length)];
        YYTextHighlight *highlight = [YYTextHighlight new];
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            [self kindChoose];
        };
        [attStr yy_setTextHighlight:highlight range:NSMakeRange(LLSTR(@"101462").length+1, LLSTR(@"101465").length)];
        self.typeLabel.attributedText = attStr;
        
        
        self.totalPricelabel = [[UILabel alloc] init];
        [self.containerV addSubview:self.totalPricelabel];
        [self.totalPricelabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.priceView.mas_bottom);
            make.height.equalTo(@25);
            make.right.equalTo(self.priceView.subTF);
            make.width.equalTo(@150);
        }];
        self.totalPricelabel.font = Font(14);
        self.totalPricelabel.textColor = THEME_GRAY;
        self.totalPricelabel.textAlignment = NSTextAlignmentRight;
        
        self.countView = [[WPRedPacketSendView alloc]init];
        [self.containerV addSubview:self.countView];
        [self.countView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerV).offset(15);
            make.right.equalTo(self.containerV).offset(-15);
            make.top.equalTo(self.typeLabel.mas_bottom).offset(9);
            make.height.equalTo(@50);
        }];
        self.countView.titleTF.text = LLSTR(@"101467");
        self.countView.subTF.placeholder = LLSTR(@"101471");
        self.countView.subTF.userInteractionEnabled = YES;
        self.countView.subTF.keyboardType = UIKeyboardTypeNumberPad;
        self.countView.subTF.delegate = self;
        
        self.peopleCountLabel = [[UILabel alloc]init];
        [self.containerV addSubview:self.peopleCountLabel];
        self.peopleCountLabel.textColor = THEME_GRAY;
        self.peopleCountLabel.font = Font(14);
        [self.peopleCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerV).offset(25);
            make.top.equalTo(self.countView.mas_bottom);
            make.height.equalTo(@25);
            make.right.equalTo(self.containerV).offset(-30);
        }];
    }
    
    self.contentTV = [[UITextView alloc]init];
    [self.containerV addSubview:self.contentTV];
    [self.contentTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.priceView);
        if (self.isGroup || (!self.isGroup && self.peerId.length == 0)) {
            make.top.equalTo(self.peopleCountLabel.mas_bottom).offset(9);
        } else {
            make.top.equalTo(self.priceView.mas_bottom).offset(10);
        }
        make.height.equalTo(@65);
    }];
    self.contentTV.textColor = THEME_GRAY;
    self.contentTV.layer.borderColor = RGB(0xe5e5e5).CGColor;
    self.contentTV.layer.cornerRadius = 5;
    self.contentTV.layer.masksToBounds = YES;
    self.contentTV.text = LLSTR(@"101454");
    self.contentTV.textContainerInset = UIEdgeInsetsMake(14, 5, 10, 10);
    self.contentTV.delegate = self;
    self.contentTV.font = Font(16);
    
    self.priceLabel = [[UILabel alloc]init];
    [self.containerV addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.containerV);
        make.top.equalTo(self.contentTV.mas_bottom).offset(43);
        make.height.equalTo(@40);
    }];
    self.priceLabel.font = Font(30);
    self.priceLabel.textAlignment = NSTextAlignmentCenter;
    self.priceLabel.text = @"0.00";
    
    self.coinLabel = [[UILabel alloc]init];
    [self.containerV addSubview:self.coinLabel];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.containerV);
        make.top.equalTo(self.priceLabel.mas_bottom).offset(-3);
        make.height.equalTo(@15);
    }];
    self.coinLabel.font = Font(14);
    self.coinLabel.textAlignment = NSTextAlignmentCenter;
    
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.containerV addSubview:self.confirmBtn];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coinLabel.mas_bottom).offset(20);
        make.left.equalTo(self.containerV).offset(15);
        make.right.equalTo(self.containerV).offset(-15);
        make.height.equalTo(@45);
    }];
    [self.confirmBtn setBackgroundImage:[UIImage imageWithColor:RGB(0x2f93fa) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    self.confirmBtn.layer.cornerRadius = 5;
    self.confirmBtn.layer.masksToBounds = YES;
    [self.confirmBtn setTitle:LLSTR(@"101455") forState:UIControlStateNormal];
    self.confirmBtn.alpha = 0.5;
    [self.confirmBtn addTarget:self action:@selector(showPassView) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isInvite) {
        self.watchTipLabel = [[UILabel alloc]init];
        [self.containerV addSubview:self.watchTipLabel];
        [self.watchTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.containerV);
            make.height.equalTo(@20);
            make.top.equalTo(self.confirmBtn.mas_bottom).offset(10);
        }];
        self.watchTipLabel.font = Font(14);
        self.watchTipLabel.textColor = THEME_GRAY;
        self.watchTipLabel.textAlignment = NSTextAlignmentCenter;
        self.watchTipLabel.text = LLSTR(@"101472");
    }
    
    self.tipLabel = [[UILabel alloc]init];
    [self.containerV addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.containerV);
        make.height.equalTo(@20);
        if (self.isInvite) {
            make.top.equalTo(self.watchTipLabel.mas_bottom).offset(5);
        } else {
            make.top.equalTo(self.confirmBtn.mas_bottom).offset(10);
        }
    }];
    self.tipLabel.font = Font(14);
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.text = LLSTR(@"101456");
    self.tipLabel.textColor = THEME_GRAY;
    
    [self.containerV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.tipLabel);
    }];
}
//选择人
- (void)peopleChoose {
    [self.view endEditing:YES];
    GroupMemberSelectorViewController *groupSVC = [[GroupMemberSelectorViewController alloc]init];
    groupSVC.groupId = self.peerId;
    groupSVC.showAll = YES;
    groupSVC.hideMe = YES;
    groupSVC.showMemo = YES;
    groupSVC.groupProperty = [[BiChatDataModule sharedDataModule] getGroupProperty:self.peerId];
    [self.navigationController pushViewController:groupSVC animated:YES];
    groupSVC.delegate = self;
}

//选择人代理
- (void)memberSelected:(NSArray *)member withCookie:(NSInteger)cookie {
    [self.navigationController popViewControllerAnimated:YES];
    self.selectedPeople = member[0];
    if ([[self.selectedPeople objectForKey:@"uid"] isEqualToString:ALLMEMBER_UID]) {
        self.selectedPeople = nil;
        self.peopleView.subTF.text = LLSTR(@"101458");
        self.countView.userInteractionEnabled = YES;
    }  else {
        self.peopleView.subTF.text = [LLSTR(@"101459") llReplaceWithArray:@[[self.selectedPeople objectForKey:@"groupNickName"] ? [self.selectedPeople objectForKey:@"groupNickName"] : [self.selectedPeople objectForKey:@"nickName"]]];
        self.countView.userInteractionEnabled = NO;
        self.countView.subTF.text =  @"1";
        [self resetButtonStatus];
    }
    
}
- (void)memberSelectCancel:(NSInteger)cookie {
    [self.navigationController popViewControllerAnimated:YES];
}
//改变红包状态
- (void)typeChange:(UIButton *)btn {
    if (btn.selected) {
        return;
    }
    if (btn.tag == kBtnTag + 1) {
        [self showTransmit];
        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.containerV);
            make.top.equalTo(self.contentTV.mas_bottom).offset(13);
            make.height.equalTo(@40);
        }];
        if (self.receiveModel.total.length > 0) {
            self.peopleCountLabel.text = [NSString stringWithFormat:@"%@ %@",[LLSTR(@"101468") llReplaceWithArray:@[self.receiveModel.total]],LLSTR(@"101469")];
        } else {
            self.peopleCountLabel.text = LLSTR(@"101469");
        }
    } else {
        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.containerV);
            make.top.equalTo(self.contentTV.mas_bottom).offset(43);
            make.height.equalTo(@40);
        }];
        [self hideTransmit];
        if (self.receiveModel.total.length > 0) {
            self.peopleCountLabel.text = [NSString stringWithFormat:@"%@ %@",[LLSTR(@"101468") llReplaceWithArray:@[self.receiveModel.total]],LLSTR(@"101470")];
        } else {
            self.peopleCountLabel.text = LLSTR(@"101470");
        }
        
        
        
        
        
        if (btn.tag == kBtnTag + 2) {
//            [self resetInformation];
            if (self.receiveModel.total.length > 0) {
                self.peopleCountLabel.text = [NSString stringWithFormat:@"%@ %@",[LLSTR(@"101468") llReplaceWithArray:@[self.receiveModel.total]],LLSTR(@"101470")];
            } else {
                self.peopleCountLabel.text = LLSTR(@"101470");
            }
        }
    }
    
    for (UIButton *button in btn.superview.subviews) {
        if ([button isKindOfClass:[UIButton class]] && (btn.tag == kBtnTag || btn.tag == kBtnTag + 1 || btn.tag == kBtnTag + 2)) {
            button.selected = NO;
        }
    }
    btn.selected = YES;
    self.subType = btn.tag - kBtnTag;
    if (self.subType == 1) {
        [self resetPrice];
    }
    [self resetPrice];
}
//显示群友转发比例设置
- (void)showTransmit {
    if (!self.transmitView) {
        self.transmitView = [[UIView alloc]init];
        [self.containerV addSubview:self.transmitView];
        [self.transmitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.containerV);
            make.height.equalTo(@40);
            make.top.equalTo(self.peopleCountLabel.mas_bottom).offset(9);
        }];
        CGFloat titleWidth = 60;
        CGFloat margin = 15;
        
        self.inviteLabel = [[UILabel alloc]init];
        [self.transmitView addSubview:self.inviteLabel];
        [self.inviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.transmitView).offset(margin);
            make.top.bottom.equalTo(self.transmitView);
            make.width.equalTo(@(titleWidth));
        }];
        self.inviteLabel.text = [NSString stringWithFormat:@"%@\n50%@",LLSTR(@"101484"),@"%"];
        
//        [LLSTR(@"101484"),@"50%"]];
        self.inviteLabel.textAlignment = NSTextAlignmentCenter;
        self.inviteLabel.numberOfLines = 2;
        self.inviteLabel.font = Font(14);
        
        self.invitedLabel = [[UILabel alloc]init];
        [self.transmitView addSubview:self.invitedLabel];
        [self.invitedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.transmitView).offset(-margin);
            make.top.bottom.equalTo(self.transmitView);
            make.width.equalTo(@(titleWidth));
        }];
        self.invitedLabel.text = [NSString stringWithFormat:@"%@\n50%@",LLSTR(@"101485"),@"%"];
        self.invitedLabel.textAlignment = NSTextAlignmentCenter;
        self.invitedLabel.numberOfLines = 2;
        self.invitedLabel.font = Font(14);
        
        self.slider = [[UISlider alloc]initWithFrame:CGRectMake(titleWidth + margin, 0, ScreenWidth - titleWidth * 2 - margin * 2, 40)];
        [self.transmitView addSubview:self.slider];
        self.slider.value = 0.5;
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.awardView = [[WPRedPacketSendView alloc]init];
        [self.containerV addSubview:self.awardView];
        [self.awardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.transmitView).offset(15);
            make.right.equalTo(self.transmitView).offset(-15);
            make.top.equalTo(self.transmitView.mas_bottom).offset(6);
            make.height.equalTo(@50);
        }];
        self.awardView.titleTF.text = LLSTR(@"101486");
        self.awardView.subTF.placeholder = LLSTR(@"101471");
        self.awardView.subTF.userInteractionEnabled = YES;
        self.awardView.subTF.keyboardType = UIKeyboardTypeNumberPad;
        self.awardView.subTF.delegate = self;
        [self.awardView.titleTF mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.awardView);
            make.right.equalTo(self.awardView);
            make.left.equalTo(self.awardView).offset(10);
        }];
        [self.awardView.subTF mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.awardView);
            make.right.equalTo(self.awardView).offset(-10);
            make.width.equalTo(@80);
        }];        
    }
    
    [self.contentTV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerV).offset(15);
        make.right.equalTo(self.containerV).offset(-15);
        make.top.equalTo(self.awardView.mas_bottom).offset(10);
        make.height.equalTo(@65);
    }];
    self.transmitView.hidden = NO;
    self.awardView.hidden = NO;
}

- (void)hideTransmit {
    if (self.transmitView) {
        self.transmitView.hidden = YES;
    }
    if (self.awardView) {
        self.awardView.hidden = YES;
    }
    [self.contentTV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.priceView);
        if (self.isGroup || (!self.isGroup && self.peerId.length == 0)) {
            make.top.equalTo(self.peopleCountLabel.mas_bottom).offset(9);
        } else {
            make.top.equalTo(self.priceView.mas_bottom).offset(10);
        }
        make.height.equalTo(@65);
    }];
}
//重新设置价格
- (void)resetPrice {
    if (self.isInvite) {
        if (!self.selModel) {
            return;
        }
        if (self.priceView.subTF.text.length == 0 || self.countView.subTF.text.length == 0) {
            return;
        }
        NSDecimalNumber *dec1 = [NSDecimalNumber decimalNumberWithString:self.priceView.subTF.text];
        NSDecimalNumber *dec2 = [NSDecimalNumber decimalNumberWithString:self.countView.subTF.text];
        if (self.isNormal) {
            self.priceLabel.text = [[[dec1 decimalNumberByMultiplyingBy:dec2] stringValue] toPrise];
        } else {
            self.priceLabel.text = self.priceView.subTF.text;
        }
    } else {
        
    }
}
//滚动条值变化
- (void)sliderValueChanged:(UISlider *)slider {
    int result = (int)roundf(slider.value / 0.125) + 1;
    self.inviteLabel.text = [NSString stringWithFormat:@"%@\n%d0%@",LLSTR(@"101484"),result,@"%"];
    self.invitedLabel.text = [NSString stringWithFormat:@"%@\n%d0%@",LLSTR(@"101485"),10 - result,@"%"];
}

- (void)sliderTouchUpInSide:(UISlider *)slider {
    int result = (int)roundf(slider.value / 0.125) + 1;
    self.rate = [[NSString stringWithFormat:@"%f",result / 10.0] toPrise];
    [self.slider setValue:(result - 1) * 0.125 animated:YES];
    self.inviteLabel.text = [NSString stringWithFormat:@"%@\n%d0%@",LLSTR(@"101484"),result,@"%"];
    self.invitedLabel.text = [NSString stringWithFormat:@"%@\n%d0%@",LLSTR(@"101485"),10 - result,@"%"];
}

- (void)transmitChange:(UIButton *)btn {
    if (!self.selModel) {
        [BiChatGlobal showInfo:LLSTR(@"301201") withIcon:Image(@"icon_alert")];
        return;
    }
    UIButton *btn1 = [self.transmitView viewWithTag:kTransmitTag];
    UIButton *btn2 = [self.transmitView viewWithTag:kTransmitTag + 1];
    UIButton *btn3 = [self.transmitView viewWithTag:kTransmitTag + 2];
    btn1.selected = NO;
    btn2.selected = NO;
    btn3.selected = NO;
    btn.selected = YES;
    [self resetPrice];
}

//如果选择的是群友转发，重新计算币个数
- (void)recalculatePriceWithString:(NSString *)string {
    NSDecimalNumber *dec1 = [NSDecimalNumber decimalNumberWithString:string];
    NSDecimalNumber *dec2 = [NSDecimalNumber decimalNumberWithString:@"2"];
    NSInteger floatWidth = [string integerValue];
//    if ([self.selModel.bit rangeOfString:@"."].location == NSNotFound) {
//        floatWidth = 0;
//    } else {
//        floatWidth = self.selModel.bit.length - 2;
//    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    //设置最多保留几位小数
    formatter.maximumFractionDigits = floatWidth;
    //设置最少保留几位小数
    formatter.minimumFractionDigits = 0;
    //不分段（千分符）
    formatter.usesGroupingSeparator = NO;
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithDouble:[[dec1 decimalNumberByMultiplyingBy:dec2] doubleValue]]];
    self.priceLabel.text = result;
}

//选择红包广场后验证信息
//公开群无提示。非公开群是群主、管理员，弹出修改提示。非群主、管理员，弹出联系群主提示
//- (void)resetInformation {
//    if (self.isGroup && self.peerId.length == 0 && self.isPrivate) {
//        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"本群是普通群" message:@"\n红包无法同步到红包广场，是否要把本群修改为公开群？" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            self.isPrivate = NO;
//
//        }];
//        UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self typeChange:[self.containerV viewWithTag:kBtnTag]];
//        }];
//        [action2 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
//        [action1 setValue:LightBlue forKey:@"_titleTextColor"];
//        [alertC addAction:action1];
//        [alertC addAction:action2];
//        [self presentViewController:alertC animated:YES completion:nil];
//    } else {
//        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"本群是普通群" message:@"\n红包无法同步到红包广场，请联系群主或管理员修改为公开群先" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101023") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self typeChange:[self.containerV viewWithTag:kBtnTag]];
//        }];
//        [action1 setValue:LightBlue forKey:@"_titleTextColor"];
//        [alertC addAction:action1];
//        [self presentViewController:alertC animated:YES completion:nil];
//    }
//}

//重置提交按钮状态
- (void)resetButtonStatus {
    BOOL canSend = YES;
    if (!self.selModel) {
        canSend = NO;
    } else if (self.isGroup || (!self.isGroup && self.peerId.length == 0)) {
        if ([self.countView.subTF.text floatValue] == 0 || [self.priceView.subTF.text floatValue] == 0) {
            canSend = NO;
        }
    } else {
        if ([self.priceView.subTF.text floatValue] == 0) {
            canSend = NO;
        }
    }
    if (canSend) {
        self.confirmBtn.alpha = 1;
        self.confirmBtn.userInteractionEnabled = YES;
    } else {
        self.confirmBtn.alpha = 0.5;
        self.confirmBtn.userInteractionEnabled = NO;
    }
}
//选择币
- (void)coinChoose {
    
    MyWalletViewController *walletVC = [[MyWalletViewController alloc]init];
    walletVC.delegate = self;
    [self.navigationController pushViewController:walletVC animated:YES];
    
    
    
    
    
    
    
//    if (!self.receiveModel) {
//        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:Image(@"icon_alert")];
//        return;
//    }
//    if (self.receiveModel.list.count == 0) {
//        [BiChatGlobal showInfo:@LLSTR(@"301114") withIcon:Image(@"icon_alert")];
//        return;
//    }
//    [self.view endEditing:YES];
//    if (!self.receiveModel || self.receiveModel.list.count == 0) {
//        return;
//    }
//    if (!self.sendV) {
//        self.sendV = [[WPRedPacketSendCoinSelectView alloc]initWithFrame:CGRectMake(0, ScreenHeight - (isIphonex ? 88 : 64), ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64))];
//        [self.view addSubview:self.sendV];
//    }
//    [self.sendV fillCoin:self.receiveModel.list];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.sendV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64));
//    }];
//    WEAKSELF;
//    self.sendV.SelectBlock = ^(WPRedPacketSendCoinModel *model) {
//
//        if ([model.symbol isEqualToString:@"TOKEN"] &&
//            [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"kycLevel"]integerValue] == 0)
//        {
//            [BiChatGlobal showInfo:@"请先绑定微信\r\n再发IMC红包" withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
//            return ;
//        }
//
//        if ([model.symbol isEqualToString:weakSelf.selModel.symbol]) {
//            [UIView animateWithDuration:0.3 animations:^{
//                weakSelf.sendV.frame = CGRectMake(0, ScreenHeight - (isIphonex ? 88 : 64), ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64));
//            }];
//            CGRect rect = [model.dSymbol boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(16)} context:nil];
//            [weakSelf.coinTL mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.equalTo(@(rect.size.width + 10));
//            }];
//            return ;
//        }
//        weakSelf.selModel = model;
//        [UIView animateWithDuration:0.3 animations:^{
//            weakSelf.sendV.frame = CGRectMake(0, ScreenHeight - (isIphonex ? 88 : 64), ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64));
//        }];
//        CGRect rect = [model.dSymbol boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(16)} context:nil];
//        [weakSelf.coinTL mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@(rect.size.width + 10));
//        }];
//        [weakSelf.coinIV sd_setImageWithURL:[NSURL URLWithString:model.imgColor]];
//        weakSelf.coinIV.hidden = NO;
//        weakSelf.coinTL.hidden = NO;
//        weakSelf.coinTL.text = model.dSymbol;
//        weakSelf.coinLabel.text = model.dSymbol;
//        weakSelf.priceView.subTF.placeholder = [@"0" accuracyCheckWithFormatterString:model.bit];
//
//        NSString *formatterString = [@"0" getFormatterStringWithBit:model.bit];
//        weakSelf.priceLabel.text = [formatterString stringByReplacingCharactersInRange:NSMakeRange(formatterString.length - 1, 1) withString:@"0"];
//        weakSelf.priceLabel.text =
//        weakSelf.priceView.subTF.text = nil;
//        weakSelf.countView.subTF.text = nil;
//        [weakSelf resetButtonStatus];
//    };
}

- (void)coinSelected:(NSString *)coinName
     coinDisplayName:(NSString *)coinDisplayName
            coinIcon:(NSString *)coinIcon
       coinIconWhite:(NSString *)coinIconWhite
        coinIconGold:(NSString *)coinIconGold
             balance:(CGFloat)balance
                 bit:(NSInteger)bit {
    [self.navigationController popViewControllerAnimated:YES];
    WPRedPacketSendCoinModel *model = [[WPRedPacketSendCoinModel alloc]init];
    model.symbol = coinName;
    model.dSymbol = coinDisplayName;
    model.bit = [NSString stringWithFormat:@"%ld",bit];
    model.amount = [NSString stringWithFormat:@"%lf",balance];
    model.imgGold = coinIconGold;
    model.imgColor = coinIcon;
    model.imgWhite = coinIconWhite;
    
    self.totalPricelabel.text = [model.amount accuracyCheckWithFormatterString:model.bit auotCheck:YES];
    if ([model.symbol isEqualToString:@"TOKEN"] &&
        [[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"kycLevel"]integerValue] == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301621") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return ;
    }
    
    if ([model.symbol isEqualToString:self.selModel.symbol]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.sendV.frame = CGRectMake(0, ScreenHeight - (isIphonex ? 88 : 64), ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64));
        }];
        CGRect rect = [model.dSymbol boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(16)} context:nil];
        [self.coinTL mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(rect.size.width + 10));
        }];
        return ;
    }
    self.selModel = model;
    [UIView animateWithDuration:0.3 animations:^{
        self.sendV.frame = CGRectMake(0, ScreenHeight - (isIphonex ? 88 : 64), ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64));
    }];
    CGRect rect = [model.dSymbol boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(16)} context:nil];
    [self.coinTL mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(rect.size.width + 10));
    }];
    [self.coinIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,model.imgColor]]];
    self.coinIV.hidden = NO;
    self.coinTL.hidden = NO;
    self.coinTL.text = model.dSymbol;
    self.coinLabel.text = model.dSymbol;
    self.priceView.subTF.placeholder = [@"0" accuracyCheckWithFormatterString:model.bit  auotCheck:NO];
    
    NSString *formatterString = [@"0" getFormatterStringWithBit:model.bit];
    self.priceLabel.text = [formatterString stringByReplacingCharactersInRange:NSMakeRange(formatterString.length - 1, 1) withString:@"0"];
    self.priceLabel.text =
    self.priceView.subTF.text = nil;
    self.countView.subTF.text = nil;
    if (self.selectedPeople) {
        self.countView.subTF.text = @"1";
    }
    [self resetButtonStatus];
}

//切换红包种类
- (void)kindChoose {
    [self.view endEditing:YES];
    self.isNormal = !self.isNormal;
    if (self.isNormal) {
        NSString *redString = [NSString stringWithFormat:@"%@，%@",LLSTR(@"101463"),LLSTR(@"101464")];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:redString];
        [attStr addAttribute:NSForegroundColorAttributeName value:THEME_GRAY range:NSMakeRange(0, redString.length)];
        [attStr addAttribute:NSFontAttributeName value:Font(14) range:NSMakeRange(0, redString.length)];
        [attStr yy_setColor:RGB(0x2f93fa) range:NSMakeRange(LLSTR(@"101463").length+1, LLSTR(@"101464").length)];
        YYTextHighlight *highlight = [YYTextHighlight new];
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            [self kindChoose];
        };
        [attStr yy_setTextHighlight:highlight range:NSMakeRange(LLSTR(@"101463").length+1, LLSTR(@"101464").length)];
        self.typeLabel.attributedText = attStr;
        self.priceView.titleTF.leftView = nil;
        self.priceView.titleTF.text = LLSTR(@"101466");
        if (self.priceView.subTF.text.length > 0 && self.countView.subTF.text.length > 0) {
            NSDecimalNumber *dec1 = [NSDecimalNumber decimalNumberWithString:self.countView.subTF.text];
            NSDecimalNumber *dec2 = [NSDecimalNumber decimalNumberWithString:self.priceLabel.text];
            NSDecimalNumber *dec3 = [dec1 decimalNumberByMultiplyingBy:dec2];
            self.priceLabel.text = [dec3 stringValue];
            if (self.isInvite) {
                [self resetPrice];
            }
        }
        
    } else {
        NSString *redString = [NSString stringWithFormat:@"%@，%@",LLSTR(@"101462"),LLSTR(@"101465")];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:redString];
        [attStr addAttribute:NSForegroundColorAttributeName value:THEME_GRAY range:NSMakeRange(0, redString.length)];
        [attStr addAttribute:NSFontAttributeName value:Font(14) range:NSMakeRange(0, redString.length)];
        [attStr yy_setColor:RGB(0x2f93fa) range:NSMakeRange(LLSTR(@"101462").length+1, LLSTR(@"101465").length)];
        YYTextHighlight *highlight = [YYTextHighlight new];
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            [self kindChoose];
        };
        [attStr yy_setTextHighlight:highlight range:NSMakeRange(LLSTR(@"101462").length+1, LLSTR(@"101465").length)];
        self.typeLabel.attributedText = attStr;
        
        UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
        leftView.backgroundColor = [UIColor clearColor];
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 20, 20)];
        leftLabel.backgroundColor = RGB(0xf9bc51);
        leftLabel.layer.cornerRadius = 3;
        leftLabel.layer.masksToBounds = YES;
        leftLabel.textColor = [UIColor whiteColor];
        leftLabel.font = Font(12);
        leftLabel.text = @"拼";
        leftLabel.textAlignment = NSTextAlignmentCenter;
        [leftView addSubview:leftLabel];
        self.priceView.titleTF.leftView = leftView;
        self.priceView.titleTF.leftViewMode = UITextFieldViewModeAlways;
        self.priceView.titleTF.text = LLSTR(@"101461");
        if (self.priceView.subTF.text.length > 0) {
            self.priceLabel.text = self.priceView.subTF.text;
            if (self.subType == 1) {
                [self resetPrice];
            }
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.priceView.subTF]) {
        NSString *formatterString = [@"0" getFormatterStringWithBit:self.selModel.bit];
        if ([string rangeOfString:@"."].location != NSNotFound && formatterString.length == 1) {
            return NO;
        }
        NSArray *array = [result componentsSeparatedByString:@"."];
        if (array.count > 1) {
            NSString *floatPart = array[1];
            if (floatPart.length > formatterString.length - 2) {
                return NO;
            }
        }
        if ([result isFloat] || [result isInt]) {
            if (self.isNormal) {
                if (self.countView.subTF.text.length > 0 && result.length > 0) {
                    NSDecimalNumber *dec1 = [NSDecimalNumber decimalNumberWithString:self.countView.subTF.text];
                    NSDecimalNumber *dec2 = [NSDecimalNumber decimalNumberWithString:result];
                    NSDecimalNumber *dec3 = [dec1 decimalNumberByMultiplyingBy:dec2];
                    self.priceLabel.text = [dec3 stringValue];
                } else {
                    if (self.selModel) {
                        self.priceLabel.text = [@"0" getFormatterStringWithBit:self.selModel.bit];
                    }
                }
            } else {
                self.priceLabel.text = result;
                if (self.subType == 1 && result.length > 0) {
                }
            }
            [self performSelector:@selector(resetButtonStatus) withObject:nil afterDelay:0.1];
            [self performSelector:@selector(resetPrice) withObject:nil afterDelay:0.1];
            return YES;
        }
        if (result.length < textField.text.length) {
            if (self.isNormal) {
                if (self.countView.subTF.text.length > 0 && result.length > 0) {
                    NSDecimalNumber *dec1 = [NSDecimalNumber decimalNumberWithString:self.countView.subTF.text];
                    NSDecimalNumber *dec2 = [NSDecimalNumber decimalNumberWithString:result];
                    NSDecimalNumber *dec3 = [dec1 decimalNumberByMultiplyingBy:dec2];
                    self.priceLabel.text = [dec3 stringValue];
                } else {
                    if (self.selModel) {
                        self.priceLabel.text = [@"0" getFormatterStringWithBit:self.selModel.bit];
                    }
                }
            } else {
                self.priceLabel.text = result;
            }
            [self performSelector:@selector(resetPrice) withObject:nil afterDelay:0.1];
            [self performSelector:@selector(resetButtonStatus) withObject:nil afterDelay:0.1];
            return YES;
        }
        return NO;
    }
    if ([textField isEqual:self.countView.subTF]) {
        if ([result isInt]) {
            if (self.isNormal) {
                if (result.length > 0 && self.priceView.subTF.text.length > 0) {
                    NSDecimalNumber *dec1 = [NSDecimalNumber decimalNumberWithString:result];
                    NSDecimalNumber *dec2 = [NSDecimalNumber decimalNumberWithString:self.priceView.subTF.text];
                    NSDecimalNumber *dec3 = [dec1 decimalNumberByMultiplyingBy:dec2];
                    self.priceLabel.text = [dec3 stringValue];
                }
            }
            [self performSelector:@selector(resetPrice) withObject:nil afterDelay:0.1];
            [self performSelector:@selector(resetButtonStatus) withObject:nil afterDelay:0.1];
            self.awardView.subTF.text = result;
            return YES;
        }
        if (result.length < textField.text.length) {
            [self performSelector:@selector(resetPrice) withObject:nil afterDelay:0.1];
            [self performSelector:@selector(resetButtonStatus) withObject:nil afterDelay:0.1];
            self.awardView.subTF.text = result;
            return YES;
        }
        return NO;
    }
    [self performSelector:@selector(resetPrice) withObject:nil afterDelay:0.1];
    [self performSelector:@selector(resetButtonStatus) withObject:nil afterDelay:0.1];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (([textField isEqual:self.priceView.subTF] || [textField isEqual:self.countView.subTF]) && !self.selModel) {
        [BiChatGlobal showInfo:LLSTR(@"301201") withIcon:Image(@"icon_alert")];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.hasEdit) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length > 0) {
        self.hasEdit = YES;
    } else {
        self.hasEdit = NO;
        textView.text = LLSTR(@"101454");
        NSString *cusStr = [[BiChatGlobal sharedManager].systemConfig objectForKey:@"rpTitle"];
        if (cusStr.length > 0) {
            textView.text = cusStr;
        }
        textView.textColor = THEME_GRAY;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *lang = [[[UITextInputMode activeInputModes] firstObject] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *range = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:range.start offset:0];
        if (!position) {
            [self checkText:textView];
        }
    }
    else {
        [self checkText:textView];
    }
}

- (void)checkText:(UITextView *)textView {
    NSString *string = textView.text;
    if (string.length > kMaxLength) {
        textView.text = [string substringToIndex:kMaxLength];
    }
    NSInteger length = textView.text.length;
    NSInteger num = 16 - length;
    num = MAX(num, 0);
}

- (UIViewController *)paymentPasswordSetSuccess:(NSInteger)cookie {
    [self showPassView];
    return nil;
}
//显示输入交易密码页面
- (void)showPassView {
    [self.view endEditing:YES];
    if ([[[self.contentTV.text stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [BiChatGlobal showFailWithString:LLSTR(@"301235")];
        return;
    }
    if ([self.countView.subTF.text integerValue] < 10 && self.subType == 2 && self.isInvite) {
        [BiChatGlobal showFailWithString:LLSTR(@"301236")];
        return;
    }
    double count = [self.priceLabel.text doubleValue];
    if (count > [self.selModel.amount doubleValue]) {
        [BiChatGlobal showInfo:[LLSTR(@"301125") llReplaceWithArray:@[self.selModel.dSymbol]] withIcon:Image(@"icon_alert")];
        return;
    }
    NSString *formatterString = [@"0" getFormatterStringWithBit:self.selModel.bit];
    if (self.isInvite && self.subType == 1) {
        NSString *leastStr = [NSString stringWithFormat:@"%lf",[[@"0" getFormatterStringWithBit:self.selModel.bit] doubleValue] * 100];
        //普通红包
        if (self.isNormal) {
            if ([self.priceView.subTF.text floatValue] * [self.rate floatValue] < [formatterString floatValue] || [self.priceView.subTF.text floatValue] * (1 - [self.rate floatValue]) < [formatterString floatValue] * 100) {
                [BiChatGlobal showInfo:[LLSTR(@"301238") llReplaceWithArray:@[self.selModel.dSymbol,[leastStr accuracyCheckWithFormatterString:self.selModel.bit auotCheck:YES]]]
                  withIcon:Image(@"icon_alert")];
                return;
            }
        }
        //拼手气红包
        else {
            if ([self.priceView.subTF.text floatValue] / [self.countView.subTF.text intValue] * [self.rate floatValue] < [formatterString floatValue] || [self.priceView.subTF.text floatValue] / [self.countView.subTF.text intValue] * (1 - [self.rate floatValue]) < [formatterString floatValue] * 100) {
                [BiChatGlobal showInfo:[LLSTR(@"301238") llReplaceWithArray:@[self.selModel.dSymbol,[leastStr accuracyCheckWithFormatterString:self.selModel.bit auotCheck:YES]]]
                  withIcon:Image(@"icon_alert")];
                return;
            }
        }
    }
    //群红包
    if (!self.isNormal && (self.isGroup || (!self.isGroup && self.peerId.length == 0))) {
        NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:self.priceView.subTF.text];
        NSDecimalNumber *decNum1 = [NSDecimalNumber decimalNumberWithString:self.countView.subTF.text];
        NSDecimalNumber *perCount = [decNum decimalNumberByDividingBy:decNum1];
        NSString *leastStr = [NSString stringWithFormat:@"%lf",[[@"0" getFormatterStringWithBit:self.selModel.bit] doubleValue] * 100];
        if ([perCount doubleValue] < [[@"0" getFormatterStringWithBit:self.selModel.bit] doubleValue] * 100) {
            [BiChatGlobal showInfo:[LLSTR(@"301238") llReplaceWithArray:@[self.selModel.dSymbol,[leastStr accuracyCheckWithFormatterString:self.selModel.bit auotCheck:YES]]]
              withIcon:Image(@"icon_alert")];
            return;
        }
    }
    //个人红包
    if (!self.isInvite && !self.isGroup && count < [formatterString floatValue] * 100) {
        NSString *leastStr = [NSString stringWithFormat:@"%lf",[[@"0" getFormatterStringWithBit:self.selModel.bit] doubleValue] * 100];
        [BiChatGlobal showInfo:[LLSTR(@"301238") llReplaceWithArray:@[self.selModel.dSymbol,[leastStr accuracyCheckWithFormatterString:self.selModel.bit auotCheck:YES]]]
                      withIcon:Image(@"icon_alert")];
        return;
    }
    self.passView = [[WPProductInputView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64))];
    [self.view addSubview:self.passView];
    
    NSString *invStr = nil;
    if (self.isInvite) {
        invStr = LLSTR(@"101622");
    } else if (self.isGroup) {
        invStr = LLSTR(@"101623");
        if (self.selectedPeople) {
            invStr = LLSTR(@"101624");
        }
    } else {
        invStr = LLSTR(@"101625");
    }
    [self.passView setCoinImag:self.selModel.imgGold count:self.priceLabel.text coinName:self.selModel.dSymbol payTo:invStr payDesc:self.selectedPeople ? [self.selectedPeople objectForKey:@"nickName"] : (self.groupName ? self.groupName : self.peopleName)  wallet:0];
    WEAKSELF;
    self.passView.closeBlock = ^{
        [weakSelf hidePassView];
        weakSelf.confirmBtn.enabled = YES;
    };
    self.passView.passwordInputBlock = ^(NSString *password) {
        
        NSDate *lastdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRedPacketDate"];
        if (fabs([[NSDate date] timeIntervalSinceDate:lastdate]) < 3) {
            return ;
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastRedPacketDate"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[BiChatGlobal sharedManager].token forKey:@"tokenid"];
        
        NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
        NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
        NSArray *parts = [weakSelf.contentTV.text componentsSeparatedByCharactersInSet:whitespaces];
        NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
        NSString *greeting = [filteredArray componentsJoinedByString:@" "];
        
        if (greeting.length > 0) {
            [dict setObject:greeting forKey:@"greetings"];
        }
        if (weakSelf.countView.subTF.text.length > 0) {
            [dict setObject:weakSelf.countView.subTF.text forKey:@"rewardNum"];
        }
        if (weakSelf.priceLabel.text.length > 0) {
            [dict setObject:weakSelf.priceLabel.text forKey:@"coinNum"];
        }
        
        if (weakSelf.selModel) {
            [dict setObject:weakSelf.selModel.symbol forKey:@"coinType"];
        }
        if (weakSelf.isNormal) {
            [dict setObject:@"1" forKey:@"drawType"];
        } else {
            [dict setObject:@"0" forKey:@"drawType"];
            if (!weakSelf.isGroup) {
                [dict setObject:@"1" forKey:@"drawType"];
            }
        }
        
        if (weakSelf.isInvite) {
            if (self.subType == 0) {
                [dict setObject:@"1" forKey:@"canForward"];
                [dict setObject:@"1" forKey:@"outside"];
                [dict setObject:@"0" forKey:@"inFeed"];
                [dict setObject:@"0" forKey:@"internalSee"];
                [dict setObject:@"0" forKey:@"internal"];
                [dict setObject:@"1" forKey:@"external"];
            } else if (self.subType == 1) {
                [dict setObject:@"1" forKey:@"canForward"];
                [dict setObject:@"1" forKey:@"outside"];
                [dict setObject:@"0" forKey:@"inFeed"];
                [dict setObject:@"1" forKey:@"internalSee"];
                [dict setObject:@"0" forKey:@"internal"];
                [dict setObject:@"1" forKey:@"external"];
                [dict setObject:[NSString stringWithFormat:@"%@",weakSelf.awardView.subTF.text] forKey:@"upperLimit"];
                [dict setObject:weakSelf.rate forKey:@"rate"];
                
            } else if (self.subType == 2) {
                [dict setObject:@"0" forKey:@"canForward"];
                [dict setObject:@"0" forKey:@"outside"];
                [dict setObject:@"1" forKey:@"inFeed"];
                [dict setObject:@"0" forKey:@"internalSee"];
                [dict setObject:@"0" forKey:@"internal"];
                [dict setObject:@"1" forKey:@"external"];
            }
            [dict setObject:@(weakSelf.subType) forKey:@"subType"];
            [dict setObject:@"103" forKey:@"rewardType"];
        } else {
            if (!weakSelf.isGroup && weakSelf.peerId.length > 0) {
                [dict setObject:@"101" forKey:@"rewardType"];
                
                [dict setObject:@"0" forKey:@"canForward"];
                [dict setObject:@"0" forKey:@"outside"];
                [dict setObject:@"0" forKey:@"inFeed"];
                [dict setObject:@"1" forKey:@"internalSee"];
                [dict setObject:@"1" forKey:@"internal"];
                [dict setObject:@"0" forKey:@"external"];
            } else {
                [dict setObject:@"102" forKey:@"rewardType"];
                [dict setObject:@"0" forKey:@"canForward"];
                [dict setObject:@"0" forKey:@"outside"];
                [dict setObject:@"1" forKey:@"internalSee"];
                [dict setObject:@"1" forKey:@"internal"];
                [dict setObject:@"0" forKey:@"external"];
                [dict setObject:@"0" forKey:@"inFeed"];
                
            }
        }
        
        if (weakSelf.isGroup && weakSelf.peerId.length > 0) {
            [dict setObject:weakSelf.peerId forKey:@"groupid"];
        }
        if (weakSelf.groupName.length > 0) {
            [dict setObject:weakSelf.groupName forKey:@"groupName"];
        }
        [dict setObject:password forKey:@"password"];
        if (weakSelf.selectedPeople) {
            [dict setObject:[weakSelf.selectedPeople objectForKey:@"uid"] forKey:@"receiveUid"];
        }
        
        [dict setObject:@"1" forKey:@"isPushMsg"];
        if (!weakSelf.isGroup) {
            [dict setObject:weakSelf.peerId forKey:@"receiveUid"];
        }
        if (weakSelf.selectedPeople) {
            [dict setObject:[weakSelf.selectedPeople objectForKey:@"uid"] forKey:@"receiveUid"];
        }
        //创建红包
        weakSelf.view.userInteractionEnabled = NO;
        [BiChatGlobal ShowActivityIndicator];
        weakSelf.navigationItem.leftBarButtonItem.enabled = NO;
        [[WPBaseManager baseManager] getInterface:@"Chat/ApiReward/saveCreateReward.do" parameters:dict success:^(id response) {
            weakSelf.navigationItem.leftBarButtonItem.enabled = YES;
            [BiChatGlobal HideActivityIndicator];
            weakSelf.createModel = [WPRedPacketSendReceiveModel mj_objectWithKeyValues:[response objectForKey:@"data"]];
            //发送红包消息
            weakSelf.view.userInteractionEnabled = YES;
            if ([[response stringObjectForkey:@"code"] isEqualToString:@"2"]) {
                weakSelf.view.userInteractionEnabled = YES;
                weakSelf.confirmBtn.enabled = YES;
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"103012") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"103013") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showPassView];
                    });                    
                }];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"103014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    PaymentPasswordSetupStep1ViewController *passVC = [[PaymentPasswordSetupStep1ViewController alloc]init];
                    [weakSelf.navigationController pushViewController:passVC animated:YES];
                }];
                [action2 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                [action1 setValue:LightBlue forKey:@"_titleTextColor"];
                [alertC addAction:action1];
                [alertC addAction:action2];
                [weakSelf presentViewController:alertC animated:YES completion:nil];
                return;
            } else if ([[response stringObjectForkey:@"code"] isEqualToString:@"3"]) {
                weakSelf.view.userInteractionEnabled = YES;
                weakSelf.confirmBtn.enabled = YES;
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:LLSTR(@"301114") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [action1 setValue:DarkBlue forKey:@"_titleTextColor"];
                [alertC addAction:action1];
                [weakSelf presentViewController:alertC animated:YES completion:nil];
                return;
            } else if ([[response stringObjectForkey:@"code"] isEqualToString:@"4"]) {
                weakSelf.view.userInteractionEnabled = YES;
                weakSelf.confirmBtn.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301012") withIcon:Image(@"icon_alert")];
                return;
            } else if ([[response stringObjectForkey:@"code"] isEqualToString:@"5"]) {
                weakSelf.view.userInteractionEnabled = YES;
                weakSelf.confirmBtn.enabled = YES;
                weakSelf.confirmBtn.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:Image(@"icon_alert")];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 1", nil];
                return;
            } else if ([[response stringObjectForkey:@"code"] isEqualToString:@"6"]) {
                weakSelf.view.userInteractionEnabled = YES;
                weakSelf.confirmBtn.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301111") withIcon:Image(@"icon_alert")];
                return;
            } else if ([[response stringObjectForkey:@"code"] isEqualToString:@"7"]) {
                weakSelf.view.userInteractionEnabled = YES;
                weakSelf.confirmBtn.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301216") withIcon:Image(@"icon_alert")];
                return;
            } else if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]) {
                [BiChatGlobal showInfo:LLSTR(@"301202") withIcon:Image(@"icon_OK")duration:3 enableClick:NO];
                [weakSelf performSelector:@selector(doCancel) withObject:nil afterDelay:2];
                [NetworkModule getWallet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    [BiChatGlobal sharedManager].dict4WalletInfo = data;
                    [[BiChatGlobal sharedManager]saveUserInfo];
                }];
                
                
                
                //发一条@消息
                if (weakSelf.selectedPeople) {
                    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:weakSelf.peerId];
                    //生成消息
                    NSString *msgId = [BiChatGlobal getUuidString];
                    NSString *contentId = [BiChatGlobal getUuidString];
                    NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [NSString stringWithFormat:@"@%@",[weakSelf.selectedPeople objectForKey:@"groupNickName"] ? [weakSelf.selectedPeople objectForKey:@"groupNickName"] : [weakSelf.selectedPeople objectForKey:@"nickName"]], @"content",
                                                     [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_TEXT], @"type",
                                                     weakSelf.peerId, @"receiver",
                                                     [NSString stringWithFormat:@"%@", [groupProperty objectForKey:@"groupName"]], @"receiverNickName",
                                                     [NSString stringWithFormat:@"%@", [groupProperty objectForKey:@"avatar"]==nil?@"":[groupProperty objectForKey:@"avatar"]], @"receiverAvatar",
                                                     [BiChatGlobal sharedManager].uid, @"sender",
                                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].nickName], @"senderNickName",
                                                     [NSString stringWithFormat:@"%@", [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar], @"senderAvatar",
                                                     [BiChatGlobal getCurrentDateString], @"timeStamp",
                                                     [weakSelf.selectedPeople objectForKey:@"uid"], @"at",
                                                     [weakSelf.selectedPeople objectForKey:@"groupNickName"] ? [weakSelf.selectedPeople objectForKey:@"groupNickName"] : [weakSelf.selectedPeople objectForKey:@"nickName"], @"atName",
                                                     @"1", @"isGroup",
                                                     msgId, @"msgId",
                                                     contentId, @"contentId", nil];
                    
                    //先保存
                    if (weakSelf.chatVC) {
                        ChatViewController *chatWnd = (ChatViewController *)weakSelf.chatVC;
                        [chatWnd appendMessage:sendData];
                    } else {
                        [[BiChatDataModule sharedDataModule]addChatContentWith:weakSelf.peerId content:sendData];
                    }
                    [[BiChatDataModule sharedDataModule]setLastMessage:weakSelf.peerId
                                                          peerUserName:@""
                                                          peerNickName:[groupProperty objectForKey:@"groupName"]
                                                            peerAvatar:[groupProperty objectForKey:@"avatar"]
                                                               message:[BiChatGlobal getMessageReadableString:sendData groupProperty:groupProperty]
                                                           messageTime:[BiChatGlobal getCurrentDateString]
                                                                 isNew:NO isGroup:YES isPublic:NO createNew:YES];
                    
                    //再发送
//                    [NetworkModule sendMessageToGroup:weakSelf.peerId message:sendData completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
//
//                    }];
                }
                
                if ([weakSelf.delegate respondsToSelector:@selector(redPacketCreated:redPacketId:coinImageUrl:shareCoinImageUrl:coinSymbol:greeting:groupId:groupName:rewardType:subType:isInvite:expired:at:atName:)]) {
                    [weakSelf.delegate redPacketCreated:weakSelf.createModel.url
                                            redPacketId:weakSelf.createModel.rewardId
                                           coinImageUrl:weakSelf.createModel.coinImgUrl
                                      shareCoinImageUrl:weakSelf.createModel.coin.imgWechat
                                             coinSymbol:weakSelf.createModel.coin.dSymbol
                                               greeting:weakSelf.createModel.greetings
                                                groupId:weakSelf.createModel.groupId
                                              groupName:weakSelf.createModel.groupName
                                             rewardType:weakSelf.createModel.rewardType
                                                subType:[NSString stringWithFormat:@"%ld",weakSelf.subType]
                                               isInvite:weakSelf.isInvite
                                                expired:[[response objectForKey:@"data"] objectForKey:@"expired"]
                                                     at:weakSelf.selectedPeople ?  [weakSelf.selectedPeople objectForKey:@"uid"] : nil
                                                 atName:weakSelf.selectedPeople ?  ([weakSelf.selectedPeople objectForKey:@"groupNickName"] ? [weakSelf.selectedPeople objectForKey:@"groupNickName"] : [weakSelf.selectedPeople objectForKey:@"nickName"]) : nil
                     ];
                }
            } else {
                weakSelf.view.userInteractionEnabled = YES;
                weakSelf.confirmBtn.enabled = YES;
                [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:Image(@"icon_alert")];
            }
            
        } failure:^(NSError *error) {
            weakSelf.view.userInteractionEnabled = YES;
            //弹出提示
            weakSelf.navigationItem.leftBarButtonItem.enabled = YES;
            [BiChatGlobal HideActivityIndicator];
            weakSelf.confirmBtn.enabled = YES;
            if ([error.domain isEqualToString:@"-1"]) {
                [BiChatGlobal showInfo:LLSTR(@"301203") withIcon:Image(@"icon_alert")];
            } else if ([error.domain isEqualToString:@"2"]) {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"103012") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"103013") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showPassView];
                    });
                    
                }];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"103014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    PaymentPasswordSetupStep1ViewController *passVC = [[PaymentPasswordSetupStep1ViewController alloc]init];
                    [weakSelf.navigationController pushViewController:passVC animated:YES];
                }];
                [action2 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                [action1 setValue:LightBlue forKey:@"_titleTextColor"];
                [alertC addAction:action1];
                [alertC addAction:action2];
                [weakSelf presentViewController:alertC animated:YES completion:nil];
            } else if ([error.domain isEqualToString:@"3"]) {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:LLSTR(@"301114") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [action1 setValue:DarkBlue forKey:@"_titleTextColor"];
                [alertC addAction:action1];
                [weakSelf presentViewController:alertC animated:YES completion:nil];
            } else if ([error.domain isEqualToString:@"4"]) {
                [BiChatGlobal showInfo:LLSTR(@"301012") withIcon:Image(@"icon_alert")];
            } else if ([error.domain isEqualToString:@"5"]) {
                [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:Image(@"icon_alert")];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 2", nil];
            } else if ([error.domain isEqualToString:@"6"]) {
                [BiChatGlobal showInfo:LLSTR(@"301111") withIcon:Image(@"icon_alert")];
            } else {
                [BiChatGlobal showInfo:LLSTR(@"301203") withIcon:Image(@"icon_alert")];
            }
        }];
        [weakSelf hidePassView];
    };
}

- (void)toShare {
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [NSString stringWithFormat:@"快来抢%@红包喽～",self.createModel.coin.dSymbol];
        message.description = self.createModel.greetings;
        UIImage *newImage =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.createModel.coin.imgWechat]]];
        [message setThumbImage:newImage];
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
        WXWebpageObject *ext2 = [WXWebpageObject object];
        ext2.webpageUrl = self.createModel.url;
        message.mediaObject = ext2;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.scene = WXSceneSession;
        req.message = message;
        [WXApi sendReq:req];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)hidePassView {
    [self.passView resignFirstResponder];
    [self.passView removeFromSuperview];
    self.passView = nil;
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
