//
//  ReceiveRedPacketWebViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"

@protocol RedPacketReceiveDelegate <NSObject>
@optional
- (void)redPacketReceived:(NSString *)redPacketId;
- (void)redPacketExhaust:(NSString *)redPacketId;
@end

@interface ReceiveRedPacketWebViewController : UIViewController<WKNavigationDelegate>
{
    WKWebView* webView;
    WebViewJavascriptBridge* bridge;
    
    //用户分享出去的图标
    UIImage *image4Share;
}

@property (nonatomic, weak) id<RedPacketReceiveDelegate> delegate;
@property (nonatomic) BOOL isGroup;
@property (nonatomic, retain) NSString *peerId;
@property (nonatomic, retain) NSString *coinSymbol;
@property (nonatomic, retain) NSString *redPacketId;
@property (nonatomic, retain) NSString *shareLink;
@property (nonatomic, retain) NSString *shareIcon;

@end
