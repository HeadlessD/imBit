//
//  TransferMoneySuccessViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/31.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransferMoneyViewController.h"

@interface TransferMoneySuccessViewController : UIViewController

@property (nonatomic, weak) id<TransferMoneyDelegate> delegate;
@property (nonatomic, retain) NSString *peerNickName;
@property (nonatomic, retain) NSString *selectedCoinName;
@property (nonatomic, retain) NSString *selectedCoinIcon;
@property (nonatomic, retain) NSString *selectedCoinIconWhite;
@property (nonatomic) CGFloat count;
@property (nonatomic, retain) NSString *transactionId;
@property (nonatomic, retain) NSString *memo;
@property (nonatomic, assign) BOOL authCheck;
 
@end
