//
//  WPGroupAddMiddleViewController.h
//  BiChat
//
//  Created by iMac on 2018/7/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"

@interface WPGroupAddMiddleViewController : WPBaseViewController
{
    NSDictionary *groupProperty;
}

@property (nonatomic,strong)NSString *groupId;
@property (nonatomic,strong)NSString *source;
@property (nonatomic,assign)NSInteger defaultTabIndex;
@property (nonatomic,strong)NSString *defaultSelectedGroupHomeId;

@property (nonatomic,assign)BOOL discoverType;
@property (nonatomic,assign)BOOL groupHomeType;
@property (nonatomic,strong)NSString *refCode;

@end
