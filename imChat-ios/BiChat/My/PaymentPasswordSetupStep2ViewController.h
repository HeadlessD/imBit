//
//  PaymentPasswordSetupStep2ViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import <UIKit/UIKit.h>

@interface PaymentPasswordSetupStep2ViewController : UIViewController
{
    UITextField *input4Password;
    UIView *view4Password1;
    UIView *view4Password2;
    UIView *view4Password3;
    UIView *view4Password4;
    UIView *view4Password5;
    UIView *view4Password6;
    
    UIView *view4Seperator1;
    UIView *view4Seperator2;
    UIView *view4Seperator3;
    UIView *view4Seperator4;
    UIView *view4Seperator5;
    UIView *view4Seperator6;
}

@property (nonatomic, weak) id<PaymentPasswordSetDelegate> delegate;
@property (nonatomic) NSInteger cookie;
@property (nonatomic, retain) NSString *password;

@end
