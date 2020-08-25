//
//  SendRedPacketWebViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"

//@protocol RedPacketCreateDelegate <NSObject>
//@optional
//- (void)redPacketCreated:(NSString *)url
//             redPacketId:(NSString *)redPacketId
//            coinImageUrl:(NSString *)coinImageUrl
//       shareCoinImageUrl:(NSString *)shareCoinImageUrl
//              coinSymbol:(NSString *)coinSymbol
//                greeting:(NSString *)greeting
//                 groupId:(NSString *)groupId
//               groupName:(NSString *)groupName;
//@end

@interface SendRedPacketWebViewController : UIViewController<WKNavigationDelegate>
{
    WKWebView* webView;
    WebViewJavascriptBridge* bridge;
}

//@property (nonatomic, retain) id<RedPacketCreateDelegate> delegate;
@property (nonatomic) BOOL isGroup;
@property (nonatomic, retain) NSString *peerId;

@end
