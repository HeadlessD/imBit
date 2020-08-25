//
//  WPMyInviterViewController.h
//  BiChat Dev
//
//  Created by iMac on 2018/9/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"

@interface WPMyInviterViewController : WPBaseViewController<UITextFieldDelegate>
{
    UIButton *button4Confirm;
    UIButton *button4RefCodeInputOK;
}

@property (nonatomic,strong)NSDictionary *inviterDic;
@property (nonatomic) BOOL dismissOnFinish;

@end
