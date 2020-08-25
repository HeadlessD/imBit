//
//  WPComplaintViewController.h
//  BiChat
//
//  Created by iMac on 2018/7/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"

typedef enum {
    ComplainTypeNews = 0,
    ComplainTypeRedPakcet
}ComplainType;

@interface WPComplaintViewController : WPBaseViewController

@property (nonatomic,assign) ComplainType complainType;

@property (nonatomic,strong)NSString *contentId;
@property (nonatomic,strong)NSString *complainTitle;
@property (nonatomic,strong)id disVC;

@end
