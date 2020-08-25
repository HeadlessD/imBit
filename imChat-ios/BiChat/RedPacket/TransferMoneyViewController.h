//
//  TransferMoneyViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/29.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyWalletViewController.h"

@protocol TransferMoneyDelegate <NSObject>
@optional
- (void)transferMoneySuccess:(NSString *)coinName
                 coinIconUrl:(NSString *)coinIconUrl
            coinIconWhiteUrl:(NSString *)coinIconWhiteUrl
                       count:(CGFloat)count
               transactionId:(NSString *)transactionId
                        memo:(NSString *)memo;
- (void)transferMoneyReceived:(NSString *)transactionId;
- (void)transferMoneyRecalled:(NSString *)transactionId;
@end

@interface TransferMoneyViewController : UITableViewController<CoinSelectDelegate, UITextFieldDelegate>
{
    //界面相关
    UIImageView *image4CoinIcon;
    UILabel *label4CoinName;
    UITextField *input4Memo;
    UIButton *button4ConfirmTransfer;
    
    //内部数据
    NSString *str4SelectedCoinDisplayName;
    NSString *str4SelectedCoinIconUrl;
    NSString *str4SelectedCoinIconWhiteUrl;
    NSString *str4SelectedCoinIconGoldUrl;
    CGFloat selectedCoinTransferMax;
    NSInteger selectedCoinBit;
    UIView *view4InputPassword;
}

@property (nonatomic, strong) NSString *str4SelectedCoinName;
@property (nonatomic, strong) UITextField *input4Count;
@property (nonatomic, weak) id<TransferMoneyDelegate> delegate;
@property (nonatomic, retain) NSString *peerId;
@property (nonatomic, retain) NSString *peerNickName;
@property (nonatomic, retain) NSString *peerAvatar;
//是否自动接收
@property (nonatomic, assign) BOOL authCheck;
@property (nonatomic, strong) NSString *ticket;

@end;
