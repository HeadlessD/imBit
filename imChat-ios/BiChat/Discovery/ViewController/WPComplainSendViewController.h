//
//  WPComplainSendViewController.h
//  BiChat
//
//  Created by iMac on 2018/7/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"

@interface WPComplainSendViewController : WPBaseViewController

@property (nonatomic,strong)NSString *contentType;
@property (nonatomic,strong)NSString *contentId;
@property (nonatomic,strong)NSString *reason;
@property (nonatomic,strong)NSString *complainTitle;

@property (nonatomic,strong)id disVC;
@end
