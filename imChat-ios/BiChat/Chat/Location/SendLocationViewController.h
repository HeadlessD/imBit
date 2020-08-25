//
//  SendLocationViewController.h
//  WeChatLocationDemo
//
//  Created by Lucas.Xu on 2017/12/8.
//  Copyright © 2017年 Lucas. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SendLocationViewControllerDelegate <NSObject>
@optional;
-(void)getLocationWithAMapPOI:(AMapPOI *)loca locaImgStr:(NSString *)locaImgStr;

@end

@interface SendLocationViewController : UIViewController

@property (nonatomic,weak) id<SendLocationViewControllerDelegate> delegage;

@end


