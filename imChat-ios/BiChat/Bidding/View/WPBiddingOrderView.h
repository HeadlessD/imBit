//
//  WPBiddingOrderView.h
//  BiChat
//
//  Created by iMac on 2019/3/4.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPBiddingActivityDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPBiddingOrderView : UIView <UITextFieldDelegate>

@property (nonatomic,strong)UIView *bottomV;
@property (nonatomic,strong)UITextField *countTF;
@property (nonatomic,strong)UITextField *amountTF;

@property (nonatomic,strong)WPBiddingActivityDetailModel *model;

@property (nonatomic,copy)void (^CancelBlock)(void);
@property (nonatomic,copy)void (^BiddingBlock)(NSString *count,NSString *amount);


- (void)fillData:(WPBiddingActivityDetailModel *)data;

- (void)show;

@end

NS_ASSUME_NONNULL_END
