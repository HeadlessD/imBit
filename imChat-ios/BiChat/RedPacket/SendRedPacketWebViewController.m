//
//  SendRedPacketWebViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "SendRedPacketWebViewController.h"
#import "PaymentPasswordSetupStep1ViewController.h"

@interface SendRedPacketWebViewController ()

@end

@implementation SendRedPacketWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发红包";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancel:)];
    
    webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
//    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    [WebViewJavascriptBridge enableLogging];
    bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
//    [bridge setWebViewDelegate:self];
    
    [bridge registerHandler:@"redPacketInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        //红包创建成功
        if ([[data objectForKey:@"code"]integerValue] == 1)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                                
                //通知
//                if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketCreated:redPacketId:coinImageUrl:shareCoinImageUrl:coinSymbol:greeting:groupId:groupName:)])
//                    [self.delegate redPacketCreated:[data objectForKey:@"url"]
//                                        redPacketId:[data objectForKey:@"rewardid"]
//                                       coinImageUrl:[data objectForKey:@"coinImgUrl"]
//                                  shareCoinImageUrl:[data objectForKey:@"wechatShareCoinImg"]
//                                         coinSymbol:[data objectForKey:@"coinType"]
//                                           greeting:[data objectForKey:@"greetings"]
//                                            groupId:[data objectForKey:@"groupid"]
//                                          groupName:[data objectForKey:@"groupname"]];
            }];
        }
        else
        {
            [BiChatGlobal showInfo:@"无法创建红包" withIcon:[UIImage imageNamed:@"icon_alert"]];
        }
        
    }];
    [bridge registerHandler:@"forgetPassword" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
        wnd.resetPassword = YES;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];

    }];
    
#ifdef ENV_DEV
    // Do any additional setup after loading the view.
    if (self.isGroup)
    {
        [webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://d.iweipeng.com/Chat/Api/redPackets.do?tokenid=%@&groupid=%@", [BiChatGlobal sharedManager].token, self.peerId]]]];
    }
    else if (self.peerId.length > 0)
    {
        [webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://d.iweipeng.com/Chat/Api/redPackets.do?tokenid=%@&rewardType=3", [BiChatGlobal sharedManager].token]]]];
    }
    else
    {
        [webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://d.iweipeng.com/Chat/Api/redPackets.do?tokenid=%@", [BiChatGlobal sharedManager].token]]]];
    }
#else
    // Do any additional setup after loading the view.
    if (self.isGroup)
    {
        [webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://imchat.iweipeng.com/Chat/Api/redPackets.do?tokenid=%@&groupid=%@", [BiChatGlobal sharedManager].token, self.peerId]]]];
    }
    else if (self.peerId.length > 0)
    {
        [webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://imchat.iweipeng.com/Chat/Api/redPackets.do?tokenid=%@&rewardType=3", [BiChatGlobal sharedManager].token]]]];
    }
    else
    {
        [webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://imchat.iweipeng.com/Chat/Api/redPackets.do?tokenid=%@", [BiChatGlobal sharedManager].token]]]];
    }
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 私有函数

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
