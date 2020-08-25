//
//  WPBiddingView.h
//  BiChat
//
//  Created by iMac on 2019/2/27.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPBiddingActivityDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPBiddingView : UIView

- (void)fillData:(NSDictionary *)data;

@property (nonatomic,strong)WPBiddingActivityDetailModel *model;
@property (nonatomic,strong)NSDictionary *receiveData;
@property (nonatomic,copy)void (^CheckBlock)(NSDictionary *dict);
@property (nonatomic,copy)void (^ResultCheckBlock)(void);

@end

NS_ASSUME_NONNULL_END
