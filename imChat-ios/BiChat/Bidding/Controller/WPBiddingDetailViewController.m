//
//  WPBiddingDetailViewController.m
//  BiChat
//
//  Created by iMac on 2019/3/8.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPBiddingDetailViewController.h"
#import "WPEncryptModel.h"
#import "WPEncryptionObject.h"
#import "WPProductInputView.h"
#import <IQKeyboardManager.h>
#import "PaymentPasswordSetupStep1ViewController.h"

@interface WPBiddingDetailViewController ()<UITextFieldDelegate>

@property (nonatomic,strong)WPProductInputView *passView;

@property (nonatomic,strong)UILabel *tipLabel3;

@end

@implementation WPBiddingDetailViewController

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [IQKeyboardManager sharedManager].enable = YES;
//    [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder = NO;
//    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
//    [IQKeyboardManager sharedManager].toolbarBarTintColor = RGB(0xd2d5db);
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [IQKeyboardManager sharedManager].enable = NO;
//    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
//
//}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(0xf5f5f5);
    self.title = LLSTR(@"108013");
    [self freshPacket];
}
//刷新钱包信息
- (void)freshPacket {
    [self createUI];
}
//创建UI
- (void)createUI {
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.model.castCoinType];
    self.bottomV = [[UIView alloc]init];
    [self.view addSubview:self.bottomV];
    [self.bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(40);
        make.height.equalTo(@(150));
    }];
    
    UILabel *countLabel = [[UILabel alloc]init];
    [self.bottomV addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo (self.bottomV);
        make.right.equalTo (self.bottomV);
        make.top.equalTo(self.bottomV);
        make.height.equalTo(@(50));
    }];
    countLabel.font = Font(16);
    countLabel.text = [NSString stringWithFormat:@"  %@",LLSTR(@"108035")];
    countLabel.layer.cornerRadius = 3;
    countLabel.backgroundColor = [UIColor whiteColor];
    countLabel.layer.masksToBounds = YES;
    countLabel.userInteractionEnabled = YES;
    
    //数量
    self.countTF = [[UITextField alloc]init];
    [self.bottomV addSubview:self.countTF];
    [self.countTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(countLabel);
        make.left.equalTo(self.bottomV).offset(100);
        make.right.equalTo(countLabel).offset(-10);
    }];
    self.countTF.delegate = self;
    self.countTF.textAlignment = NSTextAlignmentRight;
    self.countTF.font = Font(14);
    self.countTF.keyboardType = UIKeyboardTypeDecimalPad;
    self.countTF.placeholder = @"FORCE";
    
    self.countTF.text = self.biddingDic ? [[NSString stringWithFormat:@"%@",[self.biddingDic objectForKey:@"accuVolume"]] accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%d",[[coinInfo objectForKey:@"bit"] intValue]] auotCheck:YES] : nil;
    
    UILabel *tiplabel = nil;
    if ([self.model.status integerValue] == 3) {
        tiplabel = [[UILabel alloc]init];
        [self.view addSubview:tiplabel];
        [tiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(countLabel);
            make.top.equalTo(countLabel.mas_bottom);
            make.height.equalTo(@20);
        }];
        tiplabel.font = Font(14);
        tiplabel.textAlignment = NSTextAlignmentRight;
        tiplabel.text = [LLSTR(@"108036") llReplaceWithArray:@[[NSString stringWithFormat:@"%.2f",[[[[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"asset"] objectForKey:@"POINT"] floatValue]]]];
        tiplabel.textColor = [UIColor lightGrayColor];
        
    }
    
    
    UILabel *amountLabel = [[UILabel alloc]init];
    [self.bottomV addSubview:amountLabel];
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomV);
        make.right.equalTo(self.bottomV);
        if (tiplabel) {
            make.top.equalTo(tiplabel.mas_bottom).offset(20);
        } else {
            make.top.equalTo(self.bottomV).offset(60);
        }
        make.height.equalTo(@(50));
        
    }];
    amountLabel.font = Font(16);
    amountLabel.text = [NSString stringWithFormat:@"  %@",LLSTR(@"108037")];
    amountLabel.layer.cornerRadius = 3;
    amountLabel.backgroundColor = [UIColor whiteColor];
    amountLabel.layer.masksToBounds = YES;
    amountLabel.userInteractionEnabled = YES;
    
    //份数
    self.amountTF = [[UITextField alloc]init];
//    self.amountTF.backgroundColor = [UIColor redColor];
    [self.bottomV addSubview:self.amountTF];
    [self.amountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(amountLabel);
        make.left.equalTo(amountLabel).offset(100);
        make.right.equalTo(amountLabel).offset(-10);
    }];
    self.amountTF.delegate = self;
    self.amountTF.textAlignment = NSTextAlignmentRight;
    self.amountTF.font = Font(14);
    self.amountTF.keyboardType = UIKeyboardTypeNumberPad;
    self.amountTF.placeholder = LLSTR(@"108045");
    WPEncryptModel *model = [WPEncryptionObject getEncryptModelByNo:self.model.batchNo];
    if ([[self.biddingDic objectForKey:@"status"] integerValue] == 17) {
        self.amountTF.text = [self.biddingDic objectForKey:@"accuAmount"];
    } else if (self.biddingDic){
        NSData *amountData = [[WPAESEncrypt decryptStringWithString:[self.biddingDic objectForKey:@"encryptData"] andKey:model.aesKey] dataUsingEncoding:NSUTF8StringEncoding];
        if (amountData) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:amountData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
            self.amountTF.text = [dic objectForKey:@"amount"];
        } else {
            [BiChatGlobal showFailWithString:LLSTR(@"108111")];
        }
    }
    
    UILabel *tipLabel1 = [[UILabel alloc]init];
    [self.view addSubview:tipLabel1];
    [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(amountLabel);
        make.top.equalTo(amountLabel.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    tipLabel1.font = Font(14);
    tipLabel1.textColor = [UIColor lightGrayColor];
    
    UILabel *tipLabel2 = [[UILabel alloc]init];
    [self.view addSubview:tipLabel2];
    [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(amountLabel);
        make.top.equalTo(tipLabel1.mas_bottom);
        make.height.equalTo(@20);
    }];
    tipLabel2.font = Font(14);
    tipLabel2.textColor = [UIColor lightGrayColor];
    
    self.tipLabel3 = [[UILabel alloc]init];
    [self.view addSubview:self.tipLabel3];
    [self.tipLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(amountLabel);
        make.top.equalTo(tipLabel2.mas_bottom);
        make.height.equalTo(@20);
    }];
    self.tipLabel3.font = Font(14);
    self.tipLabel3.textColor = [UIColor lightGrayColor];
    if ([self.countTF.text floatValue] > 0 && [self.amountTF.text floatValue] > 0) {
        NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.model.castCoinType];
        NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:self.countTF.text];
        NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:self.amountTF.text];
        NSDecimalNumber *num3 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[self.coefficient floatValue]]];
        NSDecimalNumber *num4 = [[num1 decimalNumberByMultiplyingBy:num3] decimalNumberByDividingBy:num2];
        self.tipLabel3.text = [LLSTR(@"108040") llReplaceWithArray:@[[[num4 stringValue] accuracyCheckWithFormatterString:[coinInfo objectForKey:@"bit"] auotCheck:NO]]];
    }
    
    tipLabel1.text = [LLSTR(@"108038") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",self.model.maxBidOrderCount],[NSString stringWithFormat:@"%@",self.model.userMaxAmount]]];
    tipLabel2.text = [LLSTR(@"108039") llReplaceWithArray:@[[NSString stringWithFormat:@"%.2f",[self.coefficient floatValue]]]];
//    UIView *lineV = [[UILabel alloc]init];
//    [self.view addSubview:lineV];
//    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(amountLabel);
//        make.top.equalTo(self.tipLabel3.mas_bottom);
//        make.height.equalTo(@1);
//    }];
//    lineV.backgroundColor = [UIColor lightGrayColor];
    
    
    UIButton *biddingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:biddingButton];
    [biddingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLabel3.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@(45));
    }];
    [biddingButton addTarget:self action:@selector(doBiddding) forControlEvents:UIControlEventTouchUpInside];
    biddingButton.layer.cornerRadius = 3;
    biddingButton.layer.masksToBounds = YES;
    biddingButton.backgroundColor = RGB(0x2f93fa);
    [biddingButton setTitle:LLSTR(@"108041") forState:UIControlStateNormal];
    if ([self.model.status integerValue] == 3 && self.biddingDic) {
        [biddingButton setTitle:LLSTR(@"108042") forState:UIControlStateNormal];
    } else if (([self.model.status integerValue] > 3 || [self.model.status integerValue] < 3) && self.biddingDic) {
        biddingButton.hidden = YES;
    }
    if (self.biddingDic && [self.model.status integerValue] != 3) {
        self.countTF.userInteractionEnabled = NO;
        self.amountTF.userInteractionEnabled = NO;
    }
    if ([self.model.status integerValue] > 3) {
        UIImageView *imageV = [[UIImageView alloc]init];
        [self.view addSubview:imageV];
        [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.tipLabel3.mas_bottom).offset(50);
            make.width.height.equalTo(@45);
        }];
        imageV.image = Image(@"bidding_status");
        UILabel *label = [[UILabel alloc]init];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageV.mas_bottom).offset(10);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.equalTo(@40);
        }];
        label.numberOfLines = 2;
        label.font = Font(16);
        label.textAlignment = NSTextAlignmentCenter;
        if ([self.model.status integerValue] > 3 &&[self.model.status integerValue] < 9) {
            label.text = LLSTR(@"108043");
        } else if ([self.model.status integerValue] == 9) {
            YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"bidding.db"];
            NSString * storeStr =[store getStringById:self.model.batchNo fromTable:[NSString stringWithFormat:@"b%@",[BiChatGlobal sharedManager].uid]];
            if ([storeStr boolValue]) {
                NSData *amountData = [[WPAESEncrypt decryptStringWithString:[self.biddingDic objectForKey:@"encryptData"] andKey:[self.biddingDic objectForKey:@"encryptKey"]] dataUsingEncoding:NSUTF8StringEncoding];
                if (amountData) {
                    label.text = LLSTR(@"108022");
                } else {
                    label.text = LLSTR(@"108023");
                }
            } else {
                label.text = LLSTR(@"108023");
            }
        } else if ([self.model.status integerValue] > 9 && [self.model.status integerValue] < 17) {
            if (self.model.userSummary.isSubmitKey) {
                if ([[self.biddingDic objectForKey:@"status"] integerValue] == 1 || [[self.biddingDic objectForKey:@"status"] integerValue] == 4) {
                    label.text = LLSTR(@"108022");
                } else {
                    label.text = LLSTR(@"108062");
                }
            } else {
                label.text = LLSTR(@"108062");
            }
        } else if ([self.model.status integerValue] == 17) {
            if (self.model.userSummary.isSubmitKey) {
                if ([[self.biddingDic objectForKey:@"status"] integerValue] == 5) {
                    label.text = LLSTR(@"108024");
                } else if ([[self.biddingDic objectForKey:@"status"] integerValue] == 6 || [[self.biddingDic objectForKey:@"status"] integerValue] == 7) {
                    label.text = [NSString stringWithFormat:@"%@\n%@",LLSTR(@"108025"),[LLSTR(@"108061") llReplaceWithArray:@[[self.biddingDic objectForKey:@"successAmount"]]]];
                } else if ([[self.biddingDic objectForKey:@"status"] integerValue] == 3) {
                    label.text = LLSTR(@"108027");
                } else if ([[self.biddingDic objectForKey:@"status"] integerValue] == 2) {
                    label.text = LLSTR(@"108062");
                } else {
                    label.text = LLSTR(@"108026");
                }
            } else {
                label.text = LLSTR(@"108062");
            }
        } else if ([self.model.status integerValue] == 18) {
            label.text = LLSTR(@"108062");
        } else if ([self.model.status integerValue] == 19) {
            label.text = LLSTR(@"108062");
        }
    }
}
//提交
- (void)doBiddding {
    [self.view endEditing:YES];
    //撤单
    WPEncryptModel *model = [WPEncryptionObject getEncryptModelByNo:self.model.batchNo];
    if ([self.model.status integerValue] == 3 && self.biddingDic) {
        [self cancelBid];
        return;
    }
    
    if ([self.countTF.text floatValue] == 0) {
        [BiChatGlobal showInfo:LLSTR(@"108106") withIcon:nil];
        return;
    }
    if ([self.amountTF.text floatValue] == 0) {
        [BiChatGlobal showInfo:LLSTR(@"108107") withIcon:nil];
        return;
    }
    
    if ([self.model.userMaxAmount integerValue] < [self.amountTF.text integerValue]) {
        [BiChatGlobal showInfo:[LLSTR(@"108108") llReplaceWithArray:@[self.model.userMaxAmount]] withIcon:nil];
        return;
    }
    
    //存储过数据
    if (model.batchNo.length > 0) {
        [self showPassWordInputWithCount:self.countTF.text amount:self.amountTF.text saveModel:model];
    }
    //未存储过数据
    else {
        [WPRSAEncrypt keyWith:^(NSString * _Nonnull pubKey, NSString * _Nonnull priKey) {
            WPEncryptModel *saveModel = [[WPEncryptModel alloc]init];
            saveModel.batchNo = self.model.batchNo;
            saveModel.aesKey = [WPEncryptionObject geAEStEncodId:16];
            saveModel.rsaPublicKey = pubKey;
            saveModel.rsaPrivateKey = priKey;
            saveModel.encryptId = [BiChatGlobal getUuidString];
            [WPEncryptionObject saveModel:saveModel];
            [self showPassWordInputWithCount:self.countTF.text amount:self.amountTF.text saveModel:saveModel];
        }];
    }
}

- (void)showPassWordInputWithCount:(NSString *)count amount:(NSString *)amount saveModel:(WPEncryptModel *)saveModel{
    WEAKSELF;
    self.passView = [[WPProductInputView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64))];
    [self.view addSubview:self.passView];
    NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.model.castCoinType];
    [self.passView setCoinImag:[coinInfo objectForKey:@"imgGold"] count:count coinName:[coinInfo objectForKey:@"dSymbol"] payTo:nil payDesc:LLSTR(@"108046")  wallet:0];
    NSDictionary *amountDic = @{@"amount":[NSString stringWithFormat:@"%@",amount]};
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:amountDic options:NSJSONWritingPrettyPrinted error:nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:amountDic options:0 error:0];
    NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    self.passView.closeBlock = ^{
        [weakSelf.passView removeFromSuperview];
        weakSelf.passView = nil;
    };
    self.passView.passwordInputBlock = ^(NSString *password) {
        NSString *encryptData = [WPAESEncrypt encryptStringWithString:dataStr andKey:saveModel.aesKey];
        NSString *pass = [password md5Encode];
        
        NSMutableString *sign = [NSMutableString string];
        [sign appendString:@"batchNo="];
        [sign appendString:weakSelf.model.batchNo];
        [sign appendString:@"&encryptData="];
        [sign appendString:encryptData];
        [sign appendString:@"&encryptId="];
        [sign appendString:saveModel.encryptId];
        [sign appendString:@"&password="];
        [sign appendString:pass];
        [sign appendString:@"&volume="];
        [sign appendString:count];
        NSString *signStr = [WPRSAEncrypt sign:sign withPriKey:saveModel.rsaPrivateKey];
        
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:encryptData forKey:@"encryptData"];
        [paramDic setObject:count forKey:@"volume"];
        [paramDic setObject:weakSelf.model.batchNo forKey:@"batchNo"];
        [paramDic setObject:pass forKey:@"password"];
        [paramDic setObject:saveModel.rsaPublicKey forKey:@"pubKey"];
        [paramDic setObject:saveModel.encryptId forKey:@"encryptId"];
        [paramDic setObject:signStr forKey:@"sign"];
        
        
        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/saveUserBid.do" parameters:paramDic success:^(id response) {
            [NetworkModule getWallet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success) {
                    [BiChatGlobal sharedManager].dict4WalletInfo = data;
                    [[BiChatGlobal sharedManager]saveUserInfo];
                }
            }];
            [weakSelf.passView removeFromSuperview];
            weakSelf.passView = nil;
            //密码错误
            if ([[response objectForKey:@"code"] integerValue] == 20000) {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"103012") message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"103013") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showPassWordInputWithCount:count amount:amount saveModel:saveModel];
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
                return ;
            }
            if ([[response objectForKey:@"code"] integerValue] == 0) {
                [BiChatGlobal showSuccessWithString:LLSTR(@"108101")];
                if (weakSelf.RefreshBlock) {
                    weakSelf.RefreshBlock();
                }
            } else {
                [BiChatGlobal showFailWithString:LLSTR(@"108102")];
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [BiChatGlobal showFailWithString:LLSTR(@"108102")];
        }];
    };
}

- (void)cancelBid {
    [[WPBaseManager manager] postInterface:@"/Chat/Api/cancelUserBid.do" parameters:@{@"bidNo":[self.biddingDic objectForKey:@"bidNo"],@"tokenid":[BiChatGlobal sharedManager].token} success:^(id response) {
        if ([[response objectForKey:@""] integerValue] == 0) {
            if (self.RefreshBlock) {
                self.RefreshBlock();
            }
            [BiChatGlobal showSuccessWithString:LLSTR(@"108103")];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [BiChatGlobal showSuccessWithString:LLSTR(@"108104")];
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"108104")];
    }];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *tmpStr = [[NSMutableString alloc]initWithString:textField.text];
    [tmpStr replaceCharactersInRange:range withString:string];
    if ([textField isEqual:self.countTF]) {
        if ([textField.text containsString:@"."] && [string isEqualToString:@"."]) {
            return NO;
        }
        NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.model.castCoinType];
        NSArray *array = [tmpStr componentsSeparatedByString:@"."];
        if (array.count == 2) {
            NSString *pointStr = array[1];
            if (pointStr.length > [[coinInfo objectForKey:@"bit"] integerValue]) {
                return NO;
            }
        }
        if ([self.amountTF.text floatValue] > 0 && [tmpStr floatValue] > 0) {
            NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.model.castCoinType];
            NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:tmpStr];
            NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:self.amountTF.text];
            NSDecimalNumber *num3 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[self.coefficient floatValue]]];
            NSDecimalNumber *num4 = [[num1 decimalNumberByMultiplyingBy:num3] decimalNumberByDividingBy:num2];
            self.tipLabel3.text = [LLSTR(@"108040") llReplaceWithArray:@[[num4 stringValue]]];
            self.tipLabel3.text = [LLSTR(@"108040") llReplaceWithArray:@[[[num4 stringValue] accuracyCheckWithFormatterString:[coinInfo objectForKey:@"bit"] auotCheck:NO]]];
        }
        return YES;
    } else {
        if (![string isInt] && string.length > 0) {
            return NO;
        }
        if ([self.countTF.text floatValue] > 0 && [tmpStr floatValue] > 0) {
            NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:self.model.castCoinType];
            NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:self.countTF.text];
            NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:tmpStr];
            NSDecimalNumber *num3 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[self.coefficient floatValue]]];
            NSDecimalNumber *num4 = [[num1 decimalNumberByMultiplyingBy:num3] decimalNumberByDividingBy:num2];
            self.tipLabel3.text = [LLSTR(@"108040") llReplaceWithArray:@[[[num4 stringValue] accuracyCheckWithFormatterString:[coinInfo objectForKey:@"bit"] auotCheck:NO]]];
        }
        return YES;
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
