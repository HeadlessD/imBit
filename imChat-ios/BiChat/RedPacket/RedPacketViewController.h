//
//  RedPacketViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPBaseViewController.h"
#import "MyForceViewController.h"

@interface RedPacketViewController : WPBaseViewController <WeChatBindingNotify>

@property (nonatomic, readonly)MyForceViewController *myForceViewController;

@end
