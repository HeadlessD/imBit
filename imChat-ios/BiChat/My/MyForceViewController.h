//
//  MyForceViewController.h
//  BiChat
//
//  Created by imac2 on 2018/8/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatSelectViewController.h"

@interface MyForceViewController : UITableViewController<ChatSelectDelegate, PaymentPasswordSetDelegate, WeChatBindingNotify>
{
    //内部数据
    NSMutableArray *array4ForceMenu;
    NSMutableArray *array4TaskMenu;
    NSInteger currentShowForceNumber;
    NSMutableDictionary *dict4MyForceInfo;
    NSMutableArray *array4Timers;
    NSMutableArray *array4AleradyGetBubble;
    
    //界面元素
    UIView *view4ForceFrameBk;
    UILabel *label4TodayForce;
    
    //wizard
    BOOL inWizard;
    NSInteger newUserWizardStep;
    UIView *new4UserWizard;
    CGRect wizardStep1HighlightRect;
    CGRect wizardStep2HighlightRect;
}

@property (nonatomic,strong)UINavigationController *pushNAVC;
@property (nonatomic,strong)NSMutableDictionary *dict4MyUnlockInfo;

- (void)refreshGUI;
- (void)showNewUserWizard;

@end
