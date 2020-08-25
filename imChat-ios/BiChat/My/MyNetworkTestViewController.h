//
//  MyNetworkTestViewController.h
//  BiChat
//
//  Created by imac2 on 2018/12/11.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyNetworkTestViewController : UIViewController
{
    UITextView *text4NetworkTestResult;
    NetworkModule *network;
}

@end

NS_ASSUME_NONNULL_END
