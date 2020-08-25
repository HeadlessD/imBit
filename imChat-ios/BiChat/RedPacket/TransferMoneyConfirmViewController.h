//
//  TransferMoneyConfirmViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransferMoneyViewController.h"

@interface TransferMoneyConfirmViewController : UIViewController
{
    NSMutableDictionary *transactionInfo;
}

@property (nonatomic, weak) id<TransferMoneyDelegate>delegate;
@property (nonatomic, retain) NSString *senderNickName;
@property (nonatomic, retain) NSString *receiverNickName;
@property (nonatomic, retain) NSString *selectedCoinName;
@property (nonatomic, retain) NSString *selectedCoinIcon;
@property (nonatomic) CGFloat count;
@property (nonatomic, retain) NSString *transactionId;
@property (nonatomic, retain) NSString *memo;
@property (nonatomic, retain) NSString *time;

@end

