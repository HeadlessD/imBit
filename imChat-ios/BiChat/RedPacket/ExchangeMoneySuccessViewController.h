//
//  ExchangeMoneySuccessViewController.h
//  BiChat Dev
//
//  Created by worm_kc on 2018/11/5.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExchangeMoneyViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExchangeMoneySuccessViewController : UIViewController

@property (nonatomic, weak) id<ExchangeMoneyDelegate> delegate;
@property (nonatomic, retain) NSString *peerNickName;
@property (nonatomic, retain) NSString *selectedCoinName;
@property (nonatomic, retain) NSString *selectedCoinIcon;
@property (nonatomic, retain) NSString *selectedCoinIconWhite;
@property (nonatomic) CGFloat count;
@property (nonatomic, retain) NSString *selectedExchangeCoinName;
@property (nonatomic, retain) NSString *selectedExchangeCoinIcon;
@property (nonatomic, retain) NSString *selectedExchangeCoinIconWhite;
@property (nonatomic) CGFloat exchangeCount;
@property (nonatomic, retain) NSString *transactionId;
@property (nonatomic, retain) NSString *memo;

@end

NS_ASSUME_NONNULL_END
