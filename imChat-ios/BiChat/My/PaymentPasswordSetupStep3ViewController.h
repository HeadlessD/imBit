//
//  PaymentPasswordSetupStep3ViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import <UIKit/UIKit.h>

@interface PaymentPasswordSetupStep3ViewController : UIViewController
{
    UILabel *label4CodeTarget;
    UITextField *input4VerifyCode;
    
    UIView *view4Seperator1;
    UIView *view4Seperator2;
    UIView *view4Seperator3;
    UIView *view4Seperator4;
    UIView *view4Seperator5;
    UIView *view4Seperator6;
    
    UILabel *view4VerifyCode1;
    UILabel *view4VerifyCode2;
    UILabel *view4VerifyCode3;
    UILabel *view4VerifyCode4;
    UILabel *view4VerifyCode5;
    UILabel *view4VerifyCode6;

    UILabel *label4ResendHintInfo;
    UIButton *button4ResendVerifyCode;
    NSTimer *timer4ResendVerifyCode;
    BOOL verifyProcessing;
}

@property (nonatomic, weak) id<PaymentPasswordSetDelegate> delegate;
@property (nonatomic) NSInteger cookie;
@property (nonatomic, retain) NSString *password;

@end
