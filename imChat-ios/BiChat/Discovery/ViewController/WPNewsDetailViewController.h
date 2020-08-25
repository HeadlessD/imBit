//
//  WPNewsDetailViewController.h
//  BiChat
//
//  Created by 张迅 on 2018/4/16.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"
#import "WPDiscoverModel.h"
#import <WebKit/WebKit.h>
@interface WPNewsDetailViewController : WPBaseViewController

@property (nonatomic,strong)WKWebView *webView;

@property (nonatomic)BOOL cannotShare;  //added by kongchao

@property (nonatomic,strong)WPDiscoverModel *model;

@property (nonatomic,strong)NSString *url;
//需要缓存的url
@property (nonatomic,strong)NSString *saveURL;

@property (nonatomic)BOOL isHelp;

@property (nonatomic,strong)UINavigationController *naVC;
@property (nonatomic,assign)BOOL isHomePage;


@property (nonatomic,strong)NSString *groupId;
@property (nonatomic,strong)NSString *subgroupId;
@property (nonatomic,strong)NSString *groupIndex;

@property (nonatomic,copy)void (^IdentifyCancelBlock)(void);

- (void)loadURL:(NSString *)url;

+ (WPNewsDetailViewController *)shareInstance;

- (void)beActive;

- (void)beBackground;



@end
