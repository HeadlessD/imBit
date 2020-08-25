//
//  ExchangeMoneyInfoViewController.h
//  BiChat
//
//  Created by imac2 on 2018/11/7.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExchangeMoneyViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExchangeMoneyInfoViewController : UIViewController
{
    NSMutableDictionary *exchangeMoneyInfo;
}

@property (nonatomic, retain) id<ExchangeMoneyDelegate> delegate;
@property (nonatomic, retain) NSString *peerUid;
@property (nonatomic, retain) NSString *peerNickName;
@property (nonatomic, retain) NSString *peerAvatar;
@property (nonatomic, retain) NSString *selectedCoinName;
@property (nonatomic, retain) NSString *selectedCoinIcon;
@property (nonatomic) CGFloat count;
@property (nonatomic, retain) NSString *selectedExchangeCoinName;
@property (nonatomic, retain) NSString *selectedExchangeCoinIcon;
@property (nonatomic) CGFloat exchangeCount;
@property (nonatomic, retain) NSString *transactionId;
@property (nonatomic, retain) NSString *memo;
@property (nonatomic, retain) NSString *time;

@end

NS_ASSUME_NONNULL_END
