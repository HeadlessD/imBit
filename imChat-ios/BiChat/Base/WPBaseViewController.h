//
//  WPBaseViewController.h
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPDiscoverModel.h"

@interface WPBaseViewController : UIViewController

//打开新闻详情
- (void)openNewsDetailWithModel:(WPDiscoverModel *)model;

@end
