//
//  WPWebVerificationViewController.h
//  BiChat
//
//  Created by iMac on 2018/12/21.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPWebVerificationViewController : WPBaseViewController
@property (nonatomic,strong)NSDictionary *contentDic;

@property (nonatomic,copy) void (^ConfirmBlock)(void);
@property (nonatomic,copy) void (^CancelBlock)(void);

@end

NS_ASSUME_NONNULL_END
