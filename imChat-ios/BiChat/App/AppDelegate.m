//
//  AppDelegate.m
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "NetworkModule.h"
#import "AppDelegate.h"
#import "LoginPortalViewController.h"
#import "LoginViewController.h"
#import <TTStreamer/TTStreamerClient.h>
#import "JSONKit.h"
#import "pinyin.h"
#import "WXApi.h"
#import "ChatViewController.h"
#import <AWSS3/AWSS3.h>
#import <IQKeyboardManager.h>
#import <WebKit/WebKit.h>
#import "UIButton+block.h"
#import <AdSupport/AdSupport.h>
#import <AudioToolbox/AudioToolbox.h>
//#import "CYLTabBar.h"
#import <Bugly/Bugly.h>
#import "WPNewsDetailViewController.h"

//#import "NSBundle+AppLanguageSwitch.h"


@interface AppDelegate ()
@property (nonatomic,strong)WPShareView *shareV;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //启动bugly crash追踪系统
    [Bugly startWithAppId:@"c4c0b748dc"];
    
    srand([[NSDate date]timeIntervalSince1970]);
    rand();
    [UITableView appearance].separatorColor = [UIColor colorWithWhite:.9 alpha:1];
    
    //[[UITabBar appearance] setTranslucent:NO];
    //[CYLTabBar load];
    
    //初始化通知
    [self register4Notification:application];
    
    UIWebView * tempWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString * oldAgent = [tempWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString * newAgent = [oldAgent stringByAppendingString:[NSString stringWithFormat:@"%@ imChatMessenger/%@",oldAgent,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    NSDictionary * dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //初始化微信
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    [WXApi registerApp:WXAPI];
    [AMapServices sharedServices].apiKey = AMAPAPIKEY;
    [BiChatGlobal sharedManager].progId = PROGID;
    
    [NetworkModule getAppConfig:[BiChatGlobal sharedManager].systemConfigVersionNumber completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [[BiChatGlobal sharedManager]processSystemConfigMessage:[data objectForKey:@"data"]];
    }];
    if ([BiChatGlobal sharedManager].token) {
        [[WPBaseManager baseManager] getInterface:@"Chat/Api/getUserInviteCode.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token} success:^(id response) {
            [BiChatGlobal sharedManager].RefCode = [response objectForKey:@"RefCode"];
            [[BiChatGlobal sharedManager] saveUserInfo];
        } failure:^(NSError *error) {
            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
        }];
    }
    

    //初始化S3
#ifdef ENV_DEV
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider new]initWithRegionType:AWSRegionAPSoutheast1 identityPoolId:@"ap-southeast-1:977342ef-40c1-4afa-9ce6-c91a306fde98"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionAPSoutheast1
                                                                                   endpoint:[[AWSEndpoint alloc]initWithURLString:@"http://users.dev.iweipeng.com"]
                                                                        credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
#endif
#ifdef ENV_TEST
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider new]initWithRegionType:AWSRegionAPSoutheast1 identityPoolId:@"ap-southeast-1:977342ef-40c1-4afa-9ce6-c91a306fde98"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionAPSoutheast1
                                                                                   endpoint:[[AWSEndpoint alloc]initWithURLString:@"http://users.t.iweipeng.com"]
                                                                        credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
#endif
#ifdef ENV_LIVE
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider new]initWithRegionType:AWSRegionAPSoutheast1 identityPoolId:@"ap-southeast-1:cc212756-4d40-4384-84db-740c99993e5d"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionAPSoutheast1
                                                                                   endpoint:[[AWSEndpoint alloc]initWithURLString:@"http://users.imchat.com"]
                                                                        credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
#endif
#ifdef ENV_CN
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider new]initWithRegionType:AWSRegionAPSoutheast1 identityPoolId:@"ap-southeast-1:cc212756-4d40-4384-84db-740c99993e5d"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionAPSoutheast1
                                                                                   endpoint:[[AWSEndpoint alloc]initWithURLString:@"http://users.imchat.com"]
                                                                        credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
#endif
#ifdef ENV_ENT
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider new]initWithRegionType:AWSRegionAPSoutheast1 identityPoolId:@"ap-southeast-1:cc212756-4d40-4384-84db-740c99993e5d"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionAPSoutheast1
                                                                                   endpoint:[[AWSEndpoint alloc]initWithURLString:@"http://users.imchat.com"]
                                                                        credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
#endif
#ifdef ENV_V_DEV
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider new]initWithRegionType:AWSRegionAPSoutheast1 identityPoolId:@"ap-southeast-1:977342ef-40c1-4afa-9ce6-c91a306fde98"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionAPSoutheast1
                                                                                   endpoint:[[AWSEndpoint alloc]initWithURLString:@"http://users.dev.iweipeng.com"]
                                                                        credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
#endif

    array4MessageCache = [NSMutableArray array];
//    _mapManager= [[BMKMapManager alloc]init];
//    // 如果要关注网络及授权验证事件，请设定  generalDelegate参数
//    if ([_mapManager start:@"yrOEVNLbSuu9jzGgFL1mwXrxgGrgYeCj" generalDelegate:self]) {
//        NSLog(@"manager start failed!");
//    }
    
    //加载上一次运行最后的信息
    if ([BiChatGlobal sharedManager].uid.length > 0)
    {
        [[BiChatGlobal sharedManager]loadUserInfo];
        [[BiChatGlobal sharedManager]loadUserAdditionInfo];
        [[BiChatGlobal sharedManager]loadUserEmotionInfo];
        [[BiChatDataModule sharedDataModule]loadGlobalInfo];
        [[BiChatDataModule sharedDataModule]setuid:[BiChatGlobal sharedManager].uid];
        [[BiChatGlobal sharedManager]downloadAllPendingSound];
        [[DFYTKDBManager sharedInstance] getMomentFromUser];
    }
    
    //判断是否由远程消息通知触发应用程序启动
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]!=nil) {
        //获取应用程序消息通知标记数（即小红圈中的数字）
        int badge = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badge>0) {
            //如果应用程序消息通知标记数（即小红圈中的数字）大于0，清除标记。
            badge--;
            //清除标记。清除小红圈中数字，小红圈中数字为0，小红圈才会消除。
            [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
        }
    }
    
    //设置语言
    [DFLanguageManager setUserLanguage:[DFLanguageManager getLanguageName]];
    
    [DFLanguageManager getLanguageUpdateEveryDay];
    
//    [DFLanguageManager getLanguageUpdateEveryTimeSuccessBlock:^(NSDictionary * _Nonnull respone, NSInteger updateNum) {
//    } failBlock:^(NSError * _Nonnull error) {
//    }];

    //是否需要上传本地环境
    NSString *appVersion = [BiChatGlobal getAppVersion];
    if (![[BiChatGlobal sharedManager].lastLoginAppVersion isEqualToString:appVersion])
    {
        [NetworkModule reportMyEnvironment:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
        [BiChatGlobal sharedManager].lastLoginAppVersion = appVersion;
        [[BiChatGlobal sharedManager]saveGlobalInfo];
    }
    
    //开启BackgroundFetch
    [[UIApplication sharedApplication]setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [[BiChatGlobal sharedManager]imChatLog:@"imChat 开始运行", nil];
    return YES;
}

- (void)register4Notification:(UIApplication *)application
{
    //消息推送注册
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    CGFloat currentDeviceVersionFloat = [UIDevice currentDevice].systemVersion.floatValue;
    if (currentDeviceVersionFloat >= 10.0)
    {
        [[UNUserNotificationCenter currentNotificationCenter]setDelegate:self];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                                 UNAuthorizationOptionBadge |
                                                 UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                NSLog(@"notification center open success");
                [BiChatGlobal sharedManager].bNotifyEnable = YES;
                
                //转到主线程去执行
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
                
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"notification setting : %@", settings);
                }];
            }
            else
            {
                [BiChatGlobal sharedManager].bNotifyEnable = NO;
                NSLog(@"notification center open failed");
            }
        }];
    }
    else if (currentDeviceVersionFloat >= 8.0)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert)
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge
                                                         |UIRemoteNotificationTypeSound
                                                         |UIRemoteNotificationTypeAlert)];
    }
    
#pragma clang diagnostic pop
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //获取终端设备标识，这个标识需要通过接口发送到服务器端，服务器端推送消息到APNS时需要知道终端的标识，APNS通过注册的终端标识找到终端设备。
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is:%@", token);
    
    //上报服务器
    [BiChatGlobal sharedManager].notificationDeviceToken = token;
    [NetworkModule reportMyNotificationId:token completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"Failed to get token, error:%@", error_str);
}

- (void)onGetPermissionState:(int)iError {
    
}

- (void)onGetNetworkState:(int)iError {
    
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    [[BiChatGlobal sharedManager]imChatLog:@"BEGIN BACKGROUNDFETCH OPERATION!!!", nil];
    if (networkInited)
    {
        [[BiChatGlobal sharedManager]imChatLog:@"重新激活网络...", nil];
        [NetworkModule resumeNetwork:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
    }
    else
    {
        [[BiChatGlobal sharedManager]imChatLog:@"重新开启网络...", nil];
        [self initNetStream];
    }
    
    //开启时钟来监视收到的消息情况
    NSDate *begin = [NSDate date];
    timer4BackgroupFetch = [NSTimer scheduledTimerWithTimeInterval:15 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [timer4BackgroupFetch invalidate];
        timer4BackgroupFetch = nil;
        
        //重新开始时钟
        [[BiChatGlobal sharedManager]imChatLog:@"开始监视结束条件", nil];
        timer4BackgroupFetch = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
           
            //看看现在每秒收到多少数据
            [[BiChatGlobal sharedManager]imChatLog:[NSString stringWithFormat:@"这一秒收到%ld条消息", (long)[BiChatGlobal sharedManager].newMessageCount], nil];
            if ([BiChatGlobal sharedManager].newMessageCount < 3 ||
                [[NSDate date]timeIntervalSinceDate:begin] > 180)
            {
                [[BiChatGlobal sharedManager]imChatLog:@"结束BackgroundFetch operation!!!", nil];
                completionHandler(UIBackgroundFetchResultNewData);
                [timer4BackgroupFetch invalidate];
                timer4BackgroupFetch = nil;
            }
            else
            {
                [BiChatGlobal sharedManager].newMessageCount = 0;
            }
        }];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //保存全局头像信息
    [[BiChatGlobal sharedManager]imChatLog:@"imChat 进入后台", nil];
    [BiChatGlobal sharedManager].date4NetworkBroken = nil;
    [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
    [[BiChatDataModule sharedDataModule]saveGroupProperty];
    [[BiChatGlobal sharedManager]reportGroupOperation];
    
    //申请后台运行一次
    [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:^{}];
    
    //pause network
    [NetworkModule pauseNetwork:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
    
    //通知系统关闭
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPDEACTIVE object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[BiChatGlobal sharedManager]imChatLog:@"imChat 进入前台", nil];
    [BiChatGlobal sharedManager].date4NetworkBroken = nil;
    [NetworkModule resumeNetwork:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    if ([BiChatGlobal sharedManager].view4MyBadge == nil)
    {
        if ([BiChatGlobal sharedManager].mainGUI.viewControllers.count > 0)
        {
            UIView *view4MyBadge = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
            view4MyBadge.layer.cornerRadius = 4;
            CGFloat itemWidth = [BiChatGlobal sharedManager].mainGUI.tabBar.frame.size.width / [BiChatGlobal sharedManager].mainGUI.viewControllers.count;
            view4MyBadge.center = CGPointMake(itemWidth * 4 + itemWidth / 2 + 10, 10);
            view4MyBadge.backgroundColor = [UIColor redColor];
            view4MyBadge.hidden = YES;
            [[BiChatGlobal sharedManager].mainGUI.tabBar addSubview:view4MyBadge];
            [BiChatGlobal sharedManager].view4MyBadge = view4MyBadge;
        }
    }
    
    [[BiChatGlobal sharedManager]imChatLog:@"imChat become active - connect to server", nil];
    //[self initNetStream];
    [self performSelector:@selector(initNetStream) withObject:nil afterDelay:0];
    NSThread *batchGetMessageThread = [[NSThread alloc]initWithTarget:self selector:@selector(batchGetMessage) object:nil];
    batchGetMessageThread.qualityOfService = NSQualityOfServiceBackground;
    [batchGetMessageThread start];
    
    //    [[WPBaseManager baseManager] getInterface:@"Chat/Api/rewardList.do" parameters:@{@"tokenid":[NSString stringWithFormat:@"%@",[BiChatGlobal sharedManager].token]} success:^(id response) {
    //        NSArray *array = [response objectForKey:@"list"];
    //        if (array.count > 0) {
    //            [BiChatGlobal sharedManager].mainGUI.selectedIndex = 3;
    //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOWFIRST object:nil];
    //        } else {
    //        }
    //    } failure:^(NSError *error) {
    //
    //    }];
    
    //是否需要登录
    if (![BiChatGlobal sharedManager].bLogin) {
        [[BiChatGlobal sharedManager]loginPortal];
    } else {
        [self checkPasteBoard];
    }
    
    
    //获取当前配置
    [self getConfiguration];
    [[BiChatGlobal sharedManager]checkUpdate];
    
    //通知系统开启
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPACTIVE object:nil];
}

- (void)checkPasteBoard {
    [[BiChatGlobal sharedManager] loadGlobalInfo];
    NSString *pasteString = [UIPasteboard generalPasteboard].string;
    UIPasteboard *pasteboard1 = [UIPasteboard pasteboardWithName:@"imc" create:NO];
    
    if ([pasteString isEqualToString:pasteboard1.string] && pasteString.length > 0) {
        [[UIPasteboard generalPasteboard] setString:@""];
        [pasteboard1 setString:@""];
        return;
    }
    
    NSDictionary *dict = [pasteString judGroupWithRegex:[BiChatGlobal sharedManager].shortLinkPattern];
    WEAKSELF;
    if ([dict allKeys].count > 0) {
        if ([[dict objectForKey:@"action"] isEqualToString:@"j"]) {
            if ([dict allKeys].count < 2) {
                return;
            }
            self.shortLinkView = [[WPShortLinkView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            [[UIApplication sharedApplication].keyWindow addSubview:self.shortLinkView];
            [self.shortLinkView show];
            self.shortLinkView.urlData = dict;
            [self.shortLinkView fillData:@{@"url": [[NSString alloc] initWithString:pasteString]} type:[dict objectForKey:@"action"]];
            [[UIPasteboard generalPasteboard] setString:@""];
            self.shortLinkView.CloseBlock = ^{
                [weakSelf.shortLinkView removeFromSuperview];
                weakSelf.shortLinkView = nil;
            };
            self.shortLinkView.OpenBlock = ^(UIViewController * _Nonnull vc) {
                [weakSelf.shortLinkView removeFromSuperview];
                weakSelf.shortLinkView = nil;
                [[BiChatGlobal sharedManager].mainGUI.selectedViewController pushViewController:vc animated:YES];
            };
            return;
        }
        [NetworkModule getShortUrlWithType:[dict objectForKey:@"action"] chatId:[dict objectForKey:@"id"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (!success) {
                return ;
            }
            [self.shortLinkView removeFromSuperview];
            self.shortLinkView = nil;
            UITextField *tf = [[UITextField alloc]init];
            [[UIApplication sharedApplication].keyWindow addSubview:tf];
            [tf becomeFirstResponder];
            [tf resignFirstResponder];
            [tf removeFromSuperview];
            tf = nil;
            if ([[dict objectForKey:@"action"] isEqualToString:@"g"]) {
                [[UIPasteboard generalPasteboard] setString:@""];
                self.shortLinkView = [[WPShortLinkView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
                [[UIApplication sharedApplication].keyWindow addSubview:self.shortLinkView];
                [self.shortLinkView show];
                self.shortLinkView.urlData = dict;
                [self.shortLinkView fillData:data type:[dict objectForKey:@"action"]];
                self.shortLinkView.CloseBlock = ^{
                    [weakSelf.shortLinkView removeFromSuperview];
                    weakSelf.shortLinkView = nil;
                };
                self.shortLinkView.OpenBlock = ^(UIViewController * _Nonnull vc) {
                    [weakSelf.shortLinkView removeFromSuperview];
                    weakSelf.shortLinkView = nil;
                    [[BiChatGlobal sharedManager].mainGUI.selectedViewController pushViewController:vc animated:YES];
                };
            } else if ([[dict objectForKey:@"action"] isEqualToString:@"u"]) {
                [[UIPasteboard generalPasteboard] setString:@""];
                self.shortLinkView = [[WPShortLinkView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
                [[UIApplication sharedApplication].keyWindow addSubview:self.shortLinkView];
                [self.shortLinkView show];
                self.shortLinkView.urlData = dict;
                [self.shortLinkView fillData:data type:[dict objectForKey:@"action"]];
                self.shortLinkView.CloseBlock = ^{
                    [weakSelf.shortLinkView removeFromSuperview];
                    weakSelf.shortLinkView = nil;
                };
                self.shortLinkView.OpenBlock = ^(UIViewController * _Nonnull vc) {
                    [weakSelf.shortLinkView removeFromSuperview];
                    weakSelf.shortLinkView = nil;
                    [[BiChatGlobal sharedManager].mainGUI.selectedViewController pushViewController:vc animated:YES];
                };
            } else if ([[dict objectForKey:@"action"] isEqualToString:@"h"]) {
                [[UIPasteboard generalPasteboard] setString:@""];
                self.shortLinkView = [[WPShortLinkView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
                [[UIApplication sharedApplication].keyWindow addSubview:self.shortLinkView];
                [self.shortLinkView show];
                self.shortLinkView.urlData = dict;
                [self.shortLinkView fillData:data type:[dict objectForKey:@"action"]];
                self.shortLinkView.CloseBlock = ^{
                    [weakSelf.shortLinkView removeFromSuperview];
                    weakSelf.shortLinkView = nil;
                };
                self.shortLinkView.OpenBlock = ^(UIViewController * _Nonnull vc) {
                    [weakSelf.shortLinkView removeFromSuperview];
                    weakSelf.shortLinkView = nil;
                    [[BiChatGlobal sharedManager].mainGUI.selectedViewController pushViewController:vc animated:YES];
                };
            }
        }];
    }
}

//获取配置信息
- (void)getConfiguration {
    NSString *urlString = [NSString stringWithFormat:@"%@config/urlList.json?v=1",[BiChatGlobal sharedManager].StaticUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setValue:@"application/json"forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self performSelector:@selector(getConfiguration) withObject:nil afterDelay:10];
            return ;
        }
        [BiChatGlobal sharedManager].urlList = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    }];
    [task resume];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    //其他类型的url，交给微博和微信处理
    if ([WXApi handleOpenURL:url delegate:self]) return YES;
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotatio
{
    //其他类型的url, 交给微博和微信处理
    if ([WXApi handleOpenURL:url delegate:self]) return YES;
    
    //其他类型
    if (self.window) {
        if (url) {
            [self performSelector:@selector(processURL:) withObject:url afterDelay:0.5];
        }
    }
    return YES;
}

- (void)processURL:(NSURL *)url
{
    NSString * urlStr = [NSString stringWithFormat:@"%@",url];
    
    if ([urlStr isEqualToString:@"openimchat://shareUrl"] || [urlStr isEqualToString:@"openimchatDev://shareUrl"]) {
        
        //系统分享 获取共享的UserDefaults
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.imchathk.imchatlive"];
        NSString * urlStr = [userDefaults valueForKey:@"share-url"];
        NSLog(@"新的分享 : %@", urlStr);
        
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = urlStr;
        wnd.hidesBottomBarWhenPushed = YES;

        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
             [(UINavigationController *)window.rootViewController pushViewController:wnd animated:YES];
        } else if ([window.rootViewController isKindOfClass:[UITabBarController class]]) {
            UIViewController *selectVc = [((UITabBarController *)window.rootViewController)selectedViewController];
            if ([selectVc isKindOfClass:[UINavigationController class]]) {
                 [(UINavigationController *)selectVc pushViewController:wnd animated:YES];
            }
        }
    }else if ([urlStr isEqualToString:@"openimchat://shareImg"] || [urlStr isEqualToString:@"openimchatDev://shareImg"]){
        //选择一个对象发送
        ChatSelectViewController *wnd = [ChatSelectViewController new];
        wnd.delegate = self;
        wnd.cookie = MESSAGE_CONTENT_TYPE_IMAGE;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        [[BiChatGlobal sharedManager].mainGUI presentViewController:nav animated:YES completion:nil];
    }else{
        //发送文件
        //准备对象数据
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSString *fileNameStr = [url lastPathComponent];
        NSDictionary *fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", fileNameStr, @"fileName", nil];
       
        //选择一个对象发送
        ChatSelectViewController *wnd = [ChatSelectViewController new];
        wnd.delegate = self;
        wnd.target = fileInfo;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        
        [[BiChatGlobal sharedManager].mainGUI presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - UNUserNotificationCenterDelegate functions

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler
{
    
}

#pragma mark - ChatSelectDelegate

- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target
{
    if (cookie == MESSAGE_CONTENT_TYPE_NEWS) {
        
    }else if (cookie == MESSAGE_CONTENT_TYPE_IMAGE){
        
        [[BiChatGlobal sharedManager].mainGUI dismissViewControllerAnimated:YES completion:nil];

        //系统分享 获取共享的UserDefaults
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.imchathk.imchatlive"];
        
        NSString * imageStr = [userDefaults objectForKey:@"share-urlImage"];
        
        NSArray  *array = [imageStr componentsSeparatedByString:@","];
        NSMutableArray *imagesDataArr = [NSMutableArray array];
        /// 取出图片data
        for (NSString *key in array) {
            NSData *data = [userDefaults objectForKey:key];
            UIImage * shareImg = [UIImage imageWithData:data];
            UIImage * smallImage = [DFLogicTool getSmallImageWithImage:shareImg];
            [imagesDataArr addObject:smallImage];
        }

        //WEAKSELF;

        NSDictionary *dict;
        if (chats.count > 0) {
            dict = chats[0];
        } else {
            return;
        }

        [BiChatGlobal closeShareWindow];

        ChatViewController * chatView = [[ChatViewController alloc]init];
        chatView.peerUid = [dict objectForKey:@"peerUid"];
        chatView.peerNickName = [dict objectForKey:@"peerNickName"];
        chatView.peerAvatar = [dict objectForKey:@"peerAvatar"];
        chatView.shareExtensionImages = imagesDataArr;
        chatView.hidesBottomBarWhenPushed = YES;
        chatView.isGroup = [[dict objectForKey:@"isGroup"] boolValue];

        //chatView.isPublic = YES;

        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)window.rootViewController pushViewController:chatView animated:YES];
        } else if ([window.rootViewController isKindOfClass:[UITabBarController class]]) {
            UIViewController *selectVc = [((UITabBarController *)window.rootViewController)selectedViewController];
            if ([selectVc isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)selectVc pushViewController:chatView animated:YES];
            }
        }
    }else{
        //拿到要发送的数据
        NSDateFormatter *fmt = [NSDateFormatter new];
        fmt.dateFormat = @"yyyyMMdd";
        NSString *currentDateString = [fmt stringFromDate:[NSDate date]];
        NSDictionary *fileInfo = (NSDictionary *)target;
        NSString *uploadName = [NSString stringWithFormat:@"msg/%@/%@.%@", currentDateString, [BiChatGlobal getUuidString], [[fileInfo objectForKey:@"fileName"]pathExtension]];
        
        //准备发送
        NSDictionary *dict;
        if (chats.count > 0) {
            dict = chats[0];
        } else {
            return;
        }
        NSString *avatar = [dict objectForKey:@"peerAvatar"];
        self.shareV = [BiChatGlobal showShareWindowWithTitle:[dict objectForKey:@"peerNickName"] avatar:avatar.length > 0 ? [NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[dict objectForKey:@"peerAvatar"]] : @"" content:[LLSTR(@"101192") llReplaceWithArray:@[[fileInfo objectForKey:@"fileName"]]] type:0];
        self.shareV.ChooseItemBlock = ^(NSInteger chooseStatus, NSString *content)
        {
            if (chooseStatus == 0) {
                [BiChatGlobal closeShareWindow];
            }
            else
            {
                [BiChatGlobal closeShareWindow];
                
                //开始发送，先发送到S3服务器
                S3SDK_ *S3SDK = [S3SDK_ new];
                UIButton *button4Close = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
                button4Close.alpha = 0.8;
                [button4Close setImage:[UIImage imageNamed:@"close3"] forState:UIControlStateNormal];
                [button4Close handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                    [S3SDK cancel];
                    [BiChatGlobal hideProgress];
                }];
                [BiChatGlobal showProgress:0.01 info:@"文件上传中" additionalView:button4Close clickType:CLICK_TYPE_NONE];
                [S3SDK UploadData:[fileInfo objectForKey:@"data"] withName:uploadName contentType:@"file/data"
                            begin:^(void){}
                         progress:^(float ratio)
                 {
                     //更新上传进度
                     [BiChatGlobal showProgress:ratio info:@"文件上传中" additionalView:button4Close clickType:CLICK_TYPE_NONE];
                     
                 } success:^(NSDictionary * _Nullable response) {
                     
                     //关闭进度
                     [BiChatGlobal hideProgress];
                     
                     //开发组装发送消息
                     NSDictionary *dict = chats[0];
                     NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
                     [contentDic setObject:[[fileInfo objectForKey:@"fileName"]pathExtension] forKey:@"type"];
                     [contentDic setObject:[fileInfo objectForKey:@"fileName"] forKey:@"fileName"];
                     [contentDic setObject:uploadName forKey:@"uploadName"];
                     [contentDic setObject:[NSNumber numberWithLong:[[fileInfo objectForKey:@"data"]length]] forKey:@"fileLength"];
                     
                     NSString *msgId = [BiChatGlobal getUuidString];
                     NSString *contentId = [BiChatGlobal getUuidString];
                     NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
                     [sendDic setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_FILE] forKey:@"type"];
                     [sendDic setObject:[contentDic JSONString] forKey:@"content"];
                     [sendDic setObject:[dict objectForKey:@"peerUid"] forKey:@"receiver"];
                     [sendDic setObject:[dict objectForKey:@"peerNickName"] forKey:@"receiverNickName"];
                     [sendDic setObject:[dict objectForKey:@"peerAvatar"] forKey:@"receiverAvatar"];
                     [sendDic setObject:[BiChatGlobal sharedManager].uid forKey:@"sender"];
                     [sendDic setObject:[BiChatGlobal sharedManager].nickName forKey:@"senderNickName"];
                     [sendDic setObject:[BiChatGlobal sharedManager].avatar forKey:@"senderAvatar"];
                     [sendDic setObject:[BiChatGlobal getCurrentDateString] forKey:@"timeStamp"];
                     [sendDic setObject:msgId forKey:@"msgId"];
                     [sendDic setObject:contentId forKey:@"contentId"];
                     if ([[[chats firstObject]objectForKey:@"isGroup"] boolValue]) {
                         [sendDic setObject:@"1" forKey:@"isGroup"];
                     }
                     [sendDic setObject: [BiChatGlobal getCurrentDateString] forKey:@"favTime"];
                     
                     //是不是发送给本人
                     if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid]) {
                         //直接将消息放入本地
                         [BiChatGlobal showInfo:LLSTR(@"301006") withIcon:Image(@"icon_OK")];
                         [[BiChatGlobal sharedManager].mainGUI dismissViewControllerAnimated:YES completion:nil];
                         [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                               peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                               peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                 peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                    message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                                                messageTime:[BiChatGlobal getCurrentDateString]
                                                                      isNew:NO
                                                                    isGroup:NO
                                                                   isPublic:NO
                                                                  createNew:NO];
                         [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
                     }
                     //转发给一个群
                     else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue] &&
                              ![[[chats firstObject]objectForKey:@"isPublic"]boolValue]) {
                         
                         [BiChatGlobal ShowActivityIndicator];
                         [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                             
                             [BiChatGlobal HideActivityIndicator];
                             if (success ||
                                 ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].filePubUid] &&
                                  [[sendDic objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)) {
                                     //消息放入本地
                                     [BiChatGlobal showInfo:LLSTR(@"301006") withIcon:Image(@"icon_OK")];
                                     [[BiChatGlobal sharedManager].mainGUI dismissViewControllerAnimated:YES completion:nil];
                                     [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                           peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                           peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                             peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                                message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                                                            messageTime:[BiChatGlobal getCurrentDateString]
                                                                                  isNew:NO
                                                                                isGroup:YES
                                                                               isPublic:NO
                                                                              createNew:NO];
                                     [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
                                 }
                             else if (errorCode == 3)
                                 [BiChatGlobal showInfo:LLSTR(@"301307") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                             else {
                                 [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                             }
                         }];
                     }
                     //转发给个人
                     else {
                         
                         [BiChatGlobal ShowActivityIndicator];
                         [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                             
                             [BiChatGlobal HideActivityIndicator];
                             if (success) {
                                 //消息放入本地
                                 [BiChatGlobal showInfo:LLSTR(@"301006") withIcon:Image(@"icon_OK")];
                                 [[BiChatGlobal sharedManager].mainGUI dismissViewControllerAnimated:YES completion:nil];
                                 [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                       peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                       peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                         peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                            message:[BiChatGlobal getMessageReadableString:sendDic groupProperty:nil]
                                                                        messageTime:[BiChatGlobal getCurrentDateString]
                                                                              isNew:NO
                                                                            isGroup:NO
                                                                           isPublic:NO
                                                                          createNew:NO];
                                 [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
                                 
                                 //特殊处理，是否转发给了文件传输助手一个文件
                                 if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].filePubUid] &&
                                     [[sendDic objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_FILE)
                                 {
                                     JSONDecoder *dec = [JSONDecoder new];
                                     NSDictionary *target = [dec objectWithData:[[sendDic objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                                     
                                     //通知一下服务器
                                     NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/saveFile.do?tokenid=%@&fileName=%@&uploadName=%@&length=%@&uuid=%@",
                                                          [BiChatGlobal sharedManager].apiUrl,
                                                          [BiChatGlobal sharedManager].token,
                                                          [target objectForKey:@"fileName"],
                                                          [target objectForKey:@"uploadName"],
                                                          [NSNumber numberWithLong:[[target objectForKey:@"fileLength"]longValue]],
                                                          msgId];
                                     str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                                     //NSLog(@"%@", str4Url);
                                     
                                     //上传服务器
                                     AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
                                     [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                                     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                     }];
                                 }
                                 
                             } else {
                                 [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                             }
                         }];
                     }
                     
                     if (content.length == 0) {
                         return ;
                     }
                     NSMutableDictionary *sendDic1 = [NSMutableDictionary dictionary];
                     [sendDic1 setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_TEXT] forKey:@"type"];
                     [sendDic1 setObject:content forKey:@"content"];
                     [sendDic1 setObject:[dict objectForKey:@"peerUid"] forKey:@"receiver"];
                     [sendDic1 setObject:[dict objectForKey:@"peerNickName"] forKey:@"receiverNickName"];
                     [sendDic1 setObject:[dict objectForKey:@"peerAvatar"] forKey:@"receiverAvatar"];
                     [sendDic1 setObject:[BiChatGlobal sharedManager].uid forKey:@"sender"];
                     [sendDic1 setObject:[BiChatGlobal sharedManager].nickName forKey:@"senderNickName"];
                     [sendDic1 setObject:[BiChatGlobal sharedManager].avatar forKey:@"senderAvatar"];
                     [sendDic1 setObject:[BiChatGlobal getCurrentDateString] forKey:@"timeStamp"];
                     [sendDic1 setObject:[BiChatGlobal getUuidString] forKey:@"msgId"];
                     [sendDic1 setObject:[BiChatGlobal getUuidString] forKey:@"contentId"];
                     if ([[[chats firstObject]objectForKey:@"isGroup"] boolValue]) {
                         [sendDic1 setObject:@"1" forKey:@"isGroup"];
                     }
                     [sendDic1 setObject:[[BiChatGlobal sharedManager]getCurrentLoginMobile] forKey:@"senderUserName"];
                     
                     //是不是发送给本人
                     if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid]) {
                         //直接将消息放入本地
                         [[BiChatGlobal sharedManager].mainGUI dismissViewControllerAnimated:YES completion:nil];
                         [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                               peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                               peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                 peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                    message:[BiChatGlobal getMessageReadableString:sendDic1 groupProperty:nil]
                                                                messageTime:[BiChatGlobal getCurrentDateString]
                                                                      isNew:NO
                                                                    isGroup:NO
                                                                   isPublic:NO
                                                                  createNew:NO];
                         [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic];
                     }
                     //转发给一个群
                     else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue]) {
                         [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                             if (success) {
                                 //消息放入本地
                                 [[BiChatGlobal sharedManager].mainGUI dismissViewControllerAnimated:YES completion:nil];
                                 [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                       peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                       peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                         peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                            message:[BiChatGlobal getMessageReadableString:sendDic1 groupProperty:nil]
                                                                        messageTime:[BiChatGlobal getCurrentDateString]
                                                                              isNew:NO
                                                                            isGroup:YES
                                                                           isPublic:NO
                                                                          createNew:NO];
                                 [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic1];
                             }
                             else {
                                 [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                             }
                         }];
                     }
                     //转发给个人
                     else {
                         [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                             if (success) {
                                 //消息放入本地
                                 [[BiChatGlobal sharedManager].mainGUI dismissViewControllerAnimated:YES completion:nil];
                                 [[BiChatDataModule sharedDataModule]setLastMessage:[[chats firstObject]objectForKey:@"peerUid"]
                                                                       peerUserName:[[chats firstObject]objectForKey:@"peerUserName"]
                                                                       peerNickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                                         peerAvatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                                            message:[BiChatGlobal getMessageReadableString:sendDic1 groupProperty:nil]
                                                                        messageTime:[BiChatGlobal getCurrentDateString]
                                                                              isNew:NO
                                                                            isGroup:NO
                                                                           isPublic:NO
                                                                          createNew:NO];
                                 [[BiChatDataModule sharedDataModule]addChatContentWith:[[chats firstObject]objectForKey:@"peerUid"] content:sendDic1];
                             } else {
                                 [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                             }
                         }];
                     }
                 } failure:^(NSError * _Nonnull error)
                 {
                     [BiChatGlobal hideProgress];
                     [BiChatGlobal showInfo:LLSTR(@"301802") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                 }];
            }
        };
    }
}

#pragma mark - TTStreamingDelegate functions

- (void)onLogData:(NSData * _Nonnull)logData type:(int)type
{
    //NSLog(@"receive log type:%d - %@", type, [logData description]);
}

- (void)onTextData:(NSString * _Nonnull)text
{
    //NSLog(@"onTextDate: is called");
}

- (void)onBinaryData:(NSData * _Nonnull)data
{
    //直接先解析这个消息
    if (data.length == 0)
    {
        [[BiChatGlobal sharedManager]imChatLog:@"receive a null message", nil];
        return;
    }
    
    //解析这条消息并整理
    JSONDecoder *dec = [JSONDecoder new];
    NSMutableDictionary *item;
    @try {
        item = [dec mutableObjectWithData:data error:nil];
        //预处理消息
        [self preProcessNewMessage:item];
    } @catch (NSException *exception) {
        [[BiChatGlobal sharedManager]imChatLog:
         @"Rev a message which I can't parse it:(",
         [data description],
         @")", nil];
        return;
    } @finally {
    }
    
    if (item == nil)
    {
        [[BiChatGlobal sharedManager]imChatLog:@"wrong message format -- ", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding], nil];
        return;
    }
    
    [BiChatGlobal sharedManager].newMessageCount ++;
    NSString *str = [BiChatGlobal getMessageReadableString:item groupProperty:nil];
    //NSLog(@"------process a piece of message : %@", str.length > 50?[str substringToIndex:50]:str);
    [[BiChatGlobal sharedManager]imChatLog:
     @"Rcv msg:(",
     str.length > 50?[str substringToIndex:50]:str,
     @")From:(",
     [item objectForKey:@"senderNickName"],
     @")MsgId:(",
     [item objectForKey:@"msgId"],
     @")", nil];
    [array4MessageCache addObject:item];
        
    //先把这条消息保存在本地
    [timer4DispathMessage invalidate];
    timer4DispathMessage = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        
        //真正处理到的消息数量
        NSInteger newMesssageCount = 0;
        [[BiChatGlobal sharedManager]imChatLog:@"dispath ", [NSString stringWithFormat:@"%ld", (long)self->array4MessageCache.count], @" pieces of message", nil];
        
        //逐条处理收到的数据
        for (int i = 0; i < self->array4MessageCache.count; i ++)
        {
            @try {
                //dispath a piece of message
                NSMutableDictionary *item = [self->array4MessageCache objectAtIndex:i];
                if (![self processAPieceOfMessage:item])
                    continue;
                newMesssageCount ++;
            } @catch (NSException *exception) {
                NSString *str = [[NSString alloc]initWithData:[self->array4MessageCache objectAtIndex:i] encoding:NSUTF8StringEncoding];
                [[BiChatGlobal sharedManager]imChatLog:@"process message internal error:", str, nil];
            } @finally {
            }
        }
        
        //全部dispath
        [self->array4MessageCache removeAllObjects];
        [self->timer4DispathMessage invalidate];
        self->timer4DispathMessage = nil;
        
        if (newMesssageCount > 0)
        {
            [self performSelectorOnMainThread:@selector(flushMainGUI) withObject:nil waitUntilDone:NO];
        }
    }];
    
    //如果当前聚集了20条消息，马上进行处理并刷新屏幕
    if (array4MessageCache.count > 20)
        [timer4DispathMessage fire];
}

- (void)preProcessNewMessage:(NSMutableDictionary *)item
{
    [item setObject:[NSNumber numberWithBool:YES] forKey:@"isNew"];
    [item removeObjectForKey:@"index"];
    if ([[item objectForKey:@"isPublic"]boolValue]) [item setObject:@"0" forKey:@"isGroup"];
    if ([[item objectForKey:@"content"]isKindOfClass:[NSDictionary class]])
    {
        NSString *str4Log = [NSString stringWithFormat:@"**********Receiver a MAP content message, type = %@", [item objectForKey:@"type"]];
        [[BiChatGlobal sharedManager]imChatLog:str4Log, nil];
        [item setObject:[[item objectForKey:@"content"]mj_JSONString] forKey:@"content"];
    }
}

//处理一条消息
//返回YES代表正常处理结束，NO代表可以忽略本消息
- (BOOL)processAPieceOfMessage:(NSMutableDictionary *)item
{
    //是否时间服务器通知消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_TIMERSERVER)
    {
        [self processServerTimeMessage:item];
        return NO;
    }
    
    //for debug
    //if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET)
    //    NSLog(@"%@", item);
    
    //是否朋友圈通知消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_MOMENT)
    {
        [self processMomentMessage:item];
        return NO;
    }
    
    //先截获110
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GN_CREATESUBGROUP)
        return NO;

    //是否重复消息（MESSAGE_CONTENT_TYPE_DELETEFILE, MESSAGE_CONTENT_TYPE_RECALL消息除外）
    if ([[item objectForKey:@"type"]integerValue] != MESSAGE_CONTENT_TYPE_DELETEFILE &&
        [[item objectForKey:@"type"]integerValue] != MESSAGE_CONTENT_TYPE_RECALL &&
        [[item objectForKey:@"type"]integerValue] != MESSAGE_CONTENT_TYPE_SERVERNOTIFY_NEWMESSAGECOUNT)
    {
        if ([[item objectForKey:@"isGroup"]boolValue])
        {
            if ([[BiChatDataModule sharedDataModule]isDuplicationMessage:[item objectForKey:@"msgId"] peerUid:[item objectForKey:@"receiver"]])
            {
                NSLog(@"duplicated message found, drop it");
                return NO;
            }
        }
        else
        {
            if ([[BiChatDataModule sharedDataModule]isDuplicationMessage:[item objectForKey:@"msgId"] peerUid:[item objectForKey:@"sender"]])
            {
                NSLog(@"duplicated message found, drop it");
                return NO;
            }
        }
    }
    
    //对方是否在我的黑名单中,群消息不算
    if (![[item objectForKey:@"isGroup"]boolValue] &&
        [[BiChatGlobal sharedManager]isFriendInBlackList:[item objectForKey:@"sender"]])
        return NO;

    //是否是推送消息,最先处理
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NEWS)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //通知delegate
        if ([BiChatGlobal sharedManager].pushNewsDelegate)
        {
            [[BiChatGlobal sharedManager].pushNewsDelegate pushNewsReceived:info];
        }
        return NO;
    }
    
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NEWS_DELETE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //通知delegate
        if ([BiChatGlobal sharedManager].pushNewsDelegate)
        {
            [[BiChatGlobal sharedManager].pushNewsDelegate deleteNewsReceived:info];
        }
        return NO;
    }
    
    //是否是大大群新消息数量通知消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_NEWMESSAGECOUNT)
    {
        [self processBigGroupNewMessageCountMessage:item];
        return NO;
    }
    
    //是否群主页点亮消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_HIGHLIGHTGROUPHOME)
    {
        NSLog(@"receive MESSAGE_CONTENT_TYPE_SERVERNOTIFY_HIGHLIGHTGROUPHOME");
        [self processServerNotifyHighlightGroupHome:item];
        return NO;
    }
    
    //是否群主页通知消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_NOTICEGROUPHOME)
    {
        NSLog(@"receive MESSAGE_CONTENT_TYPE_SERVERNOTIFY_NOTICEGROUPHOME");
        [self processServerNotifyNoticeGroupHome:item];
        return NO;
    }
    
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_FRESHGROUPHOME)
        NSLog(@"receive MESSAGE_CONTENT_TYPE_SERVERNOTIFY_FRESHGROUPHOME");
    
    //是否群改信息消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGEGROUPINFO)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //修改群名
        [self changeGroupInfo:info];
        return NO;
    }
    
    //是一条通讯录发生变化的消息，单独处理
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CONTACTCHANGED)
    {
        [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [[BiChatGlobal sharedManager].mainChatList refreshGUI];
            [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
            [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
        }];
        return NO;
    }
    
    //是否内部红包，不显示
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REDPACKET)
    {
        
        //解析一下红包信息
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        //内部红包
        if (![[info objectForKey:@"internalSee"]boolValue] &&
            [info objectForKey:@"internalSee"] != nil)
            return NO;

        //无效红包
        if ([[info objectForKey:@"redPacketId"]length] == 0 ||
            [[info objectForKey:@"redPacketId"]isKindOfClass:[NSNull class]] ||
            [[info objectForKey:@"redPacketId"] isEqualToString:@"(null)"])
            return NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            [[BiChatGlobal sharedManager].pushRewardDelegate pushRewardReceived:item];
        });
    }
    
    //下面进入真正的需要界面关注的消息处理阶段
    //是否群主和管理员收到的群审批消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBER||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GR_APPLYADDGROUPMEMBER ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GA_APPLYGROUP)
    {
        [self progressApplyGroupMember:item];
        
        //MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBER不需要显示，所以不用放入消息队列了
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBER)
            return NO;
    }
    
    //是否群主和管理员收到的群审批过期消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBEREXPIRE)
    {
        [self progressApplyGroupMemberExpire:item];
    }
    
    //是否群审批同意，拒绝，取消消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CANCELADDTOGROUP ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER)
    {
        [self processApplyGroupMemberOpt:item];
    }
    
    //是否需要重新获取群信息的消息，但是不需要显示
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGENICKNAME)
    {
        [NetworkModule getGroupProperty:[item objectForKey:@"receiver"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [[BiChatGlobal sharedManager].mainChatList refreshGUI];
            [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
            [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
        }];
        return NO;
    }
    
    //是否需要重新获取群信息的消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CREATEVIRTUALGROUP ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ADDVIRTUALGROUP ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ADDASSISTANT ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELASSISTANT ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ADDVIP ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELVIP ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPMUTE_ON ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPMUTE_OFF ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPADDMUTEUSERS ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPDELMUTEUSERS ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_ON ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_OFF ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_ON ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_OFF ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_ON ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_OFF ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_ON ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_OFF ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_FORBID ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPRESTART ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_UPGRADE2CHARGEGROUP ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_MODIFYCHARGEGROUP ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_NOTIFYCHARGEGROUPEXPIRE)
    {
        [NetworkModule getGroupPropertyLite:[item objectForKey:@"receiver"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [[BiChatGlobal sharedManager].mainChatList refreshGUI];
            [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
            [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
        }];
    }
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBERIN ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBEROUT ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPDISMISS)
    {
        [NetworkModule getGroupProperty:[item objectForKey:@"receiver"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [[BiChatGlobal sharedManager].mainChatList refreshGUI];
            [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
            [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
            [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
        }];
    }
    
    //进入消息filter
    [self messageFilter:item];
    
    //是一条打招呼信息,单独处理一下
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_HELLO)
        [[BiChatGlobal sharedManager]addFriendInInviteList:[item objectForKey:@"sender"]];
    
    //是加好友消息
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_PEER_MAKEFRIEND ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND ||
        [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_MAKEFRIEND)
        [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
    
    //是一条群头像变化消息，单独处理
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGEGROUPAVATAR)
    {
        //修改本地的群头像
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict4AvatarInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        [[BiChatDataModule sharedDataModule]setPeerAvatar:[item objectForKey:@"receiver"] withAvatar:[dict4AvatarInfo objectForKey:@"avatar"]];
        
        //保存本地
        [[BiChatGlobal sharedManager].dict4AvatarCache setObject:[dict4AvatarInfo objectForKey:@"avatar"] forKey:[item objectForKey:@"receiver"]];
        [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
        
        //通知本地
        [[BiChatGlobal sharedManager].mainChatList refreshGUI];
        [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
        [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
        [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
        [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
        [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
    }
    //其他消息，统一处理
    else
    {
        //如果是声音消息，马上启动线程下载这个声音
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_SOUND)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *dict4SoundInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            [[BiChatGlobal sharedManager]downloadSound:[dict4SoundInfo objectForKey:@"FileName"]
                                                 msgId:[item objectForKey:@"msgId"]];
        }
        
        //特殊的消息需要处理
        if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGEGROUPNAME)
        {
            [NetworkModule getGroupPropertyLite:[item objectForKey:@"receiver"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [[BiChatDataModule sharedDataModule]changePeerNameFor:[item objectForKey:@"receiver"]
                                                             withName:[[BiChatGlobal sharedManager]adjustGroupNickName4Display:[item objectForKey:@"receiver"] nickName:[item objectForKey:@"content"]]];
                
                //通知本地
                [[BiChatGlobal sharedManager].mainChatList refreshGUI];
                [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
                [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
            }];
            //[NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            //}];
        }
        else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME ||
                 [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME2)
        {
            [NetworkModule getGroupPropertyLite:[item objectForKey:@"receiver"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                [[BiChatDataModule sharedDataModule]changePeerNameFor:[item objectForKey:@"receiver"]
                                                             withName:[[BiChatGlobal sharedManager]adjustGroupNickName4Display:[item objectForKey:@"receiver"] nickName:[item objectForKey:@"content"]]];
                
                //通知本地
                [[BiChatGlobal sharedManager].mainChatList refreshGUI];
                [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
                [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
            }];
            //[NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            //}];
        }
        else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_CHANGEGROUPOWNER)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *dict4OwnerInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
            [[BiChatDataModule sharedDataModule]setPeerAvatar:[item objectForKey:@"receiver"]withAvatar:[dict4OwnerInfo objectForKey:@"avatar"]];
        }
        
        //处理一下这个消息里面包含的头像信息和昵称信息
        //保存全局头像
        if ([item objectForKey:@"senderAvatar"] != nil)
            [[BiChatGlobal sharedManager].dict4AvatarCache setObject:[item objectForKey:@"senderAvatar"] forKey:[item objectForKey:@"sender"]];
        //保存全局昵称
        if ([[item objectForKey:@"senderNickName"]length] > 0)
            [[BiChatGlobal sharedManager].dict4NickNameCache setObject:[item objectForKey:@"senderNickName"] forKey:[item objectForKey:@"sender"]];
        [[BiChatGlobal sharedManager]saveAvatarNickNameInfo];
        
        //分发消息
        if ([item objectForKey:@"orignalGroupId"] != nil)
            [self dispathGroupApproveMessage:item];
        else
            [self dispathMessage:item];
        
        //如果是一条群消息，而且这个群的信息没有在本地，则需要获取一下这个群的信息
        if ([[item objectForKey:@"isGroup"]boolValue]) {
            NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"receiver"]];
            if (groupProperty == nil)
            {
                [NetworkModule getGroupProperty:[item objectForKey:@"receiver"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
            }
        }
    }
    return YES;
}

//处理大大群消息条数消息
- (void)processBigGroupNewMessageCountMessage:(NSDictionary *)item
{
    //NSLog(@"big group notify message is received");
    JSONDecoder *dec = [JSONDecoder new];
    NSArray *messages = [dec mutableObjectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@", messages);
    for (NSDictionary *content in messages)
    {
        NSMutableDictionary *message = [dec mutableObjectWithData:[[content objectForKey:@"message"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //获取本地数据中本大大群的最后一条阅读消息的msgIndex
        NSInteger lastMessageIndex = [[BiChatDataModule sharedDataModule]getBigGroupLastReadMessageIndex:[message objectForKey:@"receiver"]];
        NSInteger newMessageCount = [[message objectForKey:@"msgIndex"]integerValue] - lastMessageIndex;
        if (newMessageCount > [[BiChatDataModule sharedDataModule]getNewMessageCountWith:[message objectForKey:@"receiver"]])
        {
            //设置最新的聊天
            //NSLog(@"flush big group new message count");
            [[BiChatDataModule sharedDataModule]setLastMessage:[message objectForKey:@"receiver"]
                                                  peerUserName:@""
                                                  peerNickName:[message objectForKey:@"receiverNickName"]
                                                    peerAvatar:[message objectForKey:@"receiverAvatar"]
                                                       message:[BiChatGlobal getMessageReadableString:message groupProperty:nil]
                                                   messageTime:[message objectForKey:@"timeStamp"]
                                                         isNew:NO isGroup:YES isPublic:NO createNew:YES];
            [[BiChatDataModule sharedDataModule]setNewMessageCountWith:[message objectForKey:@"receiver"] count:[[message objectForKey:@"msgIndex"]integerValue] - lastMessageIndex];
            [[BiChatGlobal sharedManager].mainChatList refreshGUI];
            [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
            
            //本消息是否at我
            NSArray *array4At = [[item objectForKey:@"at"]componentsSeparatedByString:@";"];
            for (NSString *str in array4At)
            {
                if ([str isEqualToString:[BiChatGlobal sharedManager].uid] ||
                    [str isEqualToString:ALLMEMBER_UID])
                {
                    [[BiChatDataModule sharedDataModule]addAtMeInGroup:[item objectForKey:@"receiver"]];
                    break;
                }
            }
            
            //本消息是否reply我
            if ([[item objectForKey:@"remarkSender"]isEqualToString:[BiChatGlobal sharedManager].uid])
                [[BiChatDataModule sharedDataModule]addReplyMeInGroup:[item objectForKey:@"receiver"]];
        }
        
        //入库
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[message objectForKey:@"receiver"]];
        if (groupProperty == nil)
        {
            [NetworkModule getGroupProperty:[message objectForKey:@"receiver"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                if (success)
                {
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[message objectForKey:@"receiver"] content:message];
                    [[BiChatGlobal sharedManager].mainChatList refreshGUI];
                    [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
                }
            }];
        }
        else
            [[BiChatDataModule sharedDataModule]addChatContentWith:[message objectForKey:@"receiver"] content:message];
    }
}

//朋友圈消息处理
- (void)processMomentMessage:(NSDictionary *)item
{
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *info = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    NSString * momentId = [info objectForKey:@"msgId"];
    
    DFPushModel * dfPushmodel = [DFPushModel mj_objectWithKeyValues:item];
    dfPushmodel.dfContent = [DFContent mj_objectWithKeyValues:info];
    dfPushmodel.pushModelCellHeight = [DFRemindingCell getCommentHeightWithModel:dfPushmodel];
    
    switch (dfPushmodel.dfContent.type)
    {
        case MOMENT_TYPE_NEW://新建朋友圈：
        {
            if (![dfPushmodel.sender isEqualToString:[BiChatGlobal sharedManager].uid])
            {
                //好友发布的新动态是否直接更新
                //                                [DFMomentsManager updateModelWithMomentId:momentId withType:dfPushmodel.dfContent.type   success:^(DFBaseMomentModel *model, NSString *successStr) {
                //                                }];
                
                //延迟显示红点
                [momentNewAvatar invalidate];
                momentNewAvatar = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    [DFMomentsManager sharedInstance].isNewMomentRedPoint = YES;
                    [DFMomentsManager sharedInstance].momentRedAvatar = dfPushmodel.dfContent.avatar;
                    [DFMomentsManager sharedInstance].momentRedName = dfPushmodel.dfContent.nickName;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_ADD_REDPOINT object:nil];
                }];
            }
            [DFMomentsManager updateModelWithMomentId:momentId withType:dfPushmodel.dfContent.type   success:^(DFBaseMomentModel *model, NSString *successStr) {
            }];
        }
            break;
        case MOMENT_TYPE_DELETE://删除朋友圈：
        {
            //动态处理
            [DFMomentsManager deleteModelWithMomentId:momentId];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADDATA object:nil];
            
            //消息处理
            NSArray * allModels = [[DFMomentsManager sharedInstance].remind_dict allValues];
            if (allModels.count > 0) {
                for (DFPushModel * oldModel in allModels) {
                    if ([oldModel.dfContent.msgId isEqualToString:momentId]) {
                        oldModel.isDeletedMoment = YES;
                        [DFMomentsManager insertDFPushModel:oldModel];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_MOMENT_TYPE_ChangeRemind object:oldModel];
                        });
                    }
                }
            }
        }
            break;
        case MOMENT_TYPE_ADDCOMMENT:    //添加评论：
        case MOMENT_TYPE_DELETECOMMENT: //删除评论：
        case MOMENT_TYPE_PRAISE:        //点赞：
        case MOMENT_TYPE_PRAISEUNDO:    //取消点赞：
        {
            
            //                            if (![dfPushmodel.sender isEqualToString:[BiChatGlobal sharedManager].uid])
            //                            {
            //消息处理
            if ((dfPushmodel.dfContent.type == MOMENT_TYPE_DELETECOMMENT) && dfPushmodel.dfContent.commentId) {
                DFPushModel * oldPushModel = [DFMomentsManager getRemindModelWithRemindId:dfPushmodel.dfContent.commentId];
                if (oldPushModel) {
                    oldPushModel.isDeletedRemindComment = YES;
                    [DFMomentsManager insertDFPushModel:oldPushModel];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_MOMENT_TYPE_ChangeRemind object:oldPushModel];
                    });
                }
            }
            //存库处
            [DFMomentsManager updateModelWithMomentId:momentId withType:dfPushmodel.dfContent.type   success:^(DFBaseMomentModel *model, NSString *successStr) {
            }];
            //                            }else{
            //                                if (dfPushmodel.dfContent.type == MOMENT_TYPE_ADDCOMMENT){
            //                                    //存库处
            //                                    [DFMomentsManager updateModelWithMomentId:momentId withType:dfPushmodel.dfContent.type   success:^(DFBaseMomentModel *model, NSString *successStr) {
            //                                    }];
            //                                }
            //                                NSLog(@"我自己的操作");
            //                            }
        }
            break;
        case MOMENT_TYPE_PROHIBITLOOK://不让我看朋友圈：
        {//更新数据源
            
            [[DFMomentsManager sharedInstance].blockMeMomentArr addObject:dfPushmodel.dfContent.uid];
            
            NSArray * blockMeArr = [DFMomentsManager sharedInstance].blockMeMomentArr;
            
            [[DFYTKDBManager sharedInstance].store putObject:blockMeArr withId:TabKey_BlockMeMomentArr intoTable:OtherTab];
            [DFYTKDBManager getArrAndDicFromeMomentTabWhtinIgnoreArr];
        }
            break;
        case MOMENT_TYPE_PROHIBITLOOKUNDO://取消不让我看朋友圈：
        {
            [[DFMomentsManager sharedInstance].blockMeMomentArr enumerateObjectsUsingBlock:^(NSString * blockMeId, NSUInteger idx, BOOL *stop) {
                if ([blockMeId isEqualToString:dfPushmodel.dfContent.uid]) {
                    *stop = YES;
                    if (*stop == YES) {
                        [[DFMomentsManager sharedInstance].blockMeMomentArr removeObject:blockMeId];
                        [DFYTKDBManager getArrAndDicFromeMomentTabWhtinIgnoreArr];
                    }
                }
                if (*stop) {
                    NSLog(@"array is dataSource");
                }
            }];
            
            NSArray * blockMeArr = [DFMomentsManager sharedInstance].blockMeMomentArr;
            [[DFYTKDBManager sharedInstance].store putObject:blockMeArr withId:TabKey_BlockMeMomentArr intoTable:OtherTab];
        }
            break;
        case MOMENT_TYPE_COMMENTREDPOINT://好友评论红点提示：
        case MOMENT_TYPE_PRAISEREDPOINT: //好友点赞红点提示：
        {
            
            if (![dfPushmodel.sender isEqualToString:[BiChatGlobal sharedManager].uid])
            {
                if (dfPushmodel.dfContent.type == MOMENT_TYPE_COMMENTREDPOINT) {
                    dfPushmodel.dfContent.pushId = dfPushmodel.dfContent.commentId;
                }else if (dfPushmodel.dfContent.type == MOMENT_TYPE_PRAISEREDPOINT){
                    dfPushmodel.dfContent.pushId = dfPushmodel.dfContent.praiseId;
                }
                [DFMomentsManager insertDFPushModel:dfPushmodel];
                [DFMomentsManager sharedInstance].newMomentRemindingCount += 1;
                
                NSDate * nwo = [NSDate dateWithTimeIntervalSinceNow:0];
                NSLog(@"来了一条新的推送——%@",nwo);

                [[DFYTKDBManager sharedInstance].store putNumber:[NSNumber numberWithInteger:[DFMomentsManager sharedInstance].newMomentRemindingCount] withId:TabKey_NewMomentRemindingCount intoTable:IndexTab];
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_MOMENT_TYPE_ADD_REDNUM object:nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_MOMENT_TYPE_ADD_REMINDINGVIEW object:nil];

//                //延迟显示新的评论点赞动态
//                [momentNewRedNum invalidate];
//                momentNewRedNum = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
//                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_MOMENT_TYPE_ADD_REDNUM object:nil];
//                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_MOMENT_TYPE_ADD_REMINDINGVIEW object:nil];
//                }];
            }else{
                NSLog(@"我自己的操作");
            }
        }
            break;
        default:
            break;
    }
}

//服务器时间消息处理
- (void)processServerTimeMessage:(NSDictionary *)item
{
    NSLog(@"process Server Time:%@", item);
    [BiChatGlobal sharedManager].serverTimeOffset = [[NSDate date]timeIntervalSince1970] - [[item objectForKey:@"content"]doubleValue] / 1000;
}

//消息过滤器
- (void)messageFilter:(NSMutableDictionary *)item
{
    //鲁棒性处理
    if ([[item objectForKey:@"receiverNickName"]isEqualToString:@"(null)"])
        [item setObject:@"" forKey:@"receiverNickName"];
    
    //处理消息的时间戳
    if ([item objectForKey:@"timeStamp"] == nil)
    {
        [item setObject:[BiChatGlobal getCurrentDateString] forKey:@"timeStamp"];
    }
    
    //其他类型的消息处理
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *friends = [targetInfo objectForKey:@"friends"];
        for (NSDictionary *item1 in friends)
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@", [item1 objectForKey:@"uid"], [item objectForKey:@"receiver"]];
            [[BiChatGlobal sharedManager].dict4ApplyList setObject:@"REJECTED" forKey:key];
        }
        [[BiChatGlobal sharedManager]saveUserAdditionInfo];
    }
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *friends = [targetInfo objectForKey:@"friends"];
        for (NSDictionary *item1 in friends)
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@", [item1 objectForKey:@"uid"], [item objectForKey:@"receiver"]];
            [[BiChatGlobal sharedManager].dict4ApplyList setObject:@"APPROVED" forKey:key];
        }
        [[BiChatGlobal sharedManager]saveUserAdditionInfo];
    }
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if (![[targetInfo objectForKey:@"fromGroupId"]isEqualToString:[targetInfo objectForKey:@"groupId"]])
        {
            //如果我包含在这个消息内
            for (NSDictionary *item in [targetInfo objectForKey:@"assignedMember"])
            {
                if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
                {
                    //从原来的申请加入的群转移到新的群，原来的群id统一转换为新的id
                    [[BiChatDataModule sharedDataModule]changePeerUid:[targetInfo objectForKey:@"fromGroupId"] to:[targetInfo objectForKey:@"groupId"]];
                    break;
                }
            }
        }
    }
    //是否普通群升级为超大群消息
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_UPGRADETOBIGGROUP)
    {
        NSString *groupId = [item objectForKey:@"receiver"];
        NSMutableDictionary *groupInfo = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
        [groupInfo setObject:@"1" forKey:@"isUnlimitedGroup"];
        [[BiChatDataModule sharedDataModule]setGroupProperty:groupId property:groupInfo];
        [[BiChatGlobal sharedManager].mainChatList refreshGUI];
    }
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_GROUPBOARDITEM)
    {
        NSString *groupId = [item objectForKey:@"receiver"];
        [[BiChatDataModule sharedDataModule]setNewBoardInfoInGroup:groupId];
    }
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_EXPIRE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        [[BiChatGlobal sharedManager]setExchangeMoneyFinished:[targetInfo objectForKey:@"transactionId"] status:4];
    }
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        [[BiChatGlobal sharedManager]setExchangeMoneyFinished:[targetInfo objectForKey:@"transactionId"] status:2];
    }
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        [[BiChatGlobal sharedManager]setExchangeMoneyFinished:[targetInfo objectForKey:@"transactionId"] status:1];
    }
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY &&
             [[item objectForKey:@"isGroup"]boolValue])
    {
        [[BiChatDataModule sharedDataModule]addExchangeMessageForGroup:[item objectForKey:@"receiver"] message:item];
    }
}

- (void)progressApplyGroupMember:(NSMutableDictionary *)item
{
    //检查参数
    if ([[item objectForKey:@"content"]length] == 0)
        return;
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *friendInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableArray *friends = [friendInfo objectForKey:@"friends"];
    NSString *groupId = [item objectForKey:@"receiver"];
    
    //添加到本地的列表
    for (NSDictionary *friend in friends)
    {
        //先查一下是不是已经在里面
        if ([self isUserInApproveList:[friend objectForKey:@"uid"] groupId:groupId])
            [self delUserFromApproveList:[friend objectForKey:@"uid"] groupId:groupId];
        
        //添加一个条目
        NSMutableDictionary *approveItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [friend objectForKey:@"uid"], @"uid",
                                            [friend objectForKey:@"nickName"]==nil?@"":[friend objectForKey:@"nickName"], @"nickName",
                                            [friend objectForKey:@"avatar"]==nil?@"":[friend objectForKey:@"avatar"], @"avatar",
                                            groupId, @"groupId",
                                            [friend objectForKey:@"groupNickName"]==nil?([item objectForKey:@"receiverNickName"]==nil?@"":[item objectForKey:@"receiverNickName"]):[friend objectForKey:@"groupNickName"], @"groupNickName",
                                            [item objectForKey:@"receiverAvatar"]==nil?@"":[item objectForKey:@"receiverAvatar"], @"groupAvatar",
                                            [item objectForKey:@"sender"]==nil?@"":[item objectForKey:@"sender"], @"sender",
                                            [item objectForKey:@"senderNickName"]==nil?@"":[item objectForKey:@"senderNickName"], @"senderNickName",
                                            [item objectForKey:@"senderAvatar"]==nil?@"":[item objectForKey:@"senderAvatar"], @"senderAvatar",
                                            [friendInfo objectForKey:@"apply"]==nil?@"":[friendInfo objectForKey:@"apply"], @"apply",
                                            [friendInfo objectForKey:@"source"]==nil?@"":[friendInfo objectForKey:@"source"], @"source",
                                            nil];
        
        [[BiChatGlobal sharedManager].array4ApproveList addObject:approveItem];
    }
    [[BiChatGlobal sharedManager]saveUserAdditionInfo];
    
    //主界面添加一个条目,表明有一个入群申请
    [[BiChatDataModule sharedDataModule]setLastMessage:REQUEST_FOR_APPROVE
                                          peerUserName:@""
                                          peerNickName:LLSTR(@"201311")
                                            peerAvatar:@""
                                               message:[friendInfo objectForKey:@"apply"]
                                           messageTime:[item objectForKey:@"timeStamp"]
                                                 isNew:YES
                                               isGroup:YES
                                              isPublic:NO
                                             createNew:YES];
    
    //刷新界面
    [[BiChatGlobal sharedManager].mainChatList refreshGUI];
    [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
    [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
    [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
    [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
    [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
    [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
    
    //设置有新的群聊邀请信息
    [[BiChatDataModule sharedDataModule]setNewApplyGroup:groupId];
    
    //发出一个内部通知
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_APPLYGROUP object:nil];
}

- (void)progressApplyGroupMemberExpire:(NSDictionary *)item
{
    //检查参数
    if ([item objectForKey:@"content"] == nil)
        return;
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *friendInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableArray *friends = [friendInfo objectForKey:@"friends"];
    NSString *groupId = [item objectForKey:@"receiver"];
    
    //删除本地的列表
    for (NSDictionary *friend in friends)
    {
        //查一下是不是已经在里面
        if ([self isUserInApproveList:[friend objectForKey:@"uid"] groupId:groupId])
            [self expireUserFromApproveList:[friend objectForKey:@"uid"] groupId:groupId];
        
    }
    [[BiChatGlobal sharedManager]saveUserAdditionInfo];
    
    //刷新界面
    [[BiChatGlobal sharedManager].mainChatList refreshGUI];
    [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
    [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
    [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
    [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
    [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
    [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
    
    //发出一个内部通知
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_APPLYGROUP object:nil];
}

- (void)processApplyGroupMemberOpt:(NSDictionary *)item
{
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *friendInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableArray *friends = [friendInfo objectForKey:@"friends"];
    NSString *groupId = [item objectForKey:@"receiver"];
    
    //删除本地的对应的群成员申请列表
    for (NSDictionary *item in friends)
    {
        NSString *uid = [item objectForKey:@"uid"];
        for (NSDictionary *friend in [BiChatGlobal sharedManager].array4ApproveList)
        {
            if ([groupId isEqualToString:[friend objectForKey:@"groupId"]] &&
                [uid isEqualToString:[friend objectForKey:@"uid"]])
            {
                [[BiChatGlobal sharedManager].array4ApproveList removeObject:friend];
                break;
            }
        }
    }
    
    [[BiChatGlobal sharedManager]saveUserAdditionInfo];
    
    //刷新界面
    [[BiChatGlobal sharedManager].mainChatList refreshGUI];
    [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
    [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
    [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
    [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
    [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
    [[BiChatDataModule sharedDataModule]freshTotalNewMessageCount];
}

//处理通知群主页点亮消息
- (void)processServerNotifyHighlightGroupHome:(NSDictionary *)item
{
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *groupHomeHighlightInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    [[BiChatDataModule sharedDataModule]setGroupHomeHighlightInGroup:[item objectForKey:@"receiver"] groupHomeId:[groupHomeHighlightInfo objectForKey:@"homeId"]];

    [[BiChatGlobal sharedManager].mainChatList refreshGUI];
    ChatViewController *chatWnd = (ChatViewController *)[BiChatGlobal sharedManager].currentChatWnd;
    [chatWnd freshGroupStatus];
}

//处理通知群主页通知消息
- (void)processServerNotifyNoticeGroupHome:(NSDictionary *)item
{
    //NSLog(@"%@", item);
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *groupHomeNoticeInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    [[BiChatDataModule sharedDataModule]setGroupHomeNoticeInGroup:[item objectForKey:@"receiver"]
                                                      groupHomeId:[groupHomeNoticeInfo objectForKey:@"homeId"]
                                                  groupHomeNotice:[groupHomeNoticeInfo objectForKey:@"desc"]];
    [[BiChatGlobal sharedManager].mainChatList refreshGUI];
    ChatViewController *chatWnd = (ChatViewController *)[BiChatGlobal sharedManager].currentChatWnd;
    [chatWnd freshGroupStatus];
}

//判断一个人是否在待批准列表里面
- (BOOL)isUserInApproveList:(NSString *)uid groupId:(NSString *)groupId
{
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]] &&
            [groupId isEqualToString:[item objectForKey:@"groupId"]])
            return YES;
    }
    return NO;
}

//从批准列表里面删除一个人
- (void)delUserFromApproveList:(NSString *)uid groupId:(NSString *)groupId
{
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]] &&
            [groupId isEqualToString:[item objectForKey:@"groupId"]])
        {
            [[BiChatGlobal sharedManager].array4ApproveList removeObject:item];
            return;
        }
    }
}

//设置一个条目已经过期
- (void)expireUserFromApproveList:(NSString *)uid groupId:(NSString *)groupId
{
    for (NSMutableDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]] &&
            [groupId isEqualToString:[item objectForKey:@"groupId"]])
        {
            [item setObject:@"EXPIRED" forKey:@"status"];
            return;
        }
    }
}

- (void)dispathGroupApproveMessage:(NSMutableDictionary *)item
{
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"receiver"]];
    NSString *transferMoneyTransactionId = nil;
    
    //根据不同的类型进行处理
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *transferInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        transferMoneyTransactionId = [transferInfo objectForKey:@"transactionId"];
        [[BiChatGlobal sharedManager]setTransferMoneyFinished:[transferInfo objectForKey:@"transactionId"] status:1];
    }
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *transferInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        transferMoneyTransactionId = [transferInfo objectForKey:@"transactionId"];
        [[BiChatGlobal sharedManager]setTransferMoneyFinished:[transferInfo objectForKey:@"transactionId"] status:2];
    }
    
    //这条消息的接收者是否正在显示？
    ChatViewController *chat = (ChatViewController *)[BiChatGlobal sharedManager].currentChatWnd;
    if (([[item objectForKey:@"applyUser"]isEqualToString:[BiChatGlobal sharedManager].uid] &&
         [chat.peerUid isEqualToString:[item objectForKey:@"orignalGroupId"]]) ||
        (![[item objectForKey:@"applyUser"]isEqualToString:[BiChatGlobal sharedManager].uid] &&
         [chat.peerUid isEqualToString:[item objectForKey:@"receiver"]]))
    {
        //消息是发给请求入群的人
        if ([[item objectForKey:@"applyUser"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            //是否需要忽略本条消息
            if ([item objectForKey:@"applyIgnor"])
                return;
            
            //处理这条消息
            [chat freshTransferMoneyItem:transferMoneyTransactionId];
            [chat appendMessageFromNetwork:item];
            
            //重新整理content
            NSString *str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty];
            NSString *str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                                         [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:groupProperty nickName:[item objectForKey:@"senderNickName"]],
                                         str4Content];
            
            //是系统消息或者是我的消息？
            if ([[item objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] ||
                [BiChatGlobal isSystemMessage:item])
            {
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:chat.peerUid
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4Content
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
            }
            else
            {
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:chat.peerUid
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4LastMessage
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
            }
        }
        else
        {
            [chat freshTransferMoneyItem:transferMoneyTransactionId];
            [chat appendMessageFromNetwork:item];
            
            //重新整理content
            NSString *str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty];
            NSString *str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                                         [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:groupProperty nickName:[item objectForKey:@"senderNickName"]],
                                         str4Content];
            
            //是系统消息或者是我的消息？
            if ([[item objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] ||
                [BiChatGlobal isSystemMessage:item])
            {
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:chat.peerUid
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4Content
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:NO
                                                         isApprove:YES
                                                    orignalGroupId:[item objectForKey:@"orignalGroupId"]
                                                         applyUser:[item objectForKey:@"applyUser"]
                                                 applyUserNickName:[item objectForKey:@"applyUserNickName"]
                                                   applyUserAvatar:[item objectForKey:@"applyUserAvatar"]
                                                         createNew:YES];
            }
            else
            {
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:chat.peerUid
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4LastMessage
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:NO
                                                         isApprove:YES
                                                    orignalGroupId:[item objectForKey:@"orignalGroupId"]
                                                         applyUser:[item objectForKey:@"applyUser"]
                                                 applyUserNickName:[item objectForKey:@"applyUserNickName"]
                                                   applyUserAvatar:[item objectForKey:@"applyUserAvatar"]
                                                         createNew:YES];
            }
        }
    }
    else
    {
        //是否需要发出声音和震动
        [self notifyMessage:item];
        NSString *targetId = nil;
        
        //消息是发给请求入群的人
        if ([[item objectForKey:@"applyUser"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            //是否需要忽略本条消息
            if ([item objectForKey:@"applyIgnor"])
                return;
            
            targetId = [item objectForKey:@"orignalGroupId"];
            
            //是系统消息或者是我的消息？
            if ([[item objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] ||
                [BiChatGlobal isSystemMessage:item])
            {
                if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELETEFILE ||
                    [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_RECALL)
                {
                    //修改全局聊天记录里面的数据
                    [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:targetId
                                                                                 msgId:[item objectForKey:@"msgId"]
                                                                               message:item];
                }
                else
                {
                    //记录在全局聊天记录里面
                    [[BiChatDataModule sharedDataModule]addChatContentWith:targetId content:item];
                }
                
                //重新整理content
                NSString *str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty];
                
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:targetId
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4Content
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:YES
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
            }
            else
            {
                if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELETEFILE ||
                    [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_RECALL)
                {
                    //修改全局聊天记录里面的数据
                    [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:targetId
                                                                                 msgId:[item objectForKey:@"msgId"]
                                                                               message:item];
                }
                else
                {
                    //记录在全局聊天记录里面
                    [[BiChatDataModule sharedDataModule]addChatContentWith:targetId content:item];
                }
                
                //重新整理content
                NSString *str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:nil];
                NSString *str4LastMessage;
                
                //记录在全局聊天列表里面
                if ([[item objectForKey:@"isPublic"]boolValue])
                    str4LastMessage = str4Content;
                [[BiChatDataModule sharedDataModule]setLastMessage:targetId
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4Content
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:YES
                                                           isGroup:YES
                                                          isPublic:NO
                                                         createNew:YES];
            }
        }
        
        //消息是发给管理员
        else
        {
            targetId = [item objectForKey:@"receiver"];
            
            //是系统消息或者是我的消息？
            if ([[item objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] ||
                [BiChatGlobal isSystemMessage:item])
            {
                if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELETEFILE ||
                    [[item objectForKey:@"tyep"]integerValue] == MESSAGE_CONTENT_TYPE_RECALL)
                {
                    //修改全局聊天记录里面的数据
                    [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:targetId
                                                                                 msgId:[item objectForKey:@"msgId"]
                                                                               message:item];
                }
                else
                {
                    //记录在全局聊天记录里面
                    [[BiChatDataModule sharedDataModule]addChatContentWith:targetId content:item];
                }
                
                //重新整理content
                NSString *str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty];
                
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:targetId
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4Content
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:YES
                                                         isApprove:YES
                                                    orignalGroupId:[item objectForKey:@"orignalGroupId"]
                                                         applyUser:[item objectForKey:@"applyUser"]
                                                 applyUserNickName:[item objectForKey:@"applyUserNickName"]
                                                   applyUserAvatar:[item objectForKey:@"applyUserAvatar"]
                                                         createNew:YES];
            }
            else
            {
                if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELETEFILE ||
                    [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_RECALL)
                {
                    //修改全局聊天记录里面的数据
                    [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:targetId
                                                                                 msgId:[item objectForKey:@"msgId"]
                                                                               message:item];
                }
                else
                {
                    //记录在全局聊天记录里面
                    [[BiChatDataModule sharedDataModule]addChatContentWith:targetId content:item];
                }
                
                //重新整理content
                NSString *str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty];
                NSString *str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                                             [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:groupProperty nickName:[item objectForKey:@"senderNickName"]],
                                             str4Content];
                
                //记录在全局聊天列表里面
                if ([[item objectForKey:@"isPublic"]boolValue])
                    str4LastMessage = str4Content;
                [[BiChatDataModule sharedDataModule]setLastMessage:targetId
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4Content
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:YES
                                                         isApprove:YES
                                                    orignalGroupId:[item objectForKey:@"orignalGroupId"]
                                                         applyUser:[item objectForKey:@"applyUser"]
                                                 applyUserNickName:[item objectForKey:@"applyUserNickName"]
                                                   applyUserAvatar:[item objectForKey:@"applyUserAvatar"]
                                                         createNew:YES];
            }
        }
    }
}

- (void)dispathMessage:(NSMutableDictionary *)item
{
    NSString *transferMoneyTransactionId = nil;
    
    if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *transferInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        transferMoneyTransactionId = [transferInfo objectForKey:@"transactionId"];
        [[BiChatGlobal sharedManager]setTransferMoneyFinished:[transferInfo objectForKey:@"transactionId"] status:1];
    }
    else if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *transferInfo = [dec objectWithData:[[item objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        transferMoneyTransactionId = [transferInfo objectForKey:@"transactionId"];
        [[BiChatGlobal sharedManager]setTransferMoneyFinished:[transferInfo objectForKey:@"transactionId"] status:2];
    }
    
    //这条消息的接收者是否正在显示？
    ChatViewController *chat = (ChatViewController *)[BiChatGlobal sharedManager].currentChatWnd;
    if (chat != nil &&
        ((chat.isPublic && [chat.peerUid isEqualToString:[item objectForKey:@"sender"]]) ||
         (chat.isGroup && [[item objectForKey:@"isGroup"]boolValue] && [chat.peerUid isEqualToString:[item objectForKey:@"receiver"]]) ||
         (!chat.isGroup && ![[item objectForKey:@"isGroup"]boolValue] && [chat.peerUid isEqualToString:[item objectForKey:@"sender"]])))
    {
        [chat freshTransferMoneyItem:transferMoneyTransactionId];
        [chat appendMessageFromNetwork:item];
        
        //重新整理content
        NSString *str4Content;
        NSString *str4LastMessage;
        if ([[item objectForKey:@"isGroup"]boolValue])
        {
            NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"receiver"]];
            str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty];
            str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                               [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:groupProperty nickName:[item objectForKey:@"senderNickName"]],
                               str4Content];
        }
        else
        {
            str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:nil];
            str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                               [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:nil nickName:[item objectForKey:@"senderNickName"]],
                               str4Content];
        }
        
        //是否群聊消息
        if ([[item objectForKey:@"isGroup"]boolValue])
        {
            //是系统消息或者是我的消息？
            if ([[item objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] ||
                [BiChatGlobal isSystemMessage:item])
            {
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:chat.peerUid
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4Content
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:NO
                                                           isGroup:chat.isGroup
                                                          isPublic:chat.isPublic
                                                         createNew:YES];
            }
            else
            {
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:chat.peerUid
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4LastMessage
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:NO
                                                           isGroup:chat.isGroup
                                                          isPublic:chat.isPublic
                                                         createNew:YES];
            }
        }
        else
        {
            //记录在全局聊天列表里面
            [[BiChatDataModule sharedDataModule]setLastMessage:chat.peerUid
                                                  peerUserName:[item objectForKey:@"senderUserName"]
                                                  peerNickName:[item objectForKey:@"senderNickName"]
                                                    peerAvatar:[item objectForKey:@"senderAvatar"]
                                                       message:str4Content
                                                   messageTime:[item objectForKey:@"timeStamp"]
                                                         isNew:NO
                                                       isGroup:chat.isGroup
                                                      isPublic:chat.isPublic
                                                     createNew:YES];
        }
    }
    else
    {
        //是否需要发出声音和震动
        [self notifyMessage:item];
        
        //群聊消息
        if ([[item objectForKey:@"isGroup"]boolValue])
        {
            //本消息是否at我
            NSArray *array4At = [[item objectForKey:@"at"]componentsSeparatedByString:@";"];
            for (NSString *str in array4At)
            {
                if ([str isEqualToString:[BiChatGlobal sharedManager].uid] ||
                    [str isEqualToString:ALLMEMBER_UID])
                {
                    [[BiChatDataModule sharedDataModule]addAtMeInGroup:[item objectForKey:@"receiver"]];
                    break;
                }
            }
            
            //本消息是否reply我
            if ([[item objectForKey:@"remarkSender"]isEqualToString:[BiChatGlobal sharedManager].uid])
                [[BiChatDataModule sharedDataModule]addReplyMeInGroup:[item objectForKey:@"receiver"]];
            
            //是系统消息或者是我的消息？
            if ([[item objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] ||
                [BiChatGlobal isSystemMessage:item])
            {
                if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELETEFILE ||
                    [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_RECALL)
                {
                    //修改全局聊天记录里面的数据
                    [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:[item objectForKey:@"receiver"]
                                                                                 msgId:[item objectForKey:@"msgId"]
                                                                               message:item];
                }
                else
                {
                    //记录在全局聊天记录里面
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[item objectForKey:@"receiver"] content:item];
                }
                
                //重新整理content
                NSString *str4Content;
                NSString *str4LastMessage;
                if ([[item objectForKey:@"isGroup"]boolValue])
                {
                    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"receiver"]];
                    str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty];
                    str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                                       [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:groupProperty nickName:[item objectForKey:@"senderNickName"]],
                                       str4Content];
                }
                else
                {
                    str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:nil];
                    str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                                       [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:nil nickName:[item objectForKey:@"senderNickName"]],
                                       str4Content];
                }
                
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:[item objectForKey:@"receiver"]
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4Content
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:NO
                                                           isGroup:YES
                                                          isPublic:[[item objectForKey:@"isPublic"]boolValue]
                                                         createNew:YES];
            }
            else
            {
                if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELETEFILE ||
                    [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_RECALL)
                {
                    //修改全局聊天记录里面的数据
                    [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:[item objectForKey:@"receiver"]
                                                                                 msgId:[item objectForKey:@"msgId"]
                                                                               message:item];
                }
                else
                {
                    //记录在全局聊天记录里面
                    [[BiChatDataModule sharedDataModule]addChatContentWith:[item objectForKey:@"receiver"] content:item];
                }
                
                NSString *str4Content;
                NSString *str4LastMessage;
                if ([[item objectForKey:@"isGroup"]boolValue])
                {
                    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"receiver"]];
                    str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty];
                    str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                                       [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:groupProperty nickName:[item objectForKey:@"senderNickName"]],
                                       str4Content];
                }
                else
                {
                    str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:nil];
                    str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                                       [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:nil nickName:[item objectForKey:@"senderNickName"]],
                                       str4Content];
                }
                
                //记录在全局聊天列表里面
                [[BiChatDataModule sharedDataModule]setLastMessage:[item objectForKey:@"receiver"]
                                                      peerUserName:@""
                                                      peerNickName:[item objectForKey:@"receiverNickName"]
                                                        peerAvatar:[item objectForKey:@"receiverAvatar"]
                                                           message:str4LastMessage
                                                       messageTime:[item objectForKey:@"timeStamp"]
                                                             isNew:[BiChatGlobal isSystemMessage:item]?NO:YES
                                                           isGroup:YES
                                                          isPublic:[[item objectForKey:@"isPublic"]boolValue]
                                                         createNew:YES];
            }
        }
        else
        {
            if ([[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_DELETEFILE ||
                [[item objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_RECALL)
            {
                //修改全局聊天记录里面的数据
                [[BiChatDataModule sharedDataModule]replaceAPieceOfChatContentWith:[item objectForKey:@"sender"]
                                                                             msgId:[item objectForKey:@"msgId"]
                                                                           message:item];
            }
            else
            {
                //记录在全局聊天记录里面
                [[BiChatDataModule sharedDataModule]addChatContentWith:[item objectForKey:@"sender"] content:item];
            }
            
            NSString *str4Content;
            NSString *str4LastMessage;
            if ([[item objectForKey:@"isGroup"]boolValue])
            {
                NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:[item objectForKey:@"receiver"]];
                str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:groupProperty];
                str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                                   [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:groupProperty nickName:[item objectForKey:@"senderNickName"]],
                                   str4Content];
            }
            else
            {
                str4Content = [BiChatGlobal getMessageReadableString:item groupProperty:nil];
                str4LastMessage = [NSString stringWithFormat:@"%@: %@",
                                   [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[item objectForKey:@"sender"] groupProperty:nil nickName:[item objectForKey:@"senderNickName"]],
                                   str4Content];
            }
            
            //记录在全局聊天列表里面
            [[BiChatDataModule sharedDataModule]setLastMessage:[item objectForKey:@"sender"]
                                                  peerUserName:[item objectForKey:@"senderUserName"]
                                                  peerNickName:[item objectForKey:@"senderNickName"]
                                                    peerAvatar:[item objectForKey:@"senderAvatar"]
                                                       message:str4Content
                                                   messageTime:[NSString stringWithFormat:@"%@", [item objectForKey:@"timeStamp"]]
                                                         isNew:[BiChatGlobal isSystemMessage:item]?NO:YES
                                                       isGroup:NO
                                                      isPublic:[[item objectForKey:@"isPublic"]boolValue]
                                                     createNew:YES];
        }
    }
}

- (void)onPipeState:(streamStateCode)state
{
    [[BiChatGlobal sharedManager]imChatLog:@"网络模块状态:", [NSString stringWithFormat:@"%u", state], nil];
    [BiChatGlobal sharedManager].networkState = state;
    [[BiChatGlobal sharedManager].mainChatList relayNetworkState:state];
    [[DFMomentsManager sharedInstance] relayNetworkState:state];
    
    //网络连接成功
    if (state == 200)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
           
            //开启网络
            [NetworkModule resumeNetwork:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            
#ifndef TEST_STUCK
            if (![BiChatGlobal sharedManager].batchGetMessage)
                [PokerStreamClient turnStreamingOnOff:YES];
#endif
            
            //检查一下是否有新版本
            [NetworkModule getAppVersion:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            [NetworkModule reportMyNotificationId:[BiChatGlobal sharedManager].notificationDeviceToken completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            
            //获取一下最新的appconfig
            NSLog(@"local system config version:%@", [BiChatGlobal sharedManager].systemConfigVersionNumber);
            //[BiChatGlobal sharedManager].systemConfigVersionNumber = @"0";
            if (![NetworkModule getAppConfig:[BiChatGlobal sharedManager].systemConfigVersionNumber completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                //NSLog(@"1----%@", data);
                [[BiChatGlobal sharedManager]processSystemConfigMessage:[data objectForKey:@"data"]];
                if ([data objectForKey:@"serverTime"] != nil &&
                    [[data objectForKey:@"serverTime"]integerValue] != 0)
                    [BiChatGlobal sharedManager].serverTimeOffset = [[NSDate date]timeIntervalSince1970] - [[data objectForKey:@"serverTime"]doubleValue] / 1000;
            }])
            {
                //NSLog(@"2---error");
            }
            
            //是否需要重新登录
            if ([BiChatGlobal sharedManager].bLogin &&
                [BiChatGlobal sharedManager].token.length > 0)
            {
                //加载一些数据
                //[[BiChatGlobal sharedManager]loadUserInfo];
                //[[BiChatGlobal sharedManager]loadUserAdditionInfo];
                //[[BiChatGlobal sharedManager]loadUserEmotionInfo];
                [[BiChatGlobal sharedManager]downloadAllPendingSound];
                
                //刷新主界面
                [[BiChatGlobal sharedManager].mainChatList refreshGUI];
                [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
                [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
                [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
                
                //根据不同的登录模式选择重新登录的方式
                if ([BiChatGlobal sharedManager].loginMode == LOGIN_MODE_BY_PASSWORD)
                {
                    [self reLoginByPassword];
                }
                else if ([BiChatGlobal sharedManager].loginMode == LOGIN_MODE_BY_VERIFYCODE ||
                         [BiChatGlobal sharedManager].loginMode == LOGIN_MODE_BY_WECHAT)
                {
                    //获取一下我的通讯录
                    [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
                        if (success )
                        {
                            [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
                                
                                if (success)
                                {
                                    [[BiChatGlobal sharedManager].mainChatList refreshGUI];
                                    [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
                                    [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
                                    [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
                                    [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
                                    //[[DFYTKDBManager sharedInstance] getMomentFromUser];
                                }
                            }];
                        }
                    }];
                    
                    //获取一下我的钱包的信息
                    [NetworkModule getWallet:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success)
                        {
                            [BiChatGlobal sharedManager].dict4WalletInfo = data;
                            [[BiChatGlobal sharedManager]saveUserInfo];
                        }
                    }];
                    
                    //获取token信息
                    [NetworkModule getTokenInfo:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        
                        if (success)
                            [BiChatGlobal sharedManager].dict4MyTokenInfo = data;
                    }];
                }
            }
            else if ([BiChatGlobal sharedManager].bLogin)
                [[BiChatGlobal sharedManager]loginPortal];
        }];
    }
}

- (void)onBadToken
{
    [PokerStreamClient disconect];
    
    //清除本地数据
    [BiChatGlobal sharedManager].bLogin = NO;
    [BiChatGlobal sharedManager].nickName = @"";
    [BiChatGlobal sharedManager].avatar = @"";
    [BiChatGlobal sharedManager].token = nil;
    [BiChatGlobal sharedManager].uid = @"";
    [BiChatGlobal sharedManager].array4AllFriendGroup = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4AllGroup = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4BlackList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4Invite = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4MuteList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4StickList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4FoldList = [NSMutableArray array];
    [BiChatGlobal sharedManager].array4FollowList = [NSMutableArray array];
    [[BiChatGlobal sharedManager]saveGlobalInfo];
    
    if ([BiChatGlobal sharedManager].loginMode == LOGIN_MODE_BY_PASSWORD)
        [self reLoginByPassword];
    else
        [[BiChatGlobal sharedManager]loginPortal];
}

#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req{
    
    if (req.type == 0)
    {
        LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
        WXAppExtendObject *obj = (WXAppExtendObject *)launchReq.message.mediaObject;
        NSString *info = obj.extInfo;
        if ([info hasPrefix:@"goods_id="])
        {
        }
    }
}

//微信回调
-(void) onResp:(BaseResp*)resp{
    
    //NSLog(@"%@ - %d - %d - %@", resp.class, resp.type, resp.errCode, resp.errStr);
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        
        //微信获取用户信息返回，用于微信登陆
        SendAuthResp *resp4Auth = (SendAuthResp *)resp;
        if ([resp4Auth.state isEqualToString:@"fulishe_wechat_logon_1290234"])
        {
            //通知一下
            if ([[BiChatGlobal sharedManager].weChatBindTarget conformsToProtocol:@protocol(WeChatBindingNotify)])
            {
                id<WeChatBindingNotify> delegate = (id<WeChatBindingNotify>)[BiChatGlobal sharedManager].weChatBindTarget;
                [delegate weChatBindingSuccess:resp4Auth.code];
            }
        }
        
        return;
    }
    else if([resp isKindOfClass:[PayResp class]])
    {
        return;
    }
    
    int result = [resp errCode];
    if (result == 0) {
        [BiChatGlobal showInfo:LLSTR(@"301605") withIcon:Image(@"icon_OK")];
    }else if(result == -2){
        [BiChatGlobal showInfo:LLSTR(@"301607") withIcon:Image(@"icon_alert")];
    }else if(result == -1){
        [BiChatGlobal showInfo:LLSTR(@"301608") withIcon:Image(@"icon_alert")];
    }
}

#pragma mark - 私有函数

- (void)initNetStream
{
    //建立全局网络连接(62816)(32780)
#ifdef ENV_DEV
    //开发服务器
    NSLog(@"Connect to dev server ...");
    [PokerStreamClient init:@[@"52.221.141.142"] port:62816 delegate:self];
#endif
#ifdef ENV_TEST
    //测试服务器
    NSLog(@"Connect to test server ...");
    [PokerStreamClient init:@[@"52.74.123.225", @"52.74.130.221"] port:62816 delegate:self];
#endif
#ifdef ENV_LIVE
    //生产服务器
    NSLog(@"Connect to live server ...");
    [PokerStreamClient init:@[@"13.251.33.137"] port:62816 delegate:self];
#endif
#ifdef ENV_CN
    //生产服务器
    NSLog(@"Connect to live server ...");
    [PokerStreamClient init:@[@"13.251.33.137"] port:62816 delegate:self];
#endif
#ifdef ENV_ENT
    //生产服务器
    NSLog(@"Connect to live server ...");
    [PokerStreamClient init:@[@"13.251.33.137"] port:62816 delegate:self];
#endif
#ifdef ENV_V_DEV
    //开发服务器
    NSLog(@"Connect to dev server ...");
    [PokerStreamClient init:@[@"52.221.141.142"] port:62816 delegate:self];
#endif
    networkInited = YES;
}

//批量获取消息
- (void)batchGetMessage
{
    [[BiChatGlobal sharedManager]imChatLog:@"Batch get message begin...", nil];
    [BiChatGlobal sharedManager].batchGetMessage = YES;
    [self batchGetMessageInternal:1000 ackBatchId:@""];
}

//批量获取消息
- (void)batchGetMessageInternal:(NSInteger)messageCount ackBatchId:(NSString *)ackBatchId
{
#ifdef TEST_STUCK
    NSLog(@"batchGetMessageInternal:%@", ackBatchId);
    [[BiChatDataModule sharedDataModule]clearMsgIdTable];
#endif
    [NetworkModule batchGetMessage:messageCount ackBatchId:ackBatchId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            NSThread *thread = [[NSThread alloc]initWithBlock:^{
                
                //处理所有收到的消息
                NSArray *messages = [data objectForKey:@"messages"];
                if ([messages isKindOfClass:[NSArray class]])
                {
                    [[BiChatGlobal sharedManager]imChatLog:[NSString stringWithFormat:@"receiver %ld messages", (long)[messages count]], nil];
                    for (int i = 0; i < messages.count; i ++)
                    {
                        @try {
                            NSMutableDictionary *item = [messages objectAtIndex:i];
                            NSDate *date1 = [NSDate date];
                            [self preProcessNewMessage:item];
                            [self processAPieceOfMessage:item];
                            
                            NSString *str = [BiChatGlobal getMessageReadableString:item groupProperty:nil];
                            [[BiChatGlobal sharedManager]imChatLog:[NSString stringWithFormat:@"==batchMsg(%@)-d:%f", str.length > 50?[str substringToIndex:50]:str, [[NSDate date]timeIntervalSinceDate:date1]], nil];
                            NSLog(@"==batchMsg(%@)-d:%f", str.length > 50?[str substringToIndex:50]:str, [[NSDate date]timeIntervalSinceDate:date1]);
                        } @catch (NSException *exception) {
                            NSString *str = [[NSString alloc]initWithData:[self->array4MessageCache objectAtIndex:i] encoding:NSUTF8StringEncoding];
                            [[BiChatGlobal sharedManager]imChatLog:@"process message internal error:", str, nil];
                        } @finally {
                        }
                    }
                }
                [[BiChatGlobal sharedManager]imChatLog:@"Process batch message end", nil];
                
#ifdef TEST_STUCK
                [BiChatGlobal sharedManager].batchGetMessage = NO;
#else
                //接着获取下一批
                if (([[data objectForKey:@"leftmessages"]integerValue] > 0 &&
                     [[data objectForKey:@"batchId"]length] > 0) ||
                    [messages count] > 0)
                    [self batchGetMessageInternal:1000 ackBatchId:[data objectForKey:@"batchId"]];
                else
                    [self endBatchGetMessageInternal];
#endif
            }];
            thread.qualityOfService = NSQualityOfServiceBackground;
            [thread start];
        }
        else
#ifdef TEST_STUCK
            ;
#else
            [self endBatchGetMessageInternal];
#endif
    }];
}

//结束批量获取消息
- (void)endBatchGetMessageInternal
{
    //转入正常收发消息
    [BiChatGlobal sharedManager].batchGetMessage = NO;
    [PokerStreamClient turnStreamingOnOff:YES];
    [self performSelectorOnMainThread:@selector(flushMainGUI) withObject:nil waitUntilDone:NO];
}

- (void)flushMainGUI
{
    @try {
        [[BiChatGlobal sharedManager].mainChatList refreshGUI];
        [[BiChatGlobal sharedManager].NEWFriendChatList refreshGUI];
        [[BiChatGlobal sharedManager].FOLDFriendChatList refreshGUI];
        [[BiChatGlobal sharedManager].FOLDPublicChatList refreshGUI];
        [[BiChatGlobal sharedManager].APPROVEFriendChatList refreshGUI];
        [[BiChatGlobal sharedManager].VIRTUALGroupChatList refreshGUI];
    } @catch (NSException *exception) {
    } @finally {
    }
}

- (void)changeGroupInfo:(NSDictionary *)info
{
    //修改聊天列表中的信息
    [[BiChatDataModule sharedDataModule]changePeerUid:[info objectForKey:@"oldGroupId"] to:[info objectForKey:@"groupId"]];
    [[BiChatDataModule sharedDataModule]setPeerAvatar:[info objectForKey:@"groupId"] withAvatar:[info objectForKey:@"avatar"]];
    [[BiChatDataModule sharedDataModule]setPeerNickName:[info objectForKey:@"groupId"] withNickName:[info objectForKey:@"nickName"]];
    
    //如果当前会话正在显示
    ChatViewController *chat = (ChatViewController *)[BiChatGlobal sharedManager].currentChatWnd;
    if ([chat.peerUid isEqualToString:[info objectForKey:@"oldGroupId"]])
    {
        chat.peerUid = [info objectForKey:@"groupId"];
        chat.peerAvatar = [info objectForKey:@"avatar"];
        chat.peerNickName = [info objectForKey:@"nickName"];
        chat.navigationItem.title = [info objectForKey:@"nickName"];
        chat.title = [info objectForKey:@"nickName"];
    }
}

//重新使用密码登录
- (void)reLoginByPassword
{
    //重新发送登录命令，使用保存过的用户名和密码
    NSData *data4UserName = [[BiChatGlobal sharedManager].lastLoginUserName dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4PasswordMD5 = [[BiChatGlobal sharedManager].lastLoginPasswordMD5 dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 12 + data4UserName.length + data4PasswordMD5.length;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 1;
    HTONS(CommandType);
    short UserNameLength = data4UserName.length;
    HTONS(UserNameLength);
    short ClientType = 1;
    HTONS(ClientType);
    
    //生成登录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&UserNameLength length:2]];
    [data appendData:data4UserName];
    [data appendData:data4PasswordMD5];
    [data appendData:[[NSData alloc]initWithBytes:&ClientType length:2]];
    
    //发送登录命令
    [PokerStreamClient sendRequest:nil binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (!isTimeOut)
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [BiChatGlobal sharedManager].bLogin = YES;
                    [BiChatGlobal sharedManager].token = [obj objectForKey:@"token"];
                    [BiChatGlobal sharedManager].nickName = [obj objectForKey:@"nickName"];
                    [BiChatGlobal sharedManager].uid = [obj objectForKey:@"uid"];
                    [BiChatGlobal sharedManager].createdTime = [NSDate dateWithTimeIntervalSince1970:[[obj objectForKey:@"createdTime"]doubleValue] / 1000];
                    [[BiChatGlobal sharedManager]saveGlobalInfo];
                    [[BiChatDataModule sharedDataModule]setuid:[obj objectForKey:@"uid"]];
                    [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {}];
                    
                    //获取一下最新的appconfig
                    [NetworkModule getAppConfig:[BiChatGlobal sharedManager].systemConfigVersionNumber completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        [[BiChatGlobal sharedManager]processSystemConfigMessage:[data objectForKey:@"data"]];
                    }];
                }
            }
        }
    }];
}

//震动和发声音
- (void)notifyMessage:(NSDictionary *)message
{
    NSString *target;
    
    //是否系统消息
    if ([BiChatGlobal isSystemMessage:message])
        return;
    
    //是否群消息
    if ([[message objectForKey:@"isGroup"]boolValue])
        target = [message objectForKey:@"receiver"];
    else
        target = [message objectForKey:@"sender"];
    
    //是否新的好友
    if (![[message objectForKey:@"isGroup"]boolValue] &&
        ![[BiChatGlobal sharedManager]isFriendInContact:target])
        return;
    
    //是否静音
    if ([[BiChatGlobal sharedManager]isFriendInMuteList:target])
        return;
    
    //是否免打扰折叠
    if ([[BiChatGlobal sharedManager]isFriendInFoldList:target])
        return;
    
    //是否虚拟群群主,管理群主，客服群主
    if ([[message objectForKey:@"isGroup"]boolValue])
    {
        NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:target];
        if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0 &&
            [BiChatGlobal isMeGroupOperator:groupProperty])
            return;
        
        if ([BiChatGlobal isMeGroupOperator:groupProperty] &&
            [[groupProperty objectForKey:@"isCustomerServiceGroup"]boolValue])
            return;
    }
    
    //控制每秒只能notify一次
    static NSDate *notifyTime = nil;
    if (notifyTime != nil &&
        [[NSDate date]timeIntervalSinceDate:notifyTime] < 3)
        return;
    notifyTime = [NSDate date];
    
    //开始notify
    if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"notificationVibrate"]boolValue])
    {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{});
    }
    
    if ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"notificationVoice"]boolValue])
    {
        AudioServicesPlaySystemSoundWithCompletion(1002, ^{});
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
