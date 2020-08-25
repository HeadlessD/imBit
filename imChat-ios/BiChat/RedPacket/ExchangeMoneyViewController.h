//
//  ExchangeMoneyViewController.h
//  BiChat Dev
//
//  Created by imac2 on 2018/11/2.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyWalletViewController.h"

@protocol ExchangeMoneyDelegate <NSObject>
@optional
- (void)exchangeMoneySuccess:(NSString *)coinName
                 coinIconUrl:(NSString *)coinIconUrl
            coinIconWhiteUrl:(NSString *)coinIconWhiteUrl
                       count:(CGFloat)count
            exchangeCoinName:(NSString *)exchangeCoinName
         exchangeCoinIconUrl:(NSString *)exchangeCoinIconUrl
    exchangeCoinIconWhiteUrl:(NSString *)exchangeCoinIconWhiteUrl
               exchangeCount:(CGFloat)exchangeCount
               transactionId:(NSString *)transactionId
                        memo:(NSString *)memo;
- (void)exchangeMoneyReceived:(NSString *)transactionId;
- (void)exchangeMoneyRecalled:(NSString *)transactionId;
@end

@interface ExchangeMoneyViewController : UITableViewController<CoinSelectDelegate, UITextFieldDelegate>
{
    //界面相关
    UIImageView *image4CoinIcon;
    UILabel *label4CoinName;
    UITextField *input4Count;
    UITextField *input4ExchangeCount;
    UILabel *label4Gwei;
    UILabel *label4ExchangeGwei;
    UITextField *input4Memo;
    
    //内部数据
    NSInteger selectedCoinTarget;
    NSString *str4SelectedCoinName;
    NSString *str4SelectedCoinDisplayName;
    NSString *str4SelectedCoinIconUrl;
    NSString *str4SelectedCoinIconWhiteUrl;
    NSString *str4SelectedCoinIconGoldUrl;
    CGFloat selectedCoinExchangeMax;
    NSInteger selectedCoinBit;
    NSString *currentSelectedExpireType;
    CGFloat currentSelectedExpireInterval;
    
    NSString *str4SelectedExchangeCoinName;
    NSString *str4SelectedExchangeCoinDisplayName;
    NSString *str4SelectedExchangeCoinIconUrl;
    NSString *str4SelectedExchangeCoinIconWhiteUrl;
    NSString *str4SelectedExchangeCoinIconGoldUrl;
    NSInteger selectedExchangeCoinBit;
    
    UIView *view4InputPassword;
}

@property (nonatomic, weak) id<ExchangeMoneyDelegate> delegate;
@property (nonatomic, retain) NSString *peerId;
@property (nonatomic, retain) NSString *peerNickName;
@property (nonatomic, retain) NSString *peerAvatar;
@property (nonatomic, assign) BOOL isGroup;

@end
