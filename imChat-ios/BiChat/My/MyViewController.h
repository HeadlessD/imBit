//
//  MyViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import <UIKit/UIKit.h>

@interface MyViewController : UITableViewController<PaymentPasswordSetDelegate>
{
    //界面相关
    UIImageView *image4NewVersionFlag1;
    UIImageView *image4NewVersionFlag2;
    BOOL feedbackProcessing;
    NSTimer *timer4CheckMyBidInfo;
    
    //token相关
    UIImageView *image4CurrentStepIndicator;
    UILabel *label4CurrentStep;
    UIView *view4CurrentStep;
    UIView *view4TotalStep;
    UILabel *label4CurrentStepHint;
    UILabel *label4CountingDown;
        
    NSTimer *timer4CountingDown;
    
    //新手提示
    NSInteger newUserWizardStep;
    UIView *new4UserWizard;
    CGRect wizardStep1HighlightRect;
}

- (void)showNewUserWizard;

@end
