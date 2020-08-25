//
//  WPDiscoveryListViewController.h
//  BiChat
//
//  Created by iMac on 2018/12/26.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface WPDiscoveryListViewController : WPBaseViewController

@property (nonatomic,assign)NSInteger selectItem;

+ (id)shareInstance;

- (void)pushNewsReceived:(NSDictionary *)pushNews;
- (void)deleteNewsReceived:(NSDictionary *)pushNews;

@end

NS_ASSUME_NONNULL_END
