//
//  LoginViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountrySelectorViewController.h"

@interface LoginViewController :UITableViewController<CountrySelectDelegate, WeChatBindingNotify>
{    
    //内部使用变量
    NSInteger weChatLoginState;     //1-in progress; 2-success; 3-newUser success; 4-fail
    UILabel *label4Flag;
    UILabel *label4Country;
    UILabel *label4CountryCode;
    UITextField *input4Mobile;

    //内部使用数据
    NSString *currentSelectedCountryFlag;
    NSString *currentSelectedCountryCode;
    NSString *currentSelectedCountryName;
    NSString *currentSelectedMobile;
    BOOL tryingLogin;
    NSInteger internetReachability;
    NSTimer *timer4TestNetworkState;
    BOOL CellularDataRestricted;

    //界面相关
    UIView *view4HintWnd;
    UIEdgeInsets orignalContentInset;
}

@property (nonatomic) BOOL canBack;
@property (nonatomic, retain) NSDictionary *weChatLoginParameters;
@property (nonatomic, retain) NSArray *loginOrder;
@property (nonatomic, retain) NSDictionary *myInviterInfo;

@end
