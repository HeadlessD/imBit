//
//  LoginPortalViewController.h
//  BiChat
//
//  Created by imac2 on 2018/7/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginPortalViewController : UIViewController<WeChatBindingNotify>
{
    UIButton *button4WeChatLogin;
    UIButton *button4MobileLogin;
}

@property (nonatomic, retain) NSArray *loginOrder;

@end
