//
//  WPBiddingDetailViewController.h
//  BiChat
//
//  Created by iMac on 2019/3/8.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"
#import "WPBiddingActivityDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPBiddingDetailViewController : WPBaseViewController

@property (nonatomic,strong)UIView *bottomV;
@property (nonatomic,strong)UITextField *countTF;
@property (nonatomic,strong)UITextField *amountTF;

@property (nonatomic,strong)WPBiddingActivityDetailModel *model;
@property (nonatomic,strong)NSString *coefficient;
@property (nonatomic,strong)NSDictionary *biddingDic;

@property (nonatomic,copy)void (^RefreshBlock)(void);
@property (nonatomic,copy)void (^BiddingBlock)(NSString *count,NSString *amount);


@end

NS_ASSUME_NONNULL_END
