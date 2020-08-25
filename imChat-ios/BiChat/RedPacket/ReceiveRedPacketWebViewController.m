//
//  ReceiveRedPacketWebViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "ReceiveRedPacketWebViewController.h"
#import "WXApi.h"
#import "PaymentPasswordSetupStep1ViewController.h"
#import "UIImageView+WebCache.h"

@interface ReceiveRedPacketWebViewController ()

@end

@implementation ReceiveRedPacketWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"抢红包";
    
    //只有群红包才可以共享
    if (self.isGroup)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonShare:)];
    
    webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    [WebViewJavascriptBridge enableLogging];
    bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    [bridge setWebViewDelegate:self];
    
    [bridge registerHandler:@"receiveRewardInfo" handler:^(id data, WVJBResponseCallback responseCallback) {

        //我抢到了一个红包, 通知出去
        if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketReceived:)])
            [self.delegate redPacketReceived:[data objectForKey:@"rewardid"]];
    
    }];
    [bridge registerHandler:@"forgetPassword" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        PaymentPasswordSetupStep1ViewController *wnd = [PaymentPasswordSetupStep1ViewController new];
        wnd.resetPassword = YES;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];

    }];
    [bridge registerHandler:@"rewardExpired" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[BiChatGlobal sharedManager]setRedPacketFinished:[data objectForKey:@"rewardid"] status:3];
    }];
    [bridge registerHandler:@"rewardEnd" handler:^(id data, WVJBResponseCallback responseCallback) {
         [[BiChatGlobal sharedManager]setRedPacketFinished:[data objectForKey:@"rewardid"] status:2];
    }];
    [bridge registerHandler:@"receiveLastInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        //我抢到了一个红包, 通知出去
        if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketReceived:)])
            [self.delegate redPacketReceived:[data objectForKey:@"rewardid"]];
        
        //本次红包已经被抢光
        if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketExhaust:)])
            [self.delegate redPacketExhaust:[data objectForKey:@"rewardid"]];

    }];

#ifdef ENV_DEV
    // Do any additional setup after loading the view.
    [webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://d.iweipeng.com/Chat/Api/openReward.do?tokenid=%@&rewardid=%@", [BiChatGlobal sharedManager].token, self.redPacketId]]]];
#else
    // Do any additional setup after loading the view.
    [webView loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://imchat.iweipeng.com/Chat/Api/openReward.do?tokenid=%@&rewardid=%@", [BiChatGlobal sharedManager].token, self.redPacketId]]]];
#endif
    
    //创建一个image用来获取分享的图标
    UIImageView *image4GetShareIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    [image4GetShareIcon sd_setImageWithURL:[NSURL URLWithString:self.shareIcon] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        //获取到了没有
        if (image)
            self->image4Share = image;
    }];
    
    [self.view addSubview:image4GetShareIcon];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
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

#pragma mark - 私有函数

- (void)onButtonShare:(id)sender
{
    //先判断是否拿到了分享图片
    if (image4Share == nil)
    {
        [BiChatGlobal showInfo:@"正在准备中，请稍后再试" withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi])
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = [NSString stringWithFormat:@"快来抢%@红包喽～", self.coinSymbol];
        message.description = @"我在imChat, 海量红包等你来抢";
        
        UIImage *newImage = image4Share;
        [message setThumbImage:newImage];
        WXImageObject *ext = [WXImageObject object];
        /////////////////////////////////shareURL  分享的链接
        ext.imageData = [NSMutableData dataWithData:UIImagePNGRepresentation(newImage)];
        
        WXWebpageObject *ext2 = [WXWebpageObject object];
        ext2.webpageUrl = self.shareLink;
        message.mediaObject = ext2;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.scene = WXSceneSession;
        req.message = message;
        [WXApi sendReq:req];
    }
    else
    {
        [BiChatGlobal showInfo:@"请安装微信以后再分享" withIcon:nil];
    }
}

- (void)onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
