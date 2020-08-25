//
//  WPNewsDetailViewController.m
//  BiChat
//
//  Created by 张迅 on 2018/4/16.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPNewsDetailViewController.h"
#import <YYText.h>
#import "WPPublicAccountDetailViewController.h"
#import "ChatSelectViewController.h"
#import "JSONKit.h"
#import "BiChatDataModule.h"
#import "ChatViewController.h"
#import "WPShareView.h"
#import "WXApi.h"
#import <WebViewJavascriptBridge.h>
#import "WPShareSheetView.h"
#import "WPComplaintViewController.h"
#import "DFImagesSendViewController.h"
#import "WPFontSetSliderView.h"
#import <WebKit/WebKit.h>
#import <WebKit/WKScriptMessageHandler.h>
#import "WPProductInputView.h"
#import "appDelegate.h"
#import "WPPaySuccessViewController.h"
#import "WPWebVerificationViewController.h"

static WPNewsDetailViewController *detilVC = nil;

@interface WPNewsDetailViewController ()<WKUIDelegate,WKNavigationDelegate,ChatSelectDelegate,DFImagesSendViewControllerDelegate,WKScriptMessageHandler>

//进度
@property (nonatomic,assign)double progress;
//进度条
@property (nonatomic,strong)UIProgressView *progressView;
@property (nonatomic,strong)WPShareView *shareV;
@property WebViewJavascriptBridge *bridge;

@property (nonatomic,strong)NSString *webTitle;
//分享图片
@property (nonatomic,assign)BOOL shareImage;
//长摁图片
@property (nonatomic,strong)NSData *pressImageData;
@property (nonatomic,strong)NSString *pressImageUrl;

@property (nonatomic,strong)WPFontSetSliderView *fontView;
//验证页面
//@property (nonatomic,strong)WPAuthView *authView;


//密码输入页面
@property (nonatomic,strong)WPProductInputView *inputV;
@end

@implementation WPNewsDetailViewController

+ (WPNewsDetailViewController *)shareInstance {
    if (!detilVC) {
        detilVC = [[WPNewsDetailViewController alloc]init];
    }
    return detilVC;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)reloadRequelst {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //允许转成横屏
    appDelegate.allowRotation = NO;
    self.navigationController.navigationBar.translucent = NO;
    if (!self.cannotShare) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:Image(@"more") style:UIBarButtonItemStyleDone target:self action:@selector(functionSelect)];
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(backMethod)];
//    self.navigationItem.backBarButtonItem = nil;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:Image(@"navigationbar_back_arrow") style:UIBarButtonItemStylePlain target:self action:@selector(backMethod)];
    if (self.isHelp) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:LLSTR(@"101013") style:UIBarButtonItemStylePlain target:self action:@selector(doReport)];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.model.pubnickname.length > 0) {
        self.title = self.model.pubnickname;
    } else {
//        self.title = LLSTR(@"101011");
    }
    
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
//    WKUserContentController *userCC = configuration.userContentController;
    // 注入对象，前端调用其方法时，Native 可以捕获到
    [configuration.userContentController addScriptMessageHandler:self name:@"nativeBridge"];

    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) configuration:configuration];
    [self.view addSubview:self.webView];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [WebViewJavascriptBridge enableLogging];
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    [self.bridge registerHandler:@"redirectPublicAccount" handler:^(id data, WVJBResponseCallback responseCallback) {
        for (WPPublicAccountDetailViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[WPPublicAccountDetailViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                return ;
            }
        }
        WPPublicAccountDetailViewController *detailVC = [[WPPublicAccountDetailViewController alloc]init];
        detailVC.pubid = [data objectForKey:@"publicAccount"];
        detailVC.pubnickname = [data objectForKey:@"pubNickName"];
        if (self.naVC) {
            [self.naVC pushViewController:detailVC animated:YES];
        } else {
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }];
    
//    [self.bridge registerHandler:@"webviewDestory" handler:^(id data, WVJBResponseCallback responseCallback) {
//        if ([[data objectForKey:@"status"] integerValue] == 0) {
//            if (self.url.length > 0) {
//                [[BiChatGlobal sharedManager] saveWeb:@{self.url ? self.url : self.model.url : self}];
//            }
//        }
//    }];
    
    [self.bridge registerHandler:@"imgControlBox" handler:^(id data, WVJBResponseCallback responseCallback) {
        //        NSString *baseString = [data objectForKey:@"imgUrl"];
        NSData *baseData = [[NSData alloc]initWithBase64EncodedString:[[data objectForKey:@"base64Code"] stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:baseData];
        self.pressImageData = baseData;
        self.pressImageUrl = [[data objectForKey:@"imgUrl"] substringFromIndex:1];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"102301") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doShare];
        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:LLSTR(@"102302") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //生成一个收藏消息
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  //                          [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:orgImg.size.width]], @"orgwidth",
                                  //                          [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:orgImg.size.height]], @"orgheight",
                                  [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:image.size.width]], @"width",
                                  [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:image.size.height]], @"height",
                                  [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:image.size.width]], @"thumbwidth",
                                  [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:image.size.height]], @"thumbheight",
                                  //                          [NSString stringWithFormat:@"msg/%@/%@", currentDateString, orgImageFile], @"oriFileName",
                                  [NSString stringWithFormat:@"%@",self.pressImageUrl], @"FileName",
                                  [NSString stringWithFormat:@"%@",self.pressImageUrl], @"ThumbName",
                                  //                          [NSString stringWithFormat:@"%lu", (unsigned long)orgJpg.length], @"orgFileLength",
                                  [NSString stringWithFormat:@"%lu", (unsigned long)self.pressImageData.length], @"displayFileLength",
                                  //                          orgImageFile, @"localOrgFileName",
                                  [NSString stringWithFormat:@"%@",self.pressImageUrl], @"localFileName",
                                  [NSString stringWithFormat:@"%@",self.pressImageUrl], @"localThumbName",
                                  nil];
            NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSUUID UUID].UUIDString, @"msgId",
                                         [NSUUID UUID].UUIDString, @"contentId",
                                         [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_IMAGE], @"type",
                                         [dict mj_JSONString], @"content",
                                         [BiChatGlobal sharedManager].uid, @"sender",
                                         [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                         [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                         [BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         nil];
            //发送给服务器
            [NetworkModule favoriteMessage:item msgId:[NSUUID UUID].UUIDString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                if (success)
                    [BiChatGlobal showInfo:LLSTR(@"301055") withIcon:[UIImage imageNamed:@"icon_OK"]];
                else
                    [BiChatGlobal showInfo:LLSTR(@"301056") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                
            }];
        }];
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:LLSTR(@"102303") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }];
        UIAlertAction *action4 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        //        [action2 setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
        [action1 setValue:LightBlue forKey:@"_titleTextColor"];
        [alertC addAction:action1];
        [alertC addAction:action2];
        [alertC addAction:action3];
        [alertC addAction:action4];
        [self presentViewController:alertC animated:YES completion:nil];
        
        
    }];
    if (self.model.htmlString.length > 0) {
        [self.webView loadHTMLString:self.model.htmlString baseURL:[NSURL URLWithString:self.model.url]];
    } else {
        if ([self.url containsString:@"itunes.apple.com"]) {
            UIAlertController *alertCtrler = [UIAlertController alertControllerWithTitle:LLSTR(@"105101") message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self doPop];
            }];
            [alertCtrler addAction:action1];
            UIAlertAction *action = [UIAlertAction actionWithTitle:LLSTR(@"201336") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url] options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES} completionHandler:nil];
                [self doPop];
            }];
            [alertCtrler addAction:action];
            [self presentViewController:alertCtrler animated:YES completion:nil];
        } else {
            if (![self.url containsString:@"http"] && self.url.length > 0) {
                self.url = [NSString stringWithFormat:@"http://%@",self.url];
            }
            if (self.model.url.length > 0) {
                [self loadURL:self.model.url];
            } else if (self.url.length > 0) {
                [self loadURL:self.url];
            }
        }
    }
    //添加进度条
    self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 2)];
    self.progressView.progressTintColor = RGB(0x2f93fa);
    self.progressView.trackTintColor = [UIColor clearColor];
    [self.view addSubview:self.progressView];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    //10秒后设置偏好
    [self performSelector:@selector(setPreference) withObject:nil afterDelay:10];
}
//激活
- (void)beActive {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"handlerName":@"activated",
                                                                 @"responseData":@{
                                                                 @"imc_group_id":self.groupId,
                                                                 @"imc_subgroup_id":[NSString stringWithFormat:@"%@",self.subgroupId],
                                                                 @"imc_grouppage_index":self.groupIndex
                                                                 }
                                                                 }
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.ImchatJSBridge._handleMessageFromNative(%@)",jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}
//到后台
- (void)beBackground {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"handlerName":@"deactivated",
                                                                 @"responseData":@{
                                                                         @"imc_group_id":self.groupId,
                                                                         @"imc_subgroup_id":[NSString stringWithFormat:@"%@",self.subgroupId],
                                                                         @"imc_grouppage_index":self.groupIndex
                                                                         }
                                                                 }
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.ImchatJSBridge._handleMessageFromNative(%@)",jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)noti{
    if (!self.inputV) {
        return;
    }
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.16 animations:^{
        [self.inputV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-keyboardHeight);
        }];
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti{
    if (self.inputV) {
        [self.inputV removeFromSuperview];
        self.inputV = nil;
    }
}
//返回
- (void)backMethod {
    if ([self.webView canGoBack] && self.isHelp) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doPop {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    WKUserContentController *controller = self.webView.configuration.userContentController;
    [controller removeAllUserScripts];
    [self.navigationController popViewControllerAnimated:YES];
}
//反馈
- (void)doReport {
    if ([BiChatGlobal sharedManager].feedback.length == 0) {
        return;
    }
    
    [NetworkModule getPublicProperty:[BiChatGlobal sharedManager].feedback completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success) {
            ChatViewController *wnd = [ChatViewController new];
            wnd.peerUid = [data objectForKey:@"ownerUid"];
            wnd.peerAvatar = [data objectForKey:@"avatar"];
            wnd.peerNickName = [data objectForKey:@"groupName"];
            wnd.isPublic = YES;
            if (self.naVC) {
                [self.naVC pushViewController:wnd animated:YES];
            } else {
                [self.navigationController pushViewController:wnd animated:YES];
            }
            
            if ([[BiChatDataModule sharedDataModule] isChatExist:[data objectForKey:@"ownerUid"]]) {
                return ;
            }
            NSString *strMessage = LLSTR(@"105103");
            NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_SYSTEM], @"type",
                                         [BiChatGlobal getCurrentDateString], @"timeStamp",
                                         strMessage, @"content", nil];
            [[BiChatDataModule sharedDataModule]addChatContentWith:[data objectForKey:@"ownerUid"] content:item];
            [[BiChatDataModule sharedDataModule]setLastMessage:[data objectForKey:@"ownerUid"]
                                                  peerUserName:@""
                                                  peerNickName:[data objectForKey:@"groupName"]
                                                    peerAvatar:[data objectForKey:@"avatar"]
                                                       message:strMessage
                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                         isNew:NO
                                                       isGroup:NO
                                                      isPublic:YES
                                                     createNew:YES];
            
        } else {
            [BiChatGlobal showFailWithString:LLSTR(@"301003")];
            [[BiChatGlobal sharedManager]imChatLog:@"----network error - 37", nil];
        }
    }];
}

//保存到相册回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [BiChatGlobal showSuccessWithString:LLSTR(@"301806")];
    } else {
        [BiChatGlobal showFailWithString:LLSTR(@"301807")];
    }
}

//返回取消偏好
- (void)cancelPerform {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"nativeBridge"]) {
        NSDictionary *dict = message.body;
        if ([[dict objectForKey:@"handlerName"] isEqualToString:@"config"]) {
            [[WPBaseManager baseManager] postInterface:@"Chat/ApiPay/vailSignature.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,
                                                                                                     @"appId":[NSString stringWithFormat:@"%@",[[dict objectForKey:@"data"] objectForKey:@"appId"]],
                                                                                                     @"nonceStr":[NSString stringWithFormat:@"%@",[[dict objectForKey:@"data"] objectForKey:@"nonceStr"]],
                                                                                                     @"timestamp":[NSString stringWithFormat:@"%@",[[dict objectForKey:@"data"] objectForKey:@"timestamp"]],
                                                                                                     @"signature":[NSString stringWithFormat:@"%@",[[dict objectForKey:@"data"] objectForKey:@"signature"]],
                                                                                                     @"url":self.url
                                                                                                     } success:^(id response) {
                                                                                                         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"responseId":[dict objectForKey:@"callbackId"],@"responseData":response}
                                                                                                                                                            options:NSJSONWritingPrettyPrinted
                                                                                                                                                              error:nil];
                                                                                                         
                                                                                                         NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                                                                         [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.ImchatJSBridge._handleMessageFromNative(%@)",jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                                                                                                             
                                                                                                         }];
            } failure:^(NSError *error) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"responseId":[dict objectForKey:@"callbackId"],@"responseData":@{@"code":@"-1"}}
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.ImchatJSBridge._handleMessageFromNative(%@)",jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                    
                }];
            }];
        } else if ([[dict objectForKey:@"handlerName"] isEqualToString:@"closeWindow"]) {
            //关闭窗口
            [self doPop];
        } else if ([[dict objectForKey:@"handlerName"] isEqualToString:@"rotateScreen"]) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([[[dict objectForKey:@"data"] objectForKey:@"direction"] isEqualToString:@"horizontal"]) {
                appDelegate.allowRotation = YES;
                [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
                self.webView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 32);
                self.navigationItem.rightBarButtonItem = nil;
            } else {
                appDelegate.allowRotation = NO;
                [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
                self.webView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64));
                if (!self.cannotShare) {
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:Image(@"more") style:UIBarButtonItemStyleDone target:self action:@selector(functionSelect)];
                }
            }
            
        }
        else if ([[dict objectForKey:@"handlerName"] isEqualToString:@"chooseIMCPay"]) {
            WEAKSELF;
            [[WPBaseManager baseManager] postInterface:@"/Chat/ApiPay/chooseOrder.do" parameters:[dict objectForKey:@"data"] success:^(id response) {
                [weakSelf showInputWithResponse:response orderInfo:dict];
            } failure:^(NSError *error) {
                [BiChatGlobal showFailWithString:LLSTR(@"301001")];
            }];
        }
        
    }
}

- (void)showPaySuccessWithInfo:(NSDictionary *)dict {
    WPPaySuccessViewController *payVC = [[WPPaySuccessViewController alloc]init];
    payVC.resultDic = dict;
    if (self.naVC) {
        [self.naVC pushViewController:payVC animated:YES];
    } else {
        [self.navigationController pushViewController:payVC animated:YES];
    }
}

- (void)showInputWithResponse:(NSDictionary *)response orderInfo:(NSDictionary *)dict{
    WEAKSELF;
    if ([[response objectForKey:@"code"] integerValue] == 0) {
        NSDictionary *coinInfo = [[BiChatGlobal sharedManager] getCoinInfoBySymbol:[response objectForKey:@"coinType"]];
        [self inputClose];
        self.inputV = [[WPProductInputView alloc] init];
        [self.view addSubview:self.inputV];
        [self.inputV setCoinImag:[coinInfo objectForKey:@"imgGold"] count:[[NSString stringWithFormat:@"%@",[response objectForKey:@"amount"]] accuracyCheckWithFormatterString:[NSString stringWithFormat:@"%@",[coinInfo objectForKey:@"bit"]] auotCheck:YES] coinName:[coinInfo objectForKey:@"dSymbol"] payTo:[response objectForKey:@"nickName"] payDesc:[response objectForKey:@"body"] wallet:0];
        [self.inputV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        self.inputV.closeBlock = ^{
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"responseId":[dict objectForKey:@"callbackId"],@"responseData":@{@"code":@"-2"}}
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [weakSelf.webView evaluateJavaScript:[NSString stringWithFormat:@"window.ImchatJSBridge._handleMessageFromNative(%@)",jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                
            }];
            [weakSelf inputClose];
        };
        self.inputV.passwordInputBlock = ^(NSString * _Nonnull password) {
            [BiChatGlobal ShowActivityIndicatorImmediately];
            [[WPBaseManager baseManager] postInterface:@"Chat/ApiPay/requestOrder.do" parameters:@{@"transaction_id":[response objectForKey:@"transaction_id"],@"password":[password md5Encode]} success:^(id resp) {
                [weakSelf inputClose];
                [BiChatGlobal HideActivityIndicator];
                if ([[resp objectForKey:@"code"] integerValue] == 0) {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"responseId":[dict objectForKey:@"callbackId"],@"responseData":resp}
                                                                       options:NSJSONWritingPrettyPrinted
                                                                         error:nil];
                    
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [weakSelf.webView evaluateJavaScript:[NSString stringWithFormat:@"window.ImchatJSBridge._handleMessageFromNative(%@)",jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        
                    }];
                    [weakSelf showPaySuccessWithInfo:resp];
                    
                }
                //密码错误
                else if ([[resp objectForKey:@"code"] integerValue] == 100026) {
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"103012") message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"responseId":[dict objectForKey:@"callbackId"],@"responseData":@{@"code":@"-2"}}
                                                                           options:NSJSONWritingPrettyPrinted
                                                                             error:nil];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [weakSelf.webView evaluateJavaScript:[NSString stringWithFormat:@"window.ImchatJSBridge._handleMessageFromNative(%@)",jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                            
                        }];
                    }];
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"103013") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [weakSelf showInputWithResponse:response orderInfo:dict];
                    }];
                    [alertC addAction:action];
                    [alertC addAction:action1];
                    [weakSelf presentViewController:alertC animated:YES completion:nil];
                }
                //账户金额不足
                else if ([[resp objectForKey:@"code"] integerValue] == 100027) {
                    [BiChatGlobal showFailWithString:LLSTR(@"301114")];
                }
                else {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"responseId":[dict objectForKey:@"callbackId"],@"responseData":resp}
                                                                       options:NSJSONWritingPrettyPrinted
                                                                         error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [weakSelf.webView evaluateJavaScript:[NSString stringWithFormat:@"window.ImchatJSBridge._handleMessageFromNative(%@)",jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        
                    }];
                }
            } failure:^(NSError *error) {
                [weakSelf inputClose];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"responseId":[dict objectForKey:@"callbackId"],@"responseData":@{@"code":@"-1"}}
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [weakSelf.webView evaluateJavaScript:[NSString stringWithFormat:@"window.ImchatJSBridge._handleMessageFromNative(%@)",jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                    
                }];
            }];
        };
    } else {
        [BiChatGlobal showFailWithString:[response objectForKey:@"mess"]];
    }
}
//关闭输入框
- (void)inputClose {
    [self.inputV removeFromSuperview];
    self.inputV = nil;
}

#pragma mark - 发布朋友圈
-(void)sendMomentWithText:(NSString *)text images:(NSArray *)images videoUrl:(NSString *)videoUrl videoImg:(UIImage *)videoImg location:(AMapPOI *)location
{

    NSString * locaJsonStr = @"";
    if (location) {
        NSMutableDictionary * locaDic = [NSMutableDictionary dictionary];
        [locaDic setObject:location.name forKey:@"name"];
        [locaDic setObject:location.address forKey:@"address"];
        [locaDic setObject:[NSNumber numberWithFloat:location.location.longitude] forKey:@"longitude"];
        [locaDic setObject:[NSNumber numberWithFloat:location.location.latitude] forKey:@"latitude"];
        locaJsonStr = [DFLogicTool JsonNSDictionaryToJsonStr:locaDic];
    }

    DFBaseMomentModel *textImageItem = [[DFBaseMomentModel alloc] init];
    textImageItem.message = [[Message alloc]init];
    
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    textImageItem.message.ctime = theTime;
    textImageItem.message.momentId = [DFLogicTool createUUID];
    textImageItem.message.content = text;
    textImageItem.message.location = locaJsonStr;
    textImageItem.message.type = MomentSendType_News;
    
    textImageItem.message.createUser = [[Createuser alloc]init];
    textImageItem.message.createUser.uid = [BiChatGlobal sharedManager].uid;
    textImageItem.message.createUser.avatar = [DFLogicTool getImgWithStr:[BiChatGlobal sharedManager].avatar];
    textImageItem.message.createUser.nickName = [BiChatGlobal sharedManager].nickName;
//    textImageItem.itsrcImages = images;
//    textImageItem.itthumbImages = images;
    textImageItem.dontClick = YES;

    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    //新闻id
    NSString * modelNewsid = self.model ? self.model.newsid : @"" ;
    if (modelNewsid)[contentDic setObject:modelNewsid forKey:@"newsid"];
    //发布时间
    //    NSString * modelCtime = self.model ? self.model.ctime : @"";
    //    if (modelCtime)[contentDic setObject:modelCtime forKey:@"ctime"];
    // 新闻源
    NSString * modelPubname = self.model ? self.model.pubname : @"";
    if (modelPubname)[contentDic setObject:modelPubname forKey:@"pubname"];
    // 新闻源昵称
    NSString * modelPubnickname = self.model ? self.model.pubnickname : @"" ;
    if (modelPubnickname)[contentDic setObject:modelPubnickname forKey:@"pubnickname"];
    // 新闻源id
    NSString * modelPubid = self.model ? self.model.pubid : @"" ;
    if (modelPubid)[contentDic setObject:modelPubid forKey:@"pubid"];
    // 新闻标题
    NSString * modelTitle = self.model.title ? self.model.title : (self.webTitle.length > 0 ? self.webTitle : @"");
    if (modelTitle)[contentDic setObject:modelTitle forKey:@"title"];
    // 新闻描述
    NSString * modelDesc = self.model.desc ? self.model.desc : (self.model.url.length > 0 ? self.model.url : self.url);
    if (modelDesc)[contentDic setObject:modelDesc forKey:@"desc"];
    // 新闻链接
    NSString * modelUrl = self.model.url ? self.model.url : self.url;
    if (modelUrl)[contentDic setObject:modelUrl forKey:@"url"];
    // 图标地址
    if (self.model.imgs.count)[contentDic setObject:self.model ? self.model.imgs[0] : @"" forKey:@"image"];
    
    textImageItem.message.resourceContent = [contentDic mj_JSONString];
    
    [DFMomentsManager insertMomentModel:textImageItem atTopOrBottom:@"top"];
    [BiChatGlobal showInfo:LLSTR(@"301029") withIcon:Image(@"icon_OK")];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADDATA object:nil];
    
        NSDictionary * addMessageDic = @{@"id":textImageItem.message.momentId,
                                         @"tokenid":[BiChatGlobal sharedManager].token,
                                         @"content":text,
                                         @"type":@(MomentSendType_News),
                                         @"mediasList":@"",
                                         @"resourceContent":textImageItem.message.resourceContent,
                                         @"location":locaJsonStr,
                                         @"seeType":@1,
                                         @"seeUids":@"",
                                         @"notToSeeUids":@"",
                                         @"remindUids":@""};
        [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/addMessage.do" parameters:addMessageDic success:^(id response) {
            if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
                
                //获取积分
                [NetworkModule sendMomentWithType:@{@"type":@"MOMENT"} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
            }else{
                NSLog(@"发布失败");
            }
        } failure:^(NSError *error) {
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
        }];
}

- (void)functionSelect {
    WPShareSheetItem *item1 = [WPShareSheetItem itemWithTitle:LLSTR(@"102301") icon:@"share_send" handler:^{
        [self doShare];
    }];
    WPShareSheetItem *item10 = [WPShareSheetItem itemWithTitle:LLSTR(@"102210") icon:@"share_moment" handler:^{
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
        
        // 新闻标题
        NSString * modelTitle = self.model.title ? self.model.title : (self.webTitle.length > 0 ? self.webTitle : LLSTR(@"101011"));
        if (modelTitle)[contentDic setObject:modelTitle forKey:@"title"];
        // 图标地址
        if (self.model.imgs.count)[contentDic setObject:self.model ? self.model.imgs[0] : @"" forKey:@"image"];

        //        // 新闻描述
        //        NSString * modelDesc = self.model.desc ? self.model.desc : (self.model.url.length > 0 ? self.model.url : self.url);
        //        if (modelDesc)[contentDic setObject:modelDesc forKey:@"desc"];
        //        // 新闻链接
        //        NSString * modelUrl = self.model.url ? self.model.url : self.url;
        //        if (modelUrl)[contentDic setObject:modelUrl forKey:@"url"];
        
        DFImagesSendViewController * sendView = [[DFImagesSendViewController alloc]init];
        sendView.delegate = self;
        sendView.sendNewsDic = contentDic;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sendView];
        [self presentViewController:navController animated:YES completion:nil];
    }];
    
    WPShareSheetItem *item2 = [WPShareSheetItem itemWithTitle:LLSTR(@"105000") icon:@"share_store" handler:^{
        NSDictionary *dict = nil;
        NSDictionary *sendData = nil;
        if (self.model) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%@",self.model.author], @"author",
                    [NSString stringWithFormat:@"%@",self.model.ctime], @"ctime",
                    self.model.imgs.count > 0 ? self.model.imgs[0] : @"", @"image",
                    [NSString stringWithFormat:@"%@",self.model.newsid], @"newsid",
                    [NSString stringWithFormat:@"%@",self.model.pubid], @"pubid",
                    [NSString stringWithFormat:@"%@",self.model.pubname], @"pubname",
                    [NSString stringWithFormat:@"%@",self.model.pubnickname], @"pubnickname",
                    self.model.title.length > 0 ? [NSString stringWithFormat:@"%@",self.model.title] : LLSTR(@"101011"), @"title",
                    [NSString stringWithFormat:@"%@",self.model.url], @"url",
                    nil];
            
            //生成一个收藏消息
            sendData = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%d",MESSAGE_CONTENT_TYPE_NEWS_PUBLIC], @"type",
                        [dict mj_JSONString], @"content",
                        @"", @"receiver",
                        @"", @"receiverNickName",
                        @"", @"receiverAvatar",
                        [NSString stringWithFormat:@"%@",self.model.author], @"sender",
                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                        self.model.newsid.length > 0 ? self.model.newsid : [BiChatGlobal getUuidString], @"msgId",
                        self.model.newsid.length > 0 ? self.model.newsid : [BiChatGlobal getUuidString], @"contentId",
                        [BiChatGlobal getCurrentDateString], @"favTime",
                        self.model.title.length > 0 ? [NSString stringWithFormat:@"%@",self.model.title] : LLSTR(@"101011"),@"title",
                        nil];
            
        } else {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:
                    self.webTitle.length > 0 ? self.webTitle : LLSTR(@"101011"),@"title",
                    self.url,@"url",
                    nil];
            sendData = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%d",MESSAGE_CONTENT_TYPE_NEWS_PUBLIC], @"type",
                        [dict mj_JSONString], @"content",
                        self.url,@"url",
                        @"", @"receiver",
                        @"", @"receiverNickName",
                        @"", @"receiverAvatar",
                        self.model.author.length > 0 ? self.model.author : [BiChatGlobal sharedManager].nickName, @"sender",
                        [BiChatGlobal sharedManager].nickName, @"senderNickName",
                        [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                        [BiChatGlobal getCurrentDateString], @"timeStamp",
                        [BiChatGlobal getCurrentDateString], @"favTime",
                        self.webTitle.length > 0 ? self.webTitle : LLSTR(@"101011"),@"title",
                        nil];
            
        }
        //发给服务器
        [NetworkModule favoriteMessage:sendData msgId:[sendData objectForKey:@"msgId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (success)
                [BiChatGlobal showInfo:LLSTR(@"301055") withIcon:[UIImage imageNamed:@"icon_OK"]];
            else
                [BiChatGlobal showInfo:LLSTR(@"301056") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            
        }];
    }];
    WPShareSheetItem *item3 = [WPShareSheetItem itemWithTitle:LLSTR(@"102206") icon:@"share_weChat" handler:^{
        [self shareToWeChat];
    }];
    WPShareSheetItem *item4 = [WPShareSheetItem itemWithTitle:LLSTR(@"102207") icon:@"share_timeLine" handler:^{
        [self shareToFriend];
    }];
    WPShareSheetItem *item5 = [WPShareSheetItem itemWithTitle:LLSTR(@"102208") icon:@"share_link" handler:^{
        if (self.model.url.length == 0 && self.url.length == 0) {
            [BiChatGlobal showFailWithString:LLSTR(@"301011")];
            return ;
        }
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (self.model) {
            pasteboard.string = [NSString stringWithFormat:@"%@\n%@",self.model.title,self.model.url];
        } else {
            if (self.webTitle.length > 0) {
                pasteboard.string = [NSString stringWithFormat:@"%@\n%@",self.webTitle,self.url];
            } else {
                pasteboard.string = self.url;
            }
        }
        [BiChatGlobal showInfo:LLSTR(@"301010") withIcon:Image(@"icon_OK")];
    }];
    WPShareSheetItem *item6 = [WPShareSheetItem itemWithTitle:LLSTR(@"102212") icon:@"share_refresh" handler:^{
        [self.webView reload];
    }];
    WPShareSheetItem *item7 = [WPShareSheetItem itemWithTitle:LLSTR(@"102213") icon:@"share_safari" handler:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.url.length > 0 ? self.model.url : self.url] options:@{} completionHandler:nil];
    }];
    WPShareSheetItem *item8 = [WPShareSheetItem itemWithTitle:LLSTR(@"102216") icon:@"share_showPublic" handler:^{
        [self.bridge callHandler:@"redirectPublicAccount" data:nil responseCallback:^(id responseData) {
            
        }];
    }];
    WPShareSheetItem *item9 = [WPShareSheetItem itemWithTitle:LLSTR(@"102215") icon:@"share_complain" handler:^{
        if (self.model) {
            WPComplaintViewController *complainVC = [[WPComplaintViewController alloc]init];
            complainVC.complainType = ComplainTypeNews;
            complainVC.contentId = self.model.newsid;
            complainVC.complainTitle = self.model.title;
            complainVC.disVC = self;
            if (self.naVC) {
                [self.naVC pushViewController:complainVC animated:YES];
            } else {
                [self.navigationController pushViewController:complainVC animated:YES];
            }
        }
    }];
    WEAKSELF;
    WPShareSheetItem *item11 = [WPShareSheetItem itemWithTitle:LLSTR(@"102214") icon:@"share_font" handler:^{
        self.fontView = [[WPFontSetSliderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        [self.view addSubview:self.fontView];
        weakSelf.fontView.SliderRemoveBlock = ^{
            [weakSelf.fontView removeFromSuperview];
            weakSelf.fontView = nil;
        };
        self.fontView.SliderBlock = ^(NSUInteger value) {
            if (value == 0) {
                 [weakSelf.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '80%'" completionHandler:nil];
            } else if (value == 1) {
                [weakSelf.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'" completionHandler:nil];
            } else if (value == 2) {
                [weakSelf.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '120%'" completionHandler:nil];
            } else if (value == 3) {
                [weakSelf.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '140%'" completionHandler:nil];
            } else if (value == 4) {
                [weakSelf.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '160%'" completionHandler:nil];
            }
        };
    }];
    if (self.model.pubid.length > 0) {
        WPShareSheetView *shareV = [[WPShareSheetView alloc]initWithItemsArray:@[@[item1,item10,item2,item3,item4],@[item6,item7,item5,item11,item9,item8]]];
        [shareV show];
    } else {
        WPShareSheetView *shareV = [[WPShareSheetView alloc]initWithItemsArray:@[@[item1,item10,item2,item3,item4],@[item6,item7,item5,item11]]];
        [shareV show];
    }
}

//分享到微信
- (void)shareToWeChat {
    [[WPBaseManager baseManager] postInterface:@"/Chat/Api/getFileShareUrl.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"url":self.model ? self.model.url : self.url} success:^(id response) {
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            if (self.model) {
                WXMediaMessage *message = [WXMediaMessage message];
                message.title = self.model.title;
                message.description = self.model.desc;
                if (self.model.imgs.count > 0) {
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.model.imgs[0]]];
                    UIImage *newImage =  [UIImage imageWithData:data];
                    if (newImage && data.length < 32000) {
                        [message setThumbImage:newImage];
                    }
                    WXImageObject *ext = [WXImageObject object];
                    ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
                }
                
                WXWebpageObject *ext2 = [WXWebpageObject object];
                ext2.webpageUrl = [response objectForKey:@"url"];
                message.mediaObject = ext2;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                req.bText = NO;
                req.scene = WXSceneSession;
                req.message = message;
                [WXApi sendReq:req];
                [NetworkModule reportPoint:@"SHARE_OUTSIDE" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            } else {
                WXMediaMessage *message = [WXMediaMessage message];
                message.title = self.webTitle.length > 0 ? self.webTitle : LLSTR(@"101011");
                WXWebpageObject *ext2 = [WXWebpageObject object];
                ext2.webpageUrl = self.url;
                message.mediaObject = ext2;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                req.bText = NO;
                req.scene = WXSceneSession;
                req.message = message;
                [WXApi sendReq:req];
                [NetworkModule reportPoint:@"SHARE_OUTSIDE" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301003")];
        [[BiChatGlobal sharedManager]imChatLog:@"----network error - 38", nil];
        //        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    //    [self dismissViewControllerAnimated:NO completion:nil];
}

//分享到微信
- (void)shareToFriend {
    
    [[WPBaseManager baseManager] postInterface:@"/Chat/Api/getFileShareUrl.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"url":self.model ? self.model.url : self.url} success:^(id response) {
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            if (self.model) {
                WXMediaMessage *message = [WXMediaMessage message];
                message.title = self.model.title;
                message.description = self.model.desc;
                if (self.model.imgs.count > 0) {
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.model.imgs[0]]];
                    UIImage *newImage =  [UIImage imageWithData:data];
                    if (newImage  && data.length < 32000) {
                        [message setThumbImage:newImage];
                    }
                    WXImageObject *ext = [WXImageObject object];
                    ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
                }
                
                WXWebpageObject *ext2 = [WXWebpageObject object];
                ext2.webpageUrl = [response objectForKey:@"url"];
                message.mediaObject = ext2;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                req.bText = NO;
                req.scene = WXSceneTimeline;
                req.message = message;
                [WXApi sendReq:req];
                [NetworkModule reportPoint:@"SHARE_OUTSIDE" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            } else {
                WXMediaMessage *message = [WXMediaMessage message];
                message.title = self.webTitle.length > 0 ? self.webTitle : @"";
                WXWebpageObject *ext2 = [WXWebpageObject object];
                ext2.webpageUrl = self.url;
                message.mediaObject = ext2;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
                req.bText = NO;
                req.scene = WXSceneTimeline;
                req.message = message;
                [WXApi sendReq:req];
                [NetworkModule reportPoint:@"SHARE_OUTSIDE" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {}];
            }
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301003")];
        [[BiChatGlobal sharedManager]imChatLog:@"----network error - 39", nil];
    }];
}

//分享给好友/群
- (void)doShare {
    ChatSelectViewController *chatVC = [[ChatSelectViewController alloc]init];
    chatVC.hidePublicAccount = YES;
    chatVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chatVC];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}
- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target {
    NSDictionary *dict;
    if (chats.count > 0) {
        dict = chats[0];
    } else {
        return;
    }
    
    NSString *avatar = [dict objectForKey:@"peerAvatar"];
    NSString *title = self.model ? self.model.title : self.webTitle;
    self.shareV = [BiChatGlobal showShareWindowWithTitle:[dict objectForKey:@"peerNickName"] avatar:avatar.length > 0 ? [NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[dict objectForKey:@"peerAvatar"]] : @"" content:[LLSTR(@"101191") llReplaceWithArray:@[title.length > 0 ? title : LLSTR(@"101011")]] type:0];
    if ([[dict objectForKey:@"isGroup"] boolValue]) {
        self.shareV.sendString = LLSTR(@"102424");
    } else if ([[dict objectForKey:@"isPublic"] boolValue]) {
        self.shareV.sendString = LLSTR(@"102425");
    } else {
        self.shareV.sendString = LLSTR(@"102423");
    }
    WEAKSELF;
    self.shareV.ChooseItemBlock = ^(NSInteger chooseStatus, NSString *content) {
        if (chooseStatus == 0) {
            [BiChatGlobal closeShareWindow];
        } else {
            [BiChatGlobal closeShareWindow];
            NSNumber *time = [NSNumber numberWithInteger:[weakSelf.model.ctime longLongValue]];
            NSDictionary *dict = chats[0];
            NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
            [contentDic setObject:weakSelf.model.pubnickname ? weakSelf.model.pubnickname : @"" forKey:@"pubnickname"];
            [contentDic setObject:weakSelf.model.newsid ? weakSelf.model.newsid : @"" forKey:@"newsid"];
            [contentDic setObject:title.length > 0 ? title : LLSTR(@"101011") forKey:@"title"];
            [contentDic setObject:weakSelf.model ? time : [NSNull null] forKey:@"ctime"];
            [contentDic setObject:weakSelf.model.author ? weakSelf.model.author : @"" forKey:@"author"];
            [contentDic setObject:weakSelf.model.pubid ? weakSelf.model.pubid : @"" forKey:@"pubid"];
            [contentDic setObject:weakSelf.model.pubname ? weakSelf.model.pubname : @"" forKey:@"pubname"];
            if (weakSelf.model.imgs.count > 0) {
                [contentDic setObject:weakSelf.model.imgs[0] forKey:@"image"];
            } else {
                [contentDic setObject:@"" forKey:@"image"];
            }
            [contentDic setObject:weakSelf.model.url.length > 0 ? weakSelf.model.url : weakSelf.url forKey:@"url"];
            [contentDic setObject:weakSelf.model.desc.length > 0 ? weakSelf.model.desc : (weakSelf.model.url.length > 0 ? weakSelf.model.url : weakSelf.url) forKey:@"desc"];
            
            NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
            [sendDic setObject:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_NEWS_PUBLIC] forKey:@"type"];
            [sendDic setObject:[contentDic JSONString] forKey:@"content"];
            [sendDic setObject:[dict objectForKey:@"peerUid"] forKey:@"receiver"];
            [sendDic setObject:[dict objectForKey:@"peerNickName"] forKey:@"receiverNickName"];
            [sendDic setObject:[dict objectForKey:@"peerAvatar"] forKey:@"receiverAvatar"];
            [sendDic setObject:[BiChatGlobal sharedManager].uid forKey:@"sender"];
            [sendDic setObject:[BiChatGlobal sharedManager].nickName forKey:@"senderNickName"];
            [sendDic setObject:[BiChatGlobal sharedManager].avatar forKey:@"senderAvatar"];
            [sendDic setObject:[BiChatGlobal getCurrentDateString] forKey:@"timeStamp"];
            [sendDic setObject:[BiChatGlobal getUuidString] forKey:@"msgId"];
            [sendDic setObject:weakSelf.model.newsid.length==0?[BiChatGlobal getUuidString]:weakSelf.model.newsid forKey:@"contentId"];
            if ([[[chats firstObject]objectForKey:@"isGroup"] boolValue]) {
                [sendDic setObject:@"1" forKey:@"isGroup"];
            }
            [sendDic setObject: [BiChatGlobal getCurrentDateString] forKey:@"favTime"];
            
            //是不是发送给本人
            if ([[[chats firstObject]objectForKey:@"peerUid"]isEqualToString:[BiChatGlobal sharedManager].uid]) {
                //直接将消息放入本地
                [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:Image(@"icon_OK")];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
            else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue]) {
                [NetworkModule sendMessageToGroup:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success) {
                        //分享加分
                        [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                        }];
                        //消息放入本地
                        [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:Image(@"icon_OK")];
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
                    else
                        [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }];
            }
            //转发给个人
            else {
                [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success) {
                        //分享加分
                        [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                        }];
                        //消息放入本地
                        [BiChatGlobal showInfo:LLSTR(@"301004") withIcon:Image(@"icon_OK")];
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
                        //分享加分
                        [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                        }];
                        //消息放入本地
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
                    else if (errorCode == 3)
                        [BiChatGlobal showInfo:LLSTR(@"301307") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    else
                        [BiChatGlobal showInfo:LLSTR(@"301311") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                }];
            }
            //转发给个人
            else {
                [NetworkModule sendMessageToUser:[[chats firstObject]objectForKey:@"peerUid"] message:sendDic1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    if (success) {
                        //分享加分
                        [NetworkModule reportPoint:@"SHARE_APP" completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                            
                        }];
                        //消息放入本地
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
        }
    };
}



- (BOOL)navigationShouldPopOnBackButton {
    if ([self.webView canGoBack] && self.isHelp) {
        [self.webView goBack];
        [self cancelPerform];
        return NO;
    }
//    [self.webView reload];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    WKUserContentController *controller = self.webView.configuration.userContentController;
    [controller removeAllUserScripts];
    //    [self.webView cleanForDealloc];
    //    self.webView = nil;
    //    [self.webView evaluateJavaScript:@"pauseVideo()" completionHandler:nil];
    return YES;
}
//设置偏好
- (void)setPreference {
    if (!self.model || self.model.newsid.length == 0 || [BiChatGlobal sharedManager].token.length == 0) {
        return;
    }
    //zx
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/actionNews.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":self.model.newsid,@"type":@"0"} success:^(id response) {
        
    } failure:^(NSError *error) {
        
    }];
}
//左滑返回
//- (void)didMoveToParentViewController:(UIViewController*)parent {
//    [super didMoveToParentViewController:parent];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.allowRotation = NO;
//    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
//    WKUserContentController *controller = self.webView.configuration.userContentController;
//    [controller removeAllUserScripts];
//}

//进度条、标题
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqual:@"estimatedProgress"] && [object isEqual:self.webView]) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        self.progress = self.webView.estimatedProgress;
        if (self.webView.estimatedProgress  >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^ {
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:YES];
            }];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        //        if (self.model) {
        //            self.title = self.model.pubnickname;
        //            self.webTitle = self.model.pubnickname;
        //        } else {
        //            if ([self.url rangeOfString:@"mp.weixin.qq.com"].location != NSNotFound) {
        //                return;
        //            }
        //            if ([self.url rangeOfString:@"m.toutiaocdn.com"].location != NSNotFound) {
        //                return;
        //            }
        //            if (object == self.webView) {
        //                self.title = LLSTR(@"101011");
        //                self.webTitle = self.webView.title;
        //            }
        //            else {
        //                [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        //            }
        //        }
        //        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        if (self.webTitle.length == 0) {
            self.webTitle = self.webView.title;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)loadURL:(NSString *)url {
    
//    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
//    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
//        [cookieDic setObject:cookie.value forKey:cookie.name];
//    }
//    // cookie重复，先放到字典进行去重，再进行拼接
//    for (NSString *key in cookieDic) {
//        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
//        [cookieValue appendString:appendString];
//    }
//    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//    [request addValue:cookieValue forHTTPHeaderField:@"Cookie"];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.url = url;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


#pragma mark - webviewDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
    [self.view showLoading];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *string = navigationAction.request.URL.absoluteString;
//    decisionHandler(WKNavigationActionPolicyAllow);
//    return;
//    NSArray *backArray = webView.backForwardList.backList;
//    for (WKBackForwardListItem *item in backArray) {
//
//    }
    NSString *auth = [[BiChatGlobal sharedManager].urlList objectForKey:@"webAuth"];
    if ([string judgeWithRegex:auth]) {
        NSDictionary *paramDic = [string getUrlParams];
        decisionHandler(WKNavigationActionPolicyCancel);
        //请求后台验证，是否需要弹窗
        [[WPBaseManager baseManager] postInterface:@"/Chat/Api/authorize.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"url":string,@"confirm":@"0"} success:^(id responseObject) {
            //10048需要弹窗
            if ([[responseObject objectForKey:@"code"] integerValue] == 100048) {
                WEAKSELF;
                WPWebVerificationViewController *verificationVC = [[WPWebVerificationViewController alloc]init];
                
                if (self.naVC) {
                    [self.naVC pushViewController:verificationVC animated:YES];
                } else
                {
                    [self.navigationController pushViewController:verificationVC animated:YES];
                }
                verificationVC.contentDic = responseObject;
                verificationVC.ConfirmBlock = ^{
                    [[WPBaseManager baseManager] postInterface:@"/Chat/Api/authorize.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"url":string,@"confirm":@"1"} success:^(id response) {
                        if ([[response objectForKey:@"errorCode"] integerValue] == 0) {
                            if ([response objectForKey:@"redirect_uri"]) {
                                [self loadURL:[response objectForKey:@"redirect_uri"]];
                            }
                            NSArray *array = [[responseObject objectForKey:@"scope"] componentsSeparatedByString:@","];
                            if (self.naVC) {
                                [self.naVC popViewControllerAnimated:NO];
                            }else {
                                [self.navigationController popViewControllerAnimated:NO];
                            }
                            
                            for (NSString *auth in array) {
                                if ([auth isEqualToString:@"snsapi_group"] && [paramDic objectForKey:@"group_id"]) {
                                    ChatViewController *chatVC = [[ChatViewController alloc]init];
                                    chatVC.isGroup = YES;
                                    chatVC.peerUid = [paramDic objectForKey:@"group_id"];
                                    if (weakSelf.naVC) {
                                        [weakSelf.naVC pushViewController:chatVC animated:YES];
                                    } else {
                                        [weakSelf.navigationController pushViewController:chatVC animated:YES];
                                    }
                                }
                            }
                            
                        } else {
                            if ([response objectForKey:@"redirect_uri"]) {
                                [self loadURL:[response objectForKey:@"redirect_uri"]];
                            } else {
                                if (self.naVC) {
                                    [self.naVC popViewControllerAnimated:YES];
                                }else {
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                            }
                            [BiChatGlobal showFailWithString:[LLSTR(@"301512") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[response objectForKey:@"errorCode"]]]]];
                        }
                    } failure:^(NSError *error) {
                        [BiChatGlobal showFailWithString:LLSTR(@"301001")];
                        if (self.naVC) {
                            [self.naVC popViewControllerAnimated:YES];
                        }else {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                };
                verificationVC.CancelBlock = ^{
                    if (self.isHomePage) {
                        if (self.IdentifyCancelBlock) {
                            self.IdentifyCancelBlock();
                            self.url = nil;
                        }
                        return ;
                    }
                    if (self.naVC) {
                        [self.naVC popViewControllerAnimated:YES];
                    }else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    if (self.IdentifyCancelBlock) {
                        self.IdentifyCancelBlock();
                    }
                };
            } else if ([[responseObject objectForKey:@"code"] integerValue] == 0) {
                [self loadURL:[responseObject objectForKey:@"redirect_uri"]];
            } else {
                [BiChatGlobal showFailWithString:LLSTR(@"301003")];
                [[BiChatGlobal sharedManager]imChatLog:@"----network error - 40", nil];
                [self loadURL:[responseObject objectForKey:@"redirect_uri"]];
            }
        } failure:^(NSError *error) {
            [BiChatGlobal showFailWithString:LLSTR(@"301001")];
        }];
        return;
    }
    NSArray *array1 = [[BiChatGlobal sharedManager].urlList objectForKey:@"external"];
    for (NSString *str in array1) {
        if ([string judgeWithRegex:str]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url] options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES} completionHandler:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
            [self doPop];
            return;
        }
    }
    NSArray *array4 = [[BiChatGlobal sharedManager].urlList objectForKey:@"internal"];
    for (NSString *str in array4) {
        if ([string judgeWithRegex:str]) {
            UIAlertController *alertCtrler = [UIAlertController alertControllerWithTitle:LLSTR(@"105101") message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self doPop];
            }];
            [alertCtrler addAction:action1];
            UIAlertAction *action = [UIAlertAction actionWithTitle:LLSTR(@"201336") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://%@",[string stringByReplacingOccurrencesOfString:@"https://" withString:@""]]] options:@{} completionHandler:nil];
                [self doPop];
            }];
            [alertCtrler addAction:action];
            [self presentViewController:alertCtrler animated:YES completion:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    NSArray *array2 = [[BiChatGlobal sharedManager].urlList objectForKey:@"whiteList"];
    for (NSString *str in array2) {
        if ([string judgeWithRegex:str]) {
            self.url = [NSString stringWithFormat:@"%@",navigationAction.request.URL.absoluteString];
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
    }
    NSArray *array3 = [[BiChatGlobal sharedManager].urlList objectForKey:@"blackList"];
    for (NSString *str in array3) {
        if ([string judgeWithRegex:str]) {
            decisionHandler(WKNavigationActionPolicyCancel);
            UIAlertController *alertCtrler = [UIAlertController alertControllerWithTitle:LLSTR(@"105102") message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"101023") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self doPop];
            }];
            [alertCtrler addAction:action1];
            [self presentViewController:alertCtrler animated:YES completion:nil];
            
            return;
        }
    }
    self.url = [NSString stringWithFormat:@"%@",navigationAction.request.URL.absoluteString];
    decisionHandler(WKNavigationActionPolicyAllow);
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.saveURL) {
        [[BiChatGlobal sharedManager] saveWeb:@{self.saveURL : self}];
    }
    
    [self.view hideLoading];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"webSliderValue"]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webSliderValue"] integerValue] == 0) {
            [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '80%'" completionHandler:nil];
        } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webSliderValue"] integerValue] == 1) {
            [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'" completionHandler:nil];
        } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webSliderValue"] integerValue] == 2) {
            [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '120%'" completionHandler:nil];
        } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webSliderValue"] integerValue] == 3) {
            [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '140%'" completionHandler:nil];
        } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webSliderValue"] integerValue] == 4) {
            [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '160%'" completionHandler:nil];
        }
    }
    
    [self.webView evaluateJavaScript:@"window.inImchatEnvironment = true" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    if (self.model) {
        return;
    }
    if ([self.url rangeOfString:@"mp.weixin.qq.com"].location != NSNotFound) {
        [self.webView evaluateJavaScript:@"document.getElementsByClassName(\"rich_media_title\")[0].innerText" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *resultString = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];;
            if (resultString.length > 0) {
                self.webTitle = resultString;
            }
        }];
    } else if ([self.url rangeOfString:@"m.toutiaocdn.com"].location != NSNotFound) {
        [self.webView evaluateJavaScript:@"document.getElementsByClassName(\"article__title\")[0].innerText" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *resultString = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if (resultString.length > 0) {
                self.webTitle = resultString;
            }
        }];
    } else if ([self.url rangeOfString:@"y.qq.com"].location != NSNotFound) {
        [self.webView evaluateJavaScript:@"document.getElementsByClassName(\"song_name\")[0].innerText" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *resultString = result;
            if (resultString.length > 0) {
                self.webTitle = resultString;
            }
        }];
    } else if ([self.url rangeOfString:@"m.kuwo.cn"].location != NSNotFound) {
        [self.webView evaluateJavaScript:@"document.getElementsByClassName(\"song_name\")[0].innerText" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *resultString = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];;
            if (resultString.length > 0) {
                self.webTitle = resultString;
            }
        }];
    }
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [self.view hideLoading];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
