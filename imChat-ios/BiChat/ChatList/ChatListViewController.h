//
//  ChatListViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "ContactListViewController.h"
#import "WPRedPacketSendViewController.h"
#import "ScanViewController.h"

#define NEW_FRIENDGROUP_UUID            @"00000000000000000000000000000000"             //新的朋友
#define MUTE_FRIENDGROUP_UUID           @"11111111111111111111111111111111"             //免打扰
#define MANAGER_GROUP_UUID              @"22222222222222222222222222222222"             //群管理
#define MUTE_PUBLIC_UUID                @"44444444444444444444444444444444"             //折叠公号

@interface ChatListViewController : UITableViewController<ContactSelectDelegate, RedPacketCreateDelegate, UITabBarControllerDelegate, UIScrollViewDelegate, ScanViewControllerDelegate, UITextFieldDelegate>
{
    NSMutableArray *array4ChatList;
    UIView *view4AddMenu;
    NSString *currentClickGroupId;
    NSIndexPath *editingIndexPath;
    
    //界面相关
    UIView *view4HintWnd;
    UIEdgeInsets orignalContentInset;
    BOOL showNetStatusHint;
    SEL netStatusHitFunction;
    UIImage *netStatusImage;
    NSString *netStatusHint;
    BOOL showFillMyInviterHint;
    BOOL showNewVersionHint;
    BOOL showMoreForceHint;
    NSTimer *timer4RefreshGUI;
    NSTimer *timer4CheckMyBidInfo;
    
    //搜索相关
    UITextField *input4Search;
    UIView *view4SearchFrame;
    UIButton *button4CancelSearch;
    NSString *str4SearchKey;
    
    //网络断开提示
    BOOL networkDisconnected;
    UIView *view4NetworkDisconnectHintWnd;
    NSTimer *timer4DelayShowNetworkDisconnectHintWnd;
    NSInteger internetReachability;
    NSTimer *timer4TestNetworkState;
    BOOL CellularDataRestricted;
        
    //广告
    ADBannerView *AdbannerView;
}

- (void)refreshGUI;
- (void)relayNetworkState:(NSInteger)networkState;

@end
