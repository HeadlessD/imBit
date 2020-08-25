//
//  CustomShareViewControllerVC.m
//  ShareExtensionDemo
//
//  Created by vimfung on 16/6/28.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "CustomShareViewControllerVC.h"

@interface CustomShareViewControllerVC ()<UIWebViewDelegate>

@property (nonatomic,copy) NSString * typeStr;
@property (nonatomic,copy) NSString * urlTitleStr;

@property (nonatomic,strong) UIButton *postBtn;

@property (nonatomic,strong) UIView *container;

@property (nonatomic,strong) NSMutableArray * imagesArr;

@end

@implementation CustomShareViewControllerVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imagesArr = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
    
    //定义一个容器视图来存放分享内容和两个操作按钮
    _container = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300) / 2, (self.view.frame.size.height - 175) / 2, 300, 175)];
    _container.layer.cornerRadius = 7;
    _container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _container.layer.borderWidth = 1;
    _container.layer.masksToBounds = YES;
    _container.backgroundColor = [UIColor whiteColor];
    _container.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    //定义Post和Cancel按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(0, _container.frame.size.height - 45, _container.frame.size.width/2, 45);
    [cancelBtn addTarget:self action:@selector(cancelBtnClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    cancelBtn.layer.borderWidth = 0.5f;
    cancelBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;

//    [cancelBtn setBackgroundColor:[UIColor blueColor]];
    [_container addSubview:cancelBtn];
    
    _postBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_postBtn setTitle:@"确定" forState:UIControlStateNormal];
    _postBtn.frame = CGRectMake(_container.frame.size.width/2, _container.frame.size.height - 45, _container.frame.size.width/2, 45);
    [_postBtn addTarget:self action:@selector(postBtnClickHandler:) forControlEvents:UIControlEventTouchUpInside];
   
    _postBtn.layer.borderWidth = 0.5f;
    _postBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
//    [_postBtn setBackgroundColor:[UIColor greenColor]];
    [_container addSubview:_postBtn];
    
    //定义一个分享链接标签
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, _container.frame.size.width - 16,
                                                               _container.frame.size.height - 8 - 50)];
//    label.backgroundColor = [UIColor orangeColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"是否用imChat打开此链接？";
    [_container addSubview:label];
    
    //获取分享链接
    __block BOOL hasGetUrl = NO;
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSItemProvider *itemProvider in obj.attachments) {
            //        [obj.attachments enumerateObjectsUsingBlock:^(NSItemProvider *  _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"])
            {
                _typeStr = @"shareUrl";
                
                [itemProvider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    
                    if ([(NSObject *)item isKindOfClass:[NSURL class]])
                    {
                        NSLog(@"分享的URL = %@", item);
                        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.imchathk.imchatlive"];
                        [userDefaults setValue:((NSURL *)item).absoluteString forKey:@"share-url"];
                        
                        //用于标记是新的分享
                        [userDefaults setBool:YES forKey:@"has-new-share"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
//                            label.text = ((NSURL *)item).absoluteString;
                            [self createUI];
                        });
                    }
                }];
                hasGetUrl = YES;
                *stop = YES;
            }else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.image"]){
                _typeStr = @"shareImg";
                
                [itemProvider loadItemForTypeIdentifier:@"public.image" options:nil completionHandler:^(UIImage *image, NSError *error) {
                    
                    [self.imagesArr addObject:image];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.imagesArr.count == obj.attachments.count) {
                            
                            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.imchathk.imchatlive"];
                            //                        [userDefaults setValue:urlImage forKey:@"share-urlImage"];
                            
                            ////imageKeyArr 存储图片data的key数组
                            NSMutableArray *imageKeyArr = [NSMutableArray array];
                            for (UIImage *image in self.imagesArr) {
                                //UIImage转换为NSData
                                NSData *imageData = UIImagePNGRepresentation(image);
                                char data[32];
                                for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
                                
                                NSString *key = [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
                                
                                [userDefaults setObject:imageData forKey:key];
                                [imageKeyArr addObject:key];
                            }
                            NSString * arrStr = [imageKeyArr componentsJoinedByString:@","];
                            [userDefaults setObject:arrStr forKey:@"share-urlImage"];
                            
                            
                            //用于标记是新的分享
                            [userDefaults setBool:YES forKey:@"has-new-share"];
                            
                            //执行分享内容处理  拉起寄主App(customURL是怎么来的？调研openUrl)
                            NSString *customURL = [NSString stringWithFormat:@"openimchatVC://%@",_typeStr] ;
                            UIResponder* responder = self;
                            while ((responder = [responder nextResponder]) != nil){
                                if([responder respondsToSelector:@selector(openURL:)] == YES){
                                    [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:customURL]];
                                    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                                }
                            }
                            //执行分享内容处理
                            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                        }
                    });
                }];
                hasGetUrl = YES;
                *stop = YES;
            }
            
            if (hasGetUrl)
            {
                *stop = YES;
            }
        }
    }];
}

-(void)createUI{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"用 imChat 打开此网页" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSLog(@"_urlTitleStr%@",_urlTitleStr);
        //执行分享内容处理  拉起寄主App(customURL是怎么来的？调研openUrl)
        NSString *customURL = [NSString stringWithFormat:@"openimchatVC://%@",_typeStr] ;
        UIResponder* responder = self;
        while ((responder = [responder nextResponder]) != nil){
            if([responder respondsToSelector:@selector(openURL:)] == YES){
                [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:customURL]];
                [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
            }
        }
        
        //执行分享内容处理
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
    }];
    
    [alertC addAction:action1];
    [alertC addAction:action2];
    [self presentViewController:alertC animated:YES completion:nil];

//    [self.view addSubview:_container];
}

- (void)cancelBtnClickHandler:(id)sender
{
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
}

- (void)postBtnClickHandler:(id)sender
{
//    NSLog(@"_urlTitleStr%@",_urlTitleStr);
//    //执行分享内容处理  拉起寄主App(customURL是怎么来的？调研openUrl)
//    NSString *customURL = [NSString stringWithFormat:@"openimchatVC://%@",_typeStr] ;
//    UIResponder* responder = self;
//    while ((responder = [responder nextResponder]) != nil){
//        if([responder respondsToSelector:@selector(openURL:)] == YES){
//            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:customURL]];
//            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
//        }
//    }
    //执行分享内容处理
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

@end




//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    UIWebView *web = webView;
//    //获取所有的html
//    NSString *allHtml = @"document.documentElement.innerHTML";
//    //获取网页title
//    NSString *htmlTitle = @"document.title";
//    //获取网页的一个值
//    NSString *htmlNum = @"document.getElementById('title').innerText";
//    //获取到得网页内容
//    NSString *allHtmlInfo = [web stringByEvaluatingJavaScriptFromString:allHtml];
//    NSLog(@"allHtmlInfo_%@",allHtmlInfo);
//    NSString *titleHtmlInfo = [web stringByEvaluatingJavaScriptFromString:htmlTitle];
//    NSLog(@"titleHtmlInfo_%@",titleHtmlInfo);
//    _urlTitleStr = titleHtmlInfo;
//    NSString *numHtmlInfo = [web stringByEvaluatingJavaScriptFromString:htmlNum];
//    NSLog(@"numHtmlInfo_%@",numHtmlInfo);
//
//    NSLog(@"numHtmlUrl%@",web.request.URL.absoluteString);
//
//    //这里是js，主要目的实现对url的获取
//    static  NSString * const jsGetImages =
//    @"function getImages(){\
//    var objs = document.getElementsByTagName(\"img\");\
//    var imgScr = '';\
//    for(var i=0;i<objs.length;i++){\
//    imgScr = imgScr + objs[i].src + '+';\
//    \
//    objs[i].onclick=function(){\
//    document.location=\"myweb:imageClick:\"+this.src;\
//    };\
//    };\
//    return imgScr;\
//    };";//这里获取网页中img标签对象
//
//    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
//    NSString *urlResurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
//    NSMutableArray * mUrlArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
//
//    NSString * urlImage = @"";
//    if (mUrlArray.count) {
//        urlImage = mUrlArray[0];
//    }
//
//    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.imchathk.imchatlive"];
//    [userDefaults setValue:web.request.URL.absoluteString forKey:@"share-url"];
//    [userDefaults setValue:titleHtmlInfo forKey:@"share-urlTitle"];
//    [userDefaults setValue:urlImage forKey:@"share-urlImage"];
//    //用于标记是新的分享
//    [userDefaults setBool:YES forKey:@"has-new-share"];
//
//
//    _postBtn.userInteractionEnabled = YES;
////    [_postBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//
//    NSLog(@"_urlTitleStr%@",_urlTitleStr);
//    //执行分享内容处理  拉起寄主App(customURL是怎么来的？调研openUrl)
//    NSString *customURL = [NSString stringWithFormat:@"openimchatVC://%@",_typeStr] ;
//    UIResponder* responder = self;
//    while ((responder = [responder nextResponder]) != nil){
//        if([responder respondsToSelector:@selector(openURL:)] == YES){
//            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:customURL]];
//            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
//        }
//    }
//
//    //执行分享内容处理
//    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
//}
