//
//  BindWeChat@RegisterViewController.h
//  BiChat
//
//  Created by Admin on 2018/4/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BindWeChat_RegisterViewController : UIViewController<WeChatBindingNotify>

@property (nonatomic, retain) NSDictionary *myInviterInfo;

@end
