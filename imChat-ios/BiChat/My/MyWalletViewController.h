//
//  MyWalletViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoinSelectDelegate <NSObject>
@optional
- (void)coinSelected:(NSString *)coinName
     coinDisplayName:(NSString *)coinDisplayName
            coinIcon:(NSString *)coinIcon
       coinIconWhite:(NSString *)coinIconWhite
        coinIconGold:(NSString *)coinIconGold
             balance:(CGFloat)balance
                 bit:(NSInteger)bit;
@end


@interface MyWalletViewController : UITableViewController
{
    NSMutableDictionary *myWalletDetail;
    double totalAssetValue;
    NSMutableDictionary *coinQuotation;
    
    //界面相关
    NSTimer *timer4Refresh;
}

@property (nonatomic, weak) id<CoinSelectDelegate> delegate;
@property (nonatomic) BOOL showZeroCoin;

@end
