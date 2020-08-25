//
//  LoginViewController.m
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "NetworkModule.h"
#import "LoginViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "JSONKit.h"
#import "ChatViewController.h"
#import "VerifyViewController.h"
#import "pinyin.h"
#import "CountrySelectorViewController.h"
#import "WPNewsDetailViewController.h"
#import "WXApi.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCellularData.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101016") style:UIBarButtonItemStylePlain target:self action:@selector(onButtonNext:)];
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //是否可以回退
    if (!self.canBack)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //初始化最初的地区选择
    if ([BiChatGlobal sharedManager].lastLoginAreaCode.length == 0)
    {
        NSLocale *locale = [NSLocale currentLocale];
        currentSelectedCountryCode = [BiChatGlobal getAreaCodeByCountryCode:[locale countryCode]];
        currentSelectedCountryFlag = [BiChatGlobal getCountryFlagByAreaCode:currentSelectedCountryCode];
        currentSelectedCountryName = [BiChatGlobal getCountryNameByAreaCode:currentSelectedCountryCode];
    }
    else
    {
        currentSelectedCountryCode = [BiChatGlobal sharedManager].lastLoginAreaCode;
        currentSelectedMobile = [BiChatGlobal sharedManager].lastLoginUserName;
        currentSelectedCountryName = [BiChatGlobal getCountryNameByAreaCode:currentSelectedCountryCode];
        currentSelectedCountryFlag = [BiChatGlobal getCountryFlagByAreaCode:currentSelectedCountryCode];
    }

    //UFileAPI *api = [[UFileAPI alloc]initWithBucket:@""];
    //[api putFile:@"ddd" authorization:@"dddd" option:nil data:nil progress:nil success:nil failure:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //监视网络状态
    internetReachability = AFNetworkReachabilityStatusReachableViaWiFi;
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        internetReachability = status;
    }];
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState restrictedState) {
        switch (restrictedState) {
            case kCTCellularDataRestrictedStateUnknown:
                CellularDataRestricted = NO;
                break;
            case kCTCellularDataRestricted:
                CellularDataRestricted = YES;
                break;
            case kCTCellularDataNotRestricted:
                CellularDataRestricted = NO;
                break;
            default:
                CellularDataRestricted = NO;
                break;
        }
    };
    
    [timer4TestNetworkState invalidate];
    timer4TestNetworkState = [NSTimer scheduledTimerWithTimeInterval:.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        self.navigationItem.title = @"";
        self.navigationItem.titleView = nil;
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        
        if (internetReachability != AFNetworkReachabilityStatusReachableViaWiFi &&
            internetReachability != AFNetworkReachabilityStatusReachableViaWWAN)
        {
            [BiChatGlobal sharedManager].date4NetworkBroken = nil;
            if (networkInfo.currentRadioAccessTechnology == nil)
            {
                self.navigationItem.rightBarButtonItem.enabled = NO;
                [self setHint:LLSTR(@"101141")];
            }
            else if (CellularDataRestricted)
            {
                self.navigationItem.rightBarButtonItem.enabled = NO;
                [self setHint:LLSTR(@"101142")];
            }
            else
            {
                self.navigationItem.rightBarButtonItem.enabled = NO;
                [self setHint:LLSTR(@"101143")];
            }
        }
        else
        {
            [self setHint:nil];
            if ([BiChatGlobal sharedManager].networkState == 200)
            {
                [BiChatGlobal sharedManager].date4NetworkBroken = nil;
                if (!tryingLogin)
                    self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            else
            {
                static UIView *view4Title = nil;
                if (view4Title == nil)
                {
                    NSString *title = LLSTR(@"101144");
                    CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}
                                                      context:nil];
                    view4Title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 40, 40)];
                    
                    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 40)];
                    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                    [view4Title addSubview:activityView];
                    [activityView startAnimating];
                    
                    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, rect.size.width, 40)];
                    label4Title.text = LLSTR(@"101144");
                    [view4Title addSubview:label4Title];
                }
                self.navigationItem.titleView = view4Title;
                self.navigationItem.title = @"";
                self.navigationItem.rightBarButtonItem.enabled = NO;
                if ([BiChatGlobal sharedManager].date4NetworkBroken == nil)
                {
                    [BiChatGlobal sharedManager].date4NetworkBroken = [NSDate date];
                }
                else if ([[NSDate date]timeIntervalSinceDate:[BiChatGlobal sharedManager].date4NetworkBroken] > SHOW_NETWORK_HINT_DELAY)
                {
                    [self setHint:LLSTR(@"101143")];
                }
            }
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer4TestNetworkState invalidate];
    timer4TestNetworkState = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 300;
    else if (indexPath.row == 1)
    {
        if (isIphonex)
            return self.view.frame.size.height - 300 - 30;
        else
            return self.view.frame.size.height - 300;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.row == 0)
    {
        if (self.weChatLoginParameters != nil && (weChatLoginState == 1 || weChatLoginState == 2))
        {
            CGFloat bk_height = self.view.frame.size.width / 766 * 911;
            UIImageView *image4Bk = [[UIImageView alloc]initWithFrame:CGRectMake(-5, 0, self.view.frame.size.width + 10, bk_height)];
            image4Bk.image = [UIImage imageNamed:@"loginPortal_bk"];
#ifdef ENV_V_DEV
            image4Bk.image = [UIImage imageNamed:@"loginPortal_bk_v"];
#endif
            [cell.contentView addSubview:image4Bk];
            
            UIButton *button4WeChatLogin = [[UIButton alloc]initWithFrame:CGRectMake(40, bk_height - 80, self.view.frame.size.width - 80, 50)];
            button4WeChatLogin.backgroundColor = [UIColor clearColor];
            button4WeChatLogin.layer.cornerRadius = 5;
            button4WeChatLogin.clipsToBounds = YES;
            button4WeChatLogin.layer.borderColor = [UIColor whiteColor].CGColor;
            button4WeChatLogin.layer.borderWidth = 0.5;
            [button4WeChatLogin setTitle:LLSTR(@"107108") forState:UIControlStateNormal];
            [button4WeChatLogin setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [button4WeChatLogin setImage:[UIImage imageNamed:@"wechat_logo"] forState:UIControlStateNormal];
            [button4WeChatLogin addTarget:self action:@selector(onButtonWeChatLogin:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button4WeChatLogin];
            button4WeChatLogin.userInteractionEnabled = NO;
        }
        else
        {
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(30, 30, self.view.frame.size.width - 60, 30)];
            if (self.weChatLoginParameters != nil)
            {
                if (weChatLoginState == 4)
                    label4Title.text = LLSTR(@"107111");
                else
                    label4Title.text = LLSTR(@"107113");
            }
            else
                label4Title.text = LLSTR(@"107111");
            label4Title.font = [UIFont systemFontOfSize:24];
            label4Title.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label4Title];
            
            UILabel *label4Subtitle = [[UILabel alloc]initWithFrame:CGRectMake(30, 60, self.view.frame.size.width - 60, 40)];
            if (self.weChatLoginParameters != nil)
            {
                if (weChatLoginState == 4)
                    label4Subtitle.text = LLSTR(@"107112");
                else
                    label4Subtitle.text = LLSTR(@"107114");
            }
            else
                label4Subtitle.text = LLSTR(@"107112");
            label4Subtitle.textAlignment = NSTextAlignmentCenter;
            label4Subtitle.numberOfLines = 0;
            label4Subtitle.font = [UIFont systemFontOfSize:14];
            label4Subtitle.textColor = [UIColor grayColor];
            [cell.contentView addSubview:label4Subtitle];
            
            UIImageView *image_arrow_down = [[UIImageView alloc]initWithFrame:CGRectMake(60, 190, 17, 8)];
            image_arrow_down.image = [UIImage imageNamed:@"arrow_down"];
            [cell.contentView addSubview:image_arrow_down];
            
            UIView *view4Seperator0 = [[UIView alloc]initWithFrame:CGRectMake(40, 140, self.view.frame.size.width - 80, 0.5)];
            view4Seperator0.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [cell.contentView addSubview:view4Seperator0];
            
            UIView *view4Seperator1 = [[UIView alloc]initWithFrame:CGRectMake(40, 190, 20, 0.5)];
            view4Seperator1.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [cell.contentView addSubview:view4Seperator1];
            
            UIView *view4Seperator2 = [[UIView alloc]initWithFrame:CGRectMake(77, 190, self.view.frame.size.width - 117, 0.5)];
            view4Seperator2.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [cell.contentView addSubview:view4Seperator2];
            
            UIView *view4Seperator3 = [[UIView alloc]initWithFrame:CGRectMake(100, 190, 0.5, 50)];
            view4Seperator3.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [cell.contentView addSubview:view4Seperator3];
            
            UIView *view4Seperator4 = [[UIView alloc]initWithFrame:CGRectMake(40, 240, self.view.frame.size.width - 80, 0.5)];
            view4Seperator4.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [cell.contentView addSubview:view4Seperator4];
            
            UIImageView *image4MoreCountry = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_right"]];
            image4MoreCountry.center = CGPointMake(self.view.frame.size.width - 50, 165);
            [cell.contentView addSubview:image4MoreCountry];
            
            UIButton *button4MoreCountry = [[UIButton alloc]initWithFrame:CGRectMake(40, 140, self.view.frame.size.width - 80, 50)];
            [button4MoreCountry addTarget:self action:@selector(onButtonMoreCountry:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button4MoreCountry];
            
            if (label4Flag == nil)
            {
                label4Flag = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
                label4Flag.text = currentSelectedCountryFlag;
                label4Flag.center = CGPointMake(55, 165);
            }
            [cell.contentView addSubview:label4Flag];
            
            if (label4Country == nil)
            {
                label4Country = [[UILabel alloc]initWithFrame:CGRectMake(75, 140, self.view.frame.size.width - 140, 50)];
                label4Country.text = currentSelectedCountryName;
                label4Country.adjustsFontSizeToFitWidth = YES;
                label4Country.font = [UIFont systemFontOfSize:16];
            }
            [cell.contentView addSubview:label4Country];
            
            if (label4CountryCode == nil)
            {
                label4CountryCode = [[UILabel alloc]initWithFrame:CGRectMake(40, 190, 60, 50)];
                label4CountryCode.text = currentSelectedCountryCode;
                label4CountryCode.textAlignment = NSTextAlignmentCenter;
                label4CountryCode.adjustsFontSizeToFitWidth = YES;
                label4CountryCode.font = [UIFont systemFontOfSize:16];
            }
            [cell.contentView addSubview:label4CountryCode];
            
            if (input4Mobile == nil)
            {
                input4Mobile = [[UITextField alloc]initWithFrame:CGRectMake(110, 190, self.view.frame.size.width - 150, 50)];
                input4Mobile.placeholder = currentSelectedMobile;
                input4Mobile.font = [UIFont systemFontOfSize:16];
                input4Mobile.tag = 999;
                input4Mobile.text = [BiChatGlobal sharedManager].lastLoginUserName;
                input4Mobile.keyboardType = UIKeyboardTypeNumberPad;
            }
            if (self.loginOrder.count > 1 &&
                (self.weChatLoginParameters == nil ||
                 (self.weChatLoginParameters != nil && weChatLoginState == 4)))
            {
                UIView *view4Accessory = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
                view4Accessory.backgroundColor = THEME_KEYBOARD;
                
                UIButton *button4OK = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, 2, 80, 40)];
                button4OK.titleLabel.font = [UIFont boldSystemFontOfSize:17];
                [button4OK setTitle:LLSTR(@"101022") forState:UIControlStateNormal];
                [button4OK setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button4OK addTarget:self action:@selector(onButtonInputOK:) forControlEvents:UIControlEventTouchUpInside];
                [view4Accessory addSubview:button4OK];
                
                input4Mobile.inputAccessoryView = view4Accessory;
            }
            else
                input4Mobile.inputAccessoryView = nil;
            [cell.contentView addSubview:input4Mobile];
            
            UILabel *label4Agreement = [[UILabel alloc]initWithFrame:CGRectMake(0, 250, self.view.frame.size.width, 40)];
            label4Agreement.text = LLSTR(@"107115");
            label4Agreement.font = [UIFont systemFontOfSize:12];
            label4Agreement.textColor = [UIColor grayColor];
            label4Agreement.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label4Agreement];
            
            NSString *name = LLSTR(@"107105");
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Agreement.text];
            [str addAttribute:NSForegroundColorAttributeName value:THEME_DARKBLUE range:NSMakeRange(label4Agreement.text.length - name.length, name.length)];
            label4Agreement.attributedText = str;
            
            UIButton *button4Agreement = [[UIButton alloc]initWithFrame:label4Agreement.frame];
            [button4Agreement addTarget:self action:@selector(onButtonAgreement:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button4Agreement];
        }
    }
    else if (indexPath.row == 1)
    {
        //其他登录方式
        if (self.loginOrder.count - 1 > 0)
        {
            NSInteger count = self.loginOrder.count - 1;
            UIView *view4OtherLoginMode = [[UIView alloc]initWithFrame:CGRectMake(0, 0, count * 80, 110)];
            
            for (int i = 0; i < count; i ++)
            {
                if ([[self.loginOrder objectAtIndex:(i + 1)]isEqualToString:@"w"])
                {
                    UIButton *button4WeChatLogin = [[UIButton alloc]initWithFrame:CGRectMake(i * 80, 0, 80, 110)];
                    [button4WeChatLogin setTitleColor:THEME_COLOR forState:UIControlStateNormal];
                    [button4WeChatLogin setImage:[UIImage imageNamed:@"wechat_login"] forState:UIControlStateNormal];
                    [button4WeChatLogin addTarget:self action:@selector(onButtonWeChatLogin:) forControlEvents:UIControlEventTouchUpInside];
                    [view4OtherLoginMode addSubview:button4WeChatLogin];
                    
                    UILabel *label4MobileLoginTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 90, 80, 20)];
                    label4MobileLoginTitle.text = LLSTR(@"107107");
                    label4MobileLoginTitle.font = [UIFont systemFontOfSize:12];
                    label4MobileLoginTitle.textColor = [UIColor grayColor];
                    label4MobileLoginTitle.textAlignment = NSTextAlignmentCenter;
                    [button4WeChatLogin addSubview:label4MobileLoginTitle];
                }
            }
            
            view4OtherLoginMode.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 300 - 90);
            [cell.contentView addSubview:view4OtherLoginMode];
        }
        
        //版本号
        UILabel *label4Version = [[UILabel alloc]initWithFrame:CGRectMake(15, self.view.frame.size.height - 300 - (isIphonex?50:30), self.view.frame.size.width - 30, 20)];
        label4Version.text = [NSString stringWithFormat:@"V %@", [BiChatGlobal getAppVersion]];
        label4Version.font = [UIFont systemFontOfSize:12];
        label4Version.textColor = [UIColor grayColor];
        label4Version.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label4Version];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [input4Mobile resignFirstResponder];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - CountrySelectDelegate
- (void)countrySelected:(NSString *)countryName
            countryFlag:(NSString *)countryFlag
            countryCode:(NSString *)countryCode
{
    currentSelectedCountryCode = countryCode;
    currentSelectedCountryName = countryName;
    currentSelectedCountryFlag = countryFlag;
    label4Flag.text = countryFlag;
    label4Country.text = countryName;
    label4CountryCode.text = [NSString stringWithFormat:@"%@", countryCode];
    input4Mobile.text = @"";
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (view4HintWnd)
        view4HintWnd.frame = CGRectMake(0, scrollView.contentOffset.y, self.view.frame.size.width, view4HintWnd.frame.size.height);
}

#pragma mark - WeChatBindingNotify function

- (void)weChatBindingSuccess:(NSString *)code {
    
    if (code.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301601") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    //code = @"ddddd";
    
    self.weChatLoginParameters = @{};
    weChatLoginState = 1;
    [self setHintWnd:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tableView reloadData];
        
    //开始进入微信登录阶段
    [BiChatGlobal ShowActivityIndicator];
    tryingLogin = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [NetworkModule loginByWeChat:code completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        //NSLog(@"%@", data);
        [BiChatGlobal HideActivityIndicator];
        tryingLogin = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (success)
        {
            weChatLoginState = 2;
            [self setHintWnd:nil];
            [self.navigationController setNavigationBarHidden:YES animated:NO];
            [self.tableView reloadData];
                        
            //是新用户还是老用户
            if ([[data objectForKey:@"type"]integerValue] == 1)
            {
                //进入下一步
                weChatLoginState = 3;
                [self setHintWnd:nil];
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                self.canBack = NO;
                self.weChatLoginParameters = data;
                [self.tableView reloadData];
            }
            else
            {
                [BiChatGlobal sharedManager].bLogin = YES;
                [BiChatGlobal sharedManager].loginMode = LOGIN_MODE_BY_VERIFYCODE;
                [BiChatGlobal sharedManager].token = [data objectForKey:@"token"];
                [BiChatGlobal sharedManager].uid = [data objectForKey:@"uid"];
                [BiChatGlobal sharedManager].createdTime = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"createdTime"]doubleValue] / 1000];
                [BiChatGlobal sharedManager].nickName = [data objectForKey:@"nickname"];
                [BiChatGlobal sharedManager].avatar = [data objectForKey:@"avatar"];
                [[BiChatGlobal sharedManager]saveGlobalInfo];
                
                //加载一些数据
                [[BiChatGlobal sharedManager]loadUserInfo];
                [[BiChatGlobal sharedManager]loadUserAdditionInfo];
                [[BiChatGlobal sharedManager]loadUserEmotionInfo];
                [[BiChatGlobal sharedManager]downloadAllPendingSound];
                [[DFYTKDBManager sharedInstance] getMomentFromUser];

                [BiChatGlobal sharedManager].date4NetworkBroken = nil;
                [NetworkModule reconnect];
                [self dismissViewControllerAnimated:YES completion:nil];
                
                //进入首页
                [BiChatGlobal sharedManager].mainGUI.selectedIndex = 0;
                [[BiChatGlobal sharedManager].mainChatList refreshGUI];
                
                //全局通知一下
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGINOK object:nil];

                //获取一下最新的appconfig
                [NetworkModule getAppConfig:[BiChatGlobal sharedManager].systemConfigVersionNumber completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    [[BiChatGlobal sharedManager]processSystemConfigMessage:[data objectForKey:@"data"]];
                }];
                
                //重新获取一下本人的profile
                [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
                
                //上传一下deviceid
                [NetworkModule reportMyNotificationId:[BiChatGlobal sharedManager].notificationDeviceToken completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
        }
        else
        {
            weChatLoginState = 4;
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [self.tableView reloadData];
            [BiChatGlobal showInfo:LLSTR(@"301604") withIcon:[UIImage imageNamed:@"icon_alert"]];
        }
    }];
}

#pragma mark - 私有函数

- (void)setHint:(NSString *)hintMsg
{
    if (weChatLoginState == 1 ||
        weChatLoginState == 2 ||
        weChatLoginState == 3)
        return;
    
    if (hintMsg.length == 0)
        [self setHintWnd:nil];
    else
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        view.backgroundColor = [UIColor colorWithRed:1 green:.9 blue:.9 alpha:1];
        
        //提示语
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 40)];
        label4Hint.text = hintMsg;
        label4Hint.font = [UIFont systemFontOfSize:14];
        label4Hint.textColor = [UIColor darkGrayColor];
        label4Hint.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label4Hint];
        
        [self setHintWnd:view];
    }
}

//设置上方的hit窗口
- (void)setHintWnd:(UIView *)hintWnd
{
    //如果已经设置
    if (view4HintWnd)
    {
        [view4HintWnd removeFromSuperview];
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        view4HintWnd = nil;
        self.tableView.contentInset = orignalContentInset;
    }
    
    //设置新的
    if (hintWnd)
    {
        CGPoint pt = self.tableView.contentOffset;
        hintWnd.frame = CGRectMake(0, self.tableView.contentOffset.y, self.view.frame.size.width, hintWnd.frame.size.height);
        [self.view addSubview:hintWnd];
        view4HintWnd = hintWnd;
        self.tableView.contentInset = UIEdgeInsetsMake(orignalContentInset.top + hintWnd.frame.size.height, 0, 0, 0);
        self.tableView.contentOffset = CGPointMake(pt.x, pt.y - hintWnd.frame.size.height);
    }
}

- (void)onButtonNext:(id)sender
{
    //检查参数
    if (input4Mobile.text.length == 0)
    {
        [BiChatGlobal showInfo:LLSTR(@"301908") withIcon:nil];
        return;
    }
    
    //休整电话号码输入
    NSString *mobile = input4Mobile.text;
    mobile = [mobile stringByReplacingOccurrencesOfString:@"?" withString:@""];
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];        //特殊空格字符
    mobile = [mobile stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobile = [mobile stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //检查手机号码格式是否正确
    if (![BiChatGlobal isMobileNumberLegel:currentSelectedCountryCode mobile:mobile])
    {
        [BiChatGlobal showInfo:LLSTR(@"301909") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //检查一下距离上一次发送短消息是不是超过60秒
    //获取当前手机号发送验证码的时间
    CGFloat intval = 100000;
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4SendVerifyCodeInfo)
    {
        if ([[item objectForKey:@"mobile"]isEqualToString:mobile])
        {
            intval = [[NSDate date]timeIntervalSinceDate:[item objectForKey:@"timeStamp"]];
            break;
        }
    }
    
    if (intval < 30)
    {
        [BiChatGlobal showInfo:LLSTR(@"301910") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        return;
    }
    
    //发送验证码
    [BiChatGlobal ShowActivityIndicator];
    tryingLogin = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [NetworkModule sendVerifyCode4Login:currentSelectedCountryCode
                                 mobile:mobile
                         completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        tryingLogin = NO;
        if (success)
        {
            //记录一下当前时间
            if ([BiChatGlobal sharedManager].array4SendVerifyCodeInfo == nil)
                [BiChatGlobal sharedManager].array4SendVerifyCodeInfo = [NSMutableArray array];
            
            //先删除老数据
            for (int i = 0; i < [BiChatGlobal sharedManager].array4SendVerifyCodeInfo.count; i ++)
            {
                if ([[[[BiChatGlobal sharedManager].array4SendVerifyCodeInfo objectAtIndex:i]objectForKey:@"mobile"]isEqualToString:mobile])
                {
                    [[BiChatGlobal sharedManager].array4SendVerifyCodeInfo removeObjectAtIndex:i];
                    break;
                }
            }
            
            //加一个新的数据项
            [[BiChatGlobal sharedManager].array4SendVerifyCodeInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:mobile, @"mobile", [NSDate date], @"timeStamp", nil]];

            //进入验证码输入界面
            VerifyViewController *wnd = [VerifyViewController new];
            wnd.areaCode = self->currentSelectedCountryCode;
            wnd.mobile = mobile;
            wnd.weChatLoginParameters = self.weChatLoginParameters;
            wnd.myInviterInfo = self.myInviterInfo;
            [self.navigationController pushViewController:wnd animated:YES];
        }
        else if (errorCode == 111)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[BiChatGlobal sharedManager]forceUpgrade];
        }
        else
        {
            [BiChatGlobal showInfo:LLSTR(@"301003") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 23", nil];
        }
    }];
}

- (void)LoginByWeChat
{
    //判断是否已经安装了微信
    if (![WXApi isWXAppInstalled]) {
        [BiChatGlobal showInfo:LLSTR(@"301608") withIcon:Image(@"icon_alert")];
        return;
    }
    
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"fulishe_wechat_logon_1290234" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
    
    //记录一下本窗口
    [BiChatGlobal sharedManager].weChatBindTarget = self;
}

- (void)Register
{
    
}

- (void)onButtonMoreCountry:(id)sender
{
    CountrySelectorViewController *wnd = [CountrySelectorViewController new];
    wnd.currentSelectedCode = currentSelectedCountryCode;
    wnd.delegate = self;
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonAgreement:(id)sender
{
    //生成链接窗口
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
    wnd.cannotShare = YES;
//    wnd.url = @"http://www.imchat.com/agreement.html";
    wnd.url = [NSString stringWithFormat:@"http://www.imchat.com/agreement/agreement_%@_%@.html",DIFAPPID,[DFLanguageManager getLanguageName]];
    [self.navigationController pushViewController:wnd animated:YES];
}

- (void)onButtonWeChatLogin:(id)sender
{
    //判断是否已经安装了微信
    if (![WXApi isWXAppInstalled]) {
        [BiChatGlobal showInfo:LLSTR(@"301608") withIcon:Image(@"icon_alert")];
        return;
    }
    
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"fulishe_wechat_logon_1290234" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
    
    //记录一下本窗口
    [BiChatGlobal sharedManager].weChatBindTarget = self;
}

- (void)onButtonInputOK:(id)sender
{
    [input4Mobile resignFirstResponder];
}

@end
