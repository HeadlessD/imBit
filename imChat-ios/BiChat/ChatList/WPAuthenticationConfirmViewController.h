//
//  WPAuthenticationConfirmViewController.h
//  BiChat
//
//  Created by iMac on 2018/12/11.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPAuthenticationConfirmViewController : UIViewController

@property (nonatomic,strong)NSDictionary *contentDic;
@property (nonatomic,strong)NSDictionary *scanDic;

@property (nonatomic,copy) void (^ConfirmBlock)(void);
@property (nonatomic,copy) void (^CancelBlock)(void);

@end

NS_ASSUME_NONNULL_END
