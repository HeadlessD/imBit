//
//  ModifyChargeGroupViewController.h
//  BiChat
//
//  Created by imac2 on 2019/3/18.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyWalletViewController.h"

NS_ASSUME_NONNULL_BEGIN

#define MODIFYCHARGE_HEADER_HEIGHT                             120
#define MODIFYCHARGE_FOOTER_HEIGHT                             10

@interface ModifyChargeGroupViewController : UITableViewController<CoinSelectDelegate, UITextFieldDelegate>
{
    //内部数据
    BOOL modified;
    UIButton *button4ModifyImp;
    NSString *tip1;
    CGRect rect1;
    
    NSString *str4SelectedCoinDisplayName;
    NSString *str4SelectedCoinIconUrl;
    NSString *str4SelectedCoinIconWhiteUrl;
    NSString *str4SelectedCoinIconGoldUrl;
    CGFloat selectedCoinTransferMax;
    NSInteger selectedCoinBit;
    NSInteger trailTime;                        //试用时间（秒）
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@property (nonatomic, strong) NSString *str4SelectedCoinName;
@property (nonatomic, strong) UITextField *input4Count;

@end

NS_ASSUME_NONNULL_END
