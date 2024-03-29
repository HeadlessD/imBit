//
//  ShareViewController.m
//  ShareExtenstionLive
//
//  Created by chat on 2018/12/4.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareActViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost{
    //加载动画初始化
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.frame = CGRectMake((self.view.frame.size.width - activityIndicatorView.frame.size.width) / 2,
                                             (self.view.frame.size.height - activityIndicatorView.frame.size.height) / 2,
                                             activityIndicatorView.frame.size.width,
                                             activityIndicatorView.frame.size.height);
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:activityIndicatorView];
    
    //激活加载动画
    [activityIndicatorView startAnimating];
    
    __weak ShareViewController *theController = self;
    __block BOOL hasExistsUrl = NO;
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {

            [itemProvider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                
//                if ([(NSObject *)item isKindOfClass:[NSURL class]])
//                {
                
                    if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"])
                    {
                        NSLog(@"分享的url");
                    }
                    else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.image"])
                    {
                        NSLog(@"分享的image");
                    }
                    else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.text"])
                    {
                        NSLog(@"分享的text");
                    }
                    
                    NSLog(@"分享的URL = %@", item);
                    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.imchathk.imchatlive"];
                    [userDefaults setValue:((NSURL *)item).absoluteString forKey:@"share-url"];
                    //用于标记是新的分享
                    [userDefaults setBool:YES forKey:@"has-new-share"];
                    
                    [activityIndicatorView stopAnimating];
                    
                    //执行分享内容处理  拉起寄主App(customURL是怎么来的？调研openUrl)
//                    NSString *customURL = @"openimchat://";
//                    UIResponder* responder = self;
//                    while ((responder = [responder nextResponder]) != nil){
//                        if([responder respondsToSelector:@selector(openURL:)] == YES){
//                            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:customURL]];
//                            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
//                        }
//                    }
                    
                    //直接退出
                    [theController.extensionContext completeRequestReturningItems:@[extItem] completionHandler:nil];
                    
//                }
                
            }];
            hasExistsUrl = YES;
            *stop = YES;
        }];
        
        if (hasExistsUrl)
        {
            *stop = YES;
        }
        
    }];
    
    if (!hasExistsUrl)
    {
        //直接退出
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    
    //定义两个配置项，分别记录用户选择是否公开以及公开的权限，然后根据配置的值
    static BOOL isPublic = NO;
    static NSInteger act = 0;
    
    NSMutableArray *items = [NSMutableArray array];
    
    //创建是否公开配置项
    SLComposeSheetConfigurationItem *item = [[SLComposeSheetConfigurationItem alloc] init];
    item.title = @"是否公开";
    item.value = isPublic ? @"是" : @"否";
    
    __weak ShareViewController *theController = self;
    __weak SLComposeSheetConfigurationItem *theItem = item;
    item.tapHandler = ^{
        
        isPublic = !isPublic;
        theItem.value = isPublic ? @"是" : @"否";
        
        
        [theController reloadConfigurationItems];
    };
    
    [items addObject:item];
    
    if (isPublic)
    {
        //如果公开标识为YES，则创建公开权限配置项
        SLComposeSheetConfigurationItem *actItem = [[SLComposeSheetConfigurationItem alloc] init];
        
        actItem.title = @"公开权限";
        
        switch (act)
        {
            case 0:
                actItem.value = @"所有人";
                break;
            case 1:
                actItem.value = @"好友";
                break;
            default:
                break;
        }
        
        actItem.tapHandler = ^{
            
            //设置分享权限时弹出选择界面
            ShareActViewController *actVC = [[ShareActViewController alloc] init];
            [theController pushConfigurationViewController:actVC];
            
            [actVC onSelected:^(NSIndexPath *indexPath) {
                
                //当选择完成时退出选择界面并刷新配置项。
                act = indexPath.row;
                [theController popConfigurationViewController];
                [theController reloadConfigurationItems];
                
            }];
            
        };
        
        [items addObject:actItem];
    }
    
    return items;
}

@end
