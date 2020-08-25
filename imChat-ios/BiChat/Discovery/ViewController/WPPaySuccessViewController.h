//
//  WPPaySuccessViewController.h
//  BiChat
//
//  Created by iMac on 2018/12/18.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPPaySuccessViewController : WPBaseViewController

@property (nonatomic,strong)NSDictionary *resultDic;
@property (nonatomic,copy)void (^backBlock)(NSString *url);

@end

NS_ASSUME_NONNULL_END
