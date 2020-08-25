//
//  AppDelegate.h
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTStreamer/TTStreamerClient.h>
#import "WXApi.h"
#import "ChatSelectViewController.h"
#import "NetworkModule.h"
//#import <BaiduMapAPI_Location/BMKLocationService.h>
//#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "WPShortLinkView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, TTStreamingDelegate, WXApiDelegate, ChatSelectDelegate, UNUserNotificationCenterDelegate>
{
    //本地消息暂存
    NSMutableArray *array4MessageCache;
    NSTimer *timer4DispathMessage;
    NSTimer *timer4SaveImLog;
    NSTimer *timer4BackgroupFetch;
    
    
    NSTimer * momentNewAvatar;
    NSTimer * momentNewRedNum;

    BOOL networkInited;     //网络模块是否已经init
    
    //用户http连接
    NetworkCompletedBlock httpNetworkCompletedCallback;
}

//@property (nonatomic, strong) BMKMapManager *mapManager;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSURLConnection *thisConnection;
@property (nonatomic, retain) NSMutableData *resultData;
@property (nonatomic, strong) WPShortLinkView *shortLinkView;
//是否横屏
@property (nonatomic,assign)BOOL allowRotation;

@end

