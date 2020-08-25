//
//  UpgradeChargeGroupViewController.h
//  BiChat
//
//  Created by imac2 on 2019/3/14.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyWalletViewController.h"

NS_ASSUME_NONNULL_BEGIN

#define UPGRADECHARGE_HEADER_HEIGHT                             120
#define UPGRADECHARGE_FOOTER_HEIGHT                             70

@interface UpgradeChargeGroupViewController : UITableViewController<CoinSelectDelegate, UITextFieldDelegate>
{
    //内部数据
    NSString *tip1;
    NSString *tip2;
    CGRect rect1;
    CGRect rect2;
    UIButton *button4UpgradeImp;
    NSString *newGroupName;
    
    NSString *str4SelectedCoinDisplayName;
    NSString *str4SelectedCoinIconUrl;
    NSString *str4SelectedCoinIconWhiteUrl;
    NSString *str4SelectedCoinIconGoldUrl;
    CGFloat selectedCoinTransferMax;
    NSInteger selectedCoinBit;
    NSInteger trailTime;                        //试用时间（秒）
    BOOL oldGroupUserTrail;                     //老用户是否开始试用
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@property (nonatomic, strong) NSString *str4SelectedCoinName;
@property (nonatomic, strong) UITextField *input4Count;

@end

NS_ASSUME_NONNULL_END
