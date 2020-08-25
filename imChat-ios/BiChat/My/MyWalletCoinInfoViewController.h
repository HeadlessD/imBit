//
//  MyWalletCoinInfoViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuotationView.h"

@interface MyWalletCoinInfoViewController : UIViewController<QuotationOperationDelegate>
{
    QuotationView *view4CoinQuotation;
    
    //界面相关
    UILabel *label4CurrentQuotation;
    UILabel *label4CurrentChg;
    UIButton *button4OneDay;
    UIButton *button4OneWeek;
    UIButton *button4OneMonth;
    UIButton *button4SixMonth;
    UIButton *button4All;
    UILabel *label4CoinValue;
    UILabel *label4QuotationError;
    
    //钱包地址窗口
    UIView *view4WalletAddress;
    NSString *walletAddress;
    
    NSInteger currentSelect;
    
    //内部数据
    BOOL internalQuotationDataOK;
    id internalQuotationData;
    BOOL showCurrentQuotation;
    NSNumber *beginQuotation;
    NSNumber *currentQuotation;
    NSNumber *selectedQuotation;
    NSTimer *timer4FreshCurrentQuotation;
}

@property (nonatomic, retain) NSMutableDictionary *coinInfo;
@property (nonatomic, retain) NSString *coinName;
@property (nonatomic, retain) NSString *symbol;
@property (nonatomic, retain) NSString *coinCode;
@property (nonatomic) double coinCount;
@property (nonatomic) double price;

@end
