//
//  PaymentPasswordSetupStep1ViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import <UIKit/UIKit.h>

@interface PaymentPasswordSetupStep1ViewController : UIViewController
{
    UITextField *input4Password;
    UIView *view4Password1;
    UIView *view4Password2;
    UIView *view4Password3;
    UIView *view4Password4;
    UIView *view4Password5;
    UIView *view4Password6;
}

@property (nonatomic, weak) id<PaymentPasswordSetDelegate> delegate;
@property (nonatomic) NSInteger cookie;
@property (nonatomic) BOOL resetPassword;

@end
