//
//  VerifyViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifyViewController : UITableViewController
{
    UILabel *label4Hint;
    UITextField *input4VerifyCode;
    UIButton *button4ResendVerifyCode;
    UIButton *button4VoiceVerify;
    UILabel *label4ResendVerifyCodeHint;
    
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
    
    NSTimer *timer4ResendVerifyCode;
    BOOL verifyProcessing;
}

@property (nonatomic, retain) NSString *areaCode;
@property (nonatomic, retain) NSString *mobile;
@property (nonatomic, retain) NSDictionary *weChatLoginParameters;
@property (nonatomic, retain) NSDictionary *myInviterInfo;

@end
